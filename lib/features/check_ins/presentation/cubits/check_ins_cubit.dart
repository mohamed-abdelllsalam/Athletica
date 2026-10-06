import 'dart:io';

import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/usecases/assign_check_in_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_check_in_questions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_check_ins_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_checkin_pending_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_client_submissions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_coach_submission_detail_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/get_coach_submissions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/save_check_in_questions_usecase.dart';
import 'package:athletica/features/check_ins/domain/usecases/save_check_in_response_usecase.dart';
import 'package:athletica/features/check_ins/presentation/models/check_in_preview_role.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CheckInsState {
  const CheckInsState();
}

final class CheckInsLoading extends CheckInsState {
  const CheckInsLoading();
}

final class CheckInsError extends CheckInsState {
  const CheckInsError(this.message, {this.connectionError = false});
  final String message;
  final bool connectionError;
}

final class CheckInsReady extends CheckInsState {
  const CheckInsReady({
    required this.entries,
    required this.questions,
    this.hasPending = false,
    this.history,
    this.saving = false,
    this.message,
    this.connectionError = false,
    this.previousHistory,
  });
  final List<CheckIn> entries;
  final List<CheckInQuestion> questions;

  final bool hasPending;

  /// Null while history loads; failures stay local to the history section.
  final ApiResult<List<CheckInSubmission>>? history;
  final ApiResult<List<CheckInSubmission>>? previousHistory;
  final bool saving;
  final String? message;
  final bool connectionError;

  CheckInStatus? get clientStatus {
    final visibleHistory = history is ApiSuccess<List<CheckInSubmission>> ? history : previousHistory;
    final submissions = switch (visibleHistory) {
      ApiSuccess(:final data) => data,
      _ => null,
    };
    if (!hasPending && submissions == null) return null;
    return CheckInClientStatus(
      hasPending: hasPending,
      answered: submissions?.isNotEmpty ?? false,
      submissionsCount: submissions?.length ?? 0,
    ).status;
  }
}

class CheckInsCubit extends Cubit<CheckInsState> {
  CheckInsCubit(
    this._getEntries,
    this._getQuestions,
    this._saveResponse,
    this._saveQuestions,
    this._getPending,
    this._assign,
    this._getCoachSubmissions,
    this._getCoachSubmissionDetail,
    this._getClientSubmissions,
  ) : super(const CheckInsLoading());
  final GetCheckInsUseCase _getEntries;
  final GetCheckInQuestionsUseCase _getQuestions;
  final SaveCheckInResponseUseCase _saveResponse;
  final SaveCheckInQuestionsUseCase _saveQuestions;
  final GetCheckinPendingUseCase _getPending;
  final AssignCheckInUseCase _assign;
  final GetCoachSubmissionsUseCase _getCoachSubmissions;
  final GetCoachSubmissionDetailUseCase _getCoachSubmissionDetail;
  final GetClientSubmissionsUseCase _getClientSubmissions;
  int _request = 0;
  String _query = '';
  CheckInStatus? _filter;
  CheckInPreviewRole _role = CheckInPreviewRole.coach;

  Future<void> load({
    String query = '',
    CheckInStatus? filter,
    CheckInPreviewRole role = CheckInPreviewRole.coach,
  }) async {
    _query = query;
    _filter = filter;
    _role = role;
    final request = ++_request;
    final previous = state is CheckInsReady ? state as CheckInsReady : null;
    if (role == CheckInPreviewRole.client) {
      await _loadClient(request, previous);
      return;
    }
    final entries = await _getEntries(query: query, status: filter);
    final questions = await _getQuestions();
    if (isClosed || request != _request) return;
    switch ((entries, questions)) {
      case (ApiSuccess(data: final list), ApiSuccess(data: final fields)):
        emit(CheckInsReady(entries: list, questions: fields));
      case (ApiError(:final failure), _):
        _loadFailure(failure, previous);
      case (_, ApiError(:final failure)):
        _loadFailure(failure, previous);
    }
  }

  void _loadFailure(AppFailure failure, CheckInsReady? previous) {
    if (failure is NetworkFailure && previous != null) {
      emit(
        CheckInsReady(
          entries: previous.entries,
          questions: previous.questions,
          hasPending: previous.hasPending,
          history: previous.history,
          previousHistory: previous.previousHistory,
          connectionError: true,
        ),
      );
    } else {
      emit(
        CheckInsError(
          failure.message,
          connectionError: failure is NetworkFailure,
        ),
      );
    }
  }

  Future<void> _loadClient(int request, CheckInsReady? previous) async {
    final pending = await _getPending();
    if (isClosed || request != _request) return;
    if (pending case ApiError(:final failure)) {
      _loadFailure(failure, previous);
      return;
    }
    final hasPending = (pending as ApiSuccess<bool>).data;
    final questions = hasPending
        ? await _getQuestions(coachView: false)
        : const ApiSuccess<List<CheckInQuestion>>([]);
    if (isClosed || request != _request) return;
    switch (questions) {
      case ApiError(:final failure):
        _loadFailure(failure, previous);
      case ApiSuccess(:final data):
        emit(
          CheckInsReady(
            entries: const [],
            questions: data,
            hasPending: hasPending,
            history: previous?.history,
            previousHistory: previous?.previousHistory,
          ),
        );
        await reloadClientHistory();
    }
  }

