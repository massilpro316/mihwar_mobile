import '../../../../utils/typedefs.dart';
import '../entities/farm_entity.dart';

abstract class FarmRepository {
  FutureEither<List<FarmEntity>> getFarms();
}
