import 'package:athletica/features/auth/domain/usecases/mark_profile_complete_usecase.dart';
import 'package:athletica/features/info/presentation/cubits/info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoCubit extends Cubit<InfoState> {
  final MarkProfileCompleteUseCase _markProfileComplete;

  InfoCubit(this._markProfileComplete) : super(const InfoInitial());

  Future<void> markComplete() async {
    emit(const InfoLoading());
    try {
      await _markProfileComplete();
      emit(const InfoSuccess());
    } catch (_) {
      emit(const InfoError('Failed to save your answers. Please try again.'));
    }
  }
}
