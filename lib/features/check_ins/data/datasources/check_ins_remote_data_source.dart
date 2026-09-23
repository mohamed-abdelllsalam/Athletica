import 'dart:convert';
import 'dart:io';

import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/utils/check_in_media.dart';
import 'package:athletica/features/check_ins/data/models/check_in_client_status_model.dart';
import 'package:athletica/features/check_ins/data/models/check_in_question_model.dart';
import 'package:athletica/features/check_ins/data/models/check_in_submission_model.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:dio/dio.dart';

List<Map<String, dynamic>> _listFor(dynamic body, String key) {
  if (body is Map<String, dynamic>) {
    final direct = body[key];
    if (direct is List) {
      return direct.whereType<Map<String, dynamic>>().toList();
    }
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final nested = data[key];
      if (nested is List) {
        return nested.whereType<Map<String, dynamic>>().toList();
      }
    }
  }
  return const [];
}

Map<String, dynamic> _mapFor(dynamic body, String key) {
  if (body is Map<String, dynamic>) {
    final direct = body[key];
    if (direct is Map<String, dynamic>) return direct;
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final nested = data[key];
      if (nested is Map<String, dynamic>) return nested;
    }
  }
  return const {};
}

abstract class CheckInsRemoteDataSource {
  Future<CheckInClientStatusModel> getCoachClientStatus(String coachClientId);
  // ── Coach (prefix /coach/checkin) ──
  Future<List<CheckInQuestionModel>> getCoachQuestions();
  Future<CheckInQuestionModel> createCoachQuestion({
    required String question,
    required String type,
    List<String>? options,
    bool? required,
    int? order,
  });
  Future<CheckInQuestionModel> updateCoachQuestion(
    String questionId, {
    String? question,
    String? type,
    List<String>? options,
    bool? required,
    int? order,
  });
  Future<void> deleteCoachQuestion(String questionId);
  Future<List<CheckInQuestionModel>> reorderCoachQuestions(
    List<String> questionIds,
  );
  Future<void> assignCheckin({required String coachClientId});
  Future<List<CheckInSubmissionModel>> getCoachSubmissions(
    String coachClientId,
  );
  Future<CheckInSubmissionModel> getCoachSubmissionDetail(
    String coachClientId,
    String submissionId,
  );

  // ── Client (prefix /client/checkin) ──
  Future<bool> hasPendingAssignment();
  Future<List<CheckInQuestionModel>> getClientQuestions();
  Future<CheckInSubmitResult> submitCheckin({
    required List<Map<String, String>> textAnswers,
    required Map<String, File> imageFiles,
  });
  Future<List<CheckInSubmissionModel>> getClientSubmissions();
  Future<CheckInSubmissionModel> getClientSubmissionDetail(String submissionId);
}

class CheckInsRemoteDataSourceImpl implements CheckInsRemoteDataSource {
  const CheckInsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  List<CheckInQuestionModel> _parseQuestions(dynamic body) {
    final items = _listFor(body, 'questions');
    final models = items.map(CheckInQuestionModel.fromJson).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return models;
  }

  CheckInQuestionModel _parseQuestion(dynamic body) {
    final map = _mapFor(body, 'question');
    if (map.isNotEmpty) return CheckInQuestionModel.fromJson(map);
    if (body is Map<String, dynamic>) {
      return CheckInQuestionModel.fromJson(body);
    }
    throw const FormatException('Unexpected question response format');
  }

