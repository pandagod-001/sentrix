import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentrix/core/config/app_config.dart';

/// Real API Service for SENTRIX
/// Connects to the Python/FastAPI backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  String? _authToken;
  static const String _deviceIdKey = 'sentrix_device_id';
  static const String _demoDeviceId = String.fromEnvironment(
    'SENTRIX_DEVICE_ID',
    defaultValue: 'pixel8a-001',
  );

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // Setters
  void setAuthToken(String token) => _authToken = token;
  void clearAuthToken() => _authToken = null;

  // Helper to build headers with auth token
  Map<String, String> _buildHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Generic request handler
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    dynamic body,
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse(AppConfig.buildUrl(endpoint));
      http.Response response;

      final headers = _buildHeaders(includeAuth: includeAuth);
      if (kDebugMode) {
        debugPrint('[API] ${method.toUpperCase()} $url');
        debugPrint('[API] headers: $headers');
        if (body != null) {
          debugPrint('[API] body: ${jsonEncode(body)}');
        }
      }

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );
          break;
        case 'POST':
          response = await http
              .post(
                url,
                headers: headers,
                body: jsonEncode(body),
              )
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () => throw Exception('Request timeout'),
              );
          break;
        case 'PUT':
          response = await http
              .put(
                url,
                headers: headers,
                body: jsonEncode(body),
              )
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () => throw Exception('Request timeout'),
              );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final dynamic decodedResponse = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};
      final responseMap = decodedResponse is Map<String, dynamic>
          ? decodedResponse
          : <String, dynamic>{
              'success': false,
              'message': 'Unexpected API response format',
            };

      if (kDebugMode) {
        debugPrint('[API] status: ${response.statusCode}');
        debugPrint('[API] response: $responseMap');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _normalizeSuccessResponse(responseMap);
      }

      throw Exception(
        responseMap['detail'] ??
            responseMap['message'] ??
            'API Error: ${response.statusCode}',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[API] request failed: ${method.toUpperCase()} $endpoint -> $e');
      }
      throw Exception('API Request Failed: $e');
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existingDeviceId = prefs.getString(_deviceIdKey);
    if (existingDeviceId != null && existingDeviceId.isNotEmpty) {
      return existingDeviceId;
    }

    await prefs.setString(_deviceIdKey, _demoDeviceId);
    return _demoDeviceId;
  }

  Map<String, dynamic> _normalizeSuccessResponse(Map<String, dynamic> raw) {
    if (raw.containsKey('success')) {
      return raw;
    }

    if (raw['status'] == 'success') {
      final normalized = <String, dynamic>{
        'success': true,
        'message': raw['message'] ?? 'Success',
        'data': <String, dynamic>{},
      };

      raw.forEach((key, value) {
        if (key != 'status' && key != 'message') {
          (normalized['data'] as Map<String, dynamic>)[key] = value;
        }
      });

      return normalized;
    }

    return {
      'success': true,
      'data': raw,
      'message': raw['message'] ?? 'Success',
    };
  }

  // Authentication Endpoints
  Future<Map<String, dynamic>> login(String username, String password) async {
    final deviceId = await _getOrCreateDeviceId();
    return _makeRequest(
      'POST',
      AppConfig.authLoginEndpoint,
      body: {
        'username': username,
        'password': password,
        'device_id': deviceId,
      },
      includeAuth: false,
    );
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String role,
  ) async {
    return _makeRequest(
      'POST',
      AppConfig.authRegisterEndpoint,
      body: {
        'username': username,
        'password': password,
        'role': role,
      },
      includeAuth: false,
    );
  }

  Future<Map<String, dynamic>> logout() async {
    return _makeRequest(
      'POST',
      AppConfig.authLogoutEndpoint,
      body: {},
    );
  }


  // User Endpoints
  Future<Map<String, dynamic>> getUser(String userId) async {
    return _makeRequest('GET', '${AppConfig.getUserEndpoint}/$userId');
  }

  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    return _makeRequest(
      'PUT',
      '${AppConfig.updateUserEndpoint}/$userId',
      body: userData,
    );
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return _makeRequest('GET', AppConfig.getUserProfileEndpoint);
  }

  Future<Map<String, dynamic>> getAllUsers() async {
    return _makeRequest('GET', '/users');
  }

  Future<Map<String, dynamic>> getDependents(String personnelId) async {
    return _makeRequest('GET', '/users/$personnelId/dependents');
  }

  // Chat Endpoints
  Future<Map<String, dynamic>> getChats() async {
    return _makeRequest('GET', AppConfig.getChatsEndpoint);
  }

  Future<Map<String, dynamic>> createChat(String recipientId) async {
    return _makeRequest(
      'POST',
      AppConfig.createChatEndpoint,
      body: {
        'recipient_id': recipientId,
      },
    );
  }

  Future<Map<String, dynamic>> sendMessage(
    String chatId,
    String message, {
    String? receiverId,
  }) async {
    return _makeRequest(
      'POST',
      AppConfig.sendMessageEndpoint,
      body: {
        'chat_id': chatId,
        'message': message,
        if (receiverId != null) 'receiver_id': receiverId,
      },
    );
  }

  Future<Map<String, dynamic>> getMessages(String chatId, {int limit = 50}) async {
    return _makeRequest(
      'GET',
      '${AppConfig.getMessagesEndpoint}/$chatId/messages?limit=$limit',
    );
  }

  // Groups Endpoints
  Future<Map<String, dynamic>> getGroups() async {
    return _makeRequest('GET', AppConfig.getGroupsEndpoint);
  }

  Future<Map<String, dynamic>> createGroup(
    String name,
    List<String> members,
  ) async {
    return _makeRequest(
      'POST',
      AppConfig.createGroupEndpoint,
      body: {
        'name': name,
        'members': members,
      },
    );
  }

  Future<Map<String, dynamic>> createFamilyGroup(String personnelId) async {
    return _makeRequest(
      'POST',
      '/groups/create-family',
      body: {
        'personnel_id': personnelId,
      },
    );
  }

  Future<Map<String, dynamic>> getGroupMessages(
    String groupId, {
    int limit = 50,
  }) async {
    return getMessages(groupId, limit: limit);
  }

  // QR Endpoints
  Future<Map<String, dynamic>> generateQRCode({int expiresInMinutes = 15}) async {
    return _makeRequest(
      'POST',
      AppConfig.generateQRCodeEndpoint,
      body: {'expires_in_minutes': expiresInMinutes},
    );
  }

  Future<Map<String, dynamic>> scanQRCode(String code) async {
    return _makeRequest(
      'POST',
      AppConfig.scanQRCodeEndpoint,
      body: {'code': code},
    );
  }

  // Face Auth Endpoints
  Future<Map<String, dynamic>> registerFace(String faceData) async {
    return _makeRequest(
      'POST',
      AppConfig.faceRegisterEndpoint,
      body: {
        'image': faceData,
      },
    );
  }

  Future<Map<String, dynamic>> authenticateFace(String faceData) async {
    return _makeRequest(
      'POST',
      AppConfig.faceAuthEndpoint,
      body: {'image': faceData},
    );
  }

  Future<Map<String, dynamic>> scanFaceDatabase(String faceData) async {
    return _makeRequest(
      'POST',
      '/face/scan',
      body: {'image': faceData},
    );
  }

  Future<Map<String, dynamic>> getFaceScanHistory({int limit = 10}) async {
    return _makeRequest('GET', '/face/scans?limit=$limit');
  }

  // Admin Endpoints
  Future<Map<String, dynamic>> getPendingApprovals() async {
    return _makeRequest('GET', AppConfig.getPendingApprovalsEndpoint);
  }

  Future<Map<String, dynamic>> approveUser(String userId) async {
    return _makeRequest('POST', '${AppConfig.approveUserEndpoint}/$userId/approve', body: {});
  }

  Future<Map<String, dynamic>> rejectUser(String userId, String reason) async {
    return _makeRequest(
      'POST',
      '${AppConfig.approveUserEndpoint}/$userId/reject',
      body: {'reason': reason},
    );
  }

  Future<Map<String, dynamic>> getStats() async {
    return _makeRequest('GET', '/admin/stats');
  }

  // Generic request methods
  Future<T> get<T>(String endpoint) => _makeRequest('GET', endpoint).then((data) => data as T);

  Future<T> post<T>(String endpoint, dynamic body) =>
      _makeRequest('POST', endpoint, body: body).then((data) => data as T);

  Future<T> put<T>(String endpoint, dynamic body) =>
      _makeRequest('PUT', endpoint, body: body).then((data) => data as T);

  Future<T> delete<T>(String endpoint) =>
      _makeRequest('DELETE', endpoint).then((data) => data as T);
}
