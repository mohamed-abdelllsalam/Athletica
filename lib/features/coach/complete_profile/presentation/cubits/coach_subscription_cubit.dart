import 'package:athletica/features/auth/domain/usecases/mark_profile_complete_usecase.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/coach_subscription_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachSubscriptionCubit extends Cubit<CoachSubscriptionState> {
  final MarkProfileCompleteUseCase _markProfileComplete;

  CoachSubscriptionCubit(this._markProfileComplete)
      : super(const CoachSubscriptionInitial());

  Future<void> subscribe() async {
    emit(const CoachSubscriptionLoading());
    try {
      await _markProfileComplete();
      if (isClosed) return;
      emit(const CoachSubscriptionSuccess());
    } catch (_) {
      if (isClosed) return;
      emit(const CoachSubscriptionError('Failed to save profile. Try again.'));
    }
  }
}
