import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_plans_list_view_body.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';
import 'package:athletica/features/workout/domain/usecases/create_workout_template_v1_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/delete_workout_template_usecase.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_templates_v1_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand fake: only the use cases below are ever called; anything else
/// would throw via noSuchMethod instead of silently returning nulls.
class _FakeWorkoutRepository implements WorkoutRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeGetTemplates extends GetWorkoutTemplatesV1UseCase {
  _FakeGetTemplates() : super(_FakeWorkoutRepository());

  @override
  Future<ApiResult<({List<WorkoutTemplateEntry> items, ApiPagination pagination})>>
      call({int page = 1, int pageSize = 10}) => Future.value(
            const ApiSuccess(
              (
                items: <WorkoutTemplateEntry>[],
                pagination: ApiPagination(
                  page: 1,
                  pageSize: 10,
                  total: 0,
                  totalPages: 0,
                ),
              ),
            ),
          );
}

class _FakeCreateTemplate extends CreateWorkoutTemplateV1UseCase {
  _FakeCreateTemplate() : super(_FakeWorkoutRepository());

  @override
  Future<ApiResult<WorkoutTemplateEntry>> call({
    required String title,
    required String description,
  }) =>
      Future.value(
        const ApiSuccess(
          WorkoutTemplateEntry(
            id: 't1',
            title: 'Legs',
            description: 'd',
            coachId: 'c',
            dayCount: 0,
            days: [],
          ),
        ),
      );
}

class _FakeDeleteTemplate extends DeleteWorkoutTemplateUseCase {
  _FakeDeleteTemplate() : super(_FakeWorkoutRepository());
}

Future<void> _pumpList(WidgetTester tester) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => MaterialApp(
        home: BlocProvider<WorkoutTemplatesCubit>(
          create: (_) => WorkoutTemplatesCubit(
            _FakeGetTemplates(),
            _FakeCreateTemplate(),
            _FakeDeleteTemplate(),
          )..load(),
          child: const Scaffold(body: WorkoutPlansListViewBody()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'create-template dialog pops and settles without using disposed controllers',
    (tester) async {
      await _pumpList(tester);
      expect(find.text('No programs found'), findsOneWidget);

      await tester.tap(find.text('Create New Plan'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      final fields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      expect(fields, findsNWidgets(2));
      await tester.enterText(fields.at(0), 'Legs');
      await tester.enterText(fields.at(1), 'Leg day');

      // Popping the dialog runs its exit animation while the test settles
      // every frame: with controllers disposed right after showDialog (the
      // reported bug), painting those frames throws
      // "TextEditingController was used after being disposed".
      await tester.tap(find.widgetWithText(TextButton, 'Create'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('No programs found'), findsOneWidget);
    },
  );
}
