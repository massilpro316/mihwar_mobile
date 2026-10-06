import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final int id;
  final String email;
  final String name;
  final String role;
  final String? phoneNumber;
  final String? grade;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.grade,
  });

  @override
  List<Object?> get props => [id, email, name, role, phoneNumber, grade];
}

class UpdateProfileParams extends Equatable {
  final String name;
  final String email;
  final String? phoneNumber;
  final String? grade;

  const UpdateProfileParams({
    required this.name,
    required this.email,
    this.phoneNumber,
    this.grade,
  });

  @override
  List<Object?> get props => [name, email, phoneNumber, grade];
}
