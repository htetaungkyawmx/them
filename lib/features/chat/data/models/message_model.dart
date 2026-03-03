enum MessageType { text, image, video, audio }
enum MessageStatus { sending, sent, delivered, read, failed }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final bool isMe;
  final String? mediaUrl;
  final Duration? mediaDuration;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    required this.isMe,
    this.mediaUrl,
    this.mediaDuration,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderId = json['senderId'] ?? '';
    return MessageModel(
      id: json['id'] ?? '',
      senderId: senderId,
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      type: _messageTypeFromString(json['type']),
      status: _messageStatusFromString(json['status']),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isMe: senderId == currentUserId,
      mediaUrl: json['mediaUrl'],
      mediaDuration: json['mediaDuration'] != null
          ? Duration(seconds: json['mediaDuration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'mediaUrl': mediaUrl,
      'mediaDuration': mediaDuration?.inSeconds,
    };
  }

  static MessageType _messageTypeFromString(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _messageStatusFromString(String status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }
}