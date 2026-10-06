import 'package:mihwar/src/features/profile/data/models/profile_model.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../utils/typedefs.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  const ProfileRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<ProfileEntity> getProfile() async {
    final result = await _remoteDataSource.getProfile();
    return result.map((m) => m.toEntity());
  }

  @override
  FutureEither<ProfileEntity> updateProfile(UpdateProfileParams params) async {
    final result = await _remoteDataSource.updateProfile(params);
    return result.map((m) => m.toEntity());
  }
}
