import '../../../../services/dio_service.dart';
import '../../../../utils/typedefs.dart';
import '../models/farm_model.dart';

abstract class FarmRemoteDataSource {
  FutureEither<List<FarmModel>> getFarms();
}

class FarmRemoteDataSourceImpl implements FarmRemoteDataSource {
  final _dio = DioService.instance;

  @override
  FutureEither<List<FarmModel>> getFarms() async {
    final result = await _dio.get('/api/employee/farms');
    return result.map((response) {
      final data = response.data as Map<String, dynamic>;
      final List<dynamic> firms =
          (data['firms'] ?? data['farms'] ?? []) as List<dynamic>;
      return firms
          .map((e) => FarmModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}
