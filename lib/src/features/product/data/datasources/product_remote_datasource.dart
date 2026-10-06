import '../../../../services/dio_service.dart';
import '../../../../utils/typedefs.dart';
import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  FutureEither<List<ProductModel>> getProducts(int stationId);
  FutureEither<ProductModel> createProduct(CreateProductParams params);
  FutureEither<void> deleteProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final _dio = DioService.instance;

  @override
  FutureEither<List<ProductModel>> getProducts(int stationId) async {
    final result = await _dio.get('/api/employee/stations/$stationId');
    return result.map((response) {
      final data = response.data as Map<String, dynamic>;
      final List<dynamic> products = (data['products'] ?? []) as List<dynamic>;
      return products
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  FutureEither<ProductModel> createProduct(CreateProductParams params) async {
    final result = await _dio.post(
      '/api/employee/products',
      data: {
        'station_id': params.stationId,
        'brand': params.brand,
        'quantity': params.quantity,
        'material_type': params.materialType,
        if (params.quantityUnit != null) 'quantity_unit': params.quantityUnit,
        if (params.creationDate != null) 'creation_date': params.creationDate,
      },
    );
    return result.map((response) {
      final data = response.data as Map<String, dynamic>;
      return ProductModel.fromJson(data['product'] as Map<String, dynamic>);
    });
  }

  @override
  FutureEither<void> deleteProduct(int id) async {
    final result = await _dio.delete('/api/employee/products/$id');
    return result.map((_) {});
  }
}
