enum CheckInStatus { completed, pending }

enum CheckInQuestionType { number, yesNo, sessions, text }

class CheckInQuestion {
  const CheckInQuestion({
    required this.id,
    required this.label,
    required this.type,
  });

  final String id;
  final String label;
  final CheckInQuestionType type;
}

class CheckIn {
  CheckIn({
    required this.id,
    required this.clientName,
    required this.status,
    this.timeLabel = '—',
    this.mood = 'Good',
    this.sleep = 'Good',
    this.soreness = 'Mild',
    this.energy = '7/10',
    Map<String, String> answers = const {},
    this.additionalNotes = '',
    this.coachNote = '',
  }) : answers = Map.unmodifiable(answers);

  final String id;
  final String clientName;
  final CheckInStatus status;
  final String timeLabel;
  final String mood;
  final String sleep;
  final String soreness;
  final String energy;
  final Map<String, String> answers;
  final String additionalNotes;
  final String coachNote;

  CheckIn withResponse({
    required Map<String, String> answers,
    required String additionalNotes,
    required String coachNote,
  }) => CheckIn(
    id: id,
    clientName: clientName,
    status: CheckInStatus.completed,
    timeLabel: 'Preview response',
    mood: mood,
    sleep: sleep,
    soreness: soreness,
    energy: energy,
    answers: answers,
    additionalNotes: additionalNotes,
    coachNote: coachNote,
  );
}