  int _historyRequest = 0;
  Future<void> reloadClientHistory() async {
    final current = state;
    if (current is! CheckInsReady || _role != CheckInPreviewRole.client) return;
    final request = ++_historyRequest;
    final loadRequest = _request;
    emit(
      CheckInsReady(
        entries: current.entries,
        questions: current.questions,
        hasPending: current.hasPending,
        saving: current.saving,
        message: current.message,
        history: current.history,
        previousHistory: current.history is ApiSuccess<List<CheckInSubmission>> ? current.history : current.previousHistory,
      ),
    );
    final result = await _getClientSubmissions();
    if (isClosed || request != _historyRequest || loadRequest != _request) {
      return;
    }
    final ready = state;
    if (ready is! CheckInsReady) return;
    emit(
      CheckInsReady(
        entries: ready.entries,
        questions: ready.questions,
        hasPending: ready.hasPending,
        saving: ready.saving,
        message: ready.message,
        history: result,
        previousHistory: ready.history is ApiSuccess<List<CheckInSubmission>> ? ready.history : ready.previousHistory,
      ),
    );
  }

  Future<void> refresh() async {
    // A pull-to-refresh must not clear the submit guard during an active write.
    if (state case CheckInsReady(saving: true)) return;
    await load(query: _query, filter: _filter, role: _role);
  }

  /// Client submit (`L3`). The `saving` flag guards double-taps; entered
  /// data is retained on recoverable failures. On success — and on the
  /// already-submitted 403 — pending state, questions and history are
  /// reloaded (CHECK_IN_NEW §3).
  Future<bool> saveResponse({
    required List<CheckInQuestion> questions,
    required Map<String, String> answers,
    Map<String, File> imageFiles = const {},
  }) async {
    final current = state;
    if (current is! CheckInsReady || current.saving) return false;
    emit(
      CheckInsReady(
        entries: current.entries,
        questions: current.questions,
        hasPending: current.hasPending,
        history: current.history,
        saving: true,
      ),
    );
    final result = await _saveResponse(
      questions: questions,
      answers: answers,
      imageFiles: imageFiles,
    );
    if (isClosed) return false;
    switch (result) {
      case ApiSuccess():
        await load(query: _query, filter: _filter, role: _role);
        return true;
      case ApiError(:final failure):
        if (failure is CheckinNoPendingFailure) {
          await load(query: _query, filter: _filter, role: _role);
          return false;
        }
        emit(
          CheckInsReady(
            entries: current.entries,
            questions: current.questions,
            hasPending: current.hasPending,
            history: current.history,
            message: failure.message,
          ),
        );
        return false;
    }
  }

  Future<bool> saveQuestions({
    required List<CheckInQuestion> current,
    required List<CheckInQuestion> updated,
  }) async {
    final ready = state;
    if (ready is! CheckInsReady || ready.saving) return false;
    emit(
      CheckInsReady(
        entries: ready.entries,
        questions: ready.questions,
        hasPending: ready.hasPending,
        history: ready.history,
        saving: true,
      ),
    );
    return _finishSave(
      await _saveQuestions(current: current, updated: updated),
      ready,
    );
  }

  /// Refresh even after partial success so already-assigned clients show Pending.
  Future<bool> assignCheckins(List<String> coachClientIds) async {
    final ready = state;
    if (ready is! CheckInsReady || ready.saving) return false;
    emit(
      CheckInsReady(
        entries: ready.entries,
        questions: ready.questions,
        hasPending: ready.hasPending,
        history: ready.history,
        saving: true,
      ),
    );
    String? error;
    for (final id in coachClientIds) {
      final result = await _assign(coachClientId: id);
      if (isClosed) return false;
      if (result case ApiError(:final failure)) {
        error = failure.message;
        break;
      }
    }
    await load(query: _query, filter: _filter, role: _role);
    if (isClosed) return false;
    final refreshed = state;
    if (error != null && refreshed is CheckInsReady) {
      emit(
        CheckInsReady(
          entries: refreshed.entries,
          questions: refreshed.questions,
          hasPending: refreshed.hasPending,
          history: refreshed.history,
          message: error,
        ),
      );
    } else if (error != null && refreshed is CheckInsError) {
      emit(CheckInsError('$error ${refreshed.message}'));
    }
    return error == null;
  }

  Future<ApiResult<List<CheckInSubmission>>> coachSubmissions(
    String coachClientId,
  ) => _getCoachSubmissions(coachClientId);

  Future<ApiResult<CheckInSubmission>> coachSubmissionDetail({
    required String coachClientId,
    required String submissionId,
  }) => _getCoachSubmissionDetail(
    coachClientId: coachClientId,
    submissionId: submissionId,
  );

  Future<bool> _finishSave(
    ApiResult<void> result,
    CheckInsReady previous,
  ) async {
    if (isClosed) return false;
    switch (result) {
      case ApiSuccess():
        await load(query: _query, filter: _filter, role: _role);
        return true;
      case ApiError(:final failure):
        emit(
          CheckInsReady(
            entries: previous.entries,
            questions: previous.questions,
            hasPending: previous.hasPending,
            history: previous.history,
          previousHistory: previous.previousHistory,
            message: failure.message,
          ),
        );
        return false;
    }
  }
}
