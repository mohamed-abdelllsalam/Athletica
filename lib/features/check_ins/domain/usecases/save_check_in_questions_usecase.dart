import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

class SaveCheckInQuestionsUseCase {
  const SaveCheckInQuestionsUseCase(this._repository);
  final CheckInsRepository _repository;

  Future<ApiResult<void>> call(List<CheckInQuestion> questions) async {
    if (questions.isEmpty) {
      return const ApiError(UnknownFailure('Add at least one question.'));
    }
    if (questions.length > 20) {
      return const ApiError(UnknownFailure('Use up to 20 questions.'));
    }
    final ids = <String>{};
    for (final question in questions) {
      if (question.id.trim().isEmpty ||
          !ids.add(question.id) ||
          question.label.trim().isEmpty ||
          question.label.trim().length > 160) {
        return const ApiError(
          UnknownFailure(
            'Each question needs a unique ID and a label of 1–160 characters.',
          ),
        );
      }
    }
    return _repository.saveQuestions([
      for (final q in questions)
        CheckInQuestion(id: q.id, label: q.label.trim(), type: q.type),
    ]);
  }
}
