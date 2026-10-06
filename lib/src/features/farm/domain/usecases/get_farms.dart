import '../../../../utils/typedefs.dart';
import '../entities/farm_entity.dart';
import '../repositories/farm_repository.dart';

class GetFarms {
  final FarmRepository repository;
  GetFarms(this.repository);

  FutureEither<List<FarmEntity>> call() => repository.getFarms();
}
