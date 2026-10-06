import '../../../../services/dio_service.dart';
import '../../../../utils/typedefs.dart';
import '../../domain/entities/activity_entity.dart';
import '../models/activity_model.dart';

abstract class ActivityRemoteDataSource {
  FutureEither<List<ActivityModel>> getActivities(int stationId);
  FutureEither<ActivityModel> createActivity(CreateActivityParams params);
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final _dio = DioService.instance;

  @override
  FutureEither<List<ActivityModel>> getActivities(int stationId) async {
    final result = await _dio.get('/api/employee/stations/$stationId');
    return result.map((response) {
      final data = response.data as Map<String, dynamic>;
      final List<dynamic> list =
          (data['agricultures'] ?? data['employees'] ?? []) as List<dynamic>;
      return list
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  FutureEither<ActivityModel> createActivity(
      CreateActivityParams params) async {
    final result = await _dio.post(
      '/api/employee/create',
      data: {
        'station_id': params.stationId,
        'name': params.name,
        'email': params.email,
        'password': params.password,
        if (params.phoneNumber != null) 'phone_number': params.phoneNumber,
        if (params.grade != null) 'grade': params.grade,
      },
    );
    return result.map((response) {
      final data = response.data as Map<String, dynamic>;
      return ActivityModel.fromJson(data['user'] as Map<String, dynamic>);
    });
  }
}
