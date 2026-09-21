import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/assigned_client.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/assign_nutrition_template_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_assigned_clients_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/remove_assigned_client_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/assign_plan_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _clientA = AssignedClient(
  relationId: 'rel-a',
  clientId: 'client-a',
  name: 'Ali',
  email: 'ali@x.com',
  goal: 'lose weight',
);

const _clientB = AssignedClient(
  relationId: 'rel-b',
  clientId: 'client-b',
  name: 'Sara',
  email: 'sara@x.com',
  goal: 'muscle gain',
);

/// Hand-written fake: only the roster/assign surface is configurable, the
/// rest of the 16-method contract returns a generic error.
class _FakeNutritionTemplatesRepository
    implements NutritionTemplatesRepository {
  _FakeNutritionTemplatesRepository({
    this.clientsResult = const ApiSuccess([_clientA, _clientB]),
    this.assignResult = const ApiSuccess(null),
  });

  ApiResult<List<AssignedClient>> clientsResult;
  ApiResult<void> assignResult;
  String? lastAssignedCoachClientId;

  ApiError<Never> _unused() =>
      const ApiError<Never>(UnknownFailure('unused'));

  @override
  Future<ApiResult<List<AssignedClient>>> getAssignedClients() async =>
      clientsResult;

  @override
  Future<ApiResult<void>> assignNutritionTemplate(
    String templateId, {
    required String coachClientId,
    required String title,
    required String description,
  }) async {
    lastAssignedCoachClientId = coachClientId;
    return assignResult;
  }

  @override
  Future<ApiResult<void>> removeAssignedClient(String clientId) async =>
      const ApiSuccess(null);

  @override
  Future<TemplatesPageResult> getNutritionTemplates({
    int page = 1,
    int pageSize = 20,
  }) async => _unused();

  @override
  Future<ApiResult<Never>> createNutritionTemplate({
    required String title,
    required String description,
  }) async => _unused();

  @override
  Future<ApiResult<Never>> getNutritionTemplate(String templateId) async =>
      _unused();

  @override
  Future<ApiResult<void>> updateNutritionTemplate(
    String templateId, {
    String? title,
    String? description,
  }) async => _unused();

  @override
  Future<ApiResult<void>> deleteNutritionTemplate(String templateId) async =>
      _unused();

  @override
  Future<ApiResult<Never>> addTemplateMeal(
    String templateId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  }) async => _unused();

  @override
  Future<ApiResult<void>> updateTemplateMeal(
    String templateId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  }) async => _unused();

  @override
  Future<ApiResult<void>> deleteTemplateMeal(
    String templateId,
    String mealId,
  ) async => _unused();

  @override
  Future<ApiResult<void>> reorderTemplateMeals(
    String templateId,
    List<({String mealId, int mealOrder})> mealOrders,
  ) async => _unused();

  @override
  Future<ApiResult<void>> addTemplateFood(
    String templateId,
    String mealId, {
    required String foodId,
    required num quantity,
  }) async => _unused();

  @override
  Future<ApiResult<void>> updateTemplateFood(
    String templateId,
    String mealId,
    String relationFoodId, {
    required num quantity,
  }) async => _unused();

  @override
  Future<ApiResult<void>> removeTemplateFood(
    String templateId,
    String mealId,
    String relationFoodId,
  ) async => _unused();
}

AssignPlanCubit _cubit(_FakeNutritionTemplatesRepository repository) {
  final cubit = AssignPlanCubit(
    GetAssignedClientsUseCase(repository),
    AssignNutritionTemplateUseCase(repository),
    RemoveAssignedClientUseCase(repository),
  );
  addTearDown(cubit.close);
  return cubit;
}

void main() {
  group('AssignPlanCubit.loadClients', () {
    test('emits loaded roster on success', () async {
      final cubit = _cubit(_FakeNutritionTemplatesRepository());

      await cubit.loadClients();

      final state = cubit.state;
      expect(state, isA<AssignPlanClientsLoaded>());
      expect((state as AssignPlanClientsLoaded).clients, [_clientA, _clientB]);
    });

    test('emits error with server message on failure', () async {
      final cubit = _cubit(
        _FakeNutritionTemplatesRepository(
          clientsResult: const ApiError(ServerFailure('roster down')),
        ),
      );

      await cubit.loadClients();

      final state = cubit.state;
      expect(state, isA<AssignPlanClientsError>());
      expect((state as AssignPlanClientsError).message, 'roster down');
    });

    test('empty roster loads as empty (genuine no-clients case)', () async {
      final cubit = _cubit(
        _FakeNutritionTemplatesRepository(
          clientsResult: const ApiSuccess(<AssignedClient>[]),
        ),
      );

      await cubit.loadClients();

      final state = cubit.state;
      expect(state, isA<AssignPlanClientsLoaded>());
      expect((state as AssignPlanClientsLoaded).clients, isEmpty);
    });
  });

  group('AssignPlanCubit.assign', () {
    test('sends the relation id as coach_client_id on success', () async {
      final repository = _FakeNutritionTemplatesRepository();
      final cubit = _cubit(repository);
      await cubit.loadClients();

      await cubit.assign(
        templateId: 'tpl-1',
        coachClientId: 'rel-b',
        title: 'Plan',
        description: 'Desc',
      );

      expect(cubit.state, isA<AssignPlanSuccess>());
      expect(repository.lastAssignedCoachClientId, 'rel-b');
    });

    test('emits error with clients preserved on failure', () async {
      final cubit = _cubit(
        _FakeNutritionTemplatesRepository(
          assignResult: const ApiError(ServerFailure('assign failed')),
        ),
      );
      await cubit.loadClients();

      await cubit.assign(
        templateId: 'tpl-1',
        coachClientId: 'rel-a',
        title: 'Plan',
        description: 'Desc',
      );

      final state = cubit.state;
      expect(state, isA<AssignPlanError>());
      expect((state as AssignPlanError).message, 'assign failed');
      expect(state.clients, [_clientA, _clientB]);
    });
  });

  group('findRosterMatch', () {
    const clients = [_clientA, _clientB];

    test('matches by client_profiles.id', () {
      expect(findRosterMatch(clients, 'client-b'), _clientB);
    });

    test('matches by coach_clients relation id', () {
      expect(findRosterMatch(clients, 'rel-a'), _clientA);
    });

    test('returns null for unknown id (never falls back)', () {
      expect(findRosterMatch(clients, 'unknown'), isNull);
    });

    test('returns null for empty roster', () {
      expect(findRosterMatch(const [], 'client-a'), isNull);
    });
  });
}
