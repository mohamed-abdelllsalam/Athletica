import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

class SaveCheckInResponseUseCase {
  const SaveCheckInResponseUseCase(this._repository);
  final CheckInsRepository _repository;

  Future<ApiResult<void>> call({
    required CheckIn entry,
    required List<CheckInQuestion> questions,
    required Map<String, String> answers,
    required String additionalNotes,
    required String coachNote,
    required bool coachResponse,
  }) async {
    if (coachResponse) {
      if (entry.status != CheckInStatus.completed) {
        return const ApiError(
          UnknownFailure('The client has not submitted a check-in yet.'),
        );
      }
      if (coachNote.trim().isEmpty) {
        return const ApiError(
          UnknownFailure('Write a coach note before saving.'),
        );
      }
    } else {
      for (final question in questions) {
        final answer = answers[question.id]?.trim() ?? '';
        if (answer.isEmpty) {
          return ApiError(UnknownFailure('Please answer: ${question.label}'));
        }
        if (question.type == CheckInQuestionType.number) {
          final number = double.tryParse(answer);
          if (number == null || !number.isFinite || number <= 0) {
            return ApiError(
              UnknownFailure('Enter a positive number for ${question.label}'),
            );
          }
        }
        if (question.type == CheckInQuestionType.yesNo &&
            answer != 'Yes' &&
            answer != 'No') {
          return ApiError(
            UnknownFailure('Choose Yes or No for ${question.label}'),
          );
        }
        if (question.type == CheckInQuestionType.sessions) {
          final count = int.tryParse(answer);
          if (count == null || count < 0 || count > 14) {
            return const ApiError(
              UnknownFailure('Choose between 0 and 14 sessions.'),
            );
          }
        }
      }
    }
    if (additionalNotes.length > 1000 || coachNote.length > 1000) {
      return const ApiError(
        UnknownFailure('Keep notes within 1,000 characters.'),
      );
    }
    return _repository.saveResponse(
      entry.withResponse(
        answers: coachResponse
            ? entry.answers
            : {for (final q in questions) q.id: answers[q.id]!.trim()},
        additionalNotes: coachResponse
            ? entry.additionalNotes
            : additionalNotes.trim(),
        coachNote: coachResponse ? coachNote.trim() : entry.coachNote,
      ),
    );
  }
}
