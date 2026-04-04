/// SENTRIX Enumerations
/// Define all enum types used throughout the app

// ========== User Role ==========
enum UserRole {
  personnel,
  dependent,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.personnel:
        return 'Personnel';
      case UserRole.dependent:
        return 'Dependent';
      case UserRole.admin:
        return 'Authority';
    }
  }

  String get value {
    switch (this) {
      case UserRole.personnel:
        return 'personnel';
      case UserRole.dependent:
        return 'dependent';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'authority':
        return UserRole.admin;
      case 'personnel':
        return UserRole.personnel;
      case 'dependent':
        return UserRole.dependent;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.dependent;
    }
  }
}

// ========== Message Type ==========
enum MessageType {
  sent,
  received,
}

extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.sent:
        return 'sent';
      case MessageType.received:
        return 'received';
    }
  }

  static MessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sent':
        return MessageType.sent;
      case 'received':
        return MessageType.received;
      default:
        return MessageType.received;
    }
  }
}

// ========== Chat Status ==========
enum ChatStatus {
  active,
  archived,
  muted,
}

extension ChatStatusExtension on ChatStatus {
  String get value {
    switch (this) {
      case ChatStatus.active:
        return 'active';
      case ChatStatus.archived:
        return 'archived';
      case ChatStatus.muted:
        return 'muted';
    }
  }

  static ChatStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return ChatStatus.active;
      case 'archived':
        return ChatStatus.archived;
      case 'muted':
        return ChatStatus.muted;
      default:
        return ChatStatus.active;
    }
  }
}

// ========== User Status ==========
enum UserStatus {
  online,
  offline,
  away,
  busy,
}

extension UserStatusExtension on UserStatus {
  String get displayName {
    switch (this) {
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

  String get value {
    switch (this) {
      case UserStatus.online:
        return 'online';
      case UserStatus.offline:
        return 'offline';
      case UserStatus.away:
        return 'away';
      case UserStatus.busy:
        return 'busy';
    }
  }

  static UserStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'online':
        return UserStatus.online;
      case 'offline':
        return UserStatus.offline;
      case 'away':
        return UserStatus.away;
      case 'busy':
        return UserStatus.busy;
      default:
        return UserStatus.offline;
    }
  }
}

// ========== Group Type ==========
enum GroupType {
  official,
  family,
  general,
}

extension GroupTypeExtension on GroupType {
  String get displayName {
    switch (this) {
      case GroupType.official:
        return 'Official Group';
      case GroupType.family:
        return 'Family Group';
      case GroupType.general:
        return 'General Group';
    }
  }

  String get value {
    switch (this) {
      case GroupType.official:
        return 'official';
      case GroupType.family:
        return 'family';
      case GroupType.general:
        return 'general';
    }
  }

  static GroupType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'official':
        return GroupType.official;
      case 'family':
        return GroupType.family;
      case 'general':
        return GroupType.general;
      default:
        return GroupType.general;
    }
  }
}

// ========== Auth Step ==========
enum AuthStep {
  splash,
  login,
  deviceVerify,
  faceAuth,
  pendingApproval,
  home,
}

extension AuthStepExtension on AuthStep {
  String get value {
    switch (this) {
      case AuthStep.splash:
        return 'splash';
      case AuthStep.login:
        return 'login';
      case AuthStep.deviceVerify:
        return 'device_verify';
      case AuthStep.faceAuth:
        return 'face_auth';
      case AuthStep.pendingApproval:
        return 'pending_approval';
      case AuthStep.home:
        return 'home';
    }
  }

  static AuthStep fromString(String value) {
    switch (value.toLowerCase()) {
      case 'splash':
        return AuthStep.splash;
      case 'login':
        return AuthStep.login;
      case 'device_verify':
        return AuthStep.deviceVerify;
      case 'face_auth':
        return AuthStep.faceAuth;
      case 'pending_approval':
        return AuthStep.pendingApproval;
      case 'home':
        return AuthStep.home;
      default:
        return AuthStep.splash;
    }
  }
}

// ========== Notification Type ==========
enum NotificationType {
  message,
  approval,
  alert,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.message:
        return 'message';
      case NotificationType.approval:
        return 'approval';
      case NotificationType.alert:
        return 'alert';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'message':
        return NotificationType.message;
      case 'approval':
        return NotificationType.approval;
      case 'alert':
        return NotificationType.alert;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
}
