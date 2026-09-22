import 'dart:io';

import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/utils/check_in_media.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

/// Client submit (`L3`) validation (CHECK_IN.md §7), mirrored to avoid
/// round-trips. Transport omits optional blanks and allows file-only
/// submissions; see the repository.
class SaveCheckInResponseUseCase {
  const SaveCheckInResponseUseCase(this._repository);
  final CheckInsRepository _repository;

  static final RegExp _number = RegExp(r'^\d+(\.\d+)?$');
  static final RegExp _rating = RegExp(r'^(10|[1-9])$');

  Future<ApiResult<CheckInSubmitResult>> call({
    required List<CheckInQuestion> questions,
    required Map<String, String> answers,
    Map<String, File> imageFiles = const {},
  }) async {
    if (imageFiles.length > kCheckInMaxImageCount) {
      return const ApiError(
        UnknownFailure('You can upload up to 10 images.'),
      );
    }
    for (final entry in imageFiles.entries) {
      final question = questions
          .where((q) => q.id == entry.key)
          .cast<CheckInQuestion?>();
      final match = question.isEmpty ? null : question.first;
      if (match == null || match.type != CheckInQuestionType.IMAGE) {
        return const ApiError(
          UnknownFailure('This image does not match a photo question.'),
        );
      }
      if (!isSupportedCheckInImagePath(entry.value.path)) {
        return const ApiError(
          UnknownFailure('Only JPEG, PNG, and WEBP images are allowed.'),
        );
      }
      int size;
      try {
        size = await entry.value.length();
      } catch (_) {
        return ApiError(
          UnknownFailure('Could not read the image for "${match.label}".'),
        );
      }
      if (size > kCheckInMaxImageBytes) {
        return ApiError(
          UnknownFailure('Image for "${match.label}" must be 5 MB or smaller.'),
        );
      }
    }
    for (final question in questions) {
      if (question.type == CheckInQuestionType.IMAGE) {
        if (question.required && !imageFiles.containsKey(question.id)) {
          return ApiError(
            UnknownFailure('Please answer: ${question.label}'),
          );
        }
        continue;
      }
      final answer = answers[question.id]?.trim() ?? '';
      if (answer.isEmpty) {
        if (question.required) {
          return ApiError(UnknownFailure('Please answer: ${question.label}'));
        }
        continue;
      }
      switch (question.type) {
        case CheckInQuestionType.NUMBER:
          final number = double.tryParse(answer);
          if (!_number.hasMatch(answer) ||
              number == null ||
              !number.isFinite ||
              number < 0) {
            return ApiError(
              UnknownFailure('Enter a valid number for ${question.label}'),
            );
          }
        case CheckInQuestionType.RATING:
          if (!_rating.hasMatch(answer)) {
            return ApiError(
              UnknownFailure(
                'Choose a rating from 1 to 10 for ${question.label}',
              ),
            );
          }
        case CheckInQuestionType.SINGLE_CHOICE:
        case CheckInQuestionType.YES_NO:
          if (!question.options.contains(answer)) {
            return ApiError(
              UnknownFailure('Choose a valid option for ${question.label}'),
            );
          }
        case CheckInQuestionType.TEXT:
        case CheckInQuestionType.IMAGE:
          break;
      }
    }
    return _repository.saveResponse(
      questions: questions,
      answers: answers,
      imageFiles: imageFiles,
    );
  }
}
