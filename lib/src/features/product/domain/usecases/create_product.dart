import '../../../../utils/typedefs.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;
  CreateProduct(this.repository);

  FutureEither<ProductEntity> call(CreateProductParams params) =>
      repository.createProduct(params);
}
