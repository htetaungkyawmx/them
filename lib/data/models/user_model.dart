class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? bio;
  final List<String> photos;
  final List<String> interests;
  final int? age;
  final String? gender;
  final String? lookingFor;
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.bio,
    this.photos = const [],
    this.interests = const [],
    this.age,
    this.gender,
    this.lookingFor,
    this.latitude,
    this.longitude,
    this.isVerified = false,
    required this.createdAt,
    required this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'photos': photos,
      'interests': interests,
      'age': age,
      'gender': gender,
      'lookingFor': lookingFor,
      'latitude': latitude,
      'longitude': longitude,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      bio: map['bio'],
      photos: List<String>.from(map['photos'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      age: map['age'],
      gender: map['gender'],
      lookingFor: map['lookingFor'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      isVerified: map['isVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastActive: DateTime.parse(map['lastActive'] ?? DateTime.now().toIso8601String()),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? bio,
    List<String>? photos,
    List<String>? interests,
    int? age,
    String? gender,
    String? lookingFor,
    double? latitude,
    double? longitude,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      interests: interests ?? this.interests,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      lookingFor: lookingFor ?? this.lookingFor,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}