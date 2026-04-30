import 'package:athletica/features/info/domain/entities/info_question.dart';

const List<List<InfoQuestion>> kInfoQuestionPages = [
  // Page 1 — Goals & Health Background
  [
    InfoQuestion(key: 'HEIGHT_CM', prompt: 'Type Your Height', type: InfoQuestionType.number),
    InfoQuestion(key: 'WEIGHT_KG', prompt: 'Type Your Weight', type: InfoQuestionType.number),
    InfoQuestion(
      key: 'PRIMARY_FITNESS_GOAL',
      prompt: 'What are your primary fitness goals?',
      options: [
        'Lose weight',
        'Build muscle',
        'Improve overall fitness',
        'Increase strength',
        'Rehabilitation / injury recovery',
      ],
    ),
    InfoQuestion(
      key: 'PREVIOUS_PROGRAM_EXPERIENCE',
      prompt:
          'Do you have any previous experience with personal training or fitness programs?',
      options: [
        '1-3 months',
        '+3-6 months',
        '6-12 months',
        'No specific timeline',
        'As fast as possible',
      ],
    ),
    InfoQuestion(
      key: 'GOAL_IMPORTANCE',
      prompt: 'Why is this goal important to you?',
      options: [
        'Improve appearance',
        'Health reasons',
        'Increase confidence',
        'Sports performance',
        'Lifestyle change',
      ],
    ),
    InfoQuestion(
      key: 'MEDICAL_CONDITIONS',
      prompt: 'Do you have any medical conditions?',
      options: [
        'No',
        'Yes (controlled)',
        'Yes (needs attention)',
        'Not sure',
        'Prefer not to say',
      ],
    ),
    InfoQuestion(
      key: 'CURRENT_MEDICATIONS',
      prompt: 'Are you currently taking any medications?',
      options: [
        'No',
        'Yes (regularly)',
        'Yes (occasionally)',
        'Not sure',
        'Prefer not to say',
      ],
    ),
    InfoQuestion(
      key: 'EXPECTED_CHALLENGES',
      prompt: 'What challenges do you expect to face?',
      options: [
        'Lack of time',
        'Lack of motivation',
        'Nutrition issues',
        'Injuries / pain',
        'Consistency',
      ],
    ),
  ],
  // Page 2 — Injury & Exercise History
  [
    InfoQuestion(
      key: 'PAST_INJURIES',
      prompt: 'Have you had any past injuries?',
      options: [
        'No injuries',
        'Minor injuries (fully recovered)',
        'Previous injuries (sometimes feel pain)',
        'Serious injury',
        'Currently injured',
      ],
    ),
    InfoQuestion(
      key: 'DOCTOR_EXERCISE_RESTRICTION',
      prompt: 'Has a doctor ever advised you not to exercise?',
      options: [
        'No',
        'Yes (temporarily)',
        'Yes (specific exercises only)',
        'Yes (completely)',
        'Not sure',
      ],
    ),
    InfoQuestion(
      key: 'CURRENTLY_EXERCISING',
      prompt: 'Are you currently exercising?',
      options: [
        'Not exercising',
        '1-2 times/week',
        '3-4 times/week',
        '5+ times/week',
        'Irregular',
      ],
    ),
    InfoQuestion(
      key: 'TRAINING_DAYS_PER_WEEK',
      prompt: 'How many days per week do you train?',
      options: ['0', '1-2 days', '3-4 days', '5-6 days', 'Daily'],
    ),
    InfoQuestion(
      key: 'CURRENT_EXERCISE_TYPE',
      prompt: 'What type of exercise do you do?',
      options: [
        'Gym / weight training',
        'Cardio (running, cycling)',
        'Home workouts',
        'Sports activities',
        'Mixed',
      ],
    ),
    InfoQuestion(
      key: 'MEALS_PER_DAY',
      prompt: 'How many meals do you eat per day?',
      options: ['1-2 meals', '3 meals', '4 meals', '5+ meals', 'Irregular'],
    ),
  ],
  // Page 3 — Fitness Level & Nutrition
  [
    InfoQuestion(
      key: 'FITNESS_LEVEL',
      prompt: 'How would you rate your fitness level?',
      options: [
        'Beginner',
        'Below average',
        'Average',
        'Above average',
        'Advanced',
      ],
    ),
    InfoQuestion(
      key: 'DAILY_DIET_DESCRIPTION',
      prompt: 'What does your daily diet look like?',
      options: [
        'Healthy and balanced',
        'Mixed healthy & unhealthy',
        'Mostly unhealthy',
        'Random eating habits',
        'Following a specific diet',
      ],
    ),
    InfoQuestion(
      key: 'MEALS_PER_DAY',
      prompt: 'How many meals do you eat per day?',
      options: ['1-2 meals', '3 meals', '4 meals', '5+ meals', 'Irregular'],
    ),
    InfoQuestion(
      key: 'WATER_INTAKE_LITERS',
      prompt: 'How much water do you drink daily?',
      options: ['Less than 1L', '1-2L', '2-3L', '3-4L', 'More than 4L'],
    ),
    InfoQuestion(
      key: 'CURRENT_EXERCISE_TYPE',
      prompt: 'What type of exercise do you do?',
      options: [
        'Gym / weight training',
        'Cardio (running, cycling)',
        'Home workouts',
        'Sports activities',
        'Mixed',
      ],
    ),
    InfoQuestion(
      key: 'FOOD_ALLERGIES_RESTRICTIONS',
      prompt: 'Do you have any food allergies or restrictions?',
      options: [
        'No',
        'Yes (allergies)',
        'Yes (diet preference)',
        'Yes (medical restriction)',
        'Not sure',
      ],
    ),
  ],
  // Page 4 — Lifestyle & Commitment
  [
    InfoQuestion(
      key: 'SLEEP_HOURS',
      prompt: 'How many hours do you sleep per night?',
      options: [
        'Less than 5 hours',
        '5-6 hours',
        '6-7 hours',
        '7-8 hours',
        'More than 8 hours',
      ],
    ),
    InfoQuestion(
      key: 'OCCUPATION',
      prompt: 'What is your occupation?',
      options: [
        'Sedentary (desk job)',
        'Light activity',
        'Moderate activity',
        'Very active',
        'Student',
      ],
    ),
    InfoQuestion(
      key: 'STRESS_LEVEL',
      prompt: 'How would you rate your stress level?',
      options: ['Very low', 'Low', 'Moderate', 'High', 'Very high'],
    ),
    InfoQuestion(
      key: 'SMOKE_DRINK_ALCOHOL',
      prompt: 'Do you smoke or drink alcohol?',
      options: [
        'No',
        'Smoke only',
        'Drink alcohol only',
        'Both',
        'Occasionally',
      ],
    ),
    InfoQuestion(
      key: 'COMMITMENT_DAYS_PER_WEEK',
      prompt: 'How many days per week can you commit to training?',
      options: ['1-2 days', '3-4 days', '5-6 days', 'Daily', 'Not sure'],
    ),
    InfoQuestion(
      key: 'PREFERRED_WORKOUT_LOCATION',
      prompt: 'Do you prefer training at the gym or at home?',
      options: ['Gym', 'Home', 'Both', 'Outdoor', 'No preference'],
    ),
  ],
];
