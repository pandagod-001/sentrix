import 'package:flutter/foundation.dart';
import 'package:sentrix/services/api_service.dart';

/// Authentication Service for SENTRIX
/// Handles token management, session, and authentication state
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  final ApiService _apiService = ApiService();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  String? _token;
  String? _userId;
  String? _userRole;
  bool _isAuthenticated = false;
  DateTime? _tokenExpiresAt;
  String? _errorMessage;

  // Getters
  String? get token => _token;
  String? get userId => _userId;
  String? get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isTokenExpired => _tokenExpiresAt != null && DateTime.now().isAfter(_tokenExpiresAt!);
  String? get errorMessage => _errorMessage;

  /// Initialize auth service and restore token if exists
  Future<void> initialize() async {
    // TODO: Load from secure storage (flutter_secure_storage)
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Set authentication token
  void setToken(
    String token, {
    String? userId,
    String? userRole,
    Duration expiresIn = const Duration(hours: 24),
  }) {
    _token = token;
    _userId = userId;
    _userRole = userRole;
    _tokenExpiresAt = DateTime.now().add(expiresIn);
    _isAuthenticated = true;
    _errorMessage = null;
    _apiService.setAuthToken(token); // Pass token to API service
    notifyListeners();
  }

  /// Perform login with backend
  Future<bool> login(String username, String password) async {
    try {
      _errorMessage = null;
      notifyListeners();

      // Call backend login endpoint
      final response = await _apiService.login(username, password);

      // Handle successful response (using backend's success_response format)
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final token = data['access_token'] ?? data['token'];
        final user = data['user'] as Map<String, dynamic>?;
        final userId = data['user_id'] ?? user?['id'];
        final userRole = data['role'] ?? user?['role'] ?? 'personnel';

        if (token != null) {
          setToken(
            token,
            userId: userId?.toString(),
            userRole: userRole,
          );
          return true;
        }
      }
      
      _errorMessage = response['message'] ?? 'Login failed';
      _isAuthenticated = false;
      notifyListeners();
      return false;
      
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user
  Future<bool> register(
    String username,
    String password,
    String role,
  ) async {
    try {
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.register(username, password, role);

      if (response['success'] == true && response['data'] != null) {
        _errorMessage = response['message'] ?? 'Registration successful';
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Perform logout
  Future<void> logout() async {
    try {
      if (_token != null) {
        await _apiService.logout();
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _token = null;
      _userId = null;
      _userRole = null;
      _isAuthenticated = false;
      _tokenExpiresAt = null;
      _apiService.clearAuthToken();
      notifyListeners();
    }
  }

  /// Refresh token with backend
  Future<bool> refreshToken() async {
    if (_token == null) return false;

    try {
      // TODO: Implement refresh endpoint on backend
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Check if token needs refresh
  bool get shouldRefreshToken {
    if (_tokenExpiresAt == null) return false;
    final timeUntilExpiry = _tokenExpiresAt!.difference(DateTime.now());
    // Refresh if less than 5 minutes remaining
    return timeUntilExpiry.inMinutes < 5;
  }

  /// Get authorization header
  Map<String, String> get authHeaders {
    return {
      'Authorization': _token != null ? 'Bearer $_token' : '',
      'Content-Type': 'application/json',
    };
  }

  /// Validate current session with backend
  Future<bool> validateSession() async {
    if (!_isAuthenticated || _token == null) return false;

    try {
      final profile = await getCurrentUserProfileData();
      return profile != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch the current authenticated user's profile data.
  Future<Map<String, dynamic>?> getCurrentUserProfileData() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        if (response.containsKey('id')) {
          return response;
        }
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Clear all authentication data
  void clearAuthData() {
    _token = null;
    _userId = null;
    _userRole = null;
    _isAuthenticated = false;
    _tokenExpiresAt = null;
    _errorMessage = null;
    _apiService.clearAuthToken();
    notifyListeners();
  }

  // Additional auth methods (stubs for future implementation)
  Future<bool> verifyEmail(String email, String code) async => true;
  Future<bool> verifyDevice(String deviceId, String code) async => true;
  Future<bool> setupBiometric() async => true;
  Future<bool> authenticateWithBiometric() async => true;
  Future<bool> setup2FA() async => true;
  Future<bool> verify2FA(String code) async => true;
  Future<bool> requestPasswordReset(String email) async => true;
  Future<bool> resetPassword(String email, String code, String newPassword) async => true;

  /// Get time until token expiry
  Duration? get timeUntilExpiry {
    if (_tokenExpiresAt == null) return null;
    return _tokenExpiresAt!.difference(DateTime.now());
  }
}
