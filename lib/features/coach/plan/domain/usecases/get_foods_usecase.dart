import 'package:athletica/features/coach/plan/domain/repositories/foods_repository.dart';

class GetFoodsUseCase {
  const GetFoodsUseCase(this._repository);

  final FoodsRepository _repository;

  Future<FoodsPageResult> call({
    String? search,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  }) =>
      _repository.getFoods(
        search: search,
        categoryId: categoryId,
        page: page,
        pageSize: pageSize,
      );
}
