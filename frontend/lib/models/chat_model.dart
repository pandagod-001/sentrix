import '../core/constants/app_enums.dart';

/// Chat Model - Represents a 1-on-1 conversation
class Chat {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final ChatStatus status;
  final bool isMuted;

  Chat({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.status = ChatStatus.active,
    this.isMuted = false,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'participantAvatar': participantAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'status': status.value,
      'isMuted': isMuted,
    };
  }

  // Convert from JSON
  factory Chat.fromJson(Map<String, dynamic> json) {
    final rawTimestamp = json['lastMessageTime'] ?? json['last_message_time'];
    final lastMessageTime = rawTimestamp is String
        ? DateTime.tryParse(rawTimestamp) ?? DateTime.now()
        : DateTime.now();

    return Chat(
      id: (json['id'] ?? '').toString(),
      participantId: (json['participantId'] ?? json['participant_id'] ?? json['id'] ?? '').toString(),
      participantName: (json['participantName'] ?? json['name'] ?? 'Unknown').toString(),
      participantAvatar: json['participantAvatar'] as String?,
      lastMessage: (json['lastMessage'] ?? json['last_message'] ?? '').toString(),
      lastMessageTime: lastMessageTime,
      unreadCount: json['unreadCount'] as int? ?? 0,
      status: ChatStatusExtension.fromString(json['status'] as String? ?? 'active'),
      isMuted: json['isMuted'] as bool? ?? false,
    );
  }

  // Copy with method
  Chat copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    ChatStatus? status,
    bool? isMuted,
  }) {
    return Chat(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  String toString() {
    return 'Chat(id: $id, participant: $participantName, lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chat && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
