import 'dart:convert';

class UserProfile {
  final String name;
  final String address;
  final String hobbies;
  final int age;
  final String gender;
  final String? photoPath;

  const UserProfile({
    this.name = '',
    this.address = '',
    this.hobbies = '',
    this.age = 0,
    this.gender = '',
    this.photoPath,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      hobbies: json['hobbies'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      photoPath: json['photo_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'hobbies': hobbies,
      'age': age,
      'gender': gender,
      'photo_path': photoPath,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserProfile.fromJsonString(String jsonStr) {
    try {
      return UserProfile.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile();
    }
  }

  UserProfile copyWith({
    String? name,
    String? address,
    String? hobbies,
    int? age,
    String? gender,
    String? photoPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      address: address ?? this.address,
      hobbies: hobbies ?? this.hobbies,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
