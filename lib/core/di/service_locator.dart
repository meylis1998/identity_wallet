import 'package:get_it/get_it.dart';
import '../services/secure_storage_service.dart';
import '../services/biometric_service.dart';
import '../../features/credentials/data/credential_repository.dart';
import '../../features/credentials/presentation/bloc/credential_bloc.dart';
import '../../features/did/data/did_repository.dart';
import '../../features/did/presentation/bloc/identity_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  sl.registerLazySingleton<BiometricService>(
    () => BiometricService(),
  );

  sl.registerLazySingleton<CredentialRepository>(
    () => CredentialRepository(sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<DIDRepository>(
    () => DIDRepository(sl<SecureStorageService>()),
  );

  sl.registerFactory<CredentialBloc>(
    () => CredentialBloc(sl<CredentialRepository>()),
  );

  sl.registerFactory<IdentityBloc>(
    () => IdentityBloc(sl<DIDRepository>()),
  );
}

Future<void> resetServiceLocator() async {
  await sl.reset();
}
