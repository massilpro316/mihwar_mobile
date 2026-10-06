import '../../domain/entities/activity_entity.dart';

int _intFromJson(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

class ActivityModel {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? grade;
  final String? assignedDate;

  const ActivityModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.grade,
    this.assignedDate,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: _intFromJson(json['id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: json['phone_number']?.toString(),
      grade: json['grade']?.toString(),
      assignedDate: json['assigned_date']?.toString(),
    );
  }

  ActivityEntity toEntity() => ActivityEntity(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        grade: grade,
        assignedDate: assignedDate,
      );
}
