import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';

class CoachClientUserModel {
  const CoachClientUserModel({
    required this.id,
    required this.name,
    this.profileImage,
  });

  final String id;
  final String name;
  final String? profileImage;

  factory CoachClientUserModel.fromJson(Map<String, dynamic> json) =>
      CoachClientUserModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        profileImage: json['profileImage'] as String?,
      );
}

class CoachClientModel {
  const CoachClientModel({
    required this.id,
    required this.clientId,
    required this.startedAt,
    required this.status,
    required this.client,
    this.expiresInDays,
    this.subscriptionEndDate,
  });

  final String id;
  final String clientId;
  final DateTime startedAt;
  final String status;
  final CoachClientUserModel client;
  final int? expiresInDays;
  final String? subscriptionEndDate;

  factory CoachClientModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['startedAt'] as String?;
    final parsedDate = rawDate != null
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();
    final rawExpiresInDays = json['expiresInDays'] ?? json['expires_in_days'];
    int? parsedExpiresInDays;
    if (rawExpiresInDays is int) {
      parsedExpiresInDays = rawExpiresInDays;
    } else if (rawExpiresInDays is String) {
      parsedExpiresInDays = int.tryParse(rawExpiresInDays);
    }
    final rawSubscriptionEndDate =
        json['subscriptionEndDate'] ?? json['subscription_end_date'];
    final parsedSubscriptionEndDate = rawSubscriptionEndDate?.toString();

    return CoachClientModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String? ?? json['id'] as String,
      startedAt: parsedDate,
      status: json['status'] as String? ?? 'active',
      client: CoachClientUserModel.fromJson(
        json['client'] as Map<String, dynamic>? ??
            {'id': json['clientId'] ?? json['id'], 'name': ''},
      ),
      expiresInDays: parsedExpiresInDays,
      subscriptionEndDate: parsedSubscriptionEndDate,
    );
  }

  CoachClient toEntity() {
    final monthsAgo = DateTime.now().difference(startedAt).inDays ~/ 30;
    return CoachClient(
      id: clientId,
      name: client.name,
      joinedMonthsAgo: monthsAgo < 0 ? 0 : monthsAgo,
      subscriptionActive: status == 'active',
      expiresInDays: expiresInDays,
      subscriptionEndDate: subscriptionEndDate,
      imageAsset: client.profileImage,
    );
  }
}
