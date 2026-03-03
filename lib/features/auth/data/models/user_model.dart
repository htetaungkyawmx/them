class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String? bio;
  final int? age;
  final String? gender;
  final String? occupation;
  final String? education;
  final List<String> photos;
  final List<String> interests;
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final bool isOnline;
  final DateTime lastActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.bio,
    this.age,
    this.gender,
    this.occupation,
    this.education,
    this.photos = const [],
    this.interests = const [],
    this.latitude,
    this.longitude,
    this.isVerified = false,
    this.isOnline = false,
    required this.lastActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      phoneNumber: json['phoneNumber'],
      bio: json['bio'],
      age: json['age'],
      gender: json['gender'],
      occupation: json['occupation'],
      education: json['education'],
      photos: List<String>.from(json['photos'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastActive: DateTime.parse(json['lastActive'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'education': education,
      'photos': photos,
      'interests': interests,
      'latitude': latitude,
      'longitude': longitude,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastActive': lastActive.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    int? age,
    String? gender,
    String? occupation,
    String? education,
    List<String>? photos,
    List<String>? interests,
    double? latitude,
    double? longitude,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      photos: photos ?? this.photos,
      interests: interests ?? this.interests,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}