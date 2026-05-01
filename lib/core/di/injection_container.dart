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
import 'package:athletica/features/coach/clients/data/datasources/coach_clients_remote_data_source.dart';
import 'package:athletica/features/coach/clients/data/repositories/coach_clients_repository_impl.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';
import 'package:athletica/features/coach/clients/domain/usecases/get_coach_clients_usecase.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/coach_subscription_cubit.dart';
import 'package:athletica/features/coach/profile/data/datasources/coach_profile_remote_data_source.dart';
import 'package:athletica/features/coach/profile/data/repositories/coach_profile_repository_impl.dart';
import 'package:athletica/features/coach/profile/domain/repositories/coach_profile_repository.dart';
import 'package:athletica/features/coach/profile/domain/usecases/get_coach_profile_usecase.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_cubit.dart';
import 'package:athletica/features/coach/workout_templates/data/datasources/workout_templates_remote_data_source.dart';
import 'package:athletica/features/coach/workout_templates/data/repositories/workout_templates_repository_impl.dart';
import 'package:athletica/features/coach/workout_templates/domain/repositories/workout_templates_repository.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/create_workout_template_day_usecase.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/create_workout_template_item_usecase.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/create_workout_template_usecase.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/get_workout_templates_usecase.dart';
import 'package:athletica/features/coach/workout_templates/presentation/cubits/save_workout_plan_cubit.dart';
import 'package:athletica/features/coach/workout_templates/presentation/cubits/workout_templates_list_cubit.dart';
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
import 'package:athletica/features/profile/presentation/cubits/profile_info_cubit.dart';
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
  sl.registerLazySingleton<CoachProfileRemoteDataSource>(
    () => CoachProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CoachClientsRemoteDataSource>(
    () => CoachClientsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WorkoutTemplatesRemoteDataSource>(
    () => WorkoutTemplatesRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<InfoRepository>(() => InfoRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CoachProfileRepository>(
    () => CoachProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CoachClientsRepository>(
    () => CoachClientsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WorkoutTemplatesRepository>(
    () => WorkoutTemplatesRepositoryImpl(sl()),
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
  sl.registerLazySingleton(() => GetCoachProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetCoachClientsUseCase(sl()));
  sl.registerLazySingleton(() => CreateWorkoutTemplateUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkoutTemplatesUseCase(sl()));
  sl.registerLazySingleton(() => CreateWorkoutTemplateDayUseCase(sl()));
  sl.registerLazySingleton(() => CreateWorkoutTemplateItemUseCase(sl()));

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
  sl.registerLazySingleton(() => ProfileCubit(sl()));
  sl.registerFactory(() => CoachProfileCubit(sl()));
  sl.registerFactory(() => CoachClientsCubit(sl()));
  sl.registerFactory(() => SaveWorkoutPlanCubit(sl(), sl(), sl()));
  sl.registerFactory(() => WorkoutTemplatesListCubit(sl()));
  sl.registerLazySingleton(() => ProfileInfoCubit(sl()));
}
