class WorkoutExercise {
  const WorkoutExercise({
    required this.name,
    required this.sets,
    required this.repsRange,
    required this.restRange,
    required this.bottomText,
  });

  final String name;
  final int sets;
  final String repsRange;
  final String restRange;
  final String bottomText;
}

const _r152 = '1.5-2 Minutes of rest between sets';
const _r115 = '1-1.5 Minutes of rest between sets';
const _r23 = '2-3 Minutes of rest between sets';

const List<List<WorkoutExercise>> workoutsByDay = [
  // Day 1 — Chest & Back
  [
    WorkoutExercise(name: 'Bench Press',          sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Incline Dumbbell Press',sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Cable Fly',             sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Lat Pulldown',          sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Row',                   sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Barbell Bent-Over Row', sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
  ],
  // Day 2 — Shoulders & Arms
  [
    WorkoutExercise(name: 'Shoulder Press',   sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Lateral Raises',   sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Face Pulls',       sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Biceps Curl',      sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Triceps Pushdown', sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Dips',             sets: 3, repsRange: '5-8',   restRange: '1.5-2', bottomText: _r152),
  ],
  // Day 3 — Legs
  [
    WorkoutExercise(name: 'Squat',             sets: 4, repsRange: '5-8',   restRange: '2-3',   bottomText: _r23),
    WorkoutExercise(name: 'Romanian Deadlift', sets: 3, repsRange: '8-10',  restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Leg Press',         sets: 3, repsRange: '8-12',  restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Leg Curl',          sets: 3, repsRange: '10-12', restRange: '1-1.5', bottomText: _r115),
    WorkoutExercise(name: 'Leg Extension',     sets: 3, repsRange: '10-12', restRange: '1-1.5', bottomText: _r115),
    WorkoutExercise(name: 'Calf Raises',       sets: 4, repsRange: '12-15', restRange: '1-1.5', bottomText: _r115),
  ],
  // Day 4 — Push
  [
    WorkoutExercise(name: 'Overhead Press',     sets: 4, repsRange: '5-8',   restRange: '2-3',   bottomText: _r23),
    WorkoutExercise(name: 'Incline Bench Press',sets: 3, repsRange: '6-10',  restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Dumbbell Fly',       sets: 3, repsRange: '10-12', restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Triceps Dips',       sets: 3, repsRange: '8-12',  restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Skull Crushers',     sets: 3, repsRange: '8-12',  restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Cable Lateral Raise',sets: 3, repsRange: '12-15', restRange: '1-1.5', bottomText: _r115),
  ],
  // Day 5 — Pull
  [
    WorkoutExercise(name: 'Deadlift',      sets: 4, repsRange: '4-6',   restRange: '2-3',   bottomText: _r23),
    WorkoutExercise(name: 'Pull-Ups',      sets: 3, repsRange: '6-10',  restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Cable Row',     sets: 3, repsRange: '8-12',  restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Hammer Curl',   sets: 3, repsRange: '10-12', restRange: '1-1.5', bottomText: _r115),
    WorkoutExercise(name: 'Preacher Curl', sets: 3, repsRange: '10-12', restRange: '1-1.5', bottomText: _r115),
    WorkoutExercise(name: 'Face Pulls',    sets: 3, repsRange: '12-15', restRange: '1-1.5', bottomText: _r115),
  ],
  // Day 6 — Legs (Volume)
  [
    WorkoutExercise(name: 'Front Squat',         sets: 4, repsRange: '6-8',   restRange: '2-3',   bottomText: _r23),
    WorkoutExercise(name: 'Walking Lunges',       sets: 3, repsRange: '10-12', restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Hack Squat',           sets: 3, repsRange: '8-10',  restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Seated Leg Curl',      sets: 3, repsRange: '10-12', restRange: '1-1.5', bottomText: _r115),
    WorkoutExercise(name: 'Hip Thrust',           sets: 3, repsRange: '10-12', restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Standing Calf Raises', sets: 4, repsRange: '15-20', restRange: '1-1.5', bottomText: _r115),
  ],
  // Day 7 — Full Body
  [
    WorkoutExercise(name: 'Power Clean',          sets: 4, repsRange: '3-5',   restRange: '2-3',   bottomText: _r23),
    WorkoutExercise(name: 'Bulgarian Split Squat',sets: 3, repsRange: '8-10',  restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Push-Ups',             sets: 3, repsRange: '12-15', restRange: '1-1.5', bottomText: _r115),
    WorkoutExercise(name: 'Chin-Ups',             sets: 3, repsRange: '8-12',  restRange: '1.5-2', bottomText: _r152),
    WorkoutExercise(name: 'Plank',                sets: 3, repsRange: '30-60s',restRange: '1-1.5', bottomText: _r115),
    WorkoutExercise(name: 'Russian Twist',        sets: 3, repsRange: '15-20', restRange: '1-1.5', bottomText: _r115),
  ],
];
