import 'package:athletica/features/client_coach/domain/entities/coach_link_request.dart';

/// Parses `POST /coach-requests`:
/// `{ "id", "coach_id", "client_id", "status", ... }`.
///
/// Some deployments also include coach info in the response; [coachName] is
/// best-effort parsed from it and empty when absent.
class CoachLinkRequestModel {
  const CoachLinkRequestModel({
    required this.id,
    required this.status,
    this.coachName = '',
  });

  final String id;
  final String status;
  final String coachName;

  factory CoachLinkRequestModel.fromJson(Map<String, dynamic> json) {
    return CoachLinkRequestModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      coachName: _parseCoachName(json),
    );
  }

  static String _parseCoachName(Map<String, dynamic> json) {
    final coach = json['coach'];
    if (coach is Map<String, dynamic>) {
      for (final key in ['username', 'name']) {
        final value = coach[key] as String?;
        if (value != null && value.isNotEmpty) return value;
      }
    }
    for (final key in ['coach_username', 'coach_name']) {
      final value = json[key] as String?;
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  CoachLinkRequest toEntity() => CoachLinkRequest(
        id: id,
        status: status,
        coachName: coachName,
      );
}
