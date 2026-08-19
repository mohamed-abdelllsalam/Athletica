import 'package:athletica/features/info/domain/entities/client_question.dart';

sealed class InfoState {
  const InfoState();
}

final class InfoInitial extends InfoState {
  const InfoInitial();
}

final class InfoQuestionsLoading extends InfoState {
  const InfoQuestionsLoading();
}

final class InfoQuestionsLoaded extends InfoState {
  const InfoQuestionsLoaded(this.questions);
  final List<ClientQuestion> questions;
}

final class InfoQuestionsError extends InfoState {
  const InfoQuestionsError(this.message);
  final String message;
}

final class InfoLoading extends InfoState {
  const InfoLoading();
}

final class InfoSuccess extends InfoState {
  const InfoSuccess();
}

final class InfoError extends InfoState {
  const InfoError(this.message);
  final String message;
}
