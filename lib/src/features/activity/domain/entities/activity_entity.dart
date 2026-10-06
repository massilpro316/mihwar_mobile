import 'package:equatable/equatable.dart';

class ActivityEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? grade;
  final String? assignedDate;

  const ActivityEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.grade,
    this.assignedDate,
  });

  @override
  List<Object?> get props => [id, email, name];
}

class CreateActivityParams extends Equatable {
  final int stationId;
  final String name;
  final String email;
  final String password;
  final String? phoneNumber;
  final String? grade;

  const CreateActivityParams({
    required this.stationId,
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.grade,
  });

  @override
  List<Object?> get props => [stationId, email];
}
