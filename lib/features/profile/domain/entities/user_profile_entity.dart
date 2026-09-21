// ignore_for_file: constant_identifier_names
enum Specialization {
  general,
  strength_training,
  weight_loss,
  muscle_building,
  cardio,
  crossfit,
  bodybuilding,
  flexibility,
  rehabilitation,
  sports_performance,
  nutrition,
  yoga,
  pilates,
  calisthenics,
  boxing,
  mma;

  static const display = {
    general: {'en': 'General Fitness', 'ar': '\u0627\u0644\u0644\u064a\u0627\u0642\u0629 \u0627\u0644\u0639\u0627\u0645\u0629'},
    strength_training: {'en': 'Strength Training', 'ar': '\u062a\u062f\u0631\u064a\u0628 \u0627\u0644\u0642\u0648\u0629'},
    weight_loss: {'en': 'Weight Loss', 'ar': '\u0625\u0646\u0642\u0627\u0635 \u0627\u0644\u0648\u0632\u0646'},
    muscle_building: {'en': 'Muscle Building', 'ar': '\u0628\u0646\u0627\u0621 \u0627\u0644\u0639\u0636\u0644\u0627\u062a'},
    cardio: {'en': 'Cardio & Endurance', 'ar': '\u0627\u0644\u0642\u0644\u0628 \u0648\u0627\u0644\u062a\u062d\u0645\u0644'},
    crossfit: {'en': 'CrossFit', 'ar': '\u0643\u0631\u0648\u0633 \u0641\u062a'},
    bodybuilding: {'en': 'Bodybuilding', 'ar': '\u0643\u0645\u0627\u0644 \u0627\u0644\u0623\u062c\u0633\u0627\u0645'},
    flexibility: {'en': 'Flexibility & Mobility', 'ar': '\u0627\u0644\u0645\u0631\u0648\u0646\u0629 \u0648\u0627\u0644\u062d\u0631\u0643\u0629'},
    rehabilitation: {'en': 'Rehabilitation', 'ar': '\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u062a\u0623\u0647\u064a\u0644'},
    sports_performance: {'en': 'Sports Performance', 'ar': '\u0627\u0644\u0623\u062f\u0627\u0621 \u0627\u0644\u0631\u064a\u0627\u0636\u064a'},
    nutrition: {'en': 'Nutrition Coaching', 'ar': '\u062a\u062f\u0631\u064a\u0628 \u0627\u0644\u062a\u063a\u0630\u064a\u0629'},
    yoga: {'en': 'Yoga', 'ar': '\u0627\u0644\u064a\u0648\u063a\u0627'},
    pilates: {'en': 'Pilates', 'ar': '\u0628\u064a\u0644\u0627\u062a\u0633'},
    calisthenics: {'en': 'Calisthenics', 'ar': '\u062a\u0645\u0627\u0631\u064a\u0646 \u0648\u0632\u0646 \u0627\u0644\u062c\u0633\u0645'},
    boxing: {'en': 'Boxing', 'ar': '\u0627\u0644\u0645\u0644\u0627\u0643\u0645\u0629'},
    mma: {'en': 'MMA', 'ar': '\u0627\u0644\u0641\u0646\u0648\u0646 \u0627\u0644\u0642\u062a\u0627\u0644\u064a\u0629 \u0627\u0644\u0645\u062e\u062a\u0644\u0637\u0629'},
  };

  String label(String locale) => display[this]![locale] ?? name;

  static Specialization? fromKey(String? key) {
    if (key == null) return null;
    try {
      return Specialization.values.byName(key);
    } catch (_) {
      return null;
    }
  }
}

/// Fixed list of selectable locations (Egyptian governorates).
const List<String> egyptLocations = [
  'Cairo, Egypt',
  'Giza, Egypt',
  'Alexandria, Egypt',
  'Dakahlia, Egypt',
  'Red Sea, Egypt',
  'Beheira, Egypt',
  'Faiyum, Egypt',
  'Gharbia, Egypt',
  'Ismailia, Egypt',
  'Monufia, Egypt',
  'Minya, Egypt',
  'Qalyubia, Egypt',
  'New Valley, Egypt',
  'Suez, Egypt',
  'Aswan, Egypt',
  'Asyut, Egypt',
  'Beni Suef, Egypt',
  'Port Said, Egypt',
  'Damietta, Egypt',
  'Sharqia, Egypt',
  'South Sinai, Egypt',
  'Kafr El Sheikh, Egypt',
  'Matrouh, Egypt',
  'Luxor, Egypt',
  'Qena, Egypt',
  'North Sinai, Egypt',
  'Sohag, Egypt',
];

