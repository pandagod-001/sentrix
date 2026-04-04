import '../../../core/constants/app_enums.dart';
import '../../../models/user_model.dart';

/// Auth State Model - Tracks authentication state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final AuthStep currentStep;
  final String? deviceCode;
  final String? faceStatus; // 'scanning', 'recognized', 'failed'
  final int? approvalCheckCount; // For polling approval

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.currentStep = AuthStep.splash,
    this.deviceCode,
    this.faceStatus,
    this.approvalCheckCount = 0,
  });

  // Check if user is in pending approval state
  bool get isPendingApproval => 
      currentStep == AuthStep.pendingApproval && user != null && !user!.isApproved;

  // Check if authentication is complete
  bool get isAuthComplete => isAuthenticated && user != null && user!.isApproved;

  // Copy with method
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
    AuthStep? currentStep,
    String? deviceCode,
    String? faceStatus,
    int? approvalCheckCount,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      currentStep: currentStep ?? this.currentStep,
      deviceCode: deviceCode ?? this.deviceCode,
      faceStatus: faceStatus ?? this.faceStatus,
      approvalCheckCount: approvalCheckCount ?? this.approvalCheckCount,
    );
  }

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, currentStep: ${currentStep.name}, user: ${user?.name})';
  }
}
