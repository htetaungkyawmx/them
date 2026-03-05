class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.deliveredAt,
    this.readAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.index,
      'status': status.index,
      'timestamp': timestamp.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values[map['type'] ?? 0],
      status: MessageStatus.values[map['status'] ?? 0],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.parse(map['deliveredAt'])
          : null,
      readAt: map['readAt'] != null
          ? DateTime.parse(map['readAt'])
          : null,
    );
  }
}

enum MessageType { text, image, voice }
enum MessageStatus { sent, delivered, read }