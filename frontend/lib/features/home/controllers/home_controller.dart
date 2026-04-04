import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/app_enums.dart';

/// Home Controller - Manages home screen data
class HomeController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  late List<Chat> _recentChats;
  late List<User> _availableUsers;
  int _onlineUserCount = 0;
  int _totalChats = 0;
  String? _error;
  bool _isLoadingUsers = false;

  HomeController() {
    _recentChats = [];
    _availableUsers = [];
    refreshData();
  }

  // Getters
  List<Chat> get recentChats => _recentChats;
  List<User> get availableUsers => _availableUsers;
  int get onlineUserCount => _onlineUserCount;
  int get totalChats => _totalChats;
  List<Chat> get topRecentChats => _recentChats.take(3).toList();
  String? get error => _error;
  bool get isLoadingUsers => _isLoadingUsers;

  // Methods
  Future<void> refreshData() async {
    try {
      final response = await _apiService.getChats();
      final data = response['data'] as Map<String, dynamic>?;
      final chatsData = data?['chats'] as List<dynamic>? ?? <dynamic>[];

      _recentChats = chatsData
          .whereType<Map<String, dynamic>>()
          .map(
            (chatJson) {
              final rawTime = chatJson['last_message_time'];
              final lastMessageTime = rawTime is String
                  ? DateTime.tryParse(rawTime) ?? DateTime.now()
                  : DateTime.now();

              return Chat(
                id: (chatJson['id'] ?? '').toString(),
                participantId: (chatJson['id'] ?? '').toString(),
                participantName: (chatJson['name'] ?? 'Unknown').toString(),
                lastMessage: (chatJson['last_message'] ?? 'No messages').toString(),
                lastMessageTime: lastMessageTime,
                unreadCount: 0,
              );
            },
          )
          .toList();

      _totalChats = _recentChats.length;
      _onlineUserCount = _recentChats.where((chat) {
        return DateTime.now().difference(chat.lastMessageTime).inHours < 24;
      }).length;
      _error = null;
    } catch (e) {
      _recentChats = [];
      _totalChats = 0;
      _onlineUserCount = 0;
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    // Also load available users
    await _loadAvailableUsers();
    notifyListeners();
  }

  Future<void> _loadAvailableUsers() async {
    try {
      _isLoadingUsers = true;
      notifyListeners();
      
      final response = await _apiService.getAllUsers();
      final data = response['users'] as List<dynamic>? ?? <dynamic>[];
      
      _availableUsers = data
          .whereType<Map<String, dynamic>>()
          .map((userJson) => User.fromJson(userJson))
          .where((user) => user.isApproved && user.role == UserRole.personnel)
          .toList();
      
      _isLoadingUsers = false;
    } catch (e) {
      _availableUsers = [];
      _isLoadingUsers = false;
    }
    notifyListeners();
  }

  Future<String?> createChatWithUser(String userId) async {
    try {
      final response = await _apiService.createChat(userId);
      return response['id']?.toString();
    } catch (e) {
      _error = 'Failed to create chat: $e';
      notifyListeners();
      return null;
    }
  }

  void updateOnlineUsers(int count) {
    _onlineUserCount = count;
    notifyListeners();
  }

  void updateTotalChats(int count) {
    _totalChats = count;
    notifyListeners();
  }
}
