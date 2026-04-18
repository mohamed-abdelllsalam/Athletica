class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });

  final String text;
  final bool isMe;
  final String time;
}

class ChatContact {
  const ChatContact({
    required this.id,
    required this.name,
    this.imageAsset,
    this.isRequest = false,
    this.goals = const [],
    this.heightCm,
    this.weightKg,
    this.experience,
    this.schedule,
    this.nutrition,
    this.messages = const [],
  });

  final String id;
  final String name;
  final String? imageAsset;
  final bool isRequest;
  final List<String> goals;
  final int? heightCm;
  final int? weightKg;
  final String? experience;
  final String? schedule;
  final String? nutrition;
  final List<ChatMessage> messages;
}

abstract class ChatContactsData {
  static const List<ChatContact> contacts = [
    ChatContact(
      id: '1',
      name: 'Ali Ahmed',
      goals: [
        'Weight Loss',
        'Muscle Gain',
        'Improved Energy',
        'Consistent Workout Routine',
      ],
      heightCm: 180,
      weightKg: 80,
      experience: 'Intermediate',
      schedule: 'Flexible',
      nutrition: 'Strict Diet',
      messages: [
        ChatMessage(
          text: 'Thanks, coach. Really appreciate the plan!',
          isMe: false,
          time: 'Today 10:00 Am',
        ),
        ChatMessage(
          text: 'Keep it up! You\'re making great progress.',
          isMe: true,
          time: 'Today 10:05 Am',
        ),
      ],
    ),
    ChatContact(
      id: '2',
      name: 'Zain Ziad',
      goals: ['Muscle Gain'],
      heightCm: 182,
      weightKg: 85,
      messages: [
        ChatMessage(
          text: 'coach, i need more details about my plan',
          isMe: false,
          time: 'Today 15:00',
        ),
      ],
    ),
    ChatContact(
      id: '3',
      name: 'Ziad Ali',
      goals: ['Weight Loss'],
      heightCm: 175,
      weightKg: 78,
      messages: [
        ChatMessage(
          text: 'coach, i need help with my workout',
          isMe: false,
          time: 'Today 20:00',
        ),
      ],
    ),
    ChatContact(
      id: '4',
      name: 'Ahmed Mohamed',
      goals: ['Muscle Gain', 'Improved Energy'],
      heightCm: 178,
      weightKg: 82,
      messages: [
        ChatMessage(
          text: 'Thanks, coach. The new routine is great!',
          isMe: false,
          time: 'Today 22:00',
        ),
        ChatMessage(
          text: 'Glad to hear it, keep pushing!',
          isMe: true,
          time: 'Today 22:10',
        ),
      ],
    ),
    ChatContact(
      id: '5',
      name: 'Sameh Ali',
      goals: ['Weight Loss', 'Muscle Gain'],
      heightCm: 176,
      weightKg: 90,
      messages: [
        ChatMessage(
          text: 'Thanks, coach. See you tomorrow.',
          isMe: false,
          time: 'Today 24:00',
        ),
      ],
    ),
    ChatContact(
      id: '6',
      name: 'Osama Ali',
      goals: ['Improved Energy'],
      messages: [
        ChatMessage(
          text: 'Thanks, coach.',
          isMe: false,
          time: 'Today 24:00',
        ),
      ],
    ),
  ];

  static const List<ChatContact> requests = [
    ChatContact(
      id: 'r1',
      name: 'Ali Magdy',
      isRequest: true,
      goals: [
        'Weight Loss',
        'Muscle Gain',
        'Improved Energy',
        'Consistent Workout Routine',
      ],
      heightCm: 170,
      weightKg: 70,
      experience: 'Beginner to Intermediate',
      schedule: 'Busy',
      nutrition: 'Open to Advice',
      messages: [
        ChatMessage(
          text:
              "Hi coach, I'm interested in starting a plan with you. Can you tell me how your coaching works ?",
          isMe: false,
          time: 'Today 9:00 Am',
        ),
      ],
    ),
  ];
}
