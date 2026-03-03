enum MatchStatus { pending, matched, rejected }

class MatchModel {
  final String id;
  final String userId;
  final String targetUserId;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? matchedAt;

  MatchModel({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.status,
    required this.createdAt,
    this.matchedAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      targetUserId: json['targetUserId'] ?? '',
      status: _matchStatusFromString(json['status']),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      matchedAt: json['matchedAt'] != null
          ? DateTime.parse(json['matchedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetUserId': targetUserId,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'matchedAt': matchedAt?.toIso8601String(),
    };
  }

  static MatchStatus _matchStatusFromString(String status) {
    switch (status) {
      case 'pending':
        return MatchStatus.pending;
      case 'matched':
        return MatchStatus.matched;
      case 'rejected':
        return MatchStatus.rejected;
      default:
        return MatchStatus.pending;
    }
  }
}