import '../core/constants/app_enums.dart';
import '../models/user_model.dart';

/// Role Checker Utility - Helper functions for role-based checks
class RoleChecker {
  /// Check if user has a specific role
  static bool hasRole(User user, UserRole role) {
    return user.role == role;
  }

  /// Check if user has any of the provided roles
  static bool hasAnyRole(User user, List<UserRole> roles) {
    return roles.contains(user.role);
  }

  /// Check if user has all of the provided roles (useful for combinations)
  static bool hasAllRoles(User user, List<UserRole> roles) {
    return roles.every((role) => user.role == role);
  }

  /// Check if user is personnel
  static bool isPersonnel(User user) {
    return user.role == UserRole.personnel;
  }

  /// Check if user is dependent
  static bool isDependent(User user) {
    return user.role == UserRole.dependent;
  }

  /// Check if user is admin
  static bool isAdmin(User user) {
    return user.role == UserRole.admin;
  }

  /// Check if user is approved
  static bool isApproved(User user) {
    return user.isApproved;
  }

  /// Check if user is active (not banned/disabled)
  static bool isActive(User user) {
    return user.status == UserStatus.online;
  }

  /// Check if user is pending approval
  static bool isPending(User user) {
    return user.status == UserStatus.offline;
  }

  /// Get user role display name
  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.personnel:
        return 'Personnel';
      case UserRole.dependent:
        return 'Dependent';
      case UserRole.admin:
        return 'Authority';
    }
  }

  /// Get user status display name
  static String getStatusDisplayName(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return 'Online';
      case UserStatus.offline:
        return 'Offline';
      case UserStatus.away:
        return 'Away';
      case UserStatus.busy:
        return 'Busy';
    }
  }

  /// Check if can access QR functionality (personnel only)
  static bool canAccessQR(User user) {
    return isPersonnel(user) && isApproved(user) && isActive(user);
  }

  /// Check if can access admin dashboard (admin only)
  static bool canAccessAdmin(User user) {
    return isAdmin(user) && isActive(user);
  }

  /// Check if can access groups
  static bool canAccessGroups(User user) {
    return (isPersonnel(user) || isDependent(user)) &&
        isApproved(user) &&
        isActive(user);
  }

  /// Check if can access chat
  static bool canAccessChat(User user) {
    return isApproved(user) && isActive(user);
  }

  /// Check if can manage dependents (personnel only)
  static bool canManageDependents(User user) {
    return isPersonnel(user) && isApproved(user) && isActive(user);
  }

  /// Check if can manage personnel (admin only)
  static bool canManagePersonnel(User user) {
    return isAdmin(user) && isActive(user);
  }

  /// Get user greeting based on role
  static String getGreeting(User user) {
    final roleText = getRoleDisplayName(user.role);
    return 'Welcome, ${user.name} ($roleText)';
  }

  /// Check if user has restricted access
  static bool hasRestrictedAccess(User user) {
    return !isApproved(user) || !isActive(user);
  }

  /// Get access restriction reason
  static String getRestrictionReason(User user) {
    if (!isApproved(user)) {
      return 'Your account is pending approval. Please wait for admin approval.';
    }
    if (!isActive(user)) {
      return 'Your account is currently disabled. Please contact support.';
    }
    return 'You don\'t have access to this feature.';
  }

  /// Check if user can perform action
  static bool canPerformAction(User user, String action) {
    // Define action permissions
    const personnelActions = [
      'scan_qr',
      'display_qr',
      'access_messages',
      'access_groups',
      'manage_dependents',
    ];

    const dependentActions = [
      'access_messages',
      'access_groups',
    ];

    const adminActions = [
      'admin_dashboard',
      'approve_users',
      'manage_personnel',
      'view_statistics',
      'system_settings',
      'access_messages',
      'create_group',
    ];

    if (isPersonnel(user)) {
      return personnelActions.contains(action) &&
          isApproved(user) &&
          isActive(user);
    }

    if (isDependent(user)) {
      return dependentActions.contains(action) &&
          isApproved(user) &&
          isActive(user);
    }

    if (isAdmin(user)) {
      return adminActions.contains(action) && isActive(user);
    }

    return false;
  }

  /// Get list of accessible features for user
  static List<String> getAccessibleFeatures(User user) {
    final features = <String>[];

    // Basic features for all approved users
    if (isApproved(user) && isActive(user)) {
      features.addAll(['messages', 'profile', 'settings']);
    }

    // Personnel features
    if (isPersonnel(user) && isApproved(user) && isActive(user)) {
      features.addAll(['qr', 'groups', 'dependents']);
    }

    // Dependent features
    if (isDependent(user) && isApproved(user) && isActive(user)) {
      features.addAll(['groups']);
    }

    // Admin features
    if (isAdmin(user) && isActive(user)) {
      features.addAll(['admin', 'analytics', 'user_management']);
    }

    return features;
  }

  /// Check if role can see specific user type
  static bool canSeeUser(User viewer, User target) {
    // Admin can see everyone
    if (isAdmin(viewer)) {
      return true;
    }

    // Personnel can see other personnel and their dependents
    if (isPersonnel(viewer)) {
      return isPersonnel(target) || isDependent(target);
    }

    // Dependent can see the personnel (parent) only
    if (isDependent(viewer)) {
      return isPersonnel(target);
    }

    return false;
  }

  /// Get home route for user based on role
  static String getHomeRoute(User user) {
    if (isAdmin(user)) {
      return '/home';
    }
    if (isDependent(user)) {
      return '/dependent_home';
    }
    return '/home';
  }
}
