import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_assigned_clients_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_nutrition_templates_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_templates_v1_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CoachPlanOverviewState {
  const CoachPlanOverviewState();
}

final class CoachPlanOverviewInitial extends CoachPlanOverviewState {
  const CoachPlanOverviewInitial();
}

final class CoachPlanOverviewLoading extends CoachPlanOverviewState {
  const CoachPlanOverviewLoading();
}

final class CoachPlanOverviewLoaded extends CoachPlanOverviewState {
  const CoachPlanOverviewLoaded({
    required this.nutritionPlans,
    required this.workoutPrograms,
    required this.activeClients,
  });

  /// Total nutrition plan templates (`GET /nutrition/templates` pagination).
  final int nutritionPlans;

  /// Total workout programs (`GET /workout/templates` pagination).
  final int workoutPrograms;

  /// Assigned clients (`GET /coach/clients`).
  final int activeClients;
}

final class CoachPlanOverviewError extends CoachPlanOverviewState {
  const CoachPlanOverviewError(this.message);

  final String message;
}

class CoachPlanOverviewCubit extends Cubit<CoachPlanOverviewState> {
  CoachPlanOverviewCubit(
    this._getTemplates,
    this._getAssignedClients,
    this._getWorkoutTemplates,
  ) : super(CoachPlanOverviewInitial());

  final GetNutritionTemplatesUseCase _getTemplates;
  final GetAssignedClientsUseCase _getAssignedClients;
  final GetWorkoutTemplatesV1UseCase _getWorkoutTemplates;

  Future<void> load() async {
    final current = state;
    // Silent refresh: keep the visible numbers while revalidating.
    final isSilentRefresh = current is CoachPlanOverviewLoaded;
    if (!isSilentRefresh && current is CoachPlanOverviewLoading) return;

    if (!isSilentRefresh) emit(CoachPlanOverviewLoading());

    // Only the totals are needed — one template row / no client details.
    final templatesResult = await _getTemplates(page: 1, pageSize: 1);
    final clientsResult = await _getAssignedClients();
    final workoutResult = await _getWorkoutTemplates(page: 1, pageSize: 1);

    String? error;
    var plansCount = 0;
    var clientsCount = 0;
    var workoutCount = 0;

    switch (templatesResult) {
      case ApiSuccess(:final data):
        plansCount = data.pagination.total;
      case ApiError(:final failure):
        error = failure.message;
    }
    switch (clientsResult) {
      case ApiSuccess(:final data):
        clientsCount = data.length;
      case ApiError(:final failure):
        error ??= failure.message;
    }
    switch (workoutResult) {
      case ApiSuccess(:final data):
        workoutCount = data.pagination.total;
      case ApiError(:final failure):
        error ??= failure.message;
    }

    if (error != null) {
      // On silent-refresh failure keep the previously loaded numbers.
      if (!isSilentRefresh &&
          plansCount == 0 &&
          clientsCount == 0 &&
          workoutCount == 0) {
        if (isClosed) return;
        emit(CoachPlanOverviewError(error));
      }
      return;
    }

    if (isClosed) return;
    emit(
      CoachPlanOverviewLoaded(
        nutritionPlans: plansCount,
        workoutPrograms: workoutCount,
        activeClients: clientsCount,
      ),
    );
  }
}
