enum NotificationType {
  like,
  match,
  message,
  superLike,
  system
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: _notificationTypeFromString(json['type']),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static NotificationType _notificationTypeFromString(String type) {
    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'match':
        return NotificationType.match;
      case 'message':
        return NotificationType.message;
      case 'superLike':
        return NotificationType.superLike;
      default:
        return NotificationType.system;
    }
  }
}