import 'dart:io';

import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';
import 'package:athletica/features/achievements/domain/repositories/achievements_repository.dart';

class UploadCoachAchievementUseCase {
  const UploadCoachAchievementUseCase(this._repository);

  final AchievementsRepository _repository;

  static const int maxTitleLength = 200;
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
  static const int maxCertificates = 50;

  Future<ApiResult<CoachAchievement>> call({
    required String title,
    required File file,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      return const ApiError(
        CertificateValidationFailure('Certificate title is required.'),
      );
    }
    if (normalizedTitle.length > maxTitleLength) {
      return const ApiError(
        CertificateValidationFailure(
          'Certificate title must be 200 characters or fewer.',
        ),
      );
    }
    if (!file.path.toLowerCase().endsWith('.pdf')) {
      return const ApiError(
        CertificateValidationFailure('Only PDF files are allowed.'),
      );
    }

    final int fileSize;
    try {
      fileSize = file.lengthSync();
    } catch (_) {
      return const ApiError(
        CertificateValidationFailure('The selected PDF could not be read.'),
      );
    }
    if (fileSize <= 0) {
      return const ApiError(
        CertificateValidationFailure('The selected PDF is empty.'),
      );
    }
    if (fileSize > maxFileSizeBytes) {
      return const ApiError(
        CertificateValidationFailure('PDF files must be 10 MB or smaller.'),
      );
    }

    final currentResult = await _repository.getCoachAchievements();
    switch (currentResult) {
      case ApiError(:final failure):
        return ApiError(failure);
      case ApiSuccess(:final data):
        if (data.length >= maxCertificates) {
          return const ApiError(
            CertificateValidationFailure(
              'You can upload a maximum of 50 certificates.',
            ),
          );
        }
        return _repository.uploadCoachAchievement(
          title: normalizedTitle,
          file: file,
        );
    }
  }
}
