import '../../../../utils/typedefs.dart';
import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;
  DeleteProduct(this.repository);

  FutureEither<void> call(int id) => repository.deleteProduct(id);
}
