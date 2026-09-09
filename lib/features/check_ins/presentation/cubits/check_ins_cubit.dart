import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_check_in_questions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_check_ins_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/save_check_in_questions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/save_check_in_response_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CheckInsState {
  const CheckInsState();
}

final class CheckInsLoading extends CheckInsState {
  const CheckInsLoading();
}

final class CheckInsError extends CheckInsState {
  const CheckInsError(this.message);
  final String message;
}

final class CheckInsReady extends CheckInsState {
  const CheckInsReady({
    required this.entries,
    required this.questions,
    this.saving = false,
    this.message,
  });
  final List<CheckIn> entries;
  final List<CheckInQuestion> questions;
  final bool saving;
  final String? message;
}

class CheckInsCubit extends Cubit<CheckInsState> {
  CheckInsCubit(
    this._getEntries,
    this._getQuestions,
    this._saveResponse,
    this._saveQuestions,
  ) : super(const CheckInsLoading());
  final GetCheckInsUseCase _getEntries;
  final GetCheckInQuestionsUseCase _getQuestions;
  final SaveCheckInResponseUseCase _saveResponse;
  final SaveCheckInQuestionsUseCase _saveQuestions;
  int _request = 0;
  String _query = '';
  CheckInStatus? _filter;

  Future<void> load({String query = '', CheckInStatus? filter}) async {
    _query = query;
    _filter = filter;
    final request = ++_request;
    final entries = await _getEntries(query: query, status: filter);
    final questions = await _getQuestions();
    if (isClosed || request != _request) return;
    switch ((entries, questions)) {
      case (ApiSuccess(data: final list), ApiSuccess(data: final fields)):
        emit(CheckInsReady(entries: list, questions: fields));
      case (ApiError(:final failure), _):
        emit(CheckInsError(failure.message));
      case (_, ApiError(:final failure)):
        emit(CheckInsError(failure.message));
    }
  }

  Future<bool> saveResponse({
    required CheckIn entry,
    required List<CheckInQuestion> questions,
    required Map<String, String> answers,
    required String additionalNotes,
    required String coachNote,
    required bool coachResponse,
  }) async {
    final current = state;
    if (current is! CheckInsReady || current.saving) return false;
    emit(
      CheckInsReady(
        entries: current.entries,
        questions: current.questions,
        saving: true,
      ),
    );
    final result = await _saveResponse(
      entry: entry,
      questions: questions,
      answers: answers,
      additionalNotes: additionalNotes,
      coachNote: coachNote,
      coachResponse: coachResponse,
    );
    return _finishSave(result, current);
  }

  Future<bool> saveQuestions(List<CheckInQuestion> questions) async {
    final current = state;
    if (current is! CheckInsReady || current.saving) return false;
    emit(
      CheckInsReady(
        entries: current.entries,
        questions: current.questions,
        saving: true,
      ),
    );
    return _finishSave(await _saveQuestions(questions), current);
  }

  Future<bool> _finishSave(
    ApiResult<void> result,
    CheckInsReady previous,
  ) async {
    if (isClosed) return false;
    switch (result) {
      case ApiSuccess():
        await load(query: _query, filter: _filter);
        return true;
      case ApiError(:final failure):
        emit(
          CheckInsReady(
            entries: previous.entries,
            questions: previous.questions,
            message: failure.message,
          ),
        );
        return false;
    }
  }
}
