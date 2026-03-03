class UserProfileModel {
  final String id;
  final String displayName;
  final int age;
  final String gender;
  final String? bio;
  final List<String> photos;
  final List<String> interests;
  final String? occupation;
  final String? education;
  final double distance; // in km
  final bool isVerified;
  final bool isOnline;
  final DateTime lastActive;
  final double? latitude;
  final double? longitude;

  UserProfileModel({
    required this.id,
    required this.displayName,
    required this.age,
    required this.gender,
    this.bio,
    required this.photos,
    required this.interests,
    this.occupation,
    this.education,
    required this.distance,
    this.isVerified = false,
    this.isOnline = false,
    required this.lastActive,
    this.latitude,
    this.longitude,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      bio: json['bio'],
      photos: List<String>.from(json['photos'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      occupation: json['occupation'],
      education: json['education'],
      distance: (json['distance'] ?? 0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastActive: DateTime.parse(json['lastActive'] ?? DateTime.now().toIso8601String()),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

class LikeModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final LikeType type;
  final DateTime timestamp;
  final bool isMutual;

  LikeModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.timestamp,
    this.isMutual = false,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] ?? '',
      fromUserId: json['fromUserId'] ?? '',
      toUserId: json['toUserId'] ?? '',
      type: LikeType.values.firstWhere(
            (e) => e.toString() == 'LikeType.${json['type']}',
        orElse: () => LikeType.like,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isMutual: json['isMutual'] ?? false,
    );
  }
}

enum LikeType { like, superLike, pass }