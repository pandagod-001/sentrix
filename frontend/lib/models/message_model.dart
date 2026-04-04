import '../core/constants/app_enums.dart';

/// Message Model - Represents a single message
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type; // sent or received

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.value,
    };
  }

  // Convert from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    final senderId = (json['senderId'] ?? json['sender'] ?? '').toString();
    final rawTimestamp = (json['timestamp'] ?? '').toString();

    return Message(
      id: (json['id'] ?? '').toString(),
      senderId: senderId,
      senderName: (json['senderName'] ?? senderId).toString(),
      text: (json['text'] ?? json['message'] ?? '').toString(),
      timestamp: DateTime.tryParse(rawTimestamp) ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      type: MessageTypeExtension.fromString(json['type'] as String? ?? 'received'),
    );
  }

  // Copy with method
  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, from: $senderName, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
