import '../../domain/entities/profile_entity.dart';

int _intFromJson(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

class ProfileModel {
  final int id;
  final String email;
  final String name;
  final String role;
  final String? phoneNumber;
  final String? grade;

  const ProfileModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.grade,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: _intFromJson(json['id']),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      phoneNumber: json['phone_number']?.toString(),
      grade: json['grade']?.toString(),
    );
  }

  ProfileEntity toEntity() => ProfileEntity(
        id: id,
        email: email,
        name: name,
        role: role,
        phoneNumber: phoneNumber,
        grade: grade,
      );
}
