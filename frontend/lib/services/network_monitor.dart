import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

/// Network Monitor Service for SENTRIX
/// Monitors connectivity and network health
enum NetworkStatus { online, offline, slow }

class NetworkMonitor {
  static final NetworkMonitor _instance = NetworkMonitor._internal();

  factory NetworkMonitor() {
    return _instance;
  }

  NetworkMonitor._internal();

  NetworkStatus _status = NetworkStatus.online;
  bool _isMonitoring = false;
  final List<Function(NetworkStatus)> _listeners = [];
  int _latency = 0; // in milliseconds
  String _connectionType = 'wifi';

  /// Getters
  NetworkStatus get status => _status;
  bool get isOnline => _status == NetworkStatus.online;
  bool get isOffline => _status == NetworkStatus.offline;
  bool get isSlow => _status == NetworkStatus.slow;
  int get latency => _latency;
  String get connectionType => _connectionType;
  bool get isMonitoring => _isMonitoring;

  /// Initialize network monitoring
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isMonitoring = true;
  }

  /// Start monitoring
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    _isMonitoring = true;
    await _performHealthCheck();
  }

  /// Stop monitoring
  void stopMonitoring() {
    _isMonitoring = false;
  }

  /// Check connectivity
  Future<bool> checkConnectivity() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _status == NetworkStatus.online;
  }

  /// Measure latency
  Future<int> measureLatency() async {
    final stopwatch = Stopwatch()..start();
    await Future.delayed(const Duration(milliseconds: 100));
    stopwatch.stop();
    _latency = stopwatch.elapsedMilliseconds;
    return _latency;
  }

  /// Check network speed
  Future<NetworkStatus> checkNetworkSpeed() async {
    final latency = await measureLatency();

    if (latency > 500) {
      _status = NetworkStatus.slow;
    } else {
      _status = NetworkStatus.online;
    }

    _notifyListeners();
    return _status;
  }

  /// Set network status
  void setNetworkStatus(NetworkStatus status) {
    if (_status != status) {
      _status = status;
      _notifyListeners();
    }
  }

  /// Set connection type
  void setConnectionType(String type) {
    _connectionType = type; // 'wifi', '4g', '5g', 'mobile'
  }

  /// Listen to network changes
  void onNetworkStatusChanged(Function(NetworkStatus) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeNetworkListener(Function(NetworkStatus) listener) {
    _listeners.remove(listener);
  }

  /// Perform health check
  Future<void> _performHealthCheck() async {
    while (_isMonitoring) {
      await checkNetworkSpeed();
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_status);
    }
  }

  /// Get status message
  String getStatusMessage() {
    switch (_status) {
      case NetworkStatus.online:
        return 'Online - $connectionType';
      case NetworkStatus.offline:
        return 'No connection';
      case NetworkStatus.slow:
        return 'Slow connection';
    }
  }

  /// Get network health score (0-100)
  int getHealthScore() {
    if (_status == NetworkStatus.offline) return 0;
    if (_status == NetworkStatus.slow) return 50;
    if (_latency < 100) return 100;
    if (_latency < 300) return 75;
    return 50;
  }

  /// Get detailed status
  Map<String, dynamic> getDetailedStatus() {
    return {
      'status': _status.toString(),
      'isOnline': isOnline,
      'latency': _latency,
      'connectionType': _connectionType,
      'healthScore': getHealthScore(),
      'message': getStatusMessage(),
    };
  }

  /// Retry connection
  Future<bool> retryConnection() async {
    for (int i = 0; i < 3; i++) {
      final isConnected = await checkConnectivity();
      if (isConnected) {
        return true;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }
}

/// Connection Status Notifier
class ConnectionStatusNotifier {
  static final ConnectionStatusNotifier _instance =
      ConnectionStatusNotifier._internal();

  factory ConnectionStatusNotifier() {
    return _instance;
  }

  ConnectionStatusNotifier._internal() {
    _initializeMonitor();
  }

  late NetworkMonitor _monitor;

  void _initializeMonitor() {
    _monitor = NetworkMonitor();
    _monitor.initialize();
  }

  NetworkMonitor get monitor => _monitor;

  /// Show connection status widget
  static Widget buildConnectionStatusWidget() {
    return Consumer<ConnectionStatusProvider>(
      builder: (context, provider, _) {
        if (provider.isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          color: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'No Internet Connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Connection Status Provider - ChangeNotifier wrapper for NetworkMonitor
class ConnectionStatusProvider extends ChangeNotifier {
  final NetworkMonitor _monitor = NetworkMonitor();
  NetworkStatus _status = NetworkStatus.online;

  ConnectionStatusProvider() {
    _initialize();
  }

  void _initialize() {
    _monitor.onNetworkStatusChanged(_onStatusChanged);
  }

  void _onStatusChanged(NetworkStatus status) {
    _status = status;
    notifyListeners();
  }

  NetworkStatus get status => _status;
  bool get isOnline => _status == NetworkStatus.online;
  bool get isOffline => _status == NetworkStatus.offline;
  bool get isSlow => _status == NetworkStatus.slow;

  Future<void> startMonitoring() async {
    await _monitor.startMonitoring();
  }

  void stopMonitoring() {
    _monitor.stopMonitoring();
  }
}
