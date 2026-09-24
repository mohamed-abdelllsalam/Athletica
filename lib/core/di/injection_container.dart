import 'package:athletica/core/network/api_client.dart';
import 'package:athletica/features/assigned/data/datasources/assigned_remote_data_source.dart';
import 'package:athletica/features/assigned/data/repositories/assigned_repository_impl.dart';
import 'package:athletica/features/assigned/domain/repositories/assigned_repository.dart';
import 'package:athletica/features/assigned/domain/usecases/assigned_usecases.dart';
import 'package:athletica/features/assigned/presentation/cubits/assigned_cubit.dart';
import 'package:athletica/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:athletica/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';
import 'package:athletica/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/check_client_profile_completion_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/confirm_password_reset_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/login_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/logout_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/mark_profile_complete_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/register_trainer_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:athletica/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/check_ins/data/datasources/check_ins_remote_data_source.dart';
import 'package:athletica/features/check_ins/data/repositories/check_ins_repository_impl.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';
import 'package:athletica/features/check_ins/domain/usecases/assign_check_in_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_check_in_questions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_check_ins_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_checkin_pending_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_client_submission_detail_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_client_submissions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_coach_submission_detail_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_coach_submissions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/save_check_in_questions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/save_check_in_response_usecase.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_in_history_cubit.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_in_submission_cubit.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:athletica/features/chat/data/realtime/ably_chat_realtime_gateway.dart';
import 'package:athletica/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:athletica/features/chat/domain/realtime/chat_realtime_gateway.dart';
import 'package:athletica/features/chat/domain/repositories/chat_repository.dart';
import 'package:athletica/features/chat/domain/usecases/get_chat_conversations_usecase.dart';
import 'package:athletica/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:athletica/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:athletica/features/chat/domain/usecases/send_first_chat_message_usecase.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:athletica/features/chat/presentation/models/chat_route_args.dart';
import 'package:athletica/features/client_coach/data/datasources/client_coach_remote_data_source.dart';
import 'package:athletica/features/client_coach/data/repositories/client_coach_repository_impl.dart';
import 'package:athletica/features/client_coach/domain/repositories/client_coach_repository.dart';
import 'package:athletica/features/client_coach/domain/usecases/get_my_coach_usecase.dart';
import 'package:athletica/features/client_coach/domain/usecases/leave_coach_usecase.dart';
import 'package:athletica/features/client_coach/domain/usecases/submit_coach_invite_token_usecase.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_cubit.dart';
import 'package:athletica/features/coach/clients/data/datasources/coach_clients_remote_data_source.dart';
import 'package:athletica/features/coach/clients/data/datasources/coach_join_requests_remote_data_source.dart';
import 'package:athletica/features/coach/clients/data/repositories/coach_clients_repository_impl.dart';
import 'package:athletica/features/coach/clients/data/repositories/coach_join_requests_repository_impl.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_join_requests_repository.dart';
import 'package:athletica/features/coach/clients/domain/usecases/accept_coach_join_request_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/delete_client_nutrition_plan_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/delete_client_workout_plan_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/get_client_detail_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/get_coach_assigned_clients_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/get_coach_clients_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/get_coach_join_requests_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/reject_coach_join_request_usecase.dart';
import 'package:athletica/features/coach/clients/domain/usecases/remove_coach_assigned_client_usecase.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/client_detail_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_join_requests_cubit.dart';
import 'package:athletica/features/coach/messages/presentation/cubits/coach_messages_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/coach_subscription_cubit.dart';
import 'package:athletica/features/coach/home/data/datasources/coach_invite_remote_data_source.dart';
import 'package:athletica/features/coach/home/data/repositories/coach_invite_repository_impl.dart';
import 'package:athletica/features/coach/home/domain/repositories/coach_invite_repository.dart';
import 'package:athletica/features/coach/home/domain/usecases/create_coach_invite_code_usecase.dart';
import 'package:athletica/features/coach/home/domain/usecases/get_coach_home_stats_usecase.dart';
import 'package:athletica/features/coach/home/domain/usecases/revoke_coach_invite_usecase.dart';
import 'package:athletica/features/coach/home/presentation/cubits/coach_home_stats_cubit.dart';
import 'package:athletica/features/coach/home/presentation/cubits/coach_invite_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/data/datasources/nutrition_templates_remote_data_source.dart';
import 'package:athletica/features/coach/nutrition_templates/data/repositories/nutrition_templates_repository_impl.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/add_template_food_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/add_template_meal_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/assign_nutrition_template_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/create_nutrition_template_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/delete_nutrition_template_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/delete_template_food_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/delete_template_meal_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_assigned_clients_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_nutrition_template_detail_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_nutrition_templates_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/remove_assigned_client_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/reorder_template_meals_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/update_nutrition_template_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/update_template_food_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/update_template_meal_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/assign_plan_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/nutrition_templates_list_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/save_nutrition_plan_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/template_detail_cubit.dart';
import 'package:athletica/features/coach/plan/data/datasources/foods_remote_data_source.dart';
import 'package:athletica/features/coach/plan/data/datasources/nutrition_plans_remote_data_source.dart';
import 'package:athletica/features/coach/plan/data/repositories/foods_repository_impl.dart';
import 'package:athletica/features/coach/plan/data/repositories/nutrition_plans_repository_impl.dart';
import 'package:athletica/features/coach/plan/domain/repositories/foods_repository.dart';
import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';
import 'package:athletica/features/coach/plan/domain/usecases/add_plan_food_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/add_plan_meal_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/delete_nutrition_plan_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/delete_plan_meal_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/get_food_categories_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/get_foods_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/get_nutrition_plan_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/get_nutrition_plans_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/remove_plan_food_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/reorder_plan_meals_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/update_plan_food_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/update_plan_meal_usecase.dart';
import 'package:athletica/features/coach/plan/presentation/cubits/coach_plan_overview_cubit.dart';
import 'package:athletica/features/coach/plan/presentation/cubits/customize_workout_assignment_cubit.dart';
import 'package:athletica/features/coach/plan/presentation/cubits/foods_cubit.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_cubit.dart';
import 'package:athletica/features/coach/workout_templates/data/datasources/workout_templates_remote_data_source.dart';
import 'package:athletica/features/coach/workout_templates/data/repositories/workout_templates_repository_impl.dart';
import 'package:athletica/features/coach/workout_templates/domain/repositories/workout_templates_repository.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/create_workout_template_day_usecase.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/create_workout_template_item_usecase.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/create_workout_template_usecase.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/get_workout_templates_usecase.dart';
import 'package:athletica/features/coach/workout_templates/presentation/cubits/save_workout_plan_cubit.dart';
import 'package:athletica/features/complete_profile/presentation/cubits/complete_profile_cubit.dart';
import 'package:athletica/features/info/data/datasources/info_remote_data_source.dart';
import 'package:athletica/features/info/data/repositories/info_repository_impl.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';
import 'package:athletica/features/info/domain/usecases/get_client_answers_usecase.dart';
import 'package:athletica/features/info/domain/usecases/get_client_questions_usecase.dart';
import 'package:athletica/features/info/domain/usecases/submit_client_answers_usecase.dart';
import 'package:athletica/features/info/domain/usecases/update_client_answers_usecase.dart';
import 'package:athletica/features/info/presentation/cubits/info_cubit.dart';
import 'package:athletica/features/nutrition/data/datasources/nutrition_remote_data_source.dart';
import 'package:athletica/features/nutrition/data/repositories/nutrition_repository_impl.dart';
import 'package:athletica/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:athletica/features/nutrition/domain/usecases/complete_meal_log_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/get_my_active_plan_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/get_my_plan_details_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/get_nutrition_history_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/get_today_meals_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/uncomplete_meal_log_usecase.dart';
import 'package:athletica/features/nutrition/presentation/cubits/my_plan_details_cubit.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_cubit.dart';
import 'package:athletica/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:athletica/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:athletica/features/profile/domain/repositories/profile_repository.dart';
import 'package:athletica/features/profile/domain/usecases/delete_profile_image_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/get_client_profile_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/get_coach_profile_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/update_client_profile_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/update_coach_profile_usecase.dart';
import 'package:athletica/features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_info_cubit.dart';
import 'package:athletica/features/splash/presentation/cubits/splash_cubit.dart';
import 'package:athletica/features/workout/data/datasources/workout_remote_data_source.dart';
import 'package:athletica/features/workout/data/repos/workout_repository_impl.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';
import 'package:athletica/features/workout/domain/usecases/add_template_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/assign_workout_template_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/complete_workout_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/create_template_day_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/create_workout_template_v1_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/delete_template_day_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/delete_template_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/delete_workout_plan_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/delete_workout_template_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_my_workout_plan_details_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_my_workout_plan_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_today_workout_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_exercises_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_history_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_plan_detail_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_plans_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_template_detail_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_templates_v1_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/manage_plan_day_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/manage_plan_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/reorder_template_days_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/uncomplete_workout_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_plan_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_template_day_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_template_exercise_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_workout_plan_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/update_workout_template_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_exercises_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_my_plan_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_template_detail_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_today_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

