import '../../../../services/dio_service.dart';
import '../../../../utils/typedefs.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  FutureEither<ProfileModel> getProfile();
  FutureEither<ProfileModel> updateProfile(UpdateProfileParams params);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final _dio = DioService.instance;

  @override
  FutureEither<ProfileModel> getProfile() async {
    final result = await _dio.get(
      '/api/auth/me',
    );
    return result.map((response) {
      final data = response.data as Map<String, dynamic>;
      return ProfileModel.fromJson(data['user'] as Map<String, dynamic>);
    });
  }

  @override
  FutureEither<ProfileModel> updateProfile(UpdateProfileParams params) async {
    final result = await _dio.patch(
      '/api/employee/profile',
      data: {
        'name': params.name,
        'email': params.email,
        if (params.phoneNumber != null) 'phone_number': params.phoneNumber,
        if (params.grade != null) 'grade': params.grade,
      },
    );
    return result.map((response) {
      final data = response.data as Map<String, dynamic>;
      return ProfileModel.fromJson(data['user'] as Map<String, dynamic>);
    });
  }
}
