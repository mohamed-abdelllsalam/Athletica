import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/data/datasources/info_remote_data_source.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';
import 'package:dio/dio.dart';

class InfoRepositoryImpl implements InfoRepository {
  const InfoRepositoryImpl(this._dataSource);

  final InfoRemoteDataSource _dataSource;

  @override
  Future<ApiResult<void>> submitAnswers(Map<String, String> answers) async {
    try {
      await _dataSource.submitAnswers(answers);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
