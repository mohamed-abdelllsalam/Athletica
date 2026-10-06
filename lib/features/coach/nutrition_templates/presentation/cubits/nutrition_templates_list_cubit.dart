import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_nutrition_template_detail_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_nutrition_templates_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/nutrition_template_ui_mapper.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class NutritionTemplatesListState {}

final class NutritionTemplatesListInitial extends NutritionTemplatesListState {}

final class NutritionTemplatesListLoading extends NutritionTemplatesListState {}

final class NutritionTemplatesListLoaded extends NutritionTemplatesListState {
  NutritionTemplatesListLoaded({
    required this.plans,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.connectionError = false,
  });

  final List<NutritionPlan> plans;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final bool connectionError;

  bool get hasMore => currentPage < totalPages;

  NutritionTemplatesListLoaded copyWith({
    bool? isLoadingMore,
    bool? connectionError,
  }) => NutritionTemplatesListLoaded(
    plans: plans,
    currentPage: currentPage,
    totalPages: totalPages,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    connectionError: connectionError ?? this.connectionError,
  );
}

final class NutritionTemplatesListError extends NutritionTemplatesListState {
  NutritionTemplatesListError(this.message, {this.connectionError = false});

  final String message;
  final bool connectionError;
}

class NutritionTemplatesListCubit extends Cubit<NutritionTemplatesListState> {
  NutritionTemplatesListCubit(this._getTemplates, this._getTemplateDetail)
    : super(NutritionTemplatesListInitial());

  static const int _pageSize = 20;

  final GetNutritionTemplatesUseCase _getTemplates;
  final GetNutritionTemplateDetailUseCase _getTemplateDetail;

  static const _mapper = NutritionTemplateUiMapper();
  NetworkFailure? _hydrationFailure;

  void _emitHydrationFailure(NutritionTemplatesListState previous) {
    if (previous is NutritionTemplatesListLoaded) {
      emit(previous.copyWith(isLoadingMore: false, connectionError: true));
    } else {
      emit(NutritionTemplatesListError(_hydrationFailure!.message, connectionError: true));
    }
  }

  Future<void> loadTemplates() async {
    final current = state;
    // Silent refresh: when data is already on screen, revalidate in the
    // background instead of flashing a loading state.
    final isSilentRefresh = current is NutritionTemplatesListLoaded;
    if (!isSilentRefresh && current is NutritionTemplatesListLoading) return;

    if (!isSilentRefresh) emit(NutritionTemplatesListLoading());

    final result = await _getTemplates(pageSize: _pageSize);
    switch (result) {
      case ApiSuccess(:final data):
        final plans = await _hydrate(data.templates);
        if (isClosed) return;
        if (_hydrationFailure != null) {
          _emitHydrationFailure(current);
          return;
        }
        emit(
          NutritionTemplatesListLoaded(
            plans: plans,
            currentPage: data.pagination.page,
            totalPages: data.pagination.totalPages,
          ),
        );
      case ApiError(:final failure):
        // On silent-refresh failure keep the existing data visible.
        if (failure is NetworkFailure &&
            current is NutritionTemplatesListLoaded) {
          if (isClosed) return;
          emit(current.copyWith(isLoadingMore: false, connectionError: true));
        } else if (!isSilentRefresh) {
          if (isClosed) return;
          emit(
            NutritionTemplatesListError(
              failure.message,
              connectionError: failure is NetworkFailure,
            ),
          );
        }
    }
  }

  Future<void> loadMore() async {
    final state = this.state;
    if (state is! NutritionTemplatesListLoaded ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    final result = await _getTemplates(
      page: state.currentPage + 1,
      pageSize: _pageSize,
    );
    switch (result) {
      case ApiSuccess(:final data):
        final existingIds = state.plans.map((p) => p.id).toSet();
        final newPlans = (await _hydrate(
          data.templates,
        )).where((p) => !existingIds.contains(p.id)).toList();
        if (isClosed) return;
        if (_hydrationFailure != null) {
          _emitHydrationFailure(state);
          return;
        }
        emit(
          NutritionTemplatesListLoaded(
            plans: [...state.plans, ...newPlans],
            currentPage: data.pagination.page,
            totalPages: data.pagination.totalPages,
          ),
        );
      case ApiError(:final failure):
        if (isClosed) return;
        if (failure is NetworkFailure) {
          emit(state.copyWith(isLoadingMore: false, connectionError: true));
        } else {
          emit(NutritionTemplatesListError(failure.message));
        }
    }
  }

  /// The list endpoint returns no macro totals; details are fetched so the
  /// approved card layout can show real aggregated values.
  Future<List<NutritionPlan>> _hydrate(List<NutritionTemplate> summaries) {
    _hydrationFailure = null;
    return Future.wait(
        summaries.map((summary) async {
          final detail = await _getTemplateDetail(summary.id);
          if (detail case ApiError(failure: final NetworkFailure failure)) {
            _hydrationFailure = failure;
          }
          return switch (detail) {
            ApiSuccess(:final data) => _mapper.toPlan(data),
            ApiError() => _mapper.toPlan(summary),
          };
        }),
      );
  }
}
