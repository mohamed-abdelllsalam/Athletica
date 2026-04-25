import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';

abstract class CoachClientsData {
  static const List<CoachClient> expiringClients = [
    CoachClient(
      id: 'e1',
      name: 'Mohamed Ahmed',
      joinedMonthsAgo: 2,
      subscriptionActive: true,
      expiresInDays: 3,
      isRenewed: true,
    ),
    CoachClient(
      id: 'e2',
      name: 'Ali Ahmed',
      joinedMonthsAgo: 3,
      subscriptionActive: true,
      expiresInDays: 5,
      isRenewed: false,
    ),
    CoachClient(
      id: 'e3',
      name: 'Ahmed Mohamed',
      joinedMonthsAgo: 1,
      subscriptionActive: true,
      expiresInDays: 7,
      isRenewed: false,
    ),
    CoachClient(
      id: 'e4',
      name: 'Sameh Ahmed',
      joinedMonthsAgo: 4,
      subscriptionActive: true,
      expiresInDays: 8,
      isRenewed: true,
    ),
    CoachClient(
      id: 'e5',
      name: 'Mohamed Ahmed',
      joinedMonthsAgo: 2,
      subscriptionActive: true,
      expiresInDays: 10,
      isRenewed: false,
    ),
    CoachClient(
      id: 'e6',
      name: 'Ali Salama',
      joinedMonthsAgo: 1,
      subscriptionActive: true,
      expiresInDays: 11,
      isRenewed: false,
    ),
  ];

  static const List<CoachClient> clients = [
    CoachClient(
      id: '1',
      name: 'Ali Ahmed',
      joinedMonthsAgo: 3,
      subscriptionActive: true,
      subscriptionPercent: 75,
      heightCm: 180,
      weightKg: 80,
      goals: [
        'Weight Loss',
        'Muscle Gain',
        'Improved Energy',
        'Consistent Workout Routine',
      ],
      sessionHistory: [
        ClientSession(
          sessionNumber: 1,
          title: 'Strength Training',
          date: '15-1-2025',
        ),
        ClientSession(
          sessionNumber: 2,
          title: 'Cardio & Core',
          date: '20-2-2025',
        ),
      ],
      assignedWorkoutPlan: 'Workout Upper',
      workoutPlanSubtitle: 'Upper Body Strength',
      assignedDietPlan: 'Diet Plan',
      dietPlanSubtitle: 'Muscle Gain Diet',
      subscriptionDurationMonths: 1,
      subscriptionStartDate: '15 May 2026',
      subscriptionEndDate: '15 Jun 2026',
      expiresInDays: 18,
      assessmentQuestions: [
        ClientHealthQuestion(
          question: 'Have you had any past injuries?',
          answer: 'Minor injuries (fully recovered)',
        ),
        ClientHealthQuestion(
          question: 'Has a doctor ever advised you not to exercise?',
          answer: 'Yes (specific exercises only)',
        ),
        ClientHealthQuestion(
          question: 'Are you currently exercising?',
          answer: '1–2 times/week',
        ),
        ClientHealthQuestion(
          question: 'How many days per week do you train?',
          answer: '5–6 days',
        ),
        ClientHealthQuestion(
          question: 'What type of exercise do you do?',
          answer: 'Gym / weight training',
        ),
        ClientHealthQuestion(
          question: 'How would you rate your fitness level?',
          answer: 'Average',
        ),
      ],
    ),
    CoachClient(
      id: '2',
      name: 'Mohsen Ahmed',
      joinedMonthsAgo: 3,
      subscriptionActive: false,
      subscriptionPercent: 40,
      heightCm: 175,
      weightKg: 75,
      goals: ['Weight Loss', 'Improved Energy'],
      sessionHistory: [
        ClientSession(
          sessionNumber: 1,
          title: 'Cardio Blast',
          date: '10-1-2025',
        ),
      ],
    ),
    CoachClient(
      id: '3',
      name: 'Mohamed Ahmed',
      joinedMonthsAgo: 2,
      subscriptionActive: true,
      subscriptionPercent: 80,
      heightCm: 178,
      weightKg: 82,
      goals: ['Muscle Gain', 'Consistent Workout Routine'],
      sessionHistory: [
        ClientSession(
          sessionNumber: 1,
          title: 'Upper Body',
          date: '5-2-2025',
        ),
        ClientSession(
          sessionNumber: 2,
          title: 'Lower Body',
          date: '12-2-2025',
        ),
      ],
    ),
    CoachClient(
      id: '4',
      name: 'Zain Karim',
      joinedMonthsAgo: 3,
      subscriptionActive: true,
      subscriptionPercent: 85,
      heightCm: 182,
      weightKg: 85,
      goals: ['Muscle Gain', 'Weight Loss'],
      sessionHistory: [
        ClientSession(
          sessionNumber: 1,
          title: 'Full Body',
          date: '8-1-2025',
        ),
      ],
    ),
  ];
}
