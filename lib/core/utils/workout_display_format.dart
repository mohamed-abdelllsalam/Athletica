String formatWorkoutPrescription(int? sets, int? reps) {
  if (sets == null && reps == null) return '';
  if (sets == null) return '$reps reps';
  if (reps == null) return '$sets sets';
  return '$sets sets × $reps reps';
}
