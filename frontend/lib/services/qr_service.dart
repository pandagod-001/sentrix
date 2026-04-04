/// QR Service for SENTRIX
/// Handles QR code generation, validation, and scanning operations
class QRData {
  final String id;
  final String userId;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;

  QRData({
    required this.id,
    required this.userId,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeRemaining => expiresAt.difference(DateTime.now());
}

class QRScanRecord {
  final String id;
  final String qrCode;
  final String scannedBy;
  final DateTime scannedAt;
  final bool success;
  final String? scannedUserId;

  QRScanRecord({
    required this.id,
    required this.qrCode,
    required this.scannedBy,
    required this.scannedAt,
    required this.success,
    this.scannedUserId,
  });
}

class QRService {
  static final QRService _instance = QRService._internal();

  factory QRService() {
    return _instance;
  }

  QRService._internal();

  final Map<String, QRData> _qrCodes = {};
  final List<QRScanRecord> _scanHistory = [];

  /// Initialize QR service
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Generate QR code for user
  Future<QRData> generateQRCode(String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    final qrId = 'qr_${DateTime.now().millisecondsSinceEpoch}';
    final code = 'SENTRIX_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    final createdAt = DateTime.now();
    final expiresAt = createdAt.add(const Duration(hours: 24));

    final qrData = QRData(
      id: qrId,
      userId: userId,
      code: code,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isActive: true,
    );

    _qrCodes[qrId] = qrData;
    return qrData;
  }

  /// Get current QR code for user
  Future<QRData?> getCurrentQRCode(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final userQRs = _qrCodes.values
        .where((qr) => qr.userId == userId && qr.isActive && !qr.isExpired)
        .toList();

    return userQRs.isNotEmpty ? userQRs.first : null;
  }

  /// Validate QR code
  Future<bool> validateQRCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final qr = _qrCodes.values.cast<QRData?>().firstWhere(
      (qr) => qr?.code == code,
      orElse: () => null,
    );

    return qr != null && qr.isActive && !qr.isExpired;
  }

  /// Record QR scan
  Future<QRScanRecord> recordScan(
    String qrCode,
    String scannedBy,
    bool success, {
    String? scannedUserId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final record = QRScanRecord(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      qrCode: qrCode,
      scannedBy: scannedBy,
      scannedAt: DateTime.now(),
      success: success,
      scannedUserId: scannedUserId,
    );

    _scanHistory.add(record);
    return record;
  }

  /// Get scan history
  Future<List<QRScanRecord>> getScanHistory(String userId, {int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _scanHistory
        .where((record) => record.scannedBy == userId)
        .take(limit)
        .toList();
  }

  /// Get QR statistics
  Future<Map<String, dynamic>> getQRStatistics(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final userScans =
        _scanHistory.where((record) => record.scannedBy == userId).toList();

    return {
      'totalScans': userScans.length,
      'successfulScans': userScans.where((r) => r.success).length,
      'failedScans': userScans.where((r) => !r.success).length,
      'lastScanTime': userScans.isNotEmpty ? userScans.last.scannedAt : null,
    };
  }

  /// Refresh QR code (generate new one)
  Future<QRData> refreshQRCode(String userId) async {
    // Deactivate old codes
    final userQRs = _qrCodes.values.where((qr) => qr.userId == userId).toList();
    for (var qr in userQRs) {
      _qrCodes[qr.id] = QRData(
        id: qr.id,
        userId: qr.userId,
        code: qr.code,
        createdAt: qr.createdAt,
        expiresAt: qr.expiresAt,
        isActive: false,
      );
    }

    // Generate new one
    return generateQRCode(userId);
  }

  /// Get QR code info
  Future<QRData?> getQRCodeInfo(String qrCodeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _qrCodes[qrCodeId];
  }

  /// Clear expired QR codes
  Future<void> clearExpiredQRCodes() async {
    await Future.delayed(const Duration(milliseconds: 500));

    _qrCodes.removeWhere((key, qr) => qr.isExpired);
  }

  /// Get all active QR codes for user
  Future<List<QRData>> getActiveQRCodes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _qrCodes.values
        .where((qr) => qr.userId == userId && qr.isActive && !qr.isExpired)
        .toList();
  }
}
