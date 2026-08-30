import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/get_workout_templates_usecase.dart';
import 'package:athletica/features/coach/workout_templates/presentation/cubits/workout_templates_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutTemplatesListCubit extends Cubit<WorkoutTemplatesListState> {
  WorkoutTemplatesListCubit(this._getTemplates)
      : super(WorkoutTemplatesListInitial());

  final GetWorkoutTemplatesUseCase _getTemplates;

  Future<void> loadTemplates() async {
    if (state is WorkoutTemplatesListLoading) return;
    emit(WorkoutTemplatesListLoading());

    final trainerId = await TokenStorageService.instance.getTrainerId();
    if (trainerId == null) {
      if (isClosed) return;
      emit(WorkoutTemplatesListError(
          'Trainer ID not found. Please log in again.'));
      return;
    }

    final result = await _getTemplates(trainerId);
    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(WorkoutTemplatesListLoaded(data.map(_toProgram).toList()));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(WorkoutTemplatesListError(failure.message));
    }
  }

  WorkoutProgram _toProgram(WorkoutTemplate t) => WorkoutProgram(
        id: t.id,
        name: t.title,
        category: _levelToCategory(t.level),
        splitType: '— Days Split',
        updatedAgo: _timeAgo(t.createdAt),
        clientCount: 0,
        iconAsset: 'assets/images/plan/workout_icon.svg',
        description: '',
        days: const [],
      );

  String _levelToCategory(String level) => switch (level) {
        'ADVANCED' => 'Strength',
        'INTERMEDIATE' => 'Fat loss',
        _ => 'Custom',
      };

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }
}
