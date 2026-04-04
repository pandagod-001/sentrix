import 'package:flutter/foundation.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

/// QR Data Model
class QRData {
  final String id;
  final String userId;
  final String userName;
  final String memberId;
  final String userRole;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isValid;

  QRData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.memberId,
    required this.userRole,
    required this.createdAt,
    required this.expiresAt,
    required this.isValid,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String toJson() {
    return '$id|$userId|$userName|$memberId|$userRole|${createdAt.toIso8601String()}|${expiresAt.toIso8601String()}';
  }

  factory QRData.fromJson(String json) {
    final parts = json.split('|');
    return QRData(
      id: parts[0],
      userId: parts[1],
      userName: parts[2],
      memberId: parts[3],
      userRole: parts[4],
      createdAt: DateTime.parse(parts[5]),
      expiresAt: DateTime.parse(parts[6]),
      isValid: true,
    );
  }
}

/// QR Scan Result Model
class QRScanResult {
  final bool success;
  final QRData? qrData;
  final String message;
  final DateTime scannedAt;

  QRScanResult({
    required this.success,
    this.qrData,
    required this.message,
    required this.scannedAt,
  });
}

/// QR Controller - Manages QR generation and scanning
class QRController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  String? _currentUserId;
  String? _currentUserName;
  String? _currentMemberId;
  String? _currentUserRole;
  String? _errorMessage;

  QRData? _currentQRData;
  List<QRScanResult> _scanHistory = [];

  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  String? get currentMemberId => _currentMemberId;
  String? get currentUserRole => _currentUserRole;
  String? get errorMessage => _errorMessage;

  QRData? get currentQRData => _currentQRData;
  List<QRScanResult> get scanHistory => _scanHistory;

  QRController() {
    _currentUserId = _authService.userId;
    _currentUserName = null;
    _currentMemberId = null;
    _currentUserRole = _authService.userRole;
  }

  Future<void> _loadCurrentUserProfile() async {
    final profile = await _authService.getCurrentUserProfileData();
    if (profile == null) {
      throw Exception('Unable to load profile for QR generation');
    }

    _currentUserId = (profile['id'] ?? _authService.userId ?? '').toString();
    _currentUserName = (profile['name'] ?? profile['username'] ?? '').toString();
    _currentMemberId = (profile['username'] ?? profile['name'] ?? '').toString();
    _currentUserRole = (profile['role'] ?? _authService.userRole ?? 'personnel').toString();

    if ((_currentUserId ?? '').isEmpty || (_currentUserName ?? '').isEmpty || (_currentMemberId ?? '').isEmpty) {
      throw Exception('Incomplete profile data for QR generation');
    }
  }

  /// Generate new QR code for current user
  Future<void> generateQRCode() async {
    _errorMessage = null;
    try {
      await _loadCurrentUserProfile();
      final response = await _apiService.generateQRCode();
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null || (data['code']?.toString().isEmpty ?? true)) {
        throw Exception('QR data was empty');
      }

      final now = DateTime.now();
      final code = data['code'].toString();
      final expiryMinutes = (data['expires_in_minutes'] as int?) ?? 15;

      _currentQRData = QRData(
        id: code,
        userId: _currentUserId!,
        userName: _currentUserName!,
        memberId: _currentMemberId!,
        userRole: _currentUserRole!,
        createdAt: now,
        expiresAt: now.add(Duration(minutes: expiryMinutes)),
        isValid: true,
      );
    } catch (e) {
      _currentQRData = null;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Refresh/regenerate QR code
  Future<void> refreshQRCode() async {
    await generateQRCode();
  }

  /// Simulate scanning a QR code
  Future<QRScanResult> scanQRCode(String scannedData) async {
    try {
      final response = await _apiService.scanQRCode(scannedData);
      final success = response['success'] == true;
      final result = QRScanResult(
        success: success,
        qrData: null,
        message: response['message']?.toString() ?? (success ? 'QR code verified' : 'QR scan failed'),
        scannedAt: DateTime.now(),
      );

      _scanHistory.insert(0, result);
      notifyListeners();

      return result;
    } catch (e) {
      _scanHistory.insert(
        0,
        QRScanResult(
          success: false,
          message: e.toString().replaceFirst('Exception: ', ''),
          scannedAt: DateTime.now(),
        ),
      );
      notifyListeners();
      return _scanHistory.first;
    }
  }

  /// Get scan history
  List<QRScanResult> getScanHistory({int limit = 10}) {
    return _scanHistory.take(limit).toList();
  }

  /// Clear scan history
  void clearScanHistory() {
    _scanHistory.clear();
    notifyListeners();
  }

  /// Get detailed info about a scan result
  String getDetailedScanInfo(QRScanResult result) {
    if (!result.success || result.qrData == null) {
      return 'Invalid scan: ${result.message}';
    }

    final qr = result.qrData!;
    return '''
User: ${qr.userName}
Member ID: ${qr.memberId}
Role: ${qr.userRole}
Scanned: ${result.scannedAt.toString()}
Created: ${qr.createdAt.toString()}
Expires: ${qr.expiresAt.toString()}
''';
  }

  /// Convert QR data to displayable format
  String getQRDisplayData() {
    if (_currentQRData == null) return '';
    return _currentQRData!.toJson();
  }

  /// Check if current QR is valid
  bool isCurrentQRValid() {
    return _currentQRData != null && !_currentQRData!.isExpired;
  }

  /// Get time until current QR expires
  Duration? getTimeToExpiry() {
    if (_currentQRData == null) return null;
    final now = DateTime.now();
    if (now.isAfter(_currentQRData!.expiresAt)) {
      return Duration.zero;
    }
    return _currentQRData!.expiresAt.difference(now);
  }

  /// Format expiry time for display
  String getFormattedExpiryTime() {
    final timeLeft = getTimeToExpiry();
    if (timeLeft == null || timeLeft.inSeconds <= 0) {
      return 'Expired';
    }

    if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours}h ${timeLeft.inMinutes.remainder(60)}m left';
    } else if (timeLeft.inMinutes > 0) {
      return '${timeLeft.inMinutes}m left';
    } else {
      return '${timeLeft.inSeconds}s left';
    }
  }

  /// Share QR code
  Future<void> shareQRCode() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real app, would use sharing plugin
  }

  /// Export scan history
  String exportScanHistory() {
    final buffer = StringBuffer();
    buffer.writeln('QR Scan History - Generated ${DateTime.now()}');
    buffer.writeln('===========================================');

    for (var result in _scanHistory) {
      buffer.writeln('\nScan Time: ${result.scannedAt}');
      buffer.writeln('Status: ${result.success ? 'SUCCESS' : 'FAILED'}');
      if (result.qrData != null) {
        final qr = result.qrData!;
        buffer.writeln('User: ${qr.userName} (${qr.memberId})');
        buffer.writeln('Role: ${qr.userRole}');
        buffer.writeln('QR ID: ${qr.id}');
      }
      buffer.writeln('Message: ${result.message}');
    }

    return buffer.toString();
  }
}
