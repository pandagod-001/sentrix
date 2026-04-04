/// Admin Approval Request Model
class AdminApprovalRequest {
  final String id;
  final String userName;
  final String userEmail;
  final String userRole;
  final DateTime requestedAt;
  final String status; // pending, approved, rejected
  final String reason;

  AdminApprovalRequest({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.requestedAt,
    required this.status,
    required this.reason,
  });

  AdminApprovalRequest copyWith({
    String? id,
    String? userName,
    String? userEmail,
    String? userRole,
    DateTime? requestedAt,
    String? status,
    String? reason,
  }) {
    return AdminApprovalRequest(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userRole: userRole ?? this.userRole,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
      reason: reason ?? this.reason,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

/// Admin Personnel Record Model
class AdminPersonnelRecord {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status; // active, suspended, inactive
  final DateTime joinedAt;
  final bool isApproved;
  final DateTime lastActive;

  AdminPersonnelRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinedAt,
    required this.isApproved,
    required this.lastActive,
  });

  AdminPersonnelRecord copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? status,
    DateTime? joinedAt,
    bool? isApproved,
    DateTime? lastActive,
  }) {
    return AdminPersonnelRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      isApproved: isApproved ?? this.isApproved,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';
  int get daysActive {
    return DateTime.now().difference(joinedAt).inDays;
  }

  String getLastActiveText() {
    final difference = DateTime.now().difference(lastActive);
    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Admin Group Record Model
class AdminGroupRecord {
  final String id;
  final String name;
  final String createdBy;
  final int memberCount;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final String type; // family, official
  final String description;

  AdminGroupRecord({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.memberCount,
    required this.createdAt,
    required this.lastActivityAt,
    required this.type,
    required this.description,
  });

  AdminGroupRecord copyWith({
    String? id,
    String? name,
    String? createdBy,
    int? memberCount,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    String? type,
    String? description,
  }) {
    return AdminGroupRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }

  bool get isFamily => type == 'family';
  bool get isOfficial => type == 'official';
  int get daysActive {
    return DateTime.now().difference(createdAt).inDays;
  }

  String getLastActivityText() {
    final difference = DateTime.now().difference(lastActivityAt);
    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Admin Activity Log
class AdminActivityLog {
  final String id;
  final String adminName;
  final String action; // approve, reject, suspend, etc
  final String targetUser;
  final DateTime timestamp;
  final String details;

  AdminActivityLog({
    required this.id,
    required this.adminName,
    required this.action,
    required this.targetUser,
    required this.timestamp,
    required this.details,
  });

  String getActionText() {
    switch (action) {
      case 'approve':
        return 'Approved user';
      case 'reject':
        return 'Rejected user';
      case 'suspend':
        return 'Suspended user';
      case 'activate':
        return 'Activated user';
      case 'delete':
        return 'Deleted user';
      default:
        return 'Action: $action';
    }
  }
}

/// Admin System Health
class AdminSystemHealth {
  final bool databaseHealthy;
  final bool apiHealthy;
  final bool notificationHealthy;
  final int activeConnections;
  final double uptime; // percentage
  final DateTime lastChecked;

  AdminSystemHealth({
    required this.databaseHealthy,
    required this.apiHealthy,
    required this.notificationHealthy,
    required this.activeConnections,
    required this.uptime,
    required this.lastChecked,
  });

  bool get isHealthy =>
      databaseHealthy && apiHealthy && notificationHealthy;
  
  String getHealthStatus() {
    if (isHealthy) return 'All Systems Healthy';
    if (!databaseHealthy) return 'Database Issue';
    if (!apiHealthy) return 'API Issue';
    if (!notificationHealthy) return 'Notification Service Issue';
    return 'Unknown Issue';
  }
}

/// Admin Face Scan Record
class AdminFaceScanRecord {
  final String id;
  final String? scannedByName;
  final String? scannedByRole;
  final String? matchedUserName;
  final String? matchedUserRole;
  final bool matched;
  final bool allowed;
  final DateTime? createdAt;

  AdminFaceScanRecord({
    required this.id,
    required this.scannedByName,
    required this.scannedByRole,
    required this.matchedUserName,
    required this.matchedUserRole,
    required this.matched,
    required this.allowed,
    required this.createdAt,
  });

  factory AdminFaceScanRecord.fromJson(Map<String, dynamic> json) {
    final scannedBy = json['scanned_by'] as Map<String, dynamic>?;
    final matchedUser = json['matched_user'] as Map<String, dynamic>?;

    return AdminFaceScanRecord(
      id: (json['id'] ?? '').toString(),
      scannedByName: scannedBy?['name']?.toString(),
      scannedByRole: scannedBy?['role']?.toString(),
      matchedUserName: matchedUser?['name']?.toString(),
      matchedUserRole: matchedUser?['role']?.toString(),
      matched: json['matched'] == true,
      allowed: json['allowed'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  String get statusText => matched ? (allowed ? 'Allowed' : 'Blocked') : 'No match';
}
