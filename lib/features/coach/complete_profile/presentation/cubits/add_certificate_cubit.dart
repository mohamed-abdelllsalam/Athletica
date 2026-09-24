import 'dart:io';

import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/achievements/domain/usecases/upload_coach_achievement_usecase.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/add_certificate_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCertificateCubit extends Cubit<AddCertificateState> {
  AddCertificateCubit(this._uploadAchievement)
    : super(const AddCertificateInitial());

  final UploadCoachAchievementUseCase _uploadAchievement;

  Future<void> saveCertificate({
    required String title,
    required File file,
  }) async {
    if (state is AddCertificateSaving) return;

    emit(const AddCertificateSaving());
    final result = await _uploadAchievement(title: title, file: file);
    if (isClosed) return;

    switch (result) {
      case ApiSuccess(:final data):
        emit(AddCertificateSuccess(data));
      case ApiError(:final failure):
        emit(AddCertificateFailure(failure.message));
    }
  }
}
