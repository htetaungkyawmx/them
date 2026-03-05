class MatchModel {
  final String id;
  final String userId1;
  final String userId2;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessage;

  MatchModel({
    required this.id,
    required this.userId1,
    required this.userId2,
    this.status = MatchStatus.pending,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessage': lastMessage,
    };
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] ?? '',
      userId1: map['userId1'] ?? '',
      userId2: map['userId2'] ?? '',
      status: MatchStatus.values[map['status'] ?? 0],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.parse(map['lastMessageAt'])
          : null,
      lastMessage: map['lastMessage'],
    );
  }
}

enum MatchStatus {
  pending,   // One user liked, waiting for response
  matched,   // Both users liked
  rejected   // One user rejected
}