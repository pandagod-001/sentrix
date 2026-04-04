/// Service Locator / Service Setup for SENTRIX
/// Centralizes initialization and access to all services
import 'dart:async';

import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/database_service.dart';
import '../../services/file_service.dart';
import '../../services/log_service.dart';
import '../../services/socket_service.dart';
import '../../services/face_auth_service.dart';
import '../../services/analytics_service.dart';
import '../../services/data_sync_service.dart';
import '../../services/network_monitor.dart';

/// Service Locator Singleton
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  // Services
  late ApiService _apiService;
  late AuthService _authService;
  late NotificationService _notificationService;
  late DatabaseService _databaseService;
  late FileService _fileService;
  late LogService _logService;
  late SocketService _socketService;
  late FaceAuthService _faceAuthService;
  late AnalyticsService _analyticsService;
  late DataSyncService _dataSyncService;
  late NetworkMonitor _networkMonitor;

  bool _isInitialized = false;

  /// Getters
  ApiService get apiService => _apiService;
  AuthService get authService => _authService;
  NotificationService get notificationService => _notificationService;
  DatabaseService get databaseService => _databaseService;
  FileService get fileService => _fileService;
  LogService get logService => _logService;
  SocketService get socketService => _socketService;
  FaceAuthService get faceAuthService => _faceAuthService;
  AnalyticsService get analyticsService => _analyticsService;
  DataSyncService get dataSyncService => _dataSyncService;
  NetworkMonitor get networkMonitor => _networkMonitor;
  bool get isInitialized => _isInitialized;

  /// Initialize all services
  Future<void> initialize() async {
    if (_isInitialized) return;

    _apiService = ApiService();
    _authService = AuthService();
    _notificationService = NotificationService();
    _databaseService = DatabaseService();
    _fileService = FileService();
    _logService = LogService();
    _socketService = SocketService();
    _faceAuthService = FaceAuthService();
    _analyticsService = AnalyticsService();
    _dataSyncService = DataSyncService();
    _networkMonitor = NetworkMonitor();

    // Initialize each service
    await _logService.initialize();
    _logService.logInfo('Service locator initialization started');

    await _databaseService.initialize();
    _logService.logInfo('Database service initialized');

    await _fileService.initialize();
    _logService.logInfo('File service initialized');

    await _authService.initialize();
    _logService.logInfo('Auth service initialized');

    await _networkMonitor.initialize();
    _logService.logInfo('Network monitor initialized');

    _isInitialized = true;
    _logService.logInfo('All services initialized successfully');

    // Keep first-frame startup fast and initialize optional services in background.
    unawaited(_initializeNonCriticalServices());
  }

  Future<void> _initializeNonCriticalServices() async {
    try {
      await _notificationService.initialize();
      _logService.logInfo('Notification service initialized');

      await _analyticsService.initialize();
      _logService.logInfo('Analytics service initialized');

      await _dataSyncService.initialize();
      _logService.logInfo('Data sync service initialized');

      await _socketService.initialize();
      _logService.logInfo('Socket service initialized');
    } catch (e) {
      _logService.logError(
        'Non-critical services initialization failed',
        extra: {'error': e.toString()},
      );
    }
  }

  /// Reset all services
  Future<void> reset() async {
    if (!_isInitialized) return;

    await _authService.logout();
    await _socketService.disconnect();
    _databaseService.clearAll();
    _logService.logInfo('Services reset');
    _isInitialized = false;
  }

  /// Get service status
  Map<String, bool> getServiceStatus() {
    return {
      'isInitialized': _isInitialized,
      'authAuthenticated': _authService.isAuthenticated,
      'socketConnected': _socketService.isConnected,
      'networkOnline': _networkMonitor.isOnline,
    };
  }

  /// Log all services status
  void logServiceStatus() {
    _logService.logInfo('Service Status Report', tag: 'ServiceLocator', extra: {
      'isInitialized': _isInitialized,
      'authAuthenticated': _authService.isAuthenticated,
      'socketConnected': _socketService.isConnected,
      'networkOnline': _networkMonitor.isOnline,
      'totalLogs': _logService.totalLogs,
    });
  }
}

/// Provider setup for app
List<ChangeNotifierProvider> getAppProviders() {
  final serviceLocator = ServiceLocator();

  return [
    ChangeNotifierProvider<AuthService>(
      create: (_) => serviceLocator.authService,
    ),
    ChangeNotifierProvider<NotificationService>(
      create: (_) => serviceLocator.notificationService,
    ),
    ChangeNotifierProvider<ConnectionStatusProvider>(
      create: (_) => ConnectionStatusProvider(),
    ),
  ];
}
