import 'package:athletica/features/client_coach/domain/entities/coach_link_request.dart';

/// Parses `POST /coach-requests`:
/// `{ "id", "coach_id", "client_id", "status", ... }`
class CoachLinkRequestModel {
  const CoachLinkRequestModel({required this.id, required this.status});

  final String id;
  final String status;

  factory CoachLinkRequestModel.fromJson(Map<String, dynamic> json) {
    return CoachLinkRequestModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }

  CoachLinkRequest toEntity() => CoachLinkRequest(id: id, status: status);
}
