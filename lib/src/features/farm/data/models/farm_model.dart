import '../../domain/entities/farm_entity.dart';

int _intFromJson(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

class FarmModel {
  final int id;
  final String name;
  final String? localisation;
  final num? space;
  final String? crop;
  final String? quantity;
  final String? creationDate;
  final String? responsibleName;
  final String? responsiblePhone;

  const FarmModel({
    required this.id,
    required this.name,
    this.localisation,
    this.space,
    this.crop,
    this.quantity,
    this.creationDate,
    this.responsibleName,
    this.responsiblePhone,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: _intFromJson(json['id']),
      name: (json['name'] ?? '').toString(),
      localisation: json['localisation']?.toString(),
      space: json['space'] is num
          ? json['space'] as num
          : num.tryParse(json['space']?.toString() ?? ''),
      crop: json['crop']?.toString(),
      quantity: json['quantity']?.toString(),
      creationDate: json['creation_date']?.toString(),
      responsibleName: json['responsible_name']?.toString(),
      responsiblePhone: json['responsible_phone']?.toString(),
    );
  }

  FarmEntity toEntity() => FarmEntity(
        id: id,
        name: name,
        localisation: localisation,
        space: space,
        crop: crop,
        quantity: quantity,
        creationDate: creationDate,
        responsibleName: responsibleName,
        responsiblePhone: responsiblePhone,
      );
}
