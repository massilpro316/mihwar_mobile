import '../../../../services/dio_service.dart';
import '../../../../utils/typedefs.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  FutureEither<List<TaskModel>> getTasks({int? stationId});

  /// `POST /api/tasks/:id/status`. Returns the whole response body:
  /// `{ assignment, product, dose, message }`.
  FutureEither<Map<String, dynamic>> updateStatus(
    int taskId,
    Map<String, dynamic> body,
  );

  /// `PATCH /api/tasks/:id/status` — note only, on a closed assignment.
  /// Returns the updated `assignment` row.
  FutureEither<Map<String, dynamic>> saveNote(int taskId, String note);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final _dio = DioService.instance;

  @override
  FutureEither<List<TaskModel>> getTasks({int? stationId}) async {
    // `/api/tasks` already scopes to the caller: for an Agriculture session it
    // returns that employee's own assignments and nobody else's. `station_id`
    // narrows the same list to one farm.
    final query = stationId == null ? '' : '?station_id=$stationId';
    final result = await _dio.get('/api/tasks$query');

    return result.map((response) {
      final data = response.data as Map<String, dynamic>;
      final list = (data['tasks'] ?? []) as List<dynamic>;
      return list
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  FutureEither<Map<String, dynamic>> updateStatus(
    int taskId,
    Map<String, dynamic> body,
  ) async {
    final result = await _dio.post('/api/tasks/$taskId/status', data: body);
    return result.map((response) {
      final data = response.data;
      return data is Map ? Map<String, dynamic>.from(data) : const {};
    });
  }

  @override
  FutureEither<Map<String, dynamic>> saveNote(int taskId, String note) async {
    final result =
        await _dio.patch('/api/tasks/$taskId/status', data: {'note': note});
    return result.map(_assignment);
  }

  static Map<String, dynamic> _assignment(dynamic response) {
    final data = response.data;
    if (data is Map && data['assignment'] is Map) {
      return Map<String, dynamic>.from(data['assignment'] as Map);
    }
    return const {};
  }
}
