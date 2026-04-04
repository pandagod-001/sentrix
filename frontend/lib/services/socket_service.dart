import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sentrix/core/config/app_config.dart';

/// Socket Service for SENTRIX
/// Handles real-time WebSocket connections for messaging and notifications
class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionId;
  final List<Map<String, dynamic>> _messageQueue = [];
  final List<Function(Map<String, dynamic>)> _listeners = [];
  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;

  /// Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionId => _connectionId;
  int get queueLength => _messageQueue.length;

  /// Initialize socket service
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Connect to WebSocket
  Future<bool> connect(String userId, String token) async {
    if (_isConnecting || _isConnected) return true;

    _isConnecting = true;

    try {
      final wsUrl = AppConfig.buildUrl('/chat/ws/$token')
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');

      _socket = await WebSocket.connect(wsUrl).timeout(
        const Duration(seconds: 10),
      );

      _connectionId = 'socket_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      _isConnected = true;
      _isConnecting = false;

      _socketSubscription = _socket!.listen(
        (event) {
          try {
            final decoded = jsonDecode(event.toString());
            if (decoded is Map<String, dynamic>) {
              _notifyListeners(decoded);
            }
          } catch (_) {}
        },
        onDone: () {
          _isConnected = false;
        },
        onError: (_) {
          _isConnected = false;
        },
        cancelOnError: false,
      );

      // Process queued messages
      _processMessageQueue();

      return true;
    } catch (e) {
      _isConnecting = false;
      return false;
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    await _socketSubscription?.cancel();
    await _socket?.close();
    _socketSubscription = null;
    _socket = null;
    _isConnected = false;
    _connectionId = null;
    _messageQueue.clear();
  }

  /// Send message through socket
  Future<bool> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected) {
      _messageQueue.add(message);
      return false;
    }

    try {
      _socket?.add(jsonEncode(message));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Send chat message
  Future<bool> sendChatMessage(
    String chatId,
    String content,
    String senderId,
  ) async {
    return sendMessage({
      'type': 'message',
      'chatId': chatId,
      'content': content,
      'senderId': senderId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send group chat message
  Future<bool> sendGroupMessage(
    String groupId,
    String content,
    String senderId,
  ) async {
    return sendMessage({
      'type': 'group_message',
      'groupId': groupId,
      'content': content,
      'senderId': senderId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send typing indicator
  Future<bool> sendTypingIndicator(String chatId, String userId) async {
    return sendMessage({
      'type': 'typing',
      'chatId': chatId,
      'userId': userId,
    });
  }

  /// Send read receipt
  Future<bool> sendReadReceipt(String messageId, String userId) async {
    return sendMessage({
      'type': 'read_receipt',
      'messageId': messageId,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Subscribe to messages
  void onMessage(Function(Map<String, dynamic>) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(Function(Map<String, dynamic>) listener) {
    _listeners.remove(listener);
  }

  /// Process queued messages when connected
  void _processMessageQueue() {
    for (var message in _messageQueue) {
      sendMessage(message);
    }
    _messageQueue.clear();
  }

  /// Notify all listeners
  void _notifyListeners(Map<String, dynamic> message) {
    for (var listener in _listeners) {
      listener(message);
    }
  }

  /// Reconnect to socket
  Future<void> reconnect(String userId, String token) async {
    await disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect(userId, token);
  }

  /// Check connection health
  Future<bool> checkHealth() async {
    if (!_isConnected) return false;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get connection stats
  Map<String, dynamic> getConnectionStats() {
    return {
      'isConnected': _isConnected,
      'isConnecting': _isConnecting,
      'connectionId': _connectionId,
      'queueLength': _messageQueue.length,
      'listenerCount': _listeners.length,
    };
  }
}
