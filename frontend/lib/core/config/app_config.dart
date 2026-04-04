/// Application Configuration
/// Centralized configuration for API URLs, timeouts, and environment settings
class AppConfig {
  // Environment: 'development', 'staging', 'production'
  static const String environment = 'development';

  // API Configuration
  static const String emulatorBaseUrl = String.fromEnvironment(
    'SENTRIX_API_BASE_URL_EMULATOR',
    defaultValue: 'http://10.0.2.2:8013',
  );
  static const String deviceBaseUrl = String.fromEnvironment(
    'SENTRIX_API_BASE_URL_DEVICE',
    defaultValue: 'http://192.168.1.100:8013',
  );
  static const bool physicalDeviceTarget = bool.fromEnvironment(
    'SENTRIX_PHYSICAL_DEVICE',
    defaultValue: false,
  );
  static const String apiBaseUrl = String.fromEnvironment(
    'SENTRIX_API_BASE_URL',
    defaultValue: physicalDeviceTarget ? deviceBaseUrl : emulatorBaseUrl,
  );
  static const String apiVersion = '/api';
  
  // Full API URL
  static String get fullApiUrl => '$apiBaseUrl$apiVersion';

  // Timeouts (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  // Auth Endpoints
  static const String authRegisterEndpoint = '/auth/register';
  static const String authLoginEndpoint = '/auth/login';
  static const String authLogoutEndpoint = '/auth/logout';
  static const String authRefreshEndpoint = '/auth/refresh';

  // User Endpoints
  static const String getUserEndpoint = '/users'; // GET /users/{userId}
  static const String updateUserEndpoint = '/users'; // PUT /users/{userId}
  static const String getUserProfileEndpoint = '/users/me';

  // Chat Endpoints
  static const String getChatsEndpoint = '/chat/list';
  static const String createChatEndpoint = '/chat/create';
  static const String sendMessageEndpoint = '/chat/send';
  static const String getMessagesEndpoint = '/chat'; // Will append /{chat_id}/messages

  // Group Endpoints
  static const String getGroupsEndpoint = '/groups/list';
  static const String createGroupEndpoint = '/groups/create';
  static const String getGroupMessagesEndpoint = '/chat'; // Groups use chat messages endpoint

  // QR Endpoints
  static const String generateQRCodeEndpoint = '/connect/generate-code';
  static const String scanQRCodeEndpoint = '/connect/verify-code';

  // Face Auth Endpoints
  static const String faceRegisterEndpoint = '/face/register';
  static const String faceAuthEndpoint = '/face/verify';

  // Admin Endpoints
  static const String getPendingApprovalsEndpoint = '/users';
  static const String approveUserEndpoint = '/users';

  // Build full URL for an endpoint
  static String buildUrl(String endpoint) => '$fullApiUrl$endpoint';

  // Examples:
  // Emulator: flutter run --dart-define=SENTRIX_API_BASE_URL=http://10.0.2.2:8013
  // Physical device: flutter run --dart-define=SENTRIX_API_BASE_URL=http://192.168.1.100:8013
}
