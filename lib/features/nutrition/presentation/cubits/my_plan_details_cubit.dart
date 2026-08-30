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
  const MyPlanDetailsLoaded(this.plan);

  final MyPlan plan;
}

/// The signed-in client has no active plan.
final class MyPlanDetailsNoPlan extends MyPlanDetailsState {
  const MyPlanDetailsNoPlan();
}

final class MyPlanDetailsError extends MyPlanDetailsState {
  const MyPlanDetailsError(this.message);

  final String message;
}

class MyPlanDetailsCubit extends Cubit<MyPlanDetailsState> {
  MyPlanDetailsCubit(
    this._getActivePlan,
    this._getPlanDetails,
  ) : super(const MyPlanDetailsInitial());

  final GetMyActivePlanUseCase _getActivePlan;
  final GetMyPlanDetailsUseCase _getPlanDetails;

  Future<void> load() async {
    if (state is MyPlanDetailsLoading) return;

    emit(const MyPlanDetailsLoading());

    var planId = '';
    final planResult = await _getActivePlan();
    switch (planResult) {
      case ApiSuccess(:final data):
        planId = data?.id ?? '';
      case ApiError(:final failure):
        if (isClosed) return;
        emit(MyPlanDetailsError(failure.message));
        return;
    }

    if (planId.isEmpty) {
      if (isClosed) return;
      emit(const MyPlanDetailsNoPlan());
      return;
    }

    final detailsResult = await _getPlanDetails(planId);
    switch (detailsResult) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(MyPlanDetailsLoaded(data));
      case ApiError(:final failure):
        if (isClosed) return;
        emit(MyPlanDetailsError(failure.message));
    }
  }
}
