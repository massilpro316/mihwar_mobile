import '../../../../utils/typedefs.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;
  UpdateProfile(this.repository);

  FutureEither<ProfileEntity> call(UpdateProfileParams params) =>
      repository.updateProfile(params);
}
