import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/domain/entities/my_plan.dart';
import 'package:athletica/features/nutrition/domain/usecases/get_my_active_plan_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/get_my_plan_details_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class MyPlanDetailsState {
  const MyPlanDetailsState();
}

final class MyPlanDetailsInitial extends MyPlanDetailsState {
  const MyPlanDetailsInitial();
}

final class MyPlanDetailsLoading extends MyPlanDetailsState {
  const MyPlanDetailsLoading();
}

/// The active plan with its meals and foods.
final class MyPlanDetailsLoaded extends MyPlanDetailsState {
  const MyPlanDetailsLoaded(this.plan, {this.isConnectionError = false});
  final bool isConnectionError;

  final MyPlan plan;
}

/// The signed-in client has no active plan.
final class MyPlanDetailsNoPlan extends MyPlanDetailsState {
  const MyPlanDetailsNoPlan();
}

final class MyPlanDetailsError extends MyPlanDetailsState {
  const MyPlanDetailsError(this.message, {this.isConnectionError = false});
  final bool isConnectionError;

  final String message;
}

class MyPlanDetailsCubit extends Cubit<MyPlanDetailsState> {
  MyPlanDetailsCubit(this._getActivePlan, this._getPlanDetails)
    : super(const MyPlanDetailsInitial());

  final GetMyActivePlanUseCase _getActivePlan;
  final GetMyPlanDetailsUseCase _getPlanDetails;

  bool _loading = false;
  String? _scope;
  MyPlanDetailsLoaded? _cached;

  void _fail(AppFailure failure) {
    _loading = false;
    emit(
      failure is NetworkFailure && _cached != null
          ? MyPlanDetailsLoaded(_cached!.plan, isConnectionError: true)
          : MyPlanDetailsError(
              failure.message,
              isConnectionError: failure is NetworkFailure,
            ),
    );
  }

  Future<void> load({String? planId}) async {
    if (_loading || isClosed) return;
    _loading = true;
    if (_scope != planId) _cached = null;
    _scope = planId;
    if (_cached == null) emit(const MyPlanDetailsLoading());

    var resolvedPlanId = planId ?? '';
    if (resolvedPlanId.isEmpty) {
      final planResult = await _getActivePlan();
      switch (planResult) {
        case ApiSuccess(:final data):
          resolvedPlanId = data?.id ?? '';
        case ApiError(:final failure):
          if (isClosed) return;
          _fail(failure);
          return;
      }
    }
    if (resolvedPlanId.isEmpty) {
      if (isClosed) return;
      _loading = false;
      _cached = null;
      emit(const MyPlanDetailsNoPlan());
      return;
    }

    if (_cached != null && _cached!.plan.id != resolvedPlanId) {
      _cached = null;
      emit(const MyPlanDetailsLoading());
    }
    final detailsResult = await _getPlanDetails(resolvedPlanId);
    switch (detailsResult) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        _loading = false;
        _cached = MyPlanDetailsLoaded(data);
        emit(_cached!);
      case ApiError(:final failure):
        if (isClosed) return;
        _fail(failure);
    }
  }
}
