/// Extended Models for SENTRIX Chat System
class ChatModel {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final bool isActive;

  ChatModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.isActive = true,
  });

  ChatModel copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isMuted,
    bool? isPinned,
    bool? isActive,
  }) =>
      ChatModel(
        id: id ?? this.id,
        participantId: participantId ?? this.participantId,
        participantName: participantName ?? this.participantName,
        participantAvatar: participantAvatar ?? this.participantAvatar,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        unreadCount: unreadCount ?? this.unreadCount,
        isMuted: isMuted ?? this.isMuted,
        isPinned: isPinned ?? this.isPinned,
        isActive: isActive ?? this.isActive,
      );
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String messageType; // 'text', 'image', 'document'
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.messageType = 'text',
    this.metadata,
  });

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? messageType,
    Map<String, dynamic>? metadata,
  }) =>
      MessageModel(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
        messageType: messageType ?? this.messageType,
        metadata: metadata ?? this.metadata,
      );
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeenAt,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? status,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeenAt,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        status: status ?? this.status,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isOnline: isOnline ?? this.isOnline,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
        createdAt: createdAt ?? this.createdAt,
      );
}

class PersonnelModel {
  final String id;
  final String userId;
  final String rank;
  final String department;
  final String unit;
  final String clearanceLevel;
  final DateTime? lastTraining;
  final bool isActive;
  final String? specialization;

  PersonnelModel({
    required this.id,
    required this.userId,
    required this.rank,
    required this.department,
    required this.unit,
    required this.clearanceLevel,
    this.lastTraining,
    this.isActive = true,
    this.specialization,
  });

  PersonnelModel copyWith({
    String? id,
    String? userId,
    String? rank,
    String? department,
    String? unit,
    String? clearanceLevel,
    DateTime? lastTraining,
    bool? isActive,
    String? specialization,
  }) =>
      PersonnelModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        rank: rank ?? this.rank,
        department: department ?? this.department,
        unit: unit ?? this.unit,
        clearanceLevel: clearanceLevel ?? this.clearanceLevel,
        lastTraining: lastTraining ?? this.lastTraining,
        isActive: isActive ?? this.isActive,
        specialization: specialization ?? this.specialization,
      );
}

class DependentModel {
  final String id;
  final String userId;
  final String guardianId;
  final String guardianName;
  final String relationship;
  final DateTime dateOfBirth;
  final String status;

  DependentModel({
    required this.id,
    required this.userId,
    required this.guardianId,
    required this.guardianName,
    required this.relationship,
    required this.dateOfBirth,
    required this.status,
  });

  DependentModel copyWith({
    String? id,
    String? userId,
    String? guardianId,
    String? guardianName,
    String? relationship,
    DateTime? dateOfBirth,
    String? status,
  }) =>
      DependentModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        guardianId: guardianId ?? this.guardianId,
        guardianName: guardianName ?? this.guardianName,
        relationship: relationship ?? this.relationship,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        status: status ?? this.status,
      );
}

class QRDataModel {
  final String id;
  final String userId;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final int scanCount;

  QRDataModel({
    required this.id,
    required this.userId,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
    this.scanCount = 0,
  });

  QRDataModel copyWith({
    String? id,
    String? userId,
    String? code,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    int? scanCount,
  }) =>
      QRDataModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        code: code ?? this.code,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
        isActive: isActive ?? this.isActive,
        scanCount: scanCount ?? this.scanCount,
      );
}

class QRScanResultModel {
  final String id;
  final String scannedBy;
  final String qrCode;
  final DateTime scanTime;
  final bool success;
  final String? scannedUserId;
  final Map<String, dynamic>? userData;

  QRScanResultModel({
    required this.id,
    required this.scannedBy,
    required this.qrCode,
    required this.scanTime,
    required this.success,
    this.scannedUserId,
    this.userData,
  });

  QRScanResultModel copyWith({
    String? id,
    String? scannedBy,
    String? qrCode,
    DateTime? scanTime,
    bool? success,
    String? scannedUserId,
    Map<String, dynamic>? userData,
  }) =>
      QRScanResultModel(
        id: id ?? this.id,
        scannedBy: scannedBy ?? this.scannedBy,
        qrCode: qrCode ?? this.qrCode,
        scanTime: scanTime ?? this.scanTime,
        success: success ?? this.success,
        scannedUserId: scannedUserId ?? this.scannedUserId,
        userData: userData ?? this.userData,
      );
}
