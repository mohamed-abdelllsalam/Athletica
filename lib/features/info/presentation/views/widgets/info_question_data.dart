import 'package:athletica/features/info/domain/entities/info_question.dart';

const List<List<InfoQuestion>> kInfoQuestionPages = [
  // Page 1 — Goals & Health Background
  [
    InfoQuestion(key: 'HEIGHT_CM', question: 'Type Your Height', type: InfoQuestionType.text),
    InfoQuestion(key: 'WEIGHT_KG', question: 'Type Your Weight', type: InfoQuestionType.text),
    InfoQuestion(
      key: 'PRIMARY_FITNESS_GOAL',
      question: 'What are your primary fitness goals?',
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
      question:
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
      question: 'Why is this goal important to you?',
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
      question: 'Do you have any medical conditions?',
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
      question: 'Are you currently taking any medications?',
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
      question: 'What challenges do you expect to face?',
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
      question: 'Have you had any past injuries?',
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
      question: 'Has a doctor ever advised you not to exercise?',
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
      question: 'Are you currently exercising?',
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
      question: 'How many days per week do you train?',
      options: ['0', '1-2 days', '3-4 days', '5-6 days', 'Daily'],
    ),
    InfoQuestion(
      key: 'CURRENT_EXERCISE_TYPE',
      question: 'What type of exercise do you do?',
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
      question: 'How many meals do you eat per day?',
      options: ['1-2 meals', '3 meals', '4 meals', '5+ meals', 'Irregular'],
    ),
  ],
  // Page 3 — Fitness Level & Nutrition
  [
    InfoQuestion(
      key: 'FITNESS_LEVEL',
      question: 'How would you rate your fitness level?',
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
      question: 'What does your daily diet look like?',
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
      question: 'How many meals do you eat per day?',
      options: ['1-2 meals', '3 meals', '4 meals', '5+ meals', 'Irregular'],
    ),
    InfoQuestion(
      key: 'WATER_INTAKE_LITERS',
      question: 'How much water do you drink daily?',
      options: ['Less than 1L', '1-2L', '2-3L', '3-4L', 'More than 4L'],
    ),
    InfoQuestion(
      key: 'CURRENT_EXERCISE_TYPE',
      question: 'What type of exercise do you do?',
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
      question: 'Do you have any food allergies or restrictions?',
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
      question: 'How many hours do you sleep per night?',
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
      question: 'What is your occupation?',
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
      question: 'How would you rate your stress level?',
      options: ['Very low', 'Low', 'Moderate', 'High', 'Very high'],
    ),
    InfoQuestion(
      key: 'SMOKE_DRINK_ALCOHOL',
      question: 'Do you smoke or drink alcohol?',
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
      question: 'How many days per week can you commit to training?',
      options: ['1-2 days', '3-4 days', '5-6 days', 'Daily', 'Not sure'],
    ),
    InfoQuestion(
      key: 'PREFERRED_WORKOUT_LOCATION',
      question: 'Do you prefer training at the gym or at home?',
      options: ['Gym', 'Home', 'Both', 'Outdoor', 'No preference'],
    ),
  ],
];