import '../../../../utils/typedefs.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;
  GetProducts(this.repository);

  FutureEither<List<ProductEntity>> call(int stationId) =>
      repository.getProducts(stationId);
}
