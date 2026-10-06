import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/data/datasources/info_remote_data_source.dart';
import 'package:athletica/features/info/domain/entities/client_answers.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';
import 'package:dio/dio.dart';

class InfoRepositoryImpl implements InfoRepository {
  const InfoRepositoryImpl(this._dataSource);

  final InfoRemoteDataSource _dataSource;

  @override
  Future<ApiResult<List<ClientQuestion>>> getQuestions() async {
    try {
      final questions = await _dataSource.getQuestions();
      return ApiSuccess(questions);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (_) {
      return const ApiError(
        UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<ApiResult<void>> submitAnswers(ClientAnswerPayload answers) async {
    try {
      await _dataSource.submitAnswers(answers);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (_) {
      return const ApiError(
        UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<ApiResult<void>> updateAnswers(ClientAnswerPayload answers) async {
    try {
      await _dataSource.updateAnswers(answers);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (_) {
      return const ApiError(
        UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<ApiResult<ClientAnswers>> getClientAnswers() async {
    try {
      final answers = await _dataSource.getClientAnswers();
      return ApiSuccess(answers);
    } on DioException catch (e) {
      return ApiError(_mapDioError(e));
    } catch (_) {
      return const ApiError(
        UnknownFailure('Something went wrong. Please try again.'),
      );
    }
  }

  AppFailure _mapDioError(DioException e) {
    if (isConnectivityException(e)) {
      return mapDioException(e);
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? (_extractMessage(data['message']) ??
              _extractMessage(data['error']) ??
              'Something went wrong.')
        : 'Something went wrong. Please try again.';

    if (statusCode == 401) {
      return UnauthorizedFailure(message);
    }
    return ServerFailure(message);
  }

  String? _extractMessage(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value;
    if (value is List && value.isNotEmpty) return value.join(', ');
    return null;
  }
}
