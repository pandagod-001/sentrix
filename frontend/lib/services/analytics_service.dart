/// Analytics and Event Tracking Service
class AnalyticsEvent {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic> properties;

  AnalyticsEvent({
    required this.name,
    DateTime? timestamp,
    this.properties = const {},
  }) : timestamp = timestamp ?? DateTime.now();
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  final List<AnalyticsEvent> _events = [];
  bool _trackingEnabled = true;
  String? _userId;

  /// Getters
  List<AnalyticsEvent> get events => List.unmodifiable(_events);
  bool get trackingEnabled => _trackingEnabled;
  int get eventCount => _events.length;

  /// Initialize analytics
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Set user ID for tracking
  void setUserId(String userId) {
    _userId = userId;
  }

  /// Track event
  void trackEvent(String name, {Map<String, dynamic>? properties}) {
    if (!_trackingEnabled) return;

    final event = AnalyticsEvent(
      name: name,
      properties: {
        ...?properties,
        'userId': _userId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    _events.add(event);
  }

  /// Track screen view
  void trackScreenView(String screenName) {
    trackEvent('screen_view', properties: {'screen': screenName});
  }

  /// Track button click
  void trackButtonClick(String buttonName, {String? screenName}) {
    trackEvent('button_click', properties: {
      'button': buttonName,
      'screen': screenName,
    });
  }

  /// Track login
  void trackLogin(String method) {
    trackEvent('login', properties: {'method': method});
  }

  /// Track logout
  void trackLogout() {
    trackEvent('logout');
  }

  /// Track message sent
  void trackMessageSent(String chatType, {int? length}) {
    trackEvent('message_sent', properties: {
      'chatType': chatType,
      'messageLength': length,
    });
  }

  /// Track QR scan
  void trackQRScan(bool success) {
    trackEvent('qr_scan', properties: {'success': success});
  }

  /// Track group action
  void trackGroupAction(String action, String groupId) {
    trackEvent('group_action', properties: {
      'action': action,
      'groupId': groupId,
    });
  }

  /// Track settings change
  void trackSettingsChange(String setting, dynamic value) {
    trackEvent('settings_change', properties: {
      'setting': setting,
      'value': value,
    });
  }

  /// Enable tracking
  void enableTracking() {
    _trackingEnabled = true;
  }

  /// Disable tracking
  void disableTracking() {
    _trackingEnabled = false;
  }

  /// Get events by name
  List<AnalyticsEvent> getEventsByName(String name) {
    return _events.where((e) => e.name == name).toList();
  }

  /// Get recent events
  List<AnalyticsEvent> getRecentEvents({int count = 10}) {
    return _events.skip((_events.length - count).clamp(0, _events.length)).toList();
  }

  /// Clear events
  void clearEvents() {
    _events.clear();
  }

  /// Get analytics summary
  Map<String, dynamic> getAnalyticsSummary() {
    final eventCounts = <String, int>{};
    for (var event in _events) {
      eventCounts[event.name] = (eventCounts[event.name] ?? 0) + 1;
    }

    return {
      'totalEvents': _events.length,
      'eventCounts': eventCounts,
      'userId': _userId,
      'trackingEnabled': _trackingEnabled,
    };
  }
}
