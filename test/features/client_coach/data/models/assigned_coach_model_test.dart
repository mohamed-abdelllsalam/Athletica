import 'package:athletica/features/client_coach/data/models/assigned_coach_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const imageUrl = 'https://res.cloudinary.com/demo/image/upload/coach.jpg';

  Map<String, dynamic> backendShape({Object? profileImage = imageUrl}) {
    final coach = <String, dynamic>{
      'id': 'coach-1',
      'user': {'id': 'user-1', 'username': 'coach_ali', 'email': 'c@x.com'},
      'bio': 'Strength coach',
      'specialization': 'strength_training',
    };
    if (profileImage != _absent) coach['profile_image'] = profileImage;
    return {
      'coach': coach,
      'assigned_at': '2026-09-01T10:00:00Z',
    };
  }

  group('AssignedCoachModel.fromJson (GET /client/coach profile_image)', () {
    test('parses coach.profile_image into imageUrl', () {
      final model = AssignedCoachModel.fromJson(backendShape());

      expect(model.imageUrl, imageUrl);
      expect(model.id, 'coach-1');
      expect(model.username, 'coach_ali');
      expect(model.email, 'c@x.com');
      expect(model.assignedAt, DateTime.parse('2026-09-01T10:00:00Z'));
    });

    test('entity hasPhoto is true when a valid image URL exists', () {
      final entity = AssignedCoachModel.fromJson(backendShape()).toEntity();

      expect(entity.hasPhoto, isTrue);
    });

    test('profile_image null results in no image', () {
      final model = AssignedCoachModel.fromJson(
        backendShape(profileImage: null),
      );

      expect(model.imageUrl, isNull);
      expect(model.toEntity().hasPhoto, isFalse);
    });

    test('missing profile_image results in no image', () {
      final model = AssignedCoachModel.fromJson(backendShape());

      // Sanity: present image parses; removing the key must not.
      expect(model.imageUrl, isNotNull);

      final json = backendShape();
      (json['coach'] as Map<String, dynamic>).remove('profile_image');
      final missing = AssignedCoachModel.fromJson(json);

      expect(missing.imageUrl, isNull);
      expect(missing.toEntity().hasPhoto, isFalse);
    });

    test('empty and literal "null" values are treated as no image', () {
      for (final bad in ['', '   ', 'null', 'NULL']) {
        final model = AssignedCoachModel.fromJson(
          backendShape(profileImage: bad),
        );

        expect(model.imageUrl, isNull, reason: 'value: "$bad"');
        expect(model.toEntity().hasPhoto, isFalse, reason: 'value: "$bad"');
      }
    });
  });
}

/// Sentinel distinguishing "key absent" from "key present with null".
const _absent = Object();
