/// Data Sync Service for SENTRIX
/// Handles synchronization of local and remote data
class SyncStatus {
  final bool isSyncing;
  final int itemsSynced;
  final int totalItems;
  final DateTime? lastSyncTime;
  final String? lastError;

  SyncStatus({
    this.isSyncing = false,
    this.itemsSynced = 0,
    this.totalItems = 0,
    this.lastSyncTime,
    this.lastError,
  });

  double get progress {
    if (totalItems == 0) return 0;
    return itemsSynced / totalItems;
  }
}

class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();

  factory DataSyncService() {
    return _instance;
  }

  DataSyncService._internal();

  bool _isSyncing = false;
  int _itemsSynced = 0;
  int _totalItems = 0;
  DateTime? _lastSyncTime;
  String? _lastError;
  final Map<String, DateTime> _syncTimestamps = {};

  /// Getters
  bool get isSyncing => _isSyncing;
  SyncStatus get status => SyncStatus(
        isSyncing: _isSyncing,
        itemsSynced: _itemsSynced,
        totalItems: _totalItems,
        lastSyncTime: _lastSyncTime,
        lastError: _lastError,
      );

  /// Initialize sync service
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Start sync
  Future<bool> startSync() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    _itemsSynced = 0;
    _lastError = null;

    try {
      // Mock sync process
      await Future.delayed(const Duration(seconds: 2));

      _isSyncing = false;
      _lastSyncTime = DateTime.now();
      return true;
    } catch (e) {
      _isSyncing = false;
      _lastError = e.toString();
      return false;
    }
  }

  /// Sync messages
  Future<void> syncMessages() async {
    _startSyncOperation();
    await Future.delayed(const Duration(seconds: 1));
    _recordSyncTime('messages');
    _endSyncOperation();
  }

  /// Sync chats
  Future<void> syncChats() async {
    _startSyncOperation();
    await Future.delayed(const Duration(seconds: 1));
    _recordSyncTime('chats');
    _endSyncOperation();
  }

  /// Sync groups
  Future<void> syncGroups() async {
    _startSyncOperation();
    await Future.delayed(const Duration(seconds: 1));
    _recordSyncTime('groups');
    _endSyncOperation();
  }

  /// Sync user profile
  Future<void> syncUserProfile() async {
    _startSyncOperation();
    await Future.delayed(const Duration(milliseconds: 500));
    _recordSyncTime('user_profile');
    _endSyncOperation();
  }

  /// Sync all data
  Future<void> syncAll() async {
    _isSyncing = true;
    _itemsSynced = 0;
    _totalItems = 4;
    _lastError = null;

    try {
      await syncMessages();
      await syncChats();
      await syncGroups();
      await syncUserProfile();

      _isSyncing = false;
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _isSyncing = false;
      _lastError = e.toString();
    }
  }

  /// Check if data needs sync
  bool needsSync(String dataType) {
    final lastSync = _syncTimestamps[dataType];
    if (lastSync == null) return true;

    final duration = DateTime.now().difference(lastSync);
    return duration.inMinutes > 5; // Sync if older than 5 minutes
  }

  /// Get sync timestamp for data type
  DateTime? getSyncTimestamp(String dataType) {
    return _syncTimestamps[dataType];
  }

  /// Clear sync timestamps
  void clearSyncTimestamps() {
    _syncTimestamps.clear();
  }

  /// Private helper methods
  void _startSyncOperation() {
    _totalItems++;
  }

  void _endSyncOperation() {
    _itemsSynced++;
  }

  void _recordSyncTime(String dataType) {
    _syncTimestamps[dataType] = DateTime.now();
  }

  /// Get sync summary
  Map<String, dynamic> getSyncSummary() {
    return {
      'isSyncing': _isSyncing,
      'itemsSynced': _itemsSynced,
      'totalItems': _totalItems,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'lastError': _lastError,
      'syncedDataTypes': _syncTimestamps.keys.toList(),
    };
  }
}
