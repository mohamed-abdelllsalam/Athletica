import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';

abstract class CoachClientsData {
  static const List<CoachClient> clients = [
    CoachClient(
      id: '1',
      name: 'Ali Ahmed',
      joinedMonthsAgo: 3,
      subscriptionActive: true,
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
    ),
    CoachClient(
      id: '2',
      name: 'Mohsen Ahmed',
      joinedMonthsAgo: 3,
      subscriptionActive: false,
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
