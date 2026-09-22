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
  const CheckInsError(this.message);
  final String message;
}

final class CheckInsReady extends CheckInsState {
  const CheckInsReady({
    required this.entries,
    required this.questions,
    this.hasPending = false,
    this.saving = false,
    this.message,
  });
  final List<CheckIn> entries;
  final List<CheckInQuestion> questions;

  /// Client pending flag (`L1`). Always false for the coach roster: the
  /// backend exposes no coach-side pending status.
  final bool hasPending;
  final bool saving;
  final String? message;
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
    if (role == CheckInPreviewRole.client) {
      await _loadClient(request);
      return;
    }
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

  Future<void> _loadClient(int request) async {
    final pending = await _getPending();
    final questions = await _getQuestions(coachView: false);
    final history = await _getClientSubmissions();
    if (isClosed || request != _request) return;
    final hasPending = switch (pending) {
      ApiSuccess(:final data) => data,
      ApiError() => false,
    };
    switch ((questions, history)) {
      case (ApiSuccess(data: final fields), ApiSuccess(data: final items)):
        emit(
          CheckInsReady(
            entries: [
              for (final s in items)
                CheckIn(
                  id: s.id,
                  clientName: '',
                  status: CheckInStatus.completed,
                  timeLabel: s.submittedAt?.toIso8601String() ?? '—',
                  answers: {
                    for (final a in s.answers)
                      if (a.questionId != null) a.questionId!: a.answerValue,
                  },
                ),
            ],
            questions: fields,
            hasPending: hasPending,
          ),
        );
      case (ApiError(:final failure), _):
        emit(CheckInsError(failure.message));
      case (_, ApiError(:final failure)):
        emit(CheckInsError(failure.message));
    }
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
        saving: true,
      ),
    );
    return _finishSave(
      await _saveQuestions(current: current, updated: updated),
      ready,
    );
  }

  /// Assigns a pending check-in to each selected client (`C6`,
  /// `coach_clients.id`). Returns false with the first error message on
  /// failure; successes refresh nothing coach-side (no pending status is
  /// exposed) — the client's next refresh shows the banner.
  Future<bool> assignCheckins(List<String> coachClientIds) async {
    final ready = state;
    if (ready is! CheckInsReady || ready.saving) return false;
    emit(
      CheckInsReady(
        entries: ready.entries,
        questions: ready.questions,
        hasPending: ready.hasPending,
        saving: true,
      ),
    );
    for (final id in coachClientIds) {
      final result = await _assign(coachClientId: id);
      if (result is ApiError) {
        if (isClosed) return false;
        emit(
          CheckInsReady(
            entries: ready.entries,
            questions: ready.questions,
            hasPending: ready.hasPending,
            message: result.failure.message,
          ),
        );
        return false;
      }
    }
    if (isClosed) return false;
    emit(
      CheckInsReady(
        entries: ready.entries,
        questions: ready.questions,
        hasPending: ready.hasPending,
      ),
    );
    return true;
  }

  Future<ApiResult<List<CheckInSubmission>>> coachSubmissions(
    String coachClientId,
  ) =>
      _getCoachSubmissions(coachClientId);

  Future<ApiResult<CheckInSubmission>> coachSubmissionDetail({
    required String coachClientId,
    required String submissionId,
  }) =>
      _getCoachSubmissionDetail(
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
            message: failure.message,
          ),
        );
        return false;
    }
  }
}
