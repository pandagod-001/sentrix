import 'package:flutter/foundation.dart';

/// Notification model for local notifications
class LocalNotification {
  final String id;
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;
  final String? icon;
  final int priority;
  bool isRead;

  LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    DateTime? timestamp,
    this.icon,
    this.priority = 0,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Notification Service for SENTRIX
/// Handles push notifications, local notifications, and notification state
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final List<LocalNotification> _notifications = [];
  bool _notificationsEnabled = true;
  String _defaultNotificationSound = 'default';

  // Getters
  List<LocalNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get notificationsEnabled => _notificationsEnabled;
  String get defaultNotificationSound => _defaultNotificationSound;

  /// Initialize notification service
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In production, setup Firebase Cloud Messaging
    // and request permissions
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // Mock permission granted
  }

  /// Send local notification
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    String? payload,
    String? icon,
    int priority = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final notification = LocalNotification(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      payload: payload,
      icon: icon,
      priority: priority,
    );

    _notifications.add(notification);
    notifyListeners();
  }

  /// Send notification for message
  Future<void> notifyNewMessage(
    String senderName,
    String messagePreview,
    String senderId,
  ) async {
    await sendLocalNotification(
      title: 'New message from $senderName',
      body: messagePreview,
      payload: senderId,
      priority: 2,
    );
  }

  /// Send notification for group message
  Future<void> notifyGroupMessage(
    String groupName,
    String senderName,
    String messagePreview,
    String groupId,
  ) async {
    await sendLocalNotification(
      title: '$senderName posted in $groupName',
      body: messagePreview,
      payload: groupId,
      priority: 1,
    );
  }

  /// Send notification for user approval
  Future<void> notifyUserApproval(String status) async {
    await sendLocalNotification(
      title: 'Account Status Update',
      body: 'Your account has been $status',
      priority: 2,
    );
  }

  /// Send notification for group invitation
  Future<void> notifyGroupInvitation(
    String groupName,
    String invitedBy,
    String groupId,
  ) async {
    await sendLocalNotification(
      title: 'Group Invitation',
      body: '$invitedBy invited you to $groupName',
      payload: groupId,
      priority: 1,
    );
  }

  /// Send notification for system alert
  Future<void> notifySystemAlert(
    String title,
    String message, {
    int priority = 2,
  }) async {
    await sendLocalNotification(
      title: title,
      body: message,
      priority: priority,
    );
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index =
        _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  /// Delete notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Delete all notifications
  void deleteAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  /// Delete all read notifications
  void deleteReadNotifications() {
    _notifications.removeWhere((n) => n.isRead);
    notifyListeners();
  }

  /// Enable notifications
  Future<void> enableNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _notificationsEnabled = true;
    notifyListeners();
  }

  /// Disable notifications
  Future<void> disableNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _notificationsEnabled = false;
    notifyListeners();
  }

  /// Set notification sound
  Future<void> setNotificationSound(String sound) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _defaultNotificationSound = sound;
    notifyListeners();
  }

  /// Get notifications by type
  List<LocalNotification> getNotificationsByType(String type) {
    return _notifications
        .where((n) => n.title.contains(type))
        .toList();
  }

  /// Get recent notifications
  List<LocalNotification> getRecentNotifications({int limit = 10}) {
    return _notifications
        .take(limit)
        .toList();
  }

  /// Check if service is enabled
  bool get serviceEnabled {
    return _notificationsEnabled;
  }

  /// Clear all data
  void clearAll() {
    _notifications.clear();
    _notificationsEnabled = true;
    _defaultNotificationSound = 'default';
    notifyListeners();
  }
}
