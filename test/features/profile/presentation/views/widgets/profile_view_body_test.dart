import 'package:athletica/features/profile/domain/entities/user_profile_entity.dart';
import 'package:athletica/features/profile/presentation/views/widgets/profile_assigned_plans_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _profileWithPlans = ClientProfileEntity(
  id: 'user-1',
  email: 'o@x.com',
  name: 'Omar',
  gender: 'male',
  height: 180,
  weight: 75,
  goal: 'lose weight',
  workoutPlan: AssignedWorkoutPlanSummary(
    id: '10',
    title: 'Week 1 - Push Pull Legs',
    description: 'Strength block',
  ),
  nutritionPlan: AssignedNutritionPlanSummary(
    id: '20',
    title: 'High Protein Plan',
    description: 'Cutting',
  ),
);

const _profileWithoutPlans = ClientProfileEntity(
  id: 'user-1',
  email: 'o@x.com',
  name: 'Omar',
  goal: 'lose weight',
);

Future<void> _pumpSection(
  WidgetTester tester,
  ClientProfileEntity? profile,
) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProfileAssignedPlansSection(profile: profile),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('ProfileAssignedPlansSection', () {
    testWidgets('shows the assigned workout and nutrition plans', (
      tester,
    ) async {
      await _pumpSection(tester, _profileWithPlans);

      expect(find.text('Week 1 - Push Pull Legs'), findsOneWidget);
      expect(find.text('Strength block'), findsOneWidget);
      expect(find.text('High Protein Plan'), findsOneWidget);
      expect(find.text('Cutting'), findsOneWidget);
      expect(find.text('lose weight'), findsOneWidget);
      expect(find.text('No workout plan assigned yet'), findsNothing);
      expect(find.text('No nutrition plan assigned yet'), findsNothing);
    });

    testWidgets('shows empty placeholders when no plans are assigned', (
      tester,
    ) async {
      await _pumpSection(tester, _profileWithoutPlans);

      expect(find.text('No workout plan assigned yet'), findsOneWidget);
      expect(find.text('No nutrition plan assigned yet'), findsOneWidget);
      // Goal card still renders from the profile.
      expect(find.text('Fitness Goal'), findsOneWidget);
      expect(find.text('lose weight'), findsOneWidget);
    });

    testWidgets('shows a loader while the profile is loading', (tester) async {
      await _pumpSection(tester, null);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
