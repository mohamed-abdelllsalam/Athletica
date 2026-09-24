import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';

class CoachAchievementModel extends CoachAchievement {
  const CoachAchievementModel({
    required super.id,
    required super.coachId,
    required super.title,
    required super.fileUrl,
    required super.mimeType,
    required super.createdAt,
    super.fileName,
    super.fileSize,
  });

  factory CoachAchievementModel.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final createdAtValue = root['created_at'] ?? root['createdAt'];
    final createdAt = DateTime.tryParse(createdAtValue?.toString() ?? '');
    if (createdAt == null) {
      throw const FormatException('Invalid certificate creation date.');
    }

    return CoachAchievementModel(
      id: _requiredString(root['id'], 'id'),
      coachId: _requiredString(root['coach_id'] ?? root['coachId'], 'coach_id'),
      title: _requiredString(root['title'], 'title'),
      fileUrl: _requiredString(root['file_url'] ?? root['fileUrl'], 'file_url'),
      fileName: _optionalString(root['file_name'] ?? root['fileName']),
      fileSize: _optionalInt(root['file_size'] ?? root['fileSize']),
      mimeType:
          _optionalString(root['mime_type'] ?? root['mimeType']) ??
          'application/pdf',
      createdAt: createdAt,
    );
  }

  CoachAchievement toEntity() => CoachAchievement(
    id: id,
    coachId: coachId,
    title: title,
    fileUrl: fileUrl,
    fileName: fileName,
    fileSize: fileSize,
    mimeType: mimeType,
    createdAt: createdAt,
  );

  static String _requiredString(Object? value, String field) {
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('Invalid certificate $field.');
  }

  static String? _optionalString(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }

  static int? _optionalInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
