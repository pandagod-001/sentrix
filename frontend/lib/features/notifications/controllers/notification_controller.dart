import 'package:flutter/foundation.dart';
import '../../../services/notification_service.dart';

/// Notification Controller for managing notifications in the app
class NotificationController extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;
  List<LocalNotification> _notifications = [];

  /// Getters
  bool get isInitialized => _isInitialized;
  List<LocalNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notificationService.unreadCount;

  /// Initialize notification controller
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _notificationService.initialize();
    await _notificationService.requestPermissions();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load notifications
  Future<void> loadNotifications() async {
    _notifications = _notificationService.notifications;
    notifyListeners();
  }

  /// Send notification
  Future<void> sendNotification({
    required String title,
    required String body,
    String? payload,
    int priority = 0,
  }) async {
    await _notificationService.sendLocalNotification(
      title: title,
      body: body,
      payload: payload,
      priority: priority,
    );
    await loadNotifications();
  }

  /// Send message notification
  Future<void> sendMessageNotification(
    String senderName,
    String message,
    String senderId,
  ) async {
    await _notificationService.notifyNewMessage(
      senderName,
      message,
      senderId,
    );
    await loadNotifications();
  }

  /// Send group notification
  Future<void> sendGroupNotification(
    String groupName,
    String senderName,
    String message,
    String groupId,
  ) async {
    await _notificationService.notifyGroupMessage(
      groupName,
      senderName,
      message,
      groupId,
    );
    await loadNotifications();
  }

  /// Send approval notification
  Future<void> sendApprovalNotification(String status) async {
    await _notificationService.notifyUserApproval(status);
    await loadNotifications();
  }

  /// Send group invitation notification
  Future<void> sendGroupInvitationNotification(
    String groupName,
    String invitedBy,
    String groupId,
  ) async {
    await _notificationService.notifyGroupInvitation(
      groupName,
      invitedBy,
      groupId,
    );
    await loadNotifications();
  }

  /// Send system alert
  Future<void> sendSystemAlert(
    String title,
    String message, {
    int priority = 2,
  }) async {
    await _notificationService.notifySystemAlert(
      title,
      message,
      priority: priority,
    );
    await loadNotifications();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    _notificationService.markAsRead(notificationId);
    await loadNotifications();
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    _notificationService.markAllAsRead();
    await loadNotifications();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    _notificationService.deleteNotification(notificationId);
    await loadNotifications();
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    _notificationService.deleteAllNotifications();
    await loadNotifications();
  }

  /// Enable/Disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      await _notificationService.enableNotifications();
    } else {
      await _notificationService.disableNotifications();
    }
    notifyListeners();
  }
}
