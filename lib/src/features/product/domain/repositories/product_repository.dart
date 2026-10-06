import '../../../../utils/typedefs.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  FutureEither<List<ProductEntity>> getProducts(int stationId);
  FutureEither<ProductEntity> createProduct(CreateProductParams params);
  FutureEither<void> deleteProduct(int id);
}
