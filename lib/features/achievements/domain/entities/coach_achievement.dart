class CoachAchievement {
  const CoachAchievement({
    required this.id,
    required this.coachId,
    required this.title,
    required this.fileUrl,
    required this.mimeType,
    required this.createdAt,
    this.fileName,
    this.fileSize,
  });

  final String id;
  final String coachId;
  final String title;
  final String fileUrl;
  final String? fileName;
  final int? fileSize;
  final String mimeType;
  final DateTime createdAt;
}
