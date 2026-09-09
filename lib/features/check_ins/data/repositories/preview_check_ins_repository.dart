import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

/// Sample data for the explicitly labelled UI preview. Never calls an API,
/// reads real profiles, or persists responses to disk.
class PreviewCheckInsRepository implements CheckInsRepository {
  List<CheckInQuestion> _questions = const [
    CheckInQuestion(
      id: 'weight',
      label: 'Current Weight?',
      type: CheckInQuestionType.number,
    ),
    CheckInQuestion(
      id: 'average',
      label: 'Weekly Average Weight',
      type: CheckInQuestionType.number,
    ),
    CheckInQuestion(
      id: 'waist',
      label: 'Waist Measurement',
      type: CheckInQuestionType.number,
    ),
    CheckInQuestion(
      id: 'photo',
      label: 'Progress Photo Uploaded?',
      type: CheckInQuestionType.yesNo,
    ),
    CheckInQuestion(
      id: 'sessions',
      label: 'How many training sessions did you complete this week?',
      type: CheckInQuestionType.sessions,
    ),
  ];

  final List<CheckIn> _entries = [
    CheckIn(
      id: 'sample-1',
      clientName: 'Ali Ahmed',
      status: CheckInStatus.completed,
      timeLabel: 'Today, 9:30 AM',
      answers: const {
        'weight': '78',
        'average': '78.5',
        'waist': '82',
        'photo': 'Yes',
        'sessions': '4',
      },
      additionalNotes:
          'Legs are a bit sore from yesterday’s workout, but overall feeling good and ready to train.',
    ),
    CheckIn(
      id: 'sample-2',
      clientName: 'Mohamed Ali',
      status: CheckInStatus.pending,
    ),
    CheckIn(
      id: 'sample-3',
      clientName: 'Jamal Ali',
      status: CheckInStatus.completed,
      timeLabel: 'Today, 9:30 AM',
      sleep: 'Normal',
      energy: '6/10',
      answers: const {
        'weight': '85',
        'average': '85.2',
        'waist': '88',
        'photo': 'No',
        'sessions': '3',
      },
      additionalNotes: 'Ready for the next session.',
    ),
  ];

  @override
  Future<ApiResult<List<CheckIn>>> getCheckIns() async =>
      ApiSuccess(List.unmodifiable(_entries));

  @override
  Future<ApiResult<List<CheckInQuestion>>> getQuestions() async =>
      ApiSuccess(List.unmodifiable(_questions));

  @override
  Future<ApiResult<void>> saveResponse(CheckIn response) async {
    final index = _entries.indexWhere((entry) => entry.id == response.id);
    if (index < 0) {
      return const ApiError(
        UnknownFailure('This check-in is no longer available.'),
      );
    }
    _entries[index] = response;
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> saveQuestions(List<CheckInQuestion> questions) async {
    _questions = List.unmodifiable(questions);
    return const ApiSuccess(null);
  }
}
