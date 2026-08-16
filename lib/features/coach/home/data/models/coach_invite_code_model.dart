import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';

class CoachInviteCodeModel {
  const CoachInviteCodeModel({
    required this.id,
    required this.trainerId,
    required this.code,
    required this.totalClients,
    required this.inviteLink,
  });

  final String id;
  final String trainerId;
  final String code;
  final int totalClients;
  final String inviteLink;

  factory CoachInviteCodeModel.fromJson(Map<String, dynamic> json) {
    final rawTotalClients = json['totalClients'];
    final parsedTotalClients = rawTotalClients is int
        ? rawTotalClients
        : int.tryParse(rawTotalClients?.toString() ?? '') ?? 0;

    return CoachInviteCodeModel(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String? ?? '',
      code: json['code'] as String? ?? '',
      totalClients: parsedTotalClients,
      inviteLink: json['inviteLink'] as String? ?? '',
    );
  }

  CoachInviteCode toEntity() => CoachInviteCode(
    id: id,
    trainerId: trainerId,
    code: code,
    totalClients: totalClients,
    inviteLink: inviteLink,
  );
}
