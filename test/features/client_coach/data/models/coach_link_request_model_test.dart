import 'package:athletica/features/client_coach/data/models/coach_link_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoachLinkRequestModel.fromJson (POST /coach-requests)', () {
    test('parses new backend shape with int ids without throwing', () {
      final model = CoachLinkRequestModel.fromJson({
        'id': 123,
        'status': 'pending',
        'coach': {
          'id': 10,
          'user': <String, dynamic>{},
          'profile_image': 'https://res.cloudinary.com/demo/coach.jpg',
        },
      });

      expect(model.id, '123');
      expect(model.status, 'pending');
      // No coach name in this shape: best-effort stays empty.
      expect(model.coachName, isEmpty);
      expect(model.toEntity().id, '123');
      expect(model.toEntity().hasCoachName, isFalse);
    });

    test('parses legacy string-id shape with nested coach username', () {
      final model = CoachLinkRequestModel.fromJson({
        'id': 'req-1',
        'coach_id': 'coach-1',
        'client_id': 'client-1',
        'status': 'pending',
        'coach': {'username': 'coach_ali'},
      });

      expect(model.id, 'req-1');
      expect(model.status, 'pending');
      expect(model.coachName, 'coach_ali');
      expect(model.toEntity().hasCoachName, isTrue);
    });

    test('falls back to coach name and flat coach_* keys', () {
      final byName = CoachLinkRequestModel.fromJson({
        'id': 'r1',
        'status': 'pending',
        'coach': {'name': 'Ali'},
      });
      expect(byName.coachName, 'Ali');

      final flat = CoachLinkRequestModel.fromJson({
        'id': 'r2',
        'status': 'pending',
        'coach_name': 'Sara',
      });
      expect(flat.coachName, 'Sara');
    });

    test('missing status defaults to pending and missing id to empty', () {
      final model = CoachLinkRequestModel.fromJson({
        'coach': <String, dynamic>{},
      });

      expect(model.id, isEmpty);
      expect(model.status, 'pending');
      expect(model.coachName, isEmpty);
    });
  });
}
