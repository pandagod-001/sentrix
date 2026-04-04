enum LogLevel { verbose, debug, info, warning, error, fatal }

/// Log entry model
class LogEntry {
  final String id;
  final LogLevel level;
  final String message;
  final String? tag;
  final DateTime timestamp;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? extra;

  LogEntry({
    required this.id,
    required this.level,
    required this.message,
    this.tag,
    DateTime? timestamp,
    this.stackTrace,
    this.extra,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      '[${level.name.toUpperCase()}] ${timestamp.toString()} - ${tag != null ? '[$tag] ' : ''}$message';
}

/// Logging Service for SENTRIX
/// Handles app logging and analytics
class LogService {
  static final LogService _instance = LogService._internal();

  factory LogService() {
    return _instance;
  }

  LogService._internal();

  final List<LogEntry> _logs = [];
  bool _loggingEnabled = true;
  LogLevel _minLogLevel = LogLevel.debug;
  final Map<String, int> _errorCounts = {};
  int _sessionId = DateTime.now().millisecondsSinceEpoch;

  // Getters
  List<LogEntry> get logs => List.unmodifiable(_logs);
  bool get loggingEnabled => _loggingEnabled;
  int get totalLogs => _logs.length;
  int get sessionId => _sessionId;

  /// Initialize logging service
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    logInfo('Logging service initialized');
  }

  /// Enable logging
  void enableLogging() {
    _loggingEnabled = true;
    logInfo('Logging enabled');
  }

  /// Disable logging
  void disableLogging() {
    _loggingEnabled = false;
  }

  /// Set minimum log level
  void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
    logInfo('Min log level set to ${level.name}');
  }

  /// Log verbose message
  void logVerbose(String message, {String? tag, Map<String, dynamic>? extra}) {
    _log(LogLevel.verbose, message, tag: tag, extra: extra);
  }

  /// Log debug message
  void logDebug(String message, {String? tag, Map<String, dynamic>? extra}) {
    _log(LogLevel.debug, message, tag: tag, extra: extra);
  }

  /// Log info message
  void logInfo(String message, {String? tag, Map<String, dynamic>? extra}) {
    _log(LogLevel.info, message, tag: tag, extra: extra);
  }

  /// Log warning message
  void logWarning(String message, {String? tag, Map<String, dynamic>? extra}) {
    _log(LogLevel.warning, message, tag: tag, extra: extra);
  }

  /// Log error message
  void logError(
    String message, {
    String? tag,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      stackTrace: stackTrace,
      extra: extra,
    );
    _incrementErrorCount(tag ?? 'general');
  }

  /// Log fatal error
  void logFatal(
    String message, {
    String? tag,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      stackTrace: stackTrace,
      extra: extra,
    );
    _incrementErrorCount(tag ?? 'general');
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    if (!_loggingEnabled || level.index < _minLogLevel.index) return;

    final logEntry = LogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      level: level,
      message: message,
      tag: tag,
      stackTrace: stackTrace,
      extra: extra,
    );

    _logs.add(logEntry);

    // In production, also send to console/file/analytics
    print(logEntry);
  }

  /// Increment error count for a tag
  void _incrementErrorCount(String tag) {
    _errorCounts[tag] = (_errorCounts[tag] ?? 0) + 1;
  }

  /// Get error count for tag
  int getErrorCount(String tag) {
    return _errorCounts[tag] ?? 0;
  }

  /// Get all error counts
  Map<String, int> getAllErrorCounts() {
    return Map.unmodifiable(_errorCounts);
  }

  /// Log screen view
  void logScreenView(String screenName) {
    logInfo('Screen viewed', tag: 'Navigation', extra: {'screen': screenName});
  }

  /// Log user action
  void logUserAction(String action, {Map<String, dynamic>? details}) {
    logInfo('User action: $action', tag: 'User', extra: details);
  }

  /// Log API call
  void logApiCall(
    String method,
    String endpoint, {
    int? statusCode,
    int? duration,
  }) {
    logInfo(
      '$method $endpoint',
      tag: 'API',
      extra: {
        'statusCode': statusCode,
        'durationMs': duration,
      },
    );
  }

  /// Log crash
  void logCrash(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
  }) {
    logFatal(
      'Crash: $error',
      tag: 'Crash',
      stackTrace: stackTrace,
      extra: context,
    );
  }

  /// Get logs by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Get logs by tag
  List<LogEntry> getLogsByTag(String tag) {
    return _logs.where((log) => log.tag == tag).toList();
  }

  /// Get recent logs
  List<LogEntry> getRecentLogs({int count = 50}) {
    return _logs.skip((_logs.length - count).clamp(0, _logs.length)).toList();
  }

  /// Export logs
  Future<String> exportLogs({String? format = 'txt'}) async {
    await Future.delayed(const Duration(seconds: 1));

    final buffer = StringBuffer();
    buffer.writeln('SENTRIX Application Logs');
    buffer.writeln('Session ID: $_sessionId');
    buffer.writeln('Exported: ${DateTime.now().toIso8601String()}');
    buffer.writeln('---');

    for (var log in _logs) {
      buffer.writeln(log.toString());
      if (log.extra != null) {
        buffer.writeln('  Extra: ${log.extra}');
      }
      if (log.stackTrace != null) {
        buffer.writeln('  Stack: ${log.stackTrace}');
      }
    }

    return 'sentrix_logs_${DateTime.now().millisecondsSinceEpoch}.$format';
  }

  /// Clear old logs
  void clearOldLogs({Duration olderThan = const Duration(days: 7)}) {
    final cutoffTime = DateTime.now().subtract(olderThan);
    _logs.removeWhere((log) => log.timestamp.isBefore(cutoffTime));
    logInfo('Cleared logs older than $olderThan');
  }

  /// Clear all logs
  void clearAll() {
    _logs.clear();
    _errorCounts.clear();
    logInfo('All logs cleared');
  }

  /// Get logs summary
  Map<String, dynamic> getLogsSummary() {
    final levelCounts = <String, int>{};
    for (var log in _logs) {
      final levelName = log.level.name;
      levelCounts[levelName] = (levelCounts[levelName] ?? 0) + 1;
    }

    return {
      'sessionId': _sessionId,
      'totalLogs': _logs.length,
      'levelCounts': levelCounts,
      'errorCounts': Map.of(_errorCounts),
      'oldestLog': _logs.isNotEmpty ? _logs.first.timestamp : null,
      'latestLog': _logs.isNotEmpty ? _logs.last.timestamp : null,
    };
  }
}
