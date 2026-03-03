class ChatRoomModel {
  final String id;
  final List<String> participantIds;
  final Map<String, dynamic> participants;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final bool isGroup;
  final String? groupName;
  final String? groupImage;

  ChatRoomModel({
    required this.id,
    required this.participantIds,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    this.isGroup = false,
    this.groupName,
    this.groupImage,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] ?? '',
      participantIds: List<String>.from(json['participantIds'] ?? []),
      participants: json['participants'] ?? {},
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'], '')
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isGroup: json['isGroup'] ?? false,
      groupName: json['groupName'],
      groupImage: json['groupImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'participants': participants,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
      'isGroup': isGroup,
      'groupName': groupName,
      'groupImage': groupImage,
    };
  }
}