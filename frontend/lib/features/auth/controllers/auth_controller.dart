import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/face_auth_service.dart';
import '../models/auth_state.dart';

/// Auth Controller - Manages authentication flow and state
class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FaceAuthService _faceAuthService = FaceAuthService();
  AuthState _state = AuthState();
  AuthState get state => _state;

  AuthController() {
    // Initialize with splash screen
    _state = AuthState(currentStep: AuthStep.splash);
  }

  /// Update state
  void _updateState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Login with member ID and password
  Future<void> login(String memberId, String password) async {
    try {
      _updateState(_state.copyWith(
        isLoading: true,
        error: null,
        currentStep: AuthStep.login,
      ));

      if (memberId.isEmpty || password.isEmpty) {
        _updateState(_state.copyWith(
          isLoading: false,
          error: 'Member ID and password are required',
        ));
        return;
      }

      final loginOk = await _authService.login(memberId.trim(), password);
      if (!loginOk) {
        _updateState(_state.copyWith(
          isLoading: false,
          error: _authService.errorMessage ?? 'Invalid username or password',
          currentStep: AuthStep.login,
        ));
        return;
      }

      final profileData = await _authService.getCurrentUserProfileData();
      final role = UserRoleExtension.fromString(
        (profileData?['role'] ?? _authService.userRole ?? 'personnel').toString(),
      );
      final approvedValue = profileData?['is_approved'] ?? profileData?['isApproved'] ?? false;
      final user = User(
        id: _authService.userId ?? 'unknown_user',
        name: (profileData?['username'] ?? profileData?['name'] ?? memberId).toString(),
        email: memberId,
        role: role,
        status: UserStatus.online,
        isApproved: approvedValue == true,
        createdAt: DateTime.now(),
      );

      _updateState(_state.copyWith(
        isLoading: false,
        user: user,
        currentStep: AuthStep.deviceVerify,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'Login failed: ${e.toString()}',
        currentStep: AuthStep.login,
      ));
    }
  }

  /// Verify device
  Future<void> verifyDevice() async {
    try {
      _updateState(_state.copyWith(
        isLoading: true,
        error: null,
        currentStep: AuthStep.deviceVerify,
      ));

      await Future.delayed(const Duration(milliseconds: 600));

      final deviceCode = 'DEV-${_state.user?.id.substring(0, 6) ?? 'UNKNOWN'}';

      _updateState(_state.copyWith(
        isLoading: false,
        deviceCode: deviceCode,
        currentStep: AuthStep.faceAuth,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'Device verification failed: ${e.toString()}',
      ));
    }
  }

  /// Verify face
  Future<void> verifyFace() async {
    try {
      _updateState(_state.copyWith(
        isLoading: true,
        faceStatus: 'scanning',
        error: null,
        currentStep: AuthStep.faceAuth,
      ));

      await _faceAuthService.initialize();
      final detectionStarted = await _faceAuthService.startFaceDetection();

      if (!detectionStarted || _state.user == null) {
        _updateState(_state.copyWith(
          isLoading: false,
          faceStatus: 'failed',
          error: 'Unable to start face detection',
        ));
        return;
      }

      final enrolled = await _faceAuthService.enrollFace(_state.user!.id);
      if (!enrolled) {
        _updateState(_state.copyWith(
          isLoading: false,
          faceStatus: 'failed',
          error: 'Face enrollment failed',
        ));
        return;
      }

      final authResult = await _faceAuthService.authenticateWithFace(_state.user!.id);
      final authSuccess = authResult['success'] == true;

      if (!authSuccess) {
        _updateState(_state.copyWith(
          isLoading: false,
          faceStatus: 'failed',
          error: authResult['message']?.toString() ?? 'Face authentication failed',
        ));
        return;
      }

      await _faceAuthService.stopFaceDetection();

      _updateState(_state.copyWith(
        isLoading: false,
        faceStatus: 'recognized',
        currentStep: AuthStep.pendingApproval,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        faceStatus: 'failed',
        error: 'Face recognition failed: ${e.toString()}',
      ));
    } finally {
      await _faceAuthService.stopFaceDetection();
    }
  }

  void setCapturedFaceImage(String base64Image) {
    _faceAuthService.setCapturedFaceData(base64Image);
  }

  /// Check if account is approved
  Future<void> checkApproval() async {
    try {
      if (_state.user == null) {
        _updateState(_state.copyWith(error: 'No user to check approval'));
        return;
      }

      _updateState(_state.copyWith(
        isLoading: true,
        error: null,
        approvalCheckCount: (_state.approvalCheckCount ?? 0) + 1,
      ));

      final profile = await _authService.getCurrentUserProfileData();
      final isApproved = (profile?['is_approved'] ?? profile?['isApproved'] ?? false) == true;

      if (isApproved) {
        _updateState(_state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: _state.user!.copyWith(isApproved: true),
          currentStep: AuthStep.home,
        ));
      } else {
        _updateState(_state.copyWith(
          isLoading: false,
          currentStep: AuthStep.pendingApproval,
        ));
      }
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'Approval check failed: ${e.toString()}',
      ));
    }
  }

  /// Logout
  void logout() {
    _updateState(AuthState(currentStep: AuthStep.splash));
  }

  /// Reset to login screen
  void resetToLogin() {
    _updateState(AuthState(currentStep: AuthStep.login));
  }

  /// Reset auth error
  void clearError() {
    _updateState(_state.copyWith(error: null));
  }

  /// Get current user
  User? get currentUser => _state.user;

  /// Check if authenticated
  bool get isAuthenticated => _state.isAuthenticated;

  /// Check if user is admin
  bool get isAdmin => _state.user?.role == UserRole.admin;

  /// Check if user is personnel
  bool get isPersonnel => _state.user?.role == UserRole.personnel;

  /// Check if user is dependent
  bool get isDependent => _state.user?.role == UserRole.dependent;
}
