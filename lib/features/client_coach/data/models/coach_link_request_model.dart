import 'package:athletica/features/client_coach/domain/entities/coach_link_request.dart';

/// Parses `POST /coach-requests`:
/// `{ "id", "coach_id", "client_id", "status", ... }`.
///
/// Newer backends return `{ "id", "status", "coach": { "id", "user", ... } }`
/// where ids may be ints; [coachName] is best-effort parsed from the nested
/// coach object and empty when absent.
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
      // Backend may return int ids (e.g. `{ "id": 123, ... }`); never cast.
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      coachName: _parseCoachName(json),
    );
  }

  static String _parseCoachName(Map<String, dynamic> json) {
    final coach = json['coach'];
    if (coach is Map<String, dynamic>) {
      for (final key in ['username', 'name']) {
        final value = coach[key]?.toString();
        if (value != null && value.isNotEmpty) return value;
      }
    }
    for (final key in ['coach_username', 'coach_name']) {
      final value = json[key]?.toString();
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
