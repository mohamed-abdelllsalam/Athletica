import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';

abstract class CheckInsRepository {
  Future<ApiResult<List<CheckIn>>> getCheckIns();
  Future<ApiResult<List<CheckInQuestion>>> getQuestions();
  Future<ApiResult<void>> saveResponse(CheckIn response);
  Future<ApiResult<void>> saveQuestions(List<CheckInQuestion> questions);
}
