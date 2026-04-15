class SetEntry {
  const SetEntry({
    required this.setNumber,
    required this.previous,
    required this.target,
    required this.kg,
    required this.reps,
    this.isCompleted = false,
  });

  final int setNumber;
  final String previous;
  final String target;
  final int kg;
  final int reps;
  final bool isCompleted;

  SetEntry copyWith({
    int? setNumber,
    String? previous,
    String? target,
    int? kg,
    int? reps,
    bool? isCompleted,
  }) {
    return SetEntry(
      setNumber: setNumber ?? this.setNumber,
      previous: previous ?? this.previous,
      target: target ?? this.target,
      kg: kg ?? this.kg,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