/// Check-in integration (CHECK_IN.md): real API via [ApiClient]'s Dio.
/// Registered after the network + coach-clients data source below.
void setupCheckInsPreviewDependencies() {
  if (sl.isRegistered<CheckInsRepository>()) return;
  sl.registerLazySingleton<CheckInsRemoteDataSource>(
    () => CheckInsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CheckInsRepository>(
    () => CheckInsRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetCheckInsUseCase(sl()));
  sl.registerLazySingleton(() => GetCheckInQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => SaveCheckInResponseUseCase(sl()));
  sl.registerLazySingleton(() => SaveCheckInQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => GetCheckinPendingUseCase(sl()));
  sl.registerLazySingleton(() => AssignCheckInUseCase(sl()));
  sl.registerLazySingleton(() => GetCoachSubmissionsUseCase(sl()));
  sl.registerLazySingleton(() => GetCoachSubmissionDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetClientSubmissionsUseCase(sl()));
  sl.registerLazySingleton(() => GetClientSubmissionDetailUseCase(sl()));
  sl.registerFactory(() => CheckInHistoryCubit(sl()));
  sl.registerFactory(() => CheckInSubmissionCubit(sl(), sl()));
  sl.registerFactory(
    () => CheckInsCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );
}

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
  sl.registerLazySingleton<CoachClientsRemoteDataSource>(
    () => CoachClientsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );
  sl.registerFactory<AblyChatRealtimeGateway>(
    () => AblyChatRealtimeGateway(sl()),
  );
  setupCheckInsPreviewDependencies();
  sl.registerLazySingleton<CoachInviteRemoteDataSource>(
    () => CoachInviteRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<FoodsRemoteDataSource>(
    () => FoodsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WorkoutTemplatesRemoteDataSource>(
    () => WorkoutTemplatesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NutritionTemplatesRemoteDataSource>(
    () => NutritionTemplatesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NutritionPlansRemoteDataSource>(
    () => NutritionPlansRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ClientCoachRemoteDataSource>(
    () => ClientCoachRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NutritionRemoteDataSource>(
    () => NutritionRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CoachJoinRequestsRemoteDataSource>(
    () => CoachJoinRequestsRemoteDataSourceImpl(sl()),
  );

  // Assigned plans data source
  sl.registerLazySingleton<AssignedRemoteDataSource>(
    () => AssignedRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<InfoRepository>(() => InfoRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CoachClientsRepository>(
    () => CoachClientsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerFactory<ChatRealtimeGateway>(() => sl<AblyChatRealtimeGateway>());
  sl.registerLazySingleton<CoachJoinRequestsRepository>(
    () => CoachJoinRequestsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CoachInviteRepository>(
    () => CoachInviteRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<FoodsRepository>(() => FoodsRepositoryImpl(sl()));
  sl.registerLazySingleton<WorkoutTemplatesRepository>(
    () => WorkoutTemplatesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NutritionTemplatesRepository>(
    () => NutritionTemplatesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NutritionPlansRepository>(
    () => NutritionPlansRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ClientCoachRepository>(
    () => ClientCoachRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AssignedRepository>(
    () => AssignedRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NutritionRepository>(
    () => NutritionRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterClientUseCase(sl()));
  sl.registerLazySingleton(() => RegisterTrainerUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => ResendVerificationUseCase(sl()));
  sl.registerLazySingleton(() => RequestPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => CheckClientProfileCompletionUseCase(sl()));
  sl.registerLazySingleton(() => MarkProfileCompleteUseCase(sl()));
  sl.registerLazySingleton(() => GetClientQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitClientAnswersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateClientAnswersUseCase(sl()));
  sl.registerLazySingleton(() => GetClientAnswersUseCase(sl()));
  sl.registerLazySingleton(() => GetClientProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetCoachProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCoachProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateClientProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfileImageUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProfileImageUseCase(sl()));
  sl.registerLazySingleton(() => GetCoachClientsUseCase(sl()));
  sl.registerLazySingleton(() => GetCoachAssignedClientsUseCase(sl()));
  sl.registerLazySingleton(() => GetChatConversationsUseCase(sl()));
  sl.registerLazySingleton(() => GetChatHistoryUseCase(sl()));
  sl.registerLazySingleton(() => SendChatMessageUseCase(sl()));
  sl.registerLazySingleton(() => SendFirstChatMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetClientDetailUseCase(sl()));
  sl.registerLazySingleton(() => RemoveCoachAssignedClientUseCase(sl()));
  sl.registerLazySingleton(() => CreateCoachInviteCodeUseCase(sl()));
  sl.registerLazySingleton(() => RevokeCoachInviteUseCase(sl()));
  sl.registerLazySingleton(() => GetCoachHomeStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetCoachJoinRequestsUseCase(sl()));
  sl.registerLazySingleton(() => AcceptCoachJoinRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectCoachJoinRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetFoodsUseCase(sl()));
  sl.registerLazySingleton(() => GetFoodCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => CreateWorkoutTemplateUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkoutTemplatesUseCase(sl()));
  sl.registerLazySingleton(() => CreateWorkoutTemplateDayUseCase(sl()));
  sl.registerLazySingleton(() => CreateWorkoutTemplateItemUseCase(sl()));

  // Nutrition — templates
  sl.registerLazySingleton(() => GetNutritionTemplatesUseCase(sl()));
  sl.registerLazySingleton(() => CreateNutritionTemplateUseCase(sl()));
  sl.registerLazySingleton(() => GetNutritionTemplateDetailUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNutritionTemplateUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNutritionTemplateUseCase(sl()));
  sl.registerLazySingleton(() => AddTemplateMealUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTemplateMealUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTemplateMealUseCase(sl()));
  sl.registerLazySingleton(() => ReorderTemplateMealsUseCase(sl()));
  sl.registerLazySingleton(() => AddTemplateFoodUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTemplateFoodUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTemplateFoodUseCase(sl()));
  sl.registerLazySingleton(() => AssignNutritionTemplateUseCase(sl()));
  sl.registerLazySingleton(() => GetAssignedClientsUseCase(sl()));

  // Nutrition — plans
  sl.registerLazySingleton(() => GetNutritionPlansUseCase(sl()));
  sl.registerLazySingleton(() => GetNutritionPlanUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNutritionPlanUseCase(sl()));
  sl.registerLazySingleton(() => DeleteClientNutritionPlanUseCase(sl()));
  sl.registerLazySingleton(() => DeleteClientWorkoutPlanUseCase(sl()));
  sl.registerLazySingleton(() => AddPlanMealUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlanMealUseCase(sl()));
  sl.registerLazySingleton(() => DeletePlanMealUseCase(sl()));
  sl.registerLazySingleton(() => ReorderPlanMealsUseCase(sl()));
  sl.registerLazySingleton(() => AddPlanFoodUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlanFoodUseCase(sl()));
  sl.registerLazySingleton(() => RemovePlanFoodUseCase(sl()));

  // Client coach connection
  sl.registerLazySingleton(() => GetMyCoachUseCase(sl()));
  sl.registerLazySingleton(() => SubmitCoachInviteTokenUseCase(sl()));
  sl.registerLazySingleton(() => LeaveCoachUseCase(sl()));
  sl.registerLazySingleton(() => RemoveAssignedClientUseCase(sl()));

  // Assigned plans use cases
  sl.registerLazySingleton(() => GetAssignedPlansUseCase(sl()));
  sl.registerLazySingleton(() => AssignClientWorkoutUseCase(sl()));
  sl.registerLazySingleton(() => AssignClientNutritionUseCase(sl()));

  // Client nutrition
  sl.registerLazySingleton(() => GetTodayMealsUseCase(sl()));
  sl.registerLazySingleton(() => CompleteMealLogUseCase(sl()));
  sl.registerLazySingleton(() => UncompleteMealLogUseCase(sl()));
  sl.registerLazySingleton(() => GetMyActivePlanUseCase(sl()));
  sl.registerLazySingleton(() => GetMyPlanDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetNutritionHistoryUseCase(sl()));

  // Workout (documented contract: WORKOUT_API_DOC_1.md)
  sl.registerLazySingleton<WorkoutRemoteDataSource>(
    () => WorkoutRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetWorkoutExercisesUseCase(sl()));
  sl.registerLazySingleton(() => CreateWorkoutTemplateV1UseCase(sl()));
  sl.registerLazySingleton(() => GetWorkoutTemplatesV1UseCase(sl()));
  sl.registerLazySingleton(() => GetWorkoutTemplateDetailUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWorkoutTemplateUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWorkoutTemplateUseCase(sl()));
  sl.registerLazySingleton(() => CreateTemplateDayUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTemplateDayUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTemplateDayUseCase(sl()));
  sl.registerLazySingleton(() => ReorderTemplateDaysUseCase(sl()));
  sl.registerLazySingleton(() => AddTemplateExerciseUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTemplateExerciseUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTemplateExerciseUseCase(sl()));
  sl.registerLazySingleton(() => AssignWorkoutTemplateUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkoutPlansUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkoutPlanDetailUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWorkoutPlanUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWorkoutPlanUseCase(sl()));
  sl.registerLazySingleton(() => ManagePlanDayUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlanExerciseUseCase(sl()));
  sl.registerLazySingleton(() => ManagePlanExerciseUseCase(sl()));
  sl.registerLazySingleton(() => GetTodayWorkoutUseCase(sl()));
  sl.registerLazySingleton(() => CompleteWorkoutExerciseUseCase(sl()));
  sl.registerLazySingleton(() => UncompleteWorkoutExerciseUseCase(sl()));
  sl.registerLazySingleton(() => GetMyWorkoutPlanUseCase(sl()));
  sl.registerLazySingleton(() => GetMyWorkoutPlanDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkoutHistoryUseCase(sl()));

  // Cubits — factory so each screen gets a fresh instance
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerClientUseCase: sl(),
      registerTrainerUseCase: sl(),
      verifyEmailUseCase: sl(),
      resendVerificationUseCase: sl(),
      requestPasswordResetUseCase: sl(),
      confirmPasswordResetUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthStatusUseCase: sl(),
    ),
  );
  sl.registerFactory(() => SplashCubit(sl()));
  sl.registerFactory(() => CompleteProfileCubit(sl()));
  sl.registerFactory(() => CoachSubscriptionCubit(sl()));
  sl.registerFactory(() => InfoCubit(sl(), sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => ProfileCubit(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => CoachProfileCubit(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => CoachClientsCubit(sl(), sl()));
  sl.registerFactoryParam<ChatCubit, ChatRouteArgs, void>(
    (args, _) => ChatCubit(
      getConversations: sl(),
      getHistory: sl(),
      sendMessage: sl(),
      sendFirstMessage: sl(),
      realtimeGateway: sl(),
      conversationId: args.conversationId,
      coachClientId: args.coachClientId,
      canStartConversation: args.canStartConversation,
    ),
  );
  sl.registerFactory(() => CoachMessagesCubit(sl()));
  sl.registerFactory(() => ClientDetailCubit(sl(), sl(), sl()));
  sl.registerFactory(() => CoachJoinRequestsCubit(sl(), sl(), sl()));
  sl.registerFactory(() => CoachInviteCubit(sl(), sl()));
  sl.registerFactory(() => ClientCoachCubit(sl(), sl(), sl()));
  sl.registerFactory(() => AssignedCubit(sl(), sl(), sl()));
  sl.registerFactory(() => NutritionTodayCubit(sl(), sl(), sl()));
  sl.registerFactory(() => MyPlanDetailsCubit(sl(), sl()));
  sl.registerFactory(() => CoachHomeStatsCubit(sl()));
  sl.registerFactory(() => FoodsCubit(sl(), sl()));
  sl.registerFactory(() => CoachPlanOverviewCubit(sl(), sl(), sl()));
  sl.registerFactory(() => SaveWorkoutPlanCubit(sl(), sl(), sl(), sl()));
  // Keep-alive so reopening the plans list shows cached data and only
  // revalidates in the background.
  sl.registerLazySingleton<NutritionTemplatesListCubit>(
    () => NutritionTemplatesListCubit(sl(), sl()),
  );
  sl.registerFactory(() => SaveNutritionPlanCubit(sl(), sl(), sl()));
  sl.registerFactory(
    () => TemplateDetailCubit(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );
  sl.registerFactory(() => AssignPlanCubit(sl(), sl(), sl()));
  sl.registerLazySingleton(() => ProfileInfoCubit(sl(), sl()));
  // Workout cubits — factory so each screen gets a fresh instance
  sl.registerFactory(() => WorkoutExercisesCubit(sl()));
  sl.registerFactory(() => WorkoutTemplatesCubit(sl(), sl(), sl()));
  sl.registerFactory(
    () => WorkoutTemplateDetailCubit(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );
  sl.registerFactory(() => WorkoutPlansCubit(sl()));
  sl.registerFactory(() => CustomizeWorkoutAssignmentCubit(sl(), sl()));
  sl.registerFactory(
    () => WorkoutPlanDetailCubit(sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerFactory(() => WorkoutTodayCubit(sl(), sl(), sl()));
  sl.registerFactory(() => WorkoutMyPlanCubit(sl(), sl()));
  sl.registerFactory(() => WorkoutHistoryCubit(sl()));
}
