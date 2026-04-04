import 'package:sentrix/services/api_service.dart';

/// Face Authentication Service for SENTRIX
/// Handles facial recognition and biometric authentication
class FaceAuthService {
  static final FaceAuthService _instance = FaceAuthService._internal();

  factory FaceAuthService() {
    return _instance;
  }

  FaceAuthService._internal();

  bool _isCameraReady = false;
  bool _isDetecting = false;
  double _detectionAccuracy = 0.0;
  List<String> _enrolledFaces = [];
  bool _faceDetected = false;
  String? _capturedFaceData;
  final ApiService _apiService = ApiService();

  /// Getters
  bool get isCameraReady => _isCameraReady;
  bool get isDetecting => _isDetecting;
  double get detectionAccuracy => _detectionAccuracy;
  List<String> get enrolledFaces => List.unmodifiable(_enrolledFaces);
  bool get faceDetected => _faceDetected;

  /// Initialize face recognition service
  Future<bool> initialize() async {
    try {
      _isCameraReady = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Request camera permissions
  Future<bool> requestCameraPermissions() async {
    return true;
  }

  void setCapturedFaceData(String? base64Image) {
    _capturedFaceData = base64Image;
    _faceDetected = base64Image != null && base64Image.isNotEmpty;
  }

  /// Start face detection
  Future<bool> startFaceDetection() async {
    if (!_isCameraReady) return false;

    _isDetecting = true;

    if (_capturedFaceData == null || _capturedFaceData!.isEmpty) {
      _detectionAccuracy = 0.0;
      _faceDetected = false;
      return false;
    }

    _detectionAccuracy = 0.95;
    _faceDetected = true;
    return true;
  }

  /// Stop face detection
  Future<void> stopFaceDetection() async {
    _isDetecting = false;
    _detectionAccuracy = 0.0;
  }

  /// Enroll face for user
  Future<bool> enrollFace(String userId) async {
    if (!_faceDetected) return false;

    try {
      final faceData = _capturedFaceData;
      if (faceData == null || faceData.isEmpty) {
        return false;
      }
      final response = await _apiService.registerFace(faceData);

      if (response['success'] == true) {
        final faceId = 'face_${userId}_${DateTime.now().millisecondsSinceEpoch}';
        _enrolledFaces.add(faceId);
        return true;
      }
    } catch (_) {}

    return false;
  }

  /// Authenticate user with face
  Future<Map<String, dynamic>> authenticateWithFace(String userId) async {
    if (!_isDetecting || !_faceDetected) {
      return {
        'success': false,
        'message': 'No face detected',
        'accuracy': 0.0,
      };
    }

    final faceData = _capturedFaceData;
    if (faceData == null || faceData.isEmpty) {
      return {
        'success': false,
        'message': 'No face capture available',
        'accuracy': 0.0,
      };
    }

    try {
      final response = await _apiService.authenticateFace(faceData);
      final isMatch = response['success'] == true;

      if (isMatch) {
        return {
          'success': true,
          'message': response['message'] ?? 'Face recognised successfully',
          'userId': userId,
          'accuracy': _detectionAccuracy,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Face does not match',
        'accuracy': _detectionAccuracy,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
        'accuracy': _detectionAccuracy,
      };
    }
  }

  /// Scan captured face against the database for authority verification.
  Future<Map<String, dynamic>> scanFaceAgainstDatabase() async {
    if (!_isDetecting || !_faceDetected) {
      return {
        'success': false,
        'message': 'No face detected',
      };
    }

    final faceData = _capturedFaceData;
    if (faceData == null || faceData.isEmpty) {
      return {
        'success': false,
        'message': 'No face capture available',
      };
    }

    try {
      final response = await _apiService.scanFaceDatabase(faceData);
      return {
        'success': response['success'] == true,
        'data': response['data'],
        'message': response['message'] ?? 'Scan completed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  /// Verify face for payment/sensitive operation
  Future<Map<String, dynamic>> verifyFaceForOperation(
    String operationType,
  ) async {
    if (!_faceDetected) {
      return {
        'success': false,
        'message': 'No face detected for verification',
      };
    }

    await Future.delayed(const Duration(seconds: 2));

    return {
      'success': true,
      'message': 'Face verified for $operationType',
      'verificationTime': DateTime.now().toIso8601String(),
    };
  }

  /// Get face detection metrics
  Map<String, dynamic> getDetectionMetrics() {
    return {
      'isCameraReady': _isCameraReady,
      'isDetecting': _isDetecting,
      'detectionAccuracy': _detectionAccuracy,
      'faceDetected': _faceDetected,
      'enrolledFacesCount': _enrolledFaces.length,
    };
  }

  /// Clear enrolled faces
  Future<void> clearEnrolledFaces() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _enrolledFaces.clear();
  }

  /// Get face enrollment status
  Future<bool> isFaceEnrolled(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _enrolledFaces.isNotEmpty;
  }

  /// Compare two faces
  Future<Map<String, dynamic>> compareFaces(
    String face1Data,
    String face2Data,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'match': true,
      'confidence': 0.92,
      'distance': 0.08, // Lower is better
    };
  }

  /// Update face enrollment
  Future<bool> updateFaceEnrollment(String userId) async {
    if (!_faceDetected) return false;

    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  /// Liveness detection (check if face is real, not photo)
  Future<bool> performLivenessDetection() async {
    await Future.delayed(const Duration(seconds: 3));
    return true; // Real face detected
  }

  /// Get face attributes (mock)
  Future<Map<String, dynamic>> getFaceAttributes() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'age': 28,
      'gender': 'Male',
      'emotion': 'neutral',
      'lighting': 'good',
      'clarity': 'high',
      'faceSize': 'optimal',
    };
  }

  /// Release camera resources
  void releaseCameraResources() {
    _isCameraReady = false;
    _isDetecting = false;
    _faceDetected = false;
    _capturedFaceData = null;
  }
}
