import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

/// Saves the coach form by fanning out to the question primitives
/// (`C2` create / `C4` update text / `C5` delete / `C3` reorder with the
/// complete ordered ID list).
///
/// New draft rows carry temporary `custom-*` ids; created questions return
/// real UUIDs that are spliced into the final order before reordering.
/// Question text is 1–500 chars (CHECK_IN.md §3.1, §7). There is no
/// question-count cap.
class SaveCheckInQuestionsUseCase {
  const SaveCheckInQuestionsUseCase(this._repository);
  final CheckInsRepository _repository;

  static const int maxQuestionLength = 500;

  static bool _isChoice(CheckInQuestionType type) =>
      type == CheckInQuestionType.SINGLE_CHOICE ||
      type == CheckInQuestionType.YES_NO;

  Future<ApiResult<void>> call({
    required List<CheckInQuestion> current,
    required List<CheckInQuestion> updated,
  }) async {
    if (updated.isEmpty) {
      return const ApiError(UnknownFailure('Add at least one question.'));
    }
    for (final question in updated) {
      final label = question.label.trim();
      if (label.isEmpty || label.length > maxQuestionLength) {
        return const ApiError(
          UnknownFailure(
            'Each question needs text of 1–500 characters.',
          ),
        );
      }
      if (_isChoice(question.type) &&
          question.options.where((o) => o.trim().isNotEmpty).length < 2) {
        return const ApiError(
          UnknownFailure(
            'Choice questions need at least two options.',
          ),
        );
      }
    }
    final currentById = {for (final q in current) q.id: q};
    final updatedIds = updated.map((q) => q.id).toSet();
    if (updatedIds.length != updated.length) {
      return const ApiError(
        UnknownFailure('Each question needs a unique ID.'),
      );
    }

    // Deletes first (backend blocks deleting the last question).
    for (final question in current) {
      if (!updatedIds.contains(question.id)) {
        final result = await _repository.deleteQuestion(question.id);
        if (result is ApiError) return result;
      }
    }

    // Creates + text updates.
    final resolvedIds = <String>[];
    for (final question in updated) {
      final existing = currentById[question.id];
      if (existing == null) {
        final result = await _repository.createQuestion(
          question: question.label.trim(),
          type: question.type,
          options: _isChoice(question.type) ? question.options : null,
        );
        switch (result) {
          case ApiError(:final failure):
            return ApiError(failure);
          case ApiSuccess(:final data):
            resolvedIds.add(data.id);
        }
      } else {
        resolvedIds.add(question.id);
        if (existing.label.trim() != question.label.trim()) {
          final result = await _repository.updateQuestion(
            questionId: question.id,
            question: question.label.trim(),
          );
          if (result is ApiError) return result;
        }
      }
    }

    // Reorder when membership or order changed. The list must contain
    // exactly all owned IDs, no dupes.
    final currentOrder = current.map((q) => q.id).toList();
    final needsReorder = resolvedIds.length != currentOrder.length ||
        !List.generate(
          resolvedIds.length,
          (i) => i < currentOrder.length && resolvedIds[i] == currentOrder[i],
        ).every((same) => same);
    if (needsReorder) {
      final result = await _repository.reorderQuestions(resolvedIds);
      if (result is ApiError) return result;
    }
    return const ApiSuccess(null);
  }
}
