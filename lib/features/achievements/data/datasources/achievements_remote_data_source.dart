import 'dart:io';

import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/achievements/data/models/coach_achievement_model.dart';
import 'package:dio/dio.dart';

abstract class AchievementsRemoteDataSource {
  Future<List<CoachAchievementModel>> getCoachAchievements();

  Future<CoachAchievementModel> uploadCoachAchievement({
    required String title,
    required File file,
  });

  Future<void> deleteCoachAchievement(String id);

  Future<List<CoachAchievementModel>> getAssignedCoachAchievements();
}

class AchievementsRemoteDataSourceImpl implements AchievementsRemoteDataSource {
  const AchievementsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CoachAchievementModel>> getCoachAchievements() async {
    final response = await _dio.get(ApiEndpoints.coachAchievements);
    return _parseAchievementList(response.data);
  }

  @override
  Future<CoachAchievementModel> uploadCoachAchievement({
    required String title,
    required File file,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('title', title.trim()));
    // Cross-platform basename (handles both '/' and '\' separators, e.g.
    // temp files on Windows vs. content-cache on Android).
    final rawSegments = file.path.split(RegExp(r'[\\/]'));
    final fileName = rawSegments.isNotEmpty && rawSegments.last.isNotEmpty
        ? rawSegments.last
        : 'certificate.pdf';
    formData.files.add(
      MapEntry(
        'pdf',
        await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: DioMediaType('application', 'pdf'),
        ),
      ),
    );

    final response = await _dio.post(
      ApiEndpoints.coachAchievements,
      data: formData,
    );
    return CoachAchievementModel.fromJson(_asMap(response.data));
  }

  @override
  Future<void> deleteCoachAchievement(String id) async {
    await _dio.delete(ApiEndpoints.coachAchievement(id));
  }

  @override
  Future<List<CoachAchievementModel>> getAssignedCoachAchievements() async {
    try {
      final response = await _dio.get(ApiEndpoints.clientCoachAchievements);
      return _parseAchievementList(response.data);
    } on DioException catch (e) {
      if (_isNoCoachAssigned(e)) return const [];
      rethrow;
    }
  }

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('Invalid certificate response.');
  }

  static List<CoachAchievementModel> _parseAchievementList(dynamic data) {
    dynamic root = data;
    if (root is Map && root['data'] is Map) {
      root = root['data'];
    }

    final Object? raw = switch (root) {
      List<dynamic>() => root,
      Map<dynamic, dynamic>() => root['achievements'],
      _ => null,
    };
    if (raw is! List) {
      throw const FormatException('Invalid certificate list response.');
    }

    return raw
        .map(
          (item) => CoachAchievementModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
  }

  static bool _isNoCoachAssigned(DioException exception) {
    final data = exception.response?.data;
    if (data is! Map) return false;
    final value = data['error']?.toString().trim().toLowerCase();
    return value == 'no_coach_assigned';
  }
}
