import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
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

  const ProductEntity({
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

  @override
  List<Object?> get props => [id, stationId, materialType, brand, quantity];
}

class CreateProductParams extends Equatable {
  final int stationId;
  final String brand;
  final double quantity;
  final String materialType;
  final String? quantityUnit;
  final String? creationDate;

  const CreateProductParams({
    required this.stationId,
    required this.brand,
    required this.quantity,
    required this.materialType,
    this.quantityUnit,
    this.creationDate,
  });

  @override
  List<Object?> get props => [stationId, brand, quantity, materialType];
}
