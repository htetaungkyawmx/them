class ParticipantModel {
  final String id;
  final String name;
  final String role;
  final bool isAudioEnabled;
  final bool isVideoEnabled;
  final bool isSpeaking;

  ParticipantModel({
    required this.id,
    required this.name,
    this.role = 'Participant',
    this.isAudioEnabled = true,
    this.isVideoEnabled = true,
    this.isSpeaking = false,
  });

  ParticipantModel copyWith({
    String? id,
    String? name,
    String? role,
    bool? isAudioEnabled,
    bool? isVideoEnabled,
    bool? isSpeaking,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

class RoomModel {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final List<String> participants;
  final bool isActive;
  final int maxParticipants;

  RoomModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.participants,
    this.isActive = true,
    this.maxParticipants = 10,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'participants': participants,
      'isActive': isActive,
      'maxParticipants': maxParticipants,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      participants: List<String>.from(map['participants'] ?? []),
      isActive: map['isActive'] ?? true,
      maxParticipants: map['maxParticipants'] ?? 10,
    );
  }
}