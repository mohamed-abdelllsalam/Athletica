import 'package:athletica/features/profile/data/models/user_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> profileResponse({
  Object? assignedAt = '2026-09-15T10:00:00Z',
  Object? workoutPlan = const {
    'id': 10,
    'title': 'Week 1 - Push Pull Legs',
    'description': 'Strength block',
    'is_active': true,
    'created_at': '2026-09-01T08:00:00Z',
    'start_date': '2026-09-01T00:00:00Z',
    'cycle_days': 6,
  },
  Object? nutritionPlan = const {
    'id': 20,
    'title': 'High Protein Plan',
    'description': 'Cutting',
    'is_active': true,
    'created_at': '2026-09-02T08:00:00Z',
  },
}) {
  final json = <String, dynamic>{
    'user': {
      'id': 'user-1',
      'username': 'client_omar',
      'email': 'o@x.com',
      'role': 'client',
      'email_verified': true,
      'created_at': '2026-01-01T00:00:00Z',
    },
    'profile': {
      'id': 'profile-1',
      'gender': 'male',
      'birth_date': '1995-05-05',
      'height': 180,
      'weight': 75,
      'goal': 'lose_weight',
      'phone_number': '0100',
      'location': 'Cairo, Egypt',
      'profile_image': 'https://example.com/me.jpg',
    },
  };
  if (assignedAt != _absent) json['assigned_at'] = assignedAt;
  if (workoutPlan != _absent) json['workout_plan'] = workoutPlan;
  if (nutritionPlan != _absent) json['nutrition_plan'] = nutritionPlan;
  return json;
}

void main() {
  group('UserProfileModel.fromJson (GET /profile assigned plans)', () {
    test('parses full response with assigned_at and both plans', () {
      final model = UserProfileModel.fromJson(profileResponse());
      final entity = model.toClientEntity();

      expect(model.assignedAt, DateTime.parse('2026-09-15T10:00:00Z'));
      expect(entity.assignedAt, DateTime.parse('2026-09-15T10:00:00Z'));

      expect(model.workoutPlan, isNotNull);
      expect(model.workoutPlan!.id, '10');
      expect(model.workoutPlan!.title, 'Week 1 - Push Pull Legs');
      expect(model.workoutPlan!.description, 'Strength block');
      expect(model.workoutPlan!.isActive, isTrue);
      expect(
        model.workoutPlan!.createdAt,
        DateTime.parse('2026-09-01T08:00:00Z'),
      );
      expect(model.workoutPlan!.startDate, '2026-09-01T00:00:00Z');
      expect(model.workoutPlan!.cycleDays, 6);

      expect(model.nutritionPlan, isNotNull);
      expect(model.nutritionPlan!.id, '20');
      expect(model.nutritionPlan!.title, 'High Protein Plan');
      expect(model.nutritionPlan!.isActive, isTrue);
      expect(
        model.nutritionPlan!.createdAt,
        DateTime.parse('2026-09-02T08:00:00Z'),
      );

      // Existing fields keep parsing.
      expect(entity.name, 'client_omar');
      expect(entity.gender, 'male');
      expect(entity.goal, 'lose weight');
      expect(entity.workoutPlan!.title, 'Week 1 - Push Pull Legs');
      expect(entity.nutritionPlan!.title, 'High Protein Plan');
    });

    test('assigned_at null is preserved', () {
      final model = UserProfileModel.fromJson(
        profileResponse(assignedAt: null),
      );

      expect(model.assignedAt, isNull);
      expect(model.toClientEntity().assignedAt, isNull);
      expect(model.workoutPlan, isNotNull);
      expect(model.nutritionPlan, isNotNull);
    });

    test('workout_plan null yields null plan', () {
      final model = UserProfileModel.fromJson(
        profileResponse(workoutPlan: null),
      );

      expect(model.workoutPlan, isNull);
      expect(model.toClientEntity().workoutPlan, isNull);
      expect(model.nutritionPlan, isNotNull);
    });

    test('nutrition_plan null yields null plan', () {
      final model = UserProfileModel.fromJson(
        profileResponse(nutritionPlan: null),
      );

      expect(model.nutritionPlan, isNull);
      expect(model.toClientEntity().nutritionPlan, isNull);
      expect(model.workoutPlan, isNotNull);
    });

    test('missing keys (old backend) yield nulls without breaking', () {
      final model = UserProfileModel.fromJson(
        profileResponse(
          assignedAt: _absent,
          workoutPlan: _absent,
          nutritionPlan: _absent,
        ),
      );
      final entity = model.toClientEntity();

      expect(model.assignedAt, isNull);
      expect(model.workoutPlan, isNull);
      expect(model.nutritionPlan, isNull);
      expect(entity.assignedAt, isNull);
      expect(entity.workoutPlan, isNull);
      expect(entity.nutritionPlan, isNull);
      // Existing contract intact.
      expect(entity.name, 'client_omar');
      expect(entity.height, 180);
      expect(entity.weight, 75);
    });

    test('partially missing plan fields fall back to defaults', () {
      final model = UserProfileModel.fromJson(
        profileResponse(
          workoutPlan: {'id': 7, 'title': 'Partial'},
          nutritionPlan: {'id': 8},
        ),
      );

      expect(model.workoutPlan!.id, '7');
      expect(model.workoutPlan!.title, 'Partial');
      expect(model.workoutPlan!.description, isEmpty);
      expect(model.workoutPlan!.isActive, isTrue);
      expect(model.workoutPlan!.createdAt, isNull);
      expect(model.workoutPlan!.startDate, isEmpty);
      expect(model.workoutPlan!.cycleDays, 0);

      expect(model.nutritionPlan!.id, '8');
      expect(model.nutritionPlan!.title, isEmpty);
    });

    test('non-map plan values are treated as absent', () {
      final model = UserProfileModel.fromJson(
        profileResponse(workoutPlan: 'oops', nutritionPlan: 42),
      );

      expect(model.workoutPlan, isNull);
      expect(model.nutritionPlan, isNull);
    });
  });
}

/// Sentinel distinguishing "key absent" from "key present with null".
const _absent = Object();
