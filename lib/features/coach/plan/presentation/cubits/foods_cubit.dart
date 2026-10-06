import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_category.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:athletica/features/coach/plan/domain/usecases/get_food_categories_usecase.dart';
import 'package:athletica/features/coach/plan/domain/usecases/get_foods_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class FoodsState {}

final class FoodsInitial extends FoodsState {}

final class FoodsLoading extends FoodsState {}

final class FoodsLoaded extends FoodsState {
  FoodsLoaded({
    required this.foods,
    required this.categories,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.isFiltering = false,
    this.connectionError = false,
  });

  final List<FoodItem> foods;
  final List<FoodCategory> categories;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;

  /// True while a search/filter re-fetch is in flight; the previous list
  /// stays visible so filtering does not flash a loading state.
  final bool isFiltering;
  final bool connectionError;

  bool get hasMore => currentPage < totalPages;

  FoodsLoaded copyWith({
    bool? isLoadingMore,
    bool? isFiltering,
    bool? connectionError,
  }) => FoodsLoaded(
    foods: foods,
    categories: categories,
    currentPage: currentPage,
    totalPages: totalPages,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isFiltering: isFiltering ?? this.isFiltering,
    connectionError: connectionError ?? this.connectionError,
  );
}

final class FoodsError extends FoodsState {
  FoodsError(this.message, {this.connectionError = false});

  final String message;
  final bool connectionError;
}

class FoodsCubit extends Cubit<FoodsState> {
  FoodsCubit(this._getFoods, this._getCategories) : super(FoodsInitial());

  static const int _pageSize = 20;

  final GetFoodsUseCase _getFoods;
  final GetFoodCategoriesUseCase _getCategories;

  String? _search;
  String? _categoryId;

  /// Guards against out-of-order responses when the user types quickly.
  int _seq = 0;
  Future<void> retry() => load(search: _search, categoryId: _categoryId);

  void _loadFailure(AppFailure failure, FoodsState previous) {
    if (failure is NetworkFailure && previous is FoodsLoaded) {
      emit(
        previous.copyWith(
          isLoadingMore: false,
          isFiltering: false,
          connectionError: true,
        ),
      );
    } else {
      emit(
        FoodsError(failure.message, connectionError: failure is NetworkFailure),
      );
    }
  }

  /// Full reload with loading state — used for the first fetch.
  ///
  /// Never drops a request: a newer [load]/[search]/[selectCategory] simply
  /// supersedes this one via [_seq] instead of being ignored.
  Future<void> load({String? search, String? categoryId}) async {
    final seq = ++_seq;
    _search = search;
    _categoryId = categoryId;
    final previous = state;
    if (previous is! FoodsLoaded) emit(FoodsLoading());

    final categoriesResult = await _getCategories();
    if (seq != _seq) return;
    switch (categoriesResult) {
      case ApiError(:final failure):
        if (isClosed) return;
        _loadFailure(failure, previous);
        return;
      case ApiSuccess():
        break;
    }

    final foodsResult = await _getFoods(
      search: _search,
      categoryId: _categoryId,
      page: 1,
      pageSize: _pageSize,
    );
    if (seq != _seq) return;
    switch (foodsResult) {
      case ApiError(:final failure):
        if (isClosed) return;
        _loadFailure(failure, previous);
        return;
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(
          FoodsLoaded(
            foods: data.foods,
            categories: categoriesResult.data,
            currentPage: data.pagination.page,
            totalPages: data.pagination.totalPages,
          ),
        );
    }
  }

  /// Smooth in-place search: keeps the current list visible while fetching
  /// and swaps results when they arrive.
  Future<void> search(String query) => _smoothRefetch(
    search: query.trim().isEmpty ? null : query.trim(),
    categoryId: _categoryId,
  );

  void selectCategory(String categoryId) =>
      _smoothRefetch(search: _search, categoryId: categoryId);

  Future<void> _smoothRefetch({String? search, String? categoryId}) async {
    final seq = ++_seq;
    final current = state;

    _search = search;
    _categoryId = categoryId;

    // Nothing cached yet → fall back to the full loading path.
    if (current is! FoodsLoaded) {
      await load(search: search, categoryId: categoryId);
      return;
    }

    if (seq == _seq) {
      emit(current.copyWith(isFiltering: true));
    }

    final result = await _getFoods(
      search: search,
      categoryId: categoryId,
      page: 1,
      pageSize: _pageSize,
    );

    // A newer keystroke/filter superseded this request.
    if (seq != _seq) return;

    switch (result) {
      case ApiSuccess(:final data):
        if (isClosed) return;
        emit(
          FoodsLoaded(
            foods: data.foods,
            categories: current.categories,
            currentPage: data.pagination.page,
            totalPages: data.pagination.totalPages,
          ),
        );
      case ApiError(:final failure):
        if (failure is NetworkFailure) {
          if (isClosed) return;
          _loadFailure(failure, current);
          return;
        }
        if (current.foods.isEmpty) {
          if (isClosed) return;
          emit(FoodsError(failure.message));
        } else {
          // Keep showing the last good list.
          if (isClosed) return;
          emit(current.copyWith(isFiltering: false));
        }
    }
  }

  /// Appends the next page to the current list (no-op while loading).
  Future<void> loadMore() async {
    final state = this.state;
    if (state is! FoodsLoaded || state.isLoadingMore || !state.hasMore) return;

    final seq = ++_seq;
    emit(state.copyWith(isLoadingMore: true));

    final result = await _getFoods(
      search: _search,
      categoryId: _categoryId,
      page: state.currentPage + 1,
      pageSize: _pageSize,
    );
    if (seq != _seq) return;
    switch (result) {
      case ApiError(:final failure):
        if (isClosed) return;
        _loadFailure(failure, state);
        return;
      case ApiSuccess(:final data):
        final existingIds = state.foods.map((f) => f.id).toSet();
        final newFoods = data.foods
            .where((f) => !existingIds.contains(f.id))
            .toList();
        if (isClosed) return;
        emit(
          FoodsLoaded(
            foods: [...state.foods, ...newFoods],
            categories: state.categories,
            currentPage: data.pagination.page,
            totalPages: data.pagination.totalPages,
          ),
        );
    }
  }
}
