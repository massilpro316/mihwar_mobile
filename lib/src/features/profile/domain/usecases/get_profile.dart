import '../../../../utils/typedefs.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;
  GetProfile(this.repository);

  FutureEither<ProfileEntity> call() => repository.getProfile();
}
