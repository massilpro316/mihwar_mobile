import '../../domain/entities/product_entity.dart';

double _doubleFromJson(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int _intFromJson(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

class ProductModel {
  final int id;
  final int stationId;
  final int agricultureId;
  final String materialType;
  final String brand;
  final double quantity;
  final String? quantityUnit;
  final String? creationDate;
  final String? employeeName;
  final String? stationName;

  const ProductModel({
    required this.id,
    required this.stationId,
    required this.agricultureId,
    required this.materialType,
    required this.brand,
    required this.quantity,
    this.quantityUnit,
    this.creationDate,
    this.employeeName,
    this.stationName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _intFromJson(json['id']),
      stationId: _intFromJson(json['station_id']),
      agricultureId: _intFromJson(json['agriculture_id']),
      materialType: (json['material_type'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      quantity: _doubleFromJson(json['quantity']),
      quantityUnit: json['quantity_unit']?.toString(),
      creationDate: json['creation_date']?.toString(),
      employeeName: json['employee_name']?.toString(),
      stationName: json['station_name']?.toString(),
    );
  }

  ProductEntity toEntity() => ProductEntity(
        id: id,
        stationId: stationId,
        agricultureId: agricultureId,
        materialType: materialType,
        brand: brand,
        quantity: quantity,
        quantityUnit: quantityUnit,
        creationDate: creationDate,
        employeeName: employeeName,
        stationName: stationName,
      );
}
