import 'package:athletica/features/coach/complete_profile/presentation/cubits/upload_video_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadVideoCubit extends Cubit<UploadVideoState> {
  UploadVideoCubit() : super(UploadVideoInitial());

  // TODO: inject UploadVideoUseCase when API + file_picker package are wired up.
  Future<void> pickAndUploadVideo() async {
    emit(UploadVideoLoading());
    // Stub — replace with actual file pick + upload call.
    await Future.delayed(const Duration(seconds: 1));
    emit(UploadVideoFailure());
  }

  void retry() => emit(UploadVideoInitial());

  void replaceVideo() => emit(UploadVideoInitial());
}
