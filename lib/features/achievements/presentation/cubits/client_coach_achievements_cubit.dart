import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/achievements/domain/usecases/get_assigned_coach_achievements_usecase.dart';
import 'package:athletica/features/achievements/presentation/cubits/client_coach_achievements_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientCoachAchievementsCubit extends Cubit<ClientCoachAchievementsState> {
  ClientCoachAchievementsCubit(this._getAchievements)
    : super(const ClientCoachAchievementsInitial());

  final GetAssignedCoachAchievementsUseCase _getAchievements;

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        (state is ClientCoachAchievementsLoading ||
            state is ClientCoachAchievementsLoaded)) {
      return;
    }

    emit(const ClientCoachAchievementsLoading());
    final result = await _getAchievements();
    if (isClosed) return;

    switch (result) {
      case ApiSuccess(:final data):
        emit(ClientCoachAchievementsLoaded(List.unmodifiable(data)));
      case ApiError(:final failure):
        emit(ClientCoachAchievementsError(failure.message));
    }
  }

  void clear() => emit(const ClientCoachAchievementsInitial());
}