class CoachProfileEntity {
  const CoachProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.location,
    this.profileImage,
    this.bio = '',
    this.specialization = '',
    this.specializationDisplay,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? location;
  final String? profileImage;
  final String bio;
  final String specialization;
  final Map<String, String>? specializationDisplay;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String displayName(String locale) {
    if (specializationDisplay != null) {
      return specializationDisplay![locale] ?? specialization;
    }
    return specialization;
  }

  CoachProfileEntity copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? location,
    String? profileImage,
    String? bio,
    String? specialization,
    Map<String, String>? specializationDisplay,
  }) =>
      CoachProfileEntity(
        id: id,
        email: email ?? this.email,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        location: location ?? this.location,
        profileImage: profileImage ?? this.profileImage,
        bio: bio ?? this.bio,
        specialization: specialization ?? this.specialization,
        specializationDisplay: specializationDisplay ?? this.specializationDisplay,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// Summary of the client's assigned workout plan as returned by
/// `GET /profile` (`workout_plan` key).
///
/// This is a summary only (id, title, description, etc.) — not the full plan
/// from `GET /workout/my/plans`. Deliberately separate from `WorkoutPlanEntry`,
/// whose contract (coach ids, days) does not match this endpoint.
class AssignedWorkoutPlanSummary {
  const AssignedWorkoutPlanSummary({
    required this.id,
    required this.title,
    this.description = '',
    this.isActive = true,
    this.createdAt,
    this.startDate = '',
    this.cycleDays = 0,
  });

  final String id;
  final String title;
  final String description;
  final bool isActive;
  final DateTime? createdAt;

  /// Raw `start_date` value; '' when unset.
  final String startDate;
  final int cycleDays;
}

/// Summary of the client's assigned nutrition plan as returned by
/// `GET /profile` (`nutrition_plan` key).
///
/// Summary only — not the full plan from `GET /nutrition/my/plans`.
/// Deliberately separate from `MyPlan`, whose contract (meal counts, meals)
/// does not match this endpoint.
class AssignedNutritionPlanSummary {
  const AssignedNutritionPlanSummary({
    required this.id,
    required this.title,
    this.description = '',
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final bool isActive;
  final DateTime? createdAt;
}

class ClientProfileEntity {
  const ClientProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.location,
    this.profileImage,
    this.gender,
    this.birthDate,
    this.height,
    this.weight,
    this.goal,
    this.createdAt,
    this.updatedAt,
    this.assignedAt,
    this.workoutPlan,
    this.nutritionPlan,
  });

  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? location;
  final String? profileImage;
  final String? gender;
  final DateTime? birthDate;
  final double? height;
  final double? weight;
  final String? goal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// When the client was assigned to their coach; null when no coach or when
  /// the backend omits it (old responses).
  final DateTime? assignedAt;

  /// Active plan summaries from `GET /profile`; null when none assigned or
  /// when the backend omits them (old responses).
  final AssignedWorkoutPlanSummary? workoutPlan;
  final AssignedNutritionPlanSummary? nutritionPlan;

  ClientProfileEntity copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? location,
    String? profileImage,
    String? gender,
    DateTime? birthDate,
    double? height,
    double? weight,
    String? goal,
    DateTime? assignedAt,
    AssignedWorkoutPlanSummary? workoutPlan,
    AssignedNutritionPlanSummary? nutritionPlan,
  }) =>
      ClientProfileEntity(
        id: id,
        email: email ?? this.email,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        location: location ?? this.location,
        profileImage: profileImage ?? this.profileImage,
        gender: gender ?? this.gender,
        birthDate: birthDate ?? this.birthDate,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        goal: goal ?? this.goal,
        createdAt: createdAt,
        updatedAt: updatedAt,
        assignedAt: assignedAt ?? this.assignedAt,
        workoutPlan: workoutPlan ?? this.workoutPlan,
        nutritionPlan: nutritionPlan ?? this.nutritionPlan,
      );
}
