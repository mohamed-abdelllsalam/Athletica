class CoachMessagePreview {
  const CoachMessagePreview({
    required this.id,
    required this.name,
    required this.preview,
    required this.timeAgo,
    this.unreadCount = 0,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String preview;
  final String timeAgo;
  final int unreadCount;
  final String? imageAsset;
}

abstract class CoachMessagesData {
  static const List<CoachMessagePreview> messages = [
    CoachMessagePreview(
      id: '1',
      name: 'Ali Ahmed',
      preview: 'Thanks, coach....',
      timeAgo: '10 h',
      unreadCount: 2,
    ),
    CoachMessagePreview(
      id: '2',
      name: 'Zain Ziad',
      preview: 'coach, i need....',
      timeAgo: '15 h',
    ),
    CoachMessagePreview(
      id: '3',
      name: 'Ziad Ali',
      preview: 'coach, i need....',
      timeAgo: '20 h',
    ),
    CoachMessagePreview(
      id: '4',
      name: 'Ahmed Mohamed',
      preview: 'Thanks, coach....',
      timeAgo: '22 h',
      unreadCount: 1,
    ),
    CoachMessagePreview(
      id: '5',
      name: 'Sameh Ali',
      preview: 'Thanks, coach....',
      timeAgo: '24 h',
      unreadCount: 3,
    ),
    CoachMessagePreview(
      id: '6',
      name: 'Osama Ali',
      preview: 'Thanks, coach....',
      timeAgo: '24 h',
    ),
    CoachMessagePreview(
      id: '7',
      name: 'Osama Ali',
      preview: 'Thanks, coach....',
      timeAgo: '24 h',
    ),
    CoachMessagePreview(
      id: '8',
      name: 'Osama Ali',
      preview: 'Thanks, coach....',
      timeAgo: '24 h',
    ),
  ];
}
