import 'package:athletica/features/info/domain/entities/info_question.dart';

class IntakeSection {
  const IntakeSection({
    required this.key,
    required this.title,
    required this.description,
    required this.questions,
  });

  final String key;
  final String title;
  final String description;
  final List<InfoQuestion> questions;
}
