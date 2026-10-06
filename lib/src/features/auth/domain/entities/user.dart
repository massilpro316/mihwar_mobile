import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? role;
  final String? phoneNumber;
  final String? grade;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.role,
    this.phoneNumber,
    this.grade,
  });

  factory AppUser.empty() => const AppUser(id: '', email: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  @override
  List<Object?> get props =>
      [id, email, name, photoUrl, role, phoneNumber, grade];
}
