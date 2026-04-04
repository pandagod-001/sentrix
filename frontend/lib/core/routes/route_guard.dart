import '../constants/app_enums.dart';

/// Route Guard - Manages role-based access control for routes
class RouteGuard {
  /// Checks if user with given role can access a route
  static bool canAccessRoute(UserRole? userRole, String routeName) {
    if (userRole == null) {
      return false;
    }

    // Public routes (no authentication required)
    final publicRoutes = [
      '/splash',
      '/login',
      '/not_found',
    ];

    if (publicRoutes.contains(routeName)) {
      return true;
    }

    // Auth-required routes (any authenticated user)
    final authRoutes = [
      '/device_verify',
      '/face_auth',
      '/pending_approval',
      '/home',
      '/chat_list',
      '/chat_screen',
      '/settings',
      '/profile',
    ];

    if (authRoutes.contains(routeName)) {
      return true;
    }

    // Route-specific access control

    // Admin-only routes
    if (userRole == UserRole.admin) {
      return true; // Authority can access everything
    }

    // Personnel-only routes
    if (userRole == UserRole.personnel) {
      final personnelRoutes = [
        '/qr_display',
        '/qr_scan',
        '/unique_code',
        '/group_list',
        '/group_chat',
        '/create_group',
      ];
      return personnelRoutes.contains(routeName);
    }

    // Dependent-only routes
    if (userRole == UserRole.dependent) {
      final dependentRoutes = [
        '/dependent_home',
        '/group_list',
        '/group_chat',
      ];
      return dependentRoutes.contains(routeName);
    }

    return false;
  }

  /// Checks if user is allowed to perform an action
  static bool canPerformAction(UserRole? userRole, String action) {
    if (userRole == null) return false;

    switch (action) {
      case 'create_group':
        return userRole == UserRole.admin;
      case 'scan_qr':
        return userRole == UserRole.personnel;
      case 'display_qr':
        return userRole == UserRole.personnel;
      case 'manage_users':
        return userRole == UserRole.admin;
      case 'view_admin_dashboard':
        return userRole == UserRole.admin;
      case 'scan_face_database':
        return userRole == UserRole.admin;
      case 'send_message':
        return userRole != UserRole.dependent || true; // All can send message
      default:
        return false;
    }
  }

  /// Gets the appropriate home route based on user role
  static String getHomeRoute(UserRole userRole) {
    switch (userRole) {
      case UserRole.admin:
        return '/home';
      case UserRole.personnel:
        return '/home';
      case UserRole.dependent:
        return '/dependent_home';
    }
  }

  /// Checks if route requires authentication
  static bool isProtectedRoute(String routeName) {
    final publicRoutes = [
      '/splash',
      '/login',
      '/not_found',
    ];
    return !publicRoutes.contains(routeName);
  }

  /// Gets all accessible routes for a given role
  static List<String> getAccessibleRoutes(UserRole userRole) {
    final baseRoutes = [
      '/home',
      '/chat_list',
      '/chat_screen',
      '/group_list',
      '/group_chat',
      '/settings',
      '/profile',
    ];

    switch (userRole) {
      case UserRole.admin:
        return [
          ...baseRoutes,
          '/qr_display',
          '/qr_scan',
          '/unique_code',
          '/create_group',
          '/admin_dashboard',
          '/authority_face_scan',
          '/manage_personnel',
          '/manage_dependents',
          '/create_official_group',
          '/create_family_group',
        ];
      case UserRole.personnel:
        return [
          ...baseRoutes,
          '/qr_display',
          '/qr_scan',
          '/unique_code',
          '/create_group',
        ];
      case UserRole.dependent:
        return [
          '/dependent_home',
          '/chat_list',
          '/chat_screen',
          '/group_list',
          '/group_chat',
          '/settings',
          '/profile',
        ];
    }
  }
}
