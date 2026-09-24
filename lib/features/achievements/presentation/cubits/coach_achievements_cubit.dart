import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';
import 'package:athletica/features/achievements/domain/usecases/delete_coach_achievement_usecase.dart';
import 'package:athletica/features/achievements/domain/usecases/get_coach_achievements_usecase.dart';
import 'package:athletica/features/achievements/presentation/cubits/coach_achievements_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachAchievementsCubit extends Cubit<CoachAchievementsState> {
  CoachAchievementsCubit(this._getAchievements, this._deleteAchievement)
    : super(const CoachAchievementsInitial());

  final GetCoachAchievementsUseCase _getAchievements;
  final DeleteCoachAchievementUseCase _deleteAchievement;

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        (state is CoachAchievementsLoading ||
            state is CoachAchievementsLoaded ||
            state is CoachAchievementsDeleteSuccess)) {
      return;
    }

    final previous = _currentAchievements;
    emit(const CoachAchievementsLoading());
    final result = await _getAchievements();
    if (isClosed) return;

    switch (result) {
      case ApiSuccess(:final data):
        emit(CoachAchievementsLoaded(List.unmodifiable(data)));
      case ApiError(:final failure):
        emit(
          CoachAchievementsError(
            failure.message,
            previous: previous,
          ),
        );
    }
  }

  Future<void> delete(String id) async {
    if (id.trim().isEmpty || state is CoachAchievementsDeleting) return;

    final previous = _currentAchievements;
    final target = previous.where((item) => item.id == id).firstOrNull;
    emit(CoachAchievementsDeleting(List.unmodifiable(previous), id));

    final result = await _deleteAchievement(id.trim());
    if (isClosed) return;

    switch (result) {
      case ApiSuccess():
        final updated = previous
            .where((item) => item.id != id.trim())
            .toList(growable: false);
        emit(
          CoachAchievementsDeleteSuccess(
            List.unmodifiable(updated),
            target?.title ?? 'Certificate',
          ),
        );
      case ApiError(:final failure):
        emit(CoachAchievementsError(failure.message, previous: previous));
    }
  }

  List<CoachAchievement> get _currentAchievements => switch (state) {
    CoachAchievementsLoaded(:final achievements) => achievements,
    CoachAchievementsDeleting(:final achievements) => achievements,
    CoachAchievementsDeleteSuccess(:final achievements) => achievements,
    CoachAchievementsError(:final previous?) => previous,
    _ => const [],
  };
}
