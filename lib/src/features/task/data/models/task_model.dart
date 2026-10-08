import '../../domain/entities/task_entity.dart';

/// `{ material_type, brand, quantity, quantity_unit, creation_date }`, as
/// `GET /api/tasks` and `POST /api/tasks/:id/status` send it.
TaskProductRecord? productRecordFromJson(dynamic json) {
  if (json is! Map) return null;
  final quantity = json['quantity']?.toString() ?? '';
  final material = json['material_type']?.toString() ?? '';
  if (quantity.isEmpty && material.isEmpty) return null;
  return TaskProductRecord(
    materialType: material,
    brand: json['brand']?.toString() ?? '',
    quantity: quantity,
    quantityUnit: json['quantity_unit']?.toString(),
    date: DateTime.tryParse(json['creation_date']?.toString() ?? ''),
  );
}

/// `{ quantity, creation_date }`.
TaskDoseRecord? doseRecordFromJson(dynamic json) {
  if (json is! Map) return null;
  final quantity = json['quantity']?.toString() ?? '';
  if (quantity.isEmpty) return null;
  return TaskDoseRecord(
    quantity: quantity,
    date: DateTime.tryParse(json['creation_date']?.toString() ?? ''),
  );
}

int _intFromJson(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

class TaskModel {
  final int id;
  final int stationId;
  final String title;
  final String? description;
  final String? taskType;
  final String? status;
  final String? dueDate;
  final String? createdAt;
  final String? completedAt;
  final String? stationName;
  final String? createdByName;
  final String? note;
  final String? cancelledAt;
  final String? cancelReason;
  final String? cancelledByName;
  final String? completedByName;
  final String? completionNote;
  final bool doneByEmployee;
  final bool doneByStation;
  final TaskProductRecord? recordedProduct;
  final TaskDoseRecord? recordedDose;

  const TaskModel({
    required this.id,
    required this.stationId,
    required this.title,
    this.description,
    this.taskType,
    this.status,
    this.dueDate,
    this.createdAt,
    this.completedAt,
    this.stationName,
    this.createdByName,
    this.note,
    this.cancelledAt,
    this.cancelReason,
    this.cancelledByName,
    this.completedByName,
    this.completionNote,
    this.doneByEmployee = true,
    this.doneByStation = false,
    this.recordedProduct,
    this.recordedDose,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: _intFromJson(json['id']),
      stationId: _intFromJson(json['station_id']),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      taskType: json['task_type']?.toString(),
      status: json['status']?.toString(),
      dueDate: json['due_date']?.toString(),
      createdAt: json['created_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      stationName: json['station_name']?.toString(),
      createdByName: json['created_by_name']?.toString(),
      note: json['note']?.toString(),
      cancelledAt: json['cancelled_at']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
      cancelledByName: json['cancelled_by_name']?.toString(),
      completedByName: json['completed_by_name']?.toString(),
      completionNote: json['completion_note']?.toString(),
      doneByEmployee: json['done_by_employee'] != false,
      doneByStation: json['done_by_station'] == true,
      recordedProduct: productRecordFromJson(json['product']),
      recordedDose: doseRecordFromJson(json['dose']),
    );
  }

  TaskEntity toEntity() => TaskEntity(
        id: id,
        stationId: stationId,
        title: title,
        description: description,
        taskType: TaskType.fromApi(taskType),
        status: TaskStatus.fromApi(status),
        dueDate: dueDate,
        createdAt: createdAt,
        completedAt: completedAt,
        stationName: stationName,
        createdByName: createdByName,
        note: note,
        cancelledAt: cancelledAt,
        cancelReason: cancelReason,
        cancelledByName: cancelledByName,
        completedByName: completedByName,
        completionNote: completionNote,
        doneByEmployee: doneByEmployee,
        doneByStation: doneByStation,
        recordedProduct: recordedProduct,
        recordedDose: recordedDose,
      );
}
