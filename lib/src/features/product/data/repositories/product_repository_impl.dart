import 'package:mihwar/src/features/product/data/models/product_model.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../../utils/typedefs.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  const ProductRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<List<ProductEntity>> getProducts(int stationId) async {
    final result = await _remoteDataSource.getProducts(stationId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  FutureEither<ProductEntity> createProduct(CreateProductParams params) async {
    final result = await _remoteDataSource.createProduct(params);
    return result.map((m) => m.toEntity());
  }

  @override
  FutureEither<void> deleteProduct(int id) =>
      _remoteDataSource.deleteProduct(id);
}
