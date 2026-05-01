import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/profile/domain/usecases/get_coach_profile_usecase.dart';
import 'package:athletica/features/coach/profile/presentation/cubits/coach_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachProfileCubit extends Cubit<CoachProfileState> {
  CoachProfileCubit(this._getCoachProfile) : super(CoachProfileInitial());

  final GetCoachProfileUseCase _getCoachProfile;

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        (state is CoachProfileLoaded || state is CoachProfileLoading)) {
      return;
    }

    emit(CoachProfileLoading());

    final trainerId = await TokenStorageService.instance.getTrainerId();
    if (trainerId == null) {
      emit(CoachProfileError('Trainer ID not found. Please log in again.'));
      return;
    }

    final result = await _getCoachProfile(trainerId);
    switch (result) {
      case ApiSuccess(:final data):
        emit(CoachProfileLoaded(data));
      case ApiError(:final failure):
        emit(CoachProfileError(failure.message));
    }
  }
}
