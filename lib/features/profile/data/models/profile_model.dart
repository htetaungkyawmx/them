class ProfileModel {
  final String id;
  final String displayName;
  final String? bio;
  final int? age;
  final String? gender;
  final String? occupation;
  final String? education;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<String> photos;
  final List<String> interests;
  final Map<String, dynamic>? preferences;
  final int followers;
  final int following;
  final int matches;
  final bool isVerified;
  final bool isOnline;
  final DateTime lastActive;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.displayName,
    this.bio,
    this.age,
    this.gender,
    this.occupation,
    this.education,
    this.location,
    this.latitude,
    this.longitude,
    this.photos = const [],
    this.interests = const [],
    this.preferences,
    this.followers = 0,
    this.following = 0,
    this.matches = 0,
    this.isVerified = false,
    this.isOnline = false,
    required this.lastActive,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      bio: json['bio'],
      age: json['age'],
      gender: json['gender'],
      occupation: json['occupation'],
      education: json['education'],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      photos: List<String>.from(json['photos'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      preferences: json['preferences'],
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      matches: json['matches'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastActive: DateTime.parse(json['lastActive'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'bio': bio,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'education': education,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
      'interests': interests,
      'preferences': preferences,
      'followers': followers,
      'following': following,
      'matches': matches,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastActive': lastActive.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? displayName,
    String? bio,
    int? age,
    String? gender,
    String? occupation,
    String? education,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? photos,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    int? followers,
    int? following,
    int? matches,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastActive,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photos: photos ?? this.photos,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      matches: matches ?? this.matches,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}