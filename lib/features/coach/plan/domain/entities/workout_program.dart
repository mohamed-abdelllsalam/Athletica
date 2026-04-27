class WorkoutProgram {
  WorkoutProgram({
    required this.id,
    required this.name,
    required this.category,
    required this.splitType,
    required this.updatedAgo,
    required this.clientCount,
    required this.description,
    required this.iconAsset,
    required this.days,
  });

  final String id;
  final String name;
  final String category;
  final String splitType;
  final String updatedAgo;
  final int clientCount;
  final String description;
  final String iconAsset;
  final List<ProgramDay> days;
}

class ProgramDay {
  ProgramDay({
    required this.dayNumber,
    required this.name,
    required this.durationMinutes,
    required this.exercises,
  });

  final int dayNumber;
  String name;
  final int durationMinutes;
  final List<ProgramExercise> exercises;

  int get exerciseCount => exercises.length;

  ProgramDay copyWith({String? name, List<ProgramExercise>? exercises}) =>
      ProgramDay(
        dayNumber: dayNumber,
        name: name ?? this.name,
        durationMinutes: durationMinutes,
        exercises: exercises ?? List.from(this.exercises),
      );
}

class ProgramExercise {
  const ProgramExercise({required this.id, required this.name});
  final String id;
  final String name;
}

class LibraryExercise {
  const LibraryExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
  });

  final String id;
  final String name;
  final String muscleGroup;
}

abstract class ExerciseLibraryData {
  static const List<String> muscleGroups = [
    'All',
    'Neck',
    'Back',
    'Chest',
    'Shoulder',
    'Arm',
    'Core',
    'Legs',
  ];

  static const List<LibraryExercise> exercises = [
    LibraryExercise(id: 'le1', name: 'Deadlift', muscleGroup: 'Back'),
    LibraryExercise(id: 'le2', name: 'One Arm Dumbbell Row', muscleGroup: 'Back'),
    LibraryExercise(id: 'le3', name: 'Incline Dumbbell Row', muscleGroup: 'Back'),
    LibraryExercise(id: 'le4', name: 'Wide-grip Lat Pulldown', muscleGroup: 'Back'),
    LibraryExercise(id: 'le5', name: 'Seated Cable Rows', muscleGroup: 'Back'),
    LibraryExercise(id: 'le6', name: 'Barbell Bent-Over Row', muscleGroup: 'Back'),
    LibraryExercise(id: 'le7', name: 'Bench Press', muscleGroup: 'Chest'),
    LibraryExercise(id: 'le8', name: 'Incline Dumbbell Press', muscleGroup: 'Chest'),
    LibraryExercise(id: 'le9', name: 'Cable Flyes', muscleGroup: 'Chest'),
    LibraryExercise(id: 'le10', name: 'Push-ups', muscleGroup: 'Chest'),
    LibraryExercise(id: 'le11', name: 'Dumbbell Pullover', muscleGroup: 'Chest'),
    LibraryExercise(id: 'le12', name: 'Overhead Press', muscleGroup: 'Shoulder'),
    LibraryExercise(id: 'le13', name: 'Lateral Raises', muscleGroup: 'Shoulder'),
    LibraryExercise(id: 'le14', name: 'Front Raises', muscleGroup: 'Shoulder'),
    LibraryExercise(id: 'le15', name: 'Face Pulls', muscleGroup: 'Shoulder'),
    LibraryExercise(id: 'le16', name: 'Arnold Press', muscleGroup: 'Shoulder'),
    LibraryExercise(id: 'le17', name: 'Barbell Curl', muscleGroup: 'Arm'),
    LibraryExercise(id: 'le18', name: 'Hammer Curl', muscleGroup: 'Arm'),
    LibraryExercise(id: 'le19', name: 'Tricep Pushdown', muscleGroup: 'Arm'),
    LibraryExercise(id: 'le20', name: 'Skull Crushers', muscleGroup: 'Arm'),
    LibraryExercise(id: 'le21', name: 'Preacher Curl', muscleGroup: 'Arm'),
    LibraryExercise(id: 'le22', name: 'Squat', muscleGroup: 'Legs'),
    LibraryExercise(id: 'le23', name: 'Leg Press', muscleGroup: 'Legs'),
    LibraryExercise(id: 'le24', name: 'Romanian Deadlift', muscleGroup: 'Legs'),
    LibraryExercise(id: 'le25', name: 'Leg Curl', muscleGroup: 'Legs'),
    LibraryExercise(id: 'le26', name: 'Lunges', muscleGroup: 'Legs'),
    LibraryExercise(id: 'le27', name: 'Plank', muscleGroup: 'Core'),
    LibraryExercise(id: 'le28', name: 'Crunches', muscleGroup: 'Core'),
    LibraryExercise(id: 'le29', name: 'Russian Twists', muscleGroup: 'Core'),
    LibraryExercise(id: 'le30', name: 'Leg Raises', muscleGroup: 'Core'),
    LibraryExercise(id: 'le31', name: 'Neck Extension', muscleGroup: 'Neck'),
    LibraryExercise(id: 'le32', name: 'Neck Flexion', muscleGroup: 'Neck'),
    LibraryExercise(id: 'le33', name: 'Neck Side Flexion', muscleGroup: 'Neck'),
  ];
}

