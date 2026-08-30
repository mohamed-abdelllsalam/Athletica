import 'package:athletica/features/auth/domain/usecases/mark_profile_complete_usecase.dart';
import 'package:athletica/features/complete_profile/presentation/cubits/complete_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  final MarkProfileCompleteUseCase _markProfileComplete;

  CompleteProfileCubit(this._markProfileComplete)
      : super(const CompleteProfileInitial());

  Future<void> submit() async {
    emit(const CompleteProfileLoading());
    try {
      await _markProfileComplete();
      if (isClosed) return;
      emit(const CompleteProfileSuccess());
    } catch (_) {
      if (isClosed) return;
      emit(const CompleteProfileError('Failed to save profile. Try again.'));
    }
  }
}
