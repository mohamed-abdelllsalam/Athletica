import 'package:athletica/core/network/api_client.dart';
import 'package:athletica/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:athletica/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';
import 'package:athletica/features/auth/domain/usecases/login_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/logout_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_trainer_usecase.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  // Network
  ApiClient.instance.init();
  sl.registerLazySingleton(() => ApiClient.instance.dio);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterClientUseCase(sl()));
  sl.registerLazySingleton(() => RegisterTrainerUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Cubits — registered as factory so each screen gets a fresh instance
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerClientUseCase: sl(),
      registerTrainerUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );
}