abstract class WorkoutProgramsData {
  static List<WorkoutProgram> get programs => [
        WorkoutProgram(
          id: 'wp1',
          name: 'Upper Body Strength',
          category: 'Strength',
          splitType: '5 Days Split',
          updatedAgo: 'Updated 2 days ago',
          clientCount: 2,
          iconAsset: 'assets/images/plan/upper_body_icon.svg',
          description:
              'A Strength focused upper body program designed\nTo build muscle and improve performance',
          days: [
            ProgramDay(
              dayNumber: 1,
              name: 'Chest & Triceps',
              durationMinutes: 60,
              exercises: [
                const ProgramExercise(id: 'e1', name: 'Deadlift'),
                const ProgramExercise(id: 'e2', name: 'One Arm Dumbbell Row'),
                const ProgramExercise(id: 'e3', name: 'Incline Dumbbell Row'),
                const ProgramExercise(id: 'e4', name: 'Deadlift'),
                const ProgramExercise(id: 'e5', name: 'One Arm Dumbbell Row'),
                const ProgramExercise(id: 'e6', name: 'Incline Dumbbell Row'),
              ],
            ),
            ProgramDay(
              dayNumber: 2,
              name: 'Back & Biceps',
              durationMinutes: 60,
              exercises: [
                const ProgramExercise(id: 'e7', name: 'Wide-grip Lat Pulldown'),
                const ProgramExercise(id: 'e8', name: 'Seated Cable Rows'),
                const ProgramExercise(id: 'e9', name: 'Barbell Bent-Over Row'),
                const ProgramExercise(id: 'e10', name: 'Deadlift'),
                const ProgramExercise(id: 'e11', name: 'One Arm Dumbbell Row'),
                const ProgramExercise(id: 'e12', name: 'Incline Dumbbell Row'),
              ],
            ),
            ProgramDay(
              dayNumber: 3,
              name: 'Shoulders',
              durationMinutes: 55,
              exercises: [
                const ProgramExercise(id: 'e13', name: 'Overhead Press'),
                const ProgramExercise(id: 'e14', name: 'Lateral Raises'),
                const ProgramExercise(id: 'e15', name: 'Front Raises'),
                const ProgramExercise(id: 'e16', name: 'Face Pulls'),
                const ProgramExercise(id: 'e17', name: 'Shrugs'),
              ],
            ),
            ProgramDay(
              dayNumber: 4,
              name: 'Arms',
              durationMinutes: 45,
              exercises: [
                const ProgramExercise(id: 'e18', name: 'Barbell Curl'),
                const ProgramExercise(id: 'e19', name: 'Hammer Curl'),
                const ProgramExercise(id: 'e20', name: 'Tricep Pushdown'),
                const ProgramExercise(id: 'e21', name: 'Skull Crushers'),
              ],
            ),
            ProgramDay(
              dayNumber: 5,
              name: 'Upper Body Power',
              durationMinutes: 60,
              exercises: [
                const ProgramExercise(id: 'e22', name: 'Bench Press'),
                const ProgramExercise(id: 'e23', name: 'Pull-ups'),
                const ProgramExercise(id: 'e24', name: 'Overhead Press'),
                const ProgramExercise(id: 'e25', name: 'Bent-Over Rows'),
              ],
            ),
          ],
        ),
        WorkoutProgram(
          id: 'wp2',
          name: 'Muscle Gain Meal Plan',
          category: 'Fat loss',
          splitType: '6 Week Plan',
          updatedAgo: 'Updated 5 days ago',
          clientCount: 5,
          iconAsset: 'assets/images/plan/muscle_gain_icon.svg',
          description:
              'A muscle gain focused program\nTo build strength and mass',
          days: [],
        ),
        WorkoutProgram(
          id: 'wp3',
          name: 'Boxing Conditioning',
          category: 'Boxing',
          splitType: '4 Week Plan',
          updatedAgo: 'Updated 1 week ago',
          clientCount: 3,
          iconAsset: 'assets/images/plan/boxing_icon.svg',
          description:
              'A boxing conditioning program\nFor improving speed and endurance',
          days: [],
        ),
        WorkoutProgram(
          id: 'wp4',
          name: 'Full Body Strength',
          category: 'Strength',
          splitType: '4 Week Plan',
          updatedAgo: 'Updated 5 days ago',
          clientCount: 5,
          iconAsset: 'assets/images/plan/full_body_icon.svg',
          description:
              'Full body strength training\nFor all muscle groups',
          days: [],
        ),
        WorkoutProgram(
          id: 'wp5',
          name: 'Mobility & Recovery',
          category: 'Custom',
          splitType: 'Daily Plan',
          updatedAgo: 'Updated 6 days ago',
          clientCount: 8,
          iconAsset: 'assets/images/plan/recover_icon.svg',
          description:
              'Mobility and recovery program\nFor flexibility and injury prevention',
          days: [],
        ),
      ];
}
