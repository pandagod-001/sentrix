import 'package:flutter/foundation.dart';

class SettingsController extends ChangeNotifier {
  // Notification Settings
  bool _notificationsEnabled = true;
  bool _messageNotifications = true;
  bool _groupNotifications = true;
  bool _systemNotifications = true;
  String _notificationSound = 'default';

  // Privacy Settings
  bool _onlineStatus = true;
  bool _readReceipts = true;
  bool _lastSeenVisible = true;
  bool _allowGroupInvites = true;
  String _blockedUsers = '';

  // Theme Settings
  String _fontSize = 'medium'; // small, medium, large

  // Security Settings
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;
  bool _loginNotifications = true;

  // Account Settings
  String _userName = 'John Doe';
  String _email = 'john.doe@defense.mil';
  String _phone = '+1-555-0100';
  String _role = 'Personnel';

  // Activity Settings
  bool _trackActivity = true;
  bool _shareLocation = false;
  int _autoLogoutMinutes = 30;

  SettingsController();

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get messageNotifications => _messageNotifications;
  bool get groupNotifications => _groupNotifications;
  bool get systemNotifications => _systemNotifications;
  String get notificationSound => _notificationSound;

  bool get onlineStatus => _onlineStatus;
  bool get readReceipts => _readReceipts;
  bool get lastSeenVisible => _lastSeenVisible;
  bool get allowGroupInvites => _allowGroupInvites;
  String get blockedUsers => _blockedUsers;

  String get fontSize => _fontSize;

  bool get biometricAuth => _biometricAuth;
  bool get twoFactorAuth => _twoFactorAuth;
  bool get loginNotifications => _loginNotifications;

  String get userName => _userName;
  String get email => _email;
  String get phone => _phone;
  String get role => _role;

  bool get trackActivity => _trackActivity;
  bool get shareLocation => _shareLocation;
  int get autoLogoutMinutes => _autoLogoutMinutes;

  // Setters with notifications
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
  }

  Future<void> setMessageNotifications(bool value) async {
    _messageNotifications = value;
    notifyListeners();
  }

  Future<void> setGroupNotifications(bool value) async {
    _groupNotifications = value;
    notifyListeners();
  }

  Future<void> setSystemNotifications(bool value) async {
    _systemNotifications = value;
    notifyListeners();
  }

  Future<void> setNotificationSound(String sound) async {
    _notificationSound = sound;
    notifyListeners();
  }

  Future<void> setOnlineStatus(bool value) async {
    _onlineStatus = value;
    notifyListeners();
  }

  Future<void> setReadReceipts(bool value) async {
    _readReceipts = value;
    notifyListeners();
  }

  Future<void> setLastSeenVisible(bool value) async {
    _lastSeenVisible = value;
    notifyListeners();
  }

  Future<void> setAllowGroupInvites(bool value) async {
    _allowGroupInvites = value;
    notifyListeners();
  }

  Future<void> setFontSize(String size) async {
    _fontSize = size;
    notifyListeners();
  }

  Future<void> setBiometricAuth(bool value) async {
    _biometricAuth = value;
    notifyListeners();
  }

  Future<void> setTwoFactorAuth(bool value) async {
    _twoFactorAuth = value;
    notifyListeners();
  }

  Future<void> setLoginNotifications(bool value) async {
    _loginNotifications = value;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _userName = name;
    _email = email;
    _phone = phone;
    notifyListeners();
  }

  Future<void> setTrackActivity(bool value) async {
    _trackActivity = value;
    notifyListeners();
  }

  Future<void> setShareLocation(bool value) async {
    _shareLocation = value;
    notifyListeners();
  }

  Future<void> setAutoLogout(int minutes) async {
    _autoLogoutMinutes = minutes;
    notifyListeners();
  }

  Future<void> addBlockedUser(String userId) async {
    _blockedUsers = _blockedUsers.isEmpty
        ? userId
        : '$_blockedUsers,$userId';
    notifyListeners();
  }

  Future<void> removeBlockedUser(String userId) async {
    final users = _blockedUsers.split(',');
    users.remove(userId);
    _blockedUsers = users.join(',');
    notifyListeners();
  }

  List<String> getBlockedUsersList() {
    return _blockedUsers.isEmpty ? [] : _blockedUsers.split(',');
  }

  Future<void> resetToDefaults() async {
    _notificationsEnabled = true;
    _messageNotifications = true;
    _groupNotifications = true;
    _systemNotifications = true;
    _notificationSound = 'default';
    _onlineStatus = true;
    _readReceipts = true;
    _lastSeenVisible = true;
    _allowGroupInvites = true;
    _fontSize = 'medium';
    _trackActivity = true;
    _shareLocation = false;
    _autoLogoutMinutes = 30;
    notifyListeners();
  }
}
