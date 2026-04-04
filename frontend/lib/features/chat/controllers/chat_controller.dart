import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../../models/message_model.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/socket_service.dart';

/// Chat Controller - Manages chat data and messaging
class ChatController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final SocketService _socketService = SocketService();
  late List<Chat> _chats;
  late List<User> _availableUsers;
  late Map<String, List<Message>> _messagesPerChat;
  String? _currentChatId;
  bool _isLoading = false;
  bool _isCreatingChat = false;
  String? _error;
  bool _socketListening = false;
  bool _socketInitializing = false;

  ChatController() {
    _chats = [];
    _availableUsers = [];
    _messagesPerChat = {};
    loadChats();
  }

  // Getters
  List<Chat> get chats => _chats;
  List<User> get availableUsers => _availableUsers;
  String? get currentChatId => _currentChatId;
  Chat? get currentChat {
    if (_currentChatId == null || _chats.isEmpty) {
      return null;
    }
    final index = _chats.indexWhere((c) => c.id == _currentChatId);
    return index >= 0 ? _chats[index] : null;
  }
  bool get isLoading => _isLoading;
  bool get isCreatingChat => _isCreatingChat;
  String? get error => _error;

  List<Message> getMessages(String chatId) {
    return _messagesPerChat[chatId] ?? [];
  }

  Future<void> _ensureRealtimeConnection() async {
    if (_socketInitializing || _socketService.isConnected) {
      return;
    }

    final token = _authService.token;
    final userId = _authService.userId;
    if (token == null || userId == null) {
      return;
    }

    _socketInitializing = true;

    try {
      if (!_socketListening) {
        _socketService.onMessage(_handleSocketMessage);
        _socketListening = true;
      }

      await _socketService.connect(userId, token);
    } finally {
      _socketInitializing = false;
    }
  }

  void _handleSocketMessage(Map<String, dynamic> payload) {
    if (payload['error'] != null || payload['blocked'] != null) {
      _error = (payload['error'] ?? payload['blocked']).toString();
      notifyListeners();
      return;
    }

    final messageText = (payload['message'] ?? '').toString();
    if (messageText.isEmpty) {
      return;
    }

    final senderId = (payload['sender_id'] ?? payload['senderId'] ?? '').toString();
    final receiverId = (payload['receiver_id'] ?? payload['receiverId'] ?? '').toString();
    final groupId = (payload['group_id'] ?? payload['groupId'] ?? '').toString();
    final chatId = groupId.isNotEmpty ? groupId : receiverId;
    if (chatId.isEmpty) {
      return;
    }

    final timestamp = DateTime.tryParse((payload['timestamp'] ?? '').toString()) ?? DateTime.now();
    final currentUserId = _authService.userId;
    final isSent = currentUserId != null && senderId == currentUserId;
    final message = Message(
      id: (payload['message_id'] ?? 'msg_${timestamp.millisecondsSinceEpoch}').toString(),
      senderId: senderId,
      senderName: isSent ? 'You' : (_chatNameFor(chatId) ?? 'User'),
      text: messageText,
      timestamp: timestamp,
      isRead: true,
      type: isSent ? MessageType.sent : MessageType.received,
    );

    _upsertMessage(chatId, message, replacePending: isSent);
    _updateChatPreview(chatId, messageText, timestamp);
    _error = null;
    notifyListeners();
  }

  String? _chatNameFor(String chatId) {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index == -1) {
      return null;
    }
    return _chats[index].participantName;
  }

  void _upsertMessage(String chatId, Message message, {bool replacePending = false}) {
    final messages = List<Message>.from(_messagesPerChat[chatId] ?? <Message>[]);

    if (replacePending) {
      final pendingIndex = messages.indexWhere((existing) =>
          existing.type == MessageType.sent &&
          existing.text == message.text &&
          existing.senderId == message.senderId &&
          message.timestamp.difference(existing.timestamp).abs() < const Duration(seconds: 10));
      if (pendingIndex != -1) {
        messages[pendingIndex] = message;
        _messagesPerChat[chatId] = messages;
        return;
      }
    }

    if (!messages.contains(message)) {
      messages.add(message);
    }
    _messagesPerChat[chatId] = messages;
  }

  void _updateChatPreview(String chatId, String messageText, DateTime timestamp) {
    final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) {
      return;
    }

    _chats[chatIndex] = _chats[chatIndex].copyWith(
      lastMessage: messageText,
      lastMessageTime: timestamp,
    );

    final chat = _chats.removeAt(chatIndex);
    _chats.insert(0, chat);
  }

  // Methods
  void selectChat(String chatId) {
    _currentChatId = chatId;
    // Mark as read
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = _chats[chatIndex].copyWith(unreadCount: 0);
    }
    notifyListeners();
  }

  Future<void> sendMessage(String chatId, String messageText) async {
    if (messageText.isEmpty) return;

    String? pendingMessageId;

    try {
      await _ensureRealtimeConnection();

      final sendChatIndex = _chats.indexWhere((c) => c.id == chatId);
      final receiverId = sendChatIndex != -1 ? _chats[sendChatIndex].participantId : null;
      final currentUserId = _authService.userId;
      final isGroupChat = receiverId == null || receiverId.isEmpty || receiverId == chatId;

      final optimisticMessage = Message(
        id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
        senderId: currentUserId ?? 'current_user',
        senderName: 'You',
        text: messageText,
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.sent,
      );
      pendingMessageId = optimisticMessage.id;

      _upsertMessage(chatId, optimisticMessage);
      _updateChatPreview(chatId, messageText, optimisticMessage.timestamp);
      notifyListeners();

      final socketSent = _socketService.isConnected
          ? await _socketService.sendMessage({
              'message': messageText,
              if (isGroupChat) 'group_id': chatId else 'receiver_id': receiverId,
            })
          : false;

      if (!socketSent) {
        await _apiService.sendMessage(
          chatId,
          messageText,
          receiverId: isGroupChat ? null : receiverId,
        );
      }

      _error = null;
    } catch (e) {
      if (pendingMessageId != null) {
        final messages = List<Message>.from(_messagesPerChat[chatId] ?? <Message>[]);
        messages.removeWhere((message) => message.id == pendingMessageId);
        _messagesPerChat[chatId] = messages;
      }
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> loadChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _ensureRealtimeConnection();

      final response = await _apiService.getChats();
      final data = response['data'] as Map<String, dynamic>?;
      final chatsData = (data?['chats'] as List<dynamic>? ?? <dynamic>[]);

      _chats = chatsData
          .whereType<Map<String, dynamic>>()
          .map((chatJson) {
            final rawTime = chatJson['last_message_time'];
            final lastMessageTime = rawTime is String && rawTime.isNotEmpty
                ? DateTime.tryParse(rawTime) ?? DateTime.now()
                : DateTime.now();

            return Chat(
              id: (chatJson['id'] ?? '').toString(),
              participantId: (chatJson['participant_id'] ?? chatJson['id'] ?? '').toString(),
              participantName: (chatJson['name'] ?? 'Unknown').toString(),
              lastMessage: (chatJson['last_message'] ?? 'No messages').toString(),
              lastMessageTime: lastMessageTime,
              unreadCount: 0,
            );
          })
          .toList();
      _error = null;
    } catch (e) {
      _chats = [];
      _messagesPerChat = {};
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
    }

    notifyListeners();
  }

  Future<void> loadAvailableUsers() async {
    try {
      final response = await _apiService.getAllUsers();
      final data = response['data'] as Map<String, dynamic>?;
      final usersData = (data?['users'] as List<dynamic>? ?? <dynamic>[]);

      _availableUsers = usersData
          .whereType<Map<String, dynamic>>()
          .map(User.fromJson)
          .where((user) => user.id.isNotEmpty)
          .toList();
      _error = null;
    } catch (e) {
      _availableUsers = [];
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  Future<String?> createChatWithUser(String userId) async {
    if (userId.isEmpty) return null;

    _isCreatingChat = true;
    notifyListeners();

    try {
      final response = await _apiService.createChat(userId);
      final data = response['data'] as Map<String, dynamic>?;
      final chatId = (data?['id'] ?? data?['chat_id'] ?? response['id'] ?? '').toString();

      if (chatId.isEmpty) {
        throw Exception('Chat creation failed');
      }

      await loadChats();
      return chatId;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    } finally {
      _isCreatingChat = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String chatId) async {
    try {
      await _ensureRealtimeConnection();

      final response = await _apiService.getMessages(chatId);
      final data = response['data'] as Map<String, dynamic>?;
      final messagesData = (data?['messages'] as List<dynamic>? ?? <dynamic>[]);

      final currentUserId = _authService.userId;
      _messagesPerChat[chatId] = messagesData
          .whereType<Map<String, dynamic>>()
          .map((msgJson) {
            final senderId = (msgJson['sender'] ?? '').toString();
            final isSent = currentUserId != null && senderId == currentUserId;
            final rawTimestamp = (msgJson['timestamp'] ?? '').toString();

            return Message(
              id: (msgJson['id'] ?? '').toString(),
              senderId: senderId,
              senderName: isSent ? 'You' : (_chatNameFor(chatId) ?? 'User'),
              text: (msgJson['message'] ?? '').toString(),
              timestamp: DateTime.tryParse(rawTimestamp) ?? DateTime.now(),
              isRead: true,
              type: isSent ? MessageType.sent : MessageType.received,
            );
          })
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _messagesPerChat[chatId] = [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_socketListening) {
      _socketService.removeListener(_handleSocketMessage);
      _socketListening = false;
    }
    _socketService.disconnect();
    super.dispose();
  }

  Future<void> deleteChat(String chatId) async {
    _chats.removeWhere((c) => c.id == chatId);
    _messagesPerChat.remove(chatId);
    notifyListeners();
  }

  void markChatAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  void muteChat(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(
        isMuted: true,
        status: ChatStatus.muted,
      );
      notifyListeners();
    }
  }

  void unmuteChat(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(
        isMuted: false,
        status: ChatStatus.active,
      );
      notifyListeners();
    }
  }
}
