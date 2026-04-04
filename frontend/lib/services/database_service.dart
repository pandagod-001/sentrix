import 'dart:convert';

/// Database Service for SENTRIX
/// Handles local data persistence using shared preferences mock
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // Mock in-memory storage
  final Map<String, String> _storage = {};

  /// Initialize database
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In production, initialize Hive or SQLite
  }

  /// Save string value
  Future<bool> saveString(String key, String value) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage[key] = value;
    return true;
  }

  /// Get string value
  Future<String?> getString(String key) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _storage[key];
  }

  /// Save integer value
  Future<bool> saveInt(String key, int value) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage[key] = value.toString();
    return true;
  }

  /// Get integer value
  Future<int?> getInt(String key) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final value = _storage[key];
    return value != null ? int.tryParse(value) : null;
  }

  /// Save boolean value
  Future<bool> saveBool(String key, bool value) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage[key] = value.toString();
    return true;
  }

  /// Get boolean value
  Future<bool?> getBool(String key) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final value = _storage[key];
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  /// Save double value
  Future<bool> saveDouble(String key, double value) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage[key] = value.toString();
    return true;
  }

  /// Get double value
  Future<double?> getDouble(String key) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final value = _storage[key];
    return value != null ? double.tryParse(value) : null;
  }

  /// Save JSON object
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage[key] = jsonEncode(value);
    return true;
  }

  /// Get JSON object
  Future<Map<String, dynamic>?> getJson(String key) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final value = _storage[key];
    try {
      return value != null ? jsonDecode(value) as Map<String, dynamic> : null;
    } catch (_) {
      return null;
    }
  }

  /// Save list of strings
  Future<bool> saveStringList(String key, List<String> value) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage[key] = jsonEncode(value);
    return true;
  }

  /// Get list of strings
  Future<List<String>?> getStringList(String key) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final value = _storage[key];
    try {
      return value != null ? List<String>.from(jsonDecode(value)) : null;
    } catch (_) {
      return null;
    }
  }

  /// Check if key exists
  Future<bool> hasKey(String key) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _storage.containsKey(key);
  }

  /// Remove a key
  Future<bool> remove(String key) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage.remove(key);
    return true;
  }

  /// Remove all keys matching pattern
  Future<void> removePattern(String pattern) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage.removeWhere((key, _) => key.contains(pattern));
  }

  /// Clear all data
  Future<void> clearAll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage.clear();
  }

  /// Get all keys
  Future<List<String>> getAllKeys() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _storage.keys.toList();
  }

  /// Get storage size
  Future<int> getStorageSize() async {
    await Future.delayed(const Duration(milliseconds: 50));
    int totalSize = 0;
    for (var value in _storage.values) {
      totalSize += value.length;
    }
    return totalSize;
  }

  // Cache-specific operations
  Future<bool> cacheUser(String userId, Map<String, dynamic> userData) async {
    return saveJson('user_$userId', userData);
  }

  Future<Map<String, dynamic>?> getCachedUser(String userId) async {
    return getJson('user_$userId');
  }

  Future<bool> cacheChat(String chatId, Map<String, dynamic> chatData) async {
    return saveJson('chat_$chatId', chatData);
  }

  Future<Map<String, dynamic>?> getCachedChat(String chatId) async {
    return getJson('chat_$chatId');
  }

  Future<bool> cacheGroup(String groupId, Map<String, dynamic> groupData) async {
    return saveJson('group_$groupId', groupData);
  }

  Future<Map<String, dynamic>?> getCachedGroup(String groupId) async {
    return getJson('group_$groupId');
  }

  // Preferences
  Future<bool> setLastLogin(DateTime timestamp) async {
    return saveString('last_login', timestamp.toIso8601String());
  }

  Future<DateTime?> getLastLogin() async {
    final value = await getString('last_login');
    return value != null ? DateTime.parse(value) : null;
  }

  Future<bool> setAppVersion(String version) async {
    return saveString('app_version', version);
  }

  Future<String?> getAppVersion() async {
    return getString('app_version');
  }

  /// Check if this is first app launch
  Future<bool> isFirstLaunch() async {
    return !(await hasKey('app_version'));
  }
}
