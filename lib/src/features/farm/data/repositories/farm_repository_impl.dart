import '../../domain/entities/farm_entity.dart';
import '../../domain/repositories/farm_repository.dart';
import '../../../../utils/typedefs.dart';
import '../datasources/farm_remote_datasource.dart';

class FarmRepositoryImpl implements FarmRepository {
  final FarmRemoteDataSource _remoteDataSource;
  const FarmRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<List<FarmEntity>> getFarms() async {
    final result = await _remoteDataSource.getFarms();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }
}
