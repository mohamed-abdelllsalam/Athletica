import 'package:athletica/features/check_ins/domain/entities/check_in.dart';

class CheckInClientStatusModel extends CheckInClientStatus {
  const CheckInClientStatusModel({
    required super.hasPending,
    required super.answered,
    required super.submissionsCount,
    super.lastSubmittedAt,
  });

  factory CheckInClientStatusModel.fromJson(Map<String, dynamic> json) {
    final pending = json['has_pending'];
    final answered = json['answered'];
    final count = json['submissions_count'];
    final rawDate = json['last_submitted_at'];
    final date = rawDate is String ? DateTime.tryParse(rawDate) : null;
    if (pending is! bool ||
        answered is! bool ||
        count is! int ||
        count < 0 ||
        (rawDate != null && date == null)) {
      throw const FormatException('Unexpected check-in status response');
    }
    return CheckInClientStatusModel(
      hasPending: pending,
      answered: answered,
      submissionsCount: count,
      lastSubmittedAt: date,
    );
  }
}
