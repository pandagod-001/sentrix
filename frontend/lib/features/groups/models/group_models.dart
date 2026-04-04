/// Group Data Model
class GroupModel {
  final String id;
  final String name;
  final String description;
  final String type; // family, official
  final String createdBy;
  final DateTime createdAt;
  final int memberCount;
  final int messages;
  final DateTime lastActivity;
  final bool isAdmin;
  final bool isMuted;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.createdBy,
    required this.createdAt,
    required this.memberCount,
    required this.messages,
    required this.lastActivity,
    required this.isAdmin,
    required this.isMuted,
  });

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? createdBy,
    DateTime? createdAt,
    int? memberCount,
    int? messages,
    DateTime? lastActivity,
    bool? isAdmin,
    bool? isMuted,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
      messages: messages ?? this.messages,
      lastActivity: lastActivity ?? this.lastActivity,
      isAdmin: isAdmin ?? this.isAdmin,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  int get daysActive => DateTime.now().difference(createdAt).inDays;

  bool get isFamily => type == 'family';
  bool get isOfficial => type == 'official';

  String getLastActivityText() {
    final difference = DateTime.now().difference(lastActivity);
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

/// Group Member Model
class GroupMember {
  final String id;
  final String name;
  final String email;
  final String role; // admin, member, moderator
  final DateTime joinedAt;
  final String? avatar;
  final String status; // online, offline, away

  GroupMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.avatar,
    required this.status,
  });

  GroupMember copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    DateTime? joinedAt,
    String? avatar,
    String? status,
  }) {
    return GroupMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';
  bool get isOnline => status == 'online';

  int get daysInGroup =>
      DateTime.now().difference(joinedAt).inDays;
}

/// Group Invitation Model
class GroupInvitation {
  final String id;
  final String groupId;
  final String groupName;
  final String invitedBy;
  final String invitedUser;
  final DateTime invitedAt;
  final String status; // pending, accepted, declined

  GroupInvitation({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.invitedBy,
    required this.invitedUser,
    required this.invitedAt,
    required this.status,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
}

/// Group Settings Model
class GroupSettings {
  final String groupId;
  final bool allowMessagesFromAll;
  final bool requireApprovalForMembers;
  final bool muteNotifications;
  final List<String> mutedWords;
  final String privacyLevel; // public, private, restricted

  GroupSettings({
    required this.groupId,
    required this.allowMessagesFromAll,
    required this.requireApprovalForMembers,
    required this.muteNotifications,
    required this.mutedWords,
    required this.privacyLevel,
  });

  GroupSettings copyWith({
    String? groupId,
    bool? allowMessagesFromAll,
    bool? requireApprovalForMembers,
    bool? muteNotifications,
    List<String>? mutedWords,
    String? privacyLevel,
  }) {
    return GroupSettings(
      groupId: groupId ?? this.groupId,
      allowMessagesFromAll:
          allowMessagesFromAll ?? this.allowMessagesFromAll,
      requireApprovalForMembers: requireApprovalForMembers ??
          this.requireApprovalForMembers,
      muteNotifications:
          muteNotifications ?? this.muteNotifications,
      mutedWords: mutedWords ?? this.mutedWords,
      privacyLevel: privacyLevel ?? this.privacyLevel,
    );
  }

  bool get isPublic => privacyLevel == 'public';
  bool get isPrivate => privacyLevel == 'private';
  bool get isRestricted => privacyLevel == 'restricted';
}
