import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/data/datasources/info_remote_data_source.dart';
import 'package:athletica/features/info/domain/entities/intake_answer.dart';
import 'package:athletica/features/info/domain/entities/intake_section.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';
import 'package:dio/dio.dart';

class InfoRepositoryImpl implements InfoRepository {
  const InfoRepositoryImpl(this._dataSource);

  final InfoRemoteDataSource _dataSource;

  @override
  Future<ApiResult<List<IntakeSection>>> getQuestions() async {
    try {
      final sections = await _dataSource.getQuestions();
      return ApiSuccess(sections);
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> submitAnswers(Map<String, dynamic> answers) async {
    try {
      await _dataSource.submitAnswers(answers);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<ClientIntakeAnswers>> getClientAnswers(
    String clientId,
  ) async {
    try {
      final answers = await _dataSource.getClientAnswers(clientId);
      return ApiSuccess(answers);
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
