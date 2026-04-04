import '../core/constants/app_enums.dart';

/// User Model - Represents a user in the system
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatar;
  final UserStatus status;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime? lastSeen;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.status = UserStatus.online,
    this.isApproved = false,
    required this.createdAt,
    this.lastSeen,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'avatar': avatar,
      'status': status.value,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  // Convert from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    final createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
        : DateTime.now();

    final rawRole = json['role']?.toString() ?? 'personnel';

    return User(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: UserRoleExtension.fromString(rawRole),
      avatar: json['avatar'] as String?,
      status: UserStatusExtension.fromString(json['status'] as String? ?? 'offline'),
      isApproved: (json['isApproved'] ?? json['is_approved']) as bool? ?? false,
      createdAt: createdAt,
      lastSeen: json['lastSeen'] != null ? DateTime.tryParse(json['lastSeen'] as String) : null,
    );
  }

  // Copy with method for updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatar,
    UserStatus? status,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: ${role.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
