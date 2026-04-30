import 'package:athletica/core/network/api_client.dart';
import 'package:athletica/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:athletica/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';
import 'package:athletica/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/login_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/logout_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/mark_profile_complete_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_trainer_usecase.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/coach_subscription_cubit.dart';
import 'package:athletica/features/complete_profile/presentation/cubits/complete_profile_cubit.dart';
import 'package:athletica/features/info/data/datasources/info_remote_data_source.dart';
import 'package:athletica/features/info/data/repositories/info_repository_impl.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';
import 'package:athletica/features/info/domain/usecases/get_client_intake_answers_usecase.dart';
import 'package:athletica/features/info/domain/usecases/get_intake_questions_usecase.dart';
import 'package:athletica/features/info/domain/usecases/submit_intake_answers_usecase.dart';
import 'package:athletica/features/info/presentation/cubits/info_cubit.dart';
import 'package:athletica/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:athletica/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';
import 'package:athletica/features/profile/domain/usecases/get_client_profile_usecase.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/splash/presentation/cubits/splash_cubit.dart';
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
  sl.registerLazySingleton<InfoRemoteDataSource>(
    () => InfoRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<InfoRepository>(
    () => InfoRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterClientUseCase(sl()));
  sl.registerLazySingleton(() => RegisterTrainerUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => MarkProfileCompleteUseCase(sl()));
  sl.registerLazySingleton(() => GetIntakeQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitIntakeAnswersUseCase(sl()));
  sl.registerLazySingleton(() => GetClientIntakeAnswersUseCase(sl()));
  sl.registerLazySingleton(() => GetClientProfileUseCase(sl()));

  // Cubits — factory so each screen gets a fresh instance
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerClientUseCase: sl(),
      registerTrainerUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthStatusUseCase: sl(),
    ),
  );
  sl.registerFactory(() => SplashCubit(sl()));
  sl.registerFactory(() => CompleteProfileCubit(sl()));
  sl.registerFactory(() => CoachSubscriptionCubit(sl()));
  sl.registerFactory(() => InfoCubit(sl(), sl()));
  sl.registerFactory(() => ProfileCubit(sl()));
}