  @override
  Future<CheckInClientStatusModel> getCoachClientStatus(
    String coachClientId,
  ) async {
    final response = await _dio.get(
      ApiEndpoints.coachCheckinStatus(coachClientId),
    );
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const FormatException('Unexpected check-in status response');
    }
    return CheckInClientStatusModel.fromJson(
      body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body,
    );
  }

  @override
  Future<List<CheckInQuestionModel>> getCoachQuestions() async {
    final response = await _dio.get(ApiEndpoints.coachCheckinQuestions);
    return _parseQuestions(response.data);
  }

  @override
  Future<CheckInQuestionModel> createCoachQuestion({
    required String question,
    required String type,
    List<String>? options,
    bool? required,
    int? order,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.coachCheckinQuestions,
      data: {
        'question': question,
        'type': type,
        'options': ?options,
        'required': ?required,
        'order': ?order,
      },
    );
    return _parseQuestion(response.data);
  }

  @override
  Future<CheckInQuestionModel> updateCoachQuestion(
    String questionId, {
    String? question,
    String? type,
    List<String>? options,
    bool? required,
    int? order,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.coachCheckinQuestion(questionId),
      data: {
        'question': ?question,
        'type': ?type,
        'options': ?options,
        'required': ?required,
        'order': ?order,
      },
    );
    return _parseQuestion(response.data);
  }

  @override
  Future<void> deleteCoachQuestion(String questionId) async {
    await _dio.delete(ApiEndpoints.coachCheckinQuestion(questionId));
  }

  @override
  Future<List<CheckInQuestionModel>> reorderCoachQuestions(
    List<String> questionIds,
  ) async {
    final response = await _dio.patch(
      ApiEndpoints.coachCheckinQuestionsReorder,
      data: {'question_ids': questionIds},
    );
    return _parseQuestions(response.data);
  }

  @override
  Future<void> assignCheckin({required String coachClientId}) async {
    await _dio.post(
      ApiEndpoints.coachCheckinAssign,
      data: {'coach_client_id': coachClientId},
    );
  }

  @override
  Future<List<CheckInSubmissionModel>> getCoachSubmissions(
    String coachClientId,
  ) async {
    final response = await _dio.get(
      ApiEndpoints.coachCheckinSubmissions(coachClientId),
    );
    return _listFor(
      response.data,
      'submissions',
    ).map(CheckInSubmissionModel.fromListJson).toList();
  }

  @override
  Future<CheckInSubmissionModel> getCoachSubmissionDetail(
    String coachClientId,
    String submissionId,
  ) async {
    final response = await _dio.get(
      ApiEndpoints.coachCheckinSubmission(coachClientId, submissionId),
    );
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return CheckInSubmissionModel.fromDetailJson(body);
    }
    throw const FormatException('Unexpected submission response format');
  }

  @override
  Future<bool> hasPendingAssignment() async {
    final response = await _dio.get(ApiEndpoints.clientCheckinHasAssign);
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final value = body['has_pending'];
      if (value is bool) return value;
      final data = body['data'];
      if (data is Map<String, dynamic> && data['has_pending'] is bool) {
        return data['has_pending'] as bool;
      }
    }
    throw const FormatException('Unexpected hasassign response format');
  }

  @override
  Future<List<CheckInQuestionModel>> getClientQuestions() async {
    final response = await _dio.get(ApiEndpoints.clientCheckinQuestions);
    return _parseQuestions(response.data);
  }

  @override
  Future<CheckInSubmitResult> submitCheckin({
    required List<Map<String, String>> textAnswers,
    required Map<String, File> imageFiles,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('answers', jsonEncode(textAnswers)));
    for (final entry in imageFiles.entries) {
      final file = entry.value;
      final fileName = file.path.split(Platform.pathSeparator).last;
      final contentType = checkInMimeForPath(file.path);
      formData.files.add(
        MapEntry(
          entry.key,
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: contentType,
          ),
        ),
      );
    }
    final response = await _dio.post(
      ApiEndpoints.clientCheckinSubmit,
      data: formData,
    );
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      final id = (data['submission_id'] ?? data['id'])?.toString() ?? '';
      final at = data['submitted_at']?.toString();
      return CheckInSubmitResult(
        submissionId: id,
        submittedAt: at == null ? null : DateTime.tryParse(at),
      );
    }
    throw const FormatException('Unexpected submit response format');
  }

  @override
  Future<List<CheckInSubmissionModel>> getClientSubmissions() async {
    final response = await _dio.get(ApiEndpoints.clientCheckinSubmissions);
    return _listFor(
      response.data,
      'submissions',
    ).map(CheckInSubmissionModel.fromListJson).toList();
  }

  @override
  Future<CheckInSubmissionModel> getClientSubmissionDetail(
    String submissionId,
  ) async {
    final response = await _dio.get(
      ApiEndpoints.clientCheckinSubmission(submissionId),
    );
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return CheckInSubmissionModel.fromDetailJson(body);
    }
    throw const FormatException('Unexpected submission response format');
  }
}
