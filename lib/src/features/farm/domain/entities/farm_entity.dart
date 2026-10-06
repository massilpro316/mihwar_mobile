import 'package:equatable/equatable.dart';

class FarmEntity extends Equatable {
  final int id;
  final String name;
  final String? localisation;
  final num? space;
  final String? crop;
  final String? quantity;
  final String? creationDate;

  /// The station (or manager) account that owns the farm.
  final String? responsibleName;

  /// Free text exactly as typed — use [dialablePhone] to call it.
  final String? responsiblePhone;

  const FarmEntity({
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

  /// [responsiblePhone] reduced to digits and "+", or null when there is
  /// nothing to dial ("0661 23 45 67" → "0661234567").
  String? get dialablePhone {
    final digits = responsiblePhone?.replaceAll(RegExp(r'[^0-9+]'), '');
    return (digits == null || digits.isEmpty) ? null : digits;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        localisation,
        space,
        crop,
        quantity,
        creationDate,
        responsibleName,
        responsiblePhone,
      ];
}
