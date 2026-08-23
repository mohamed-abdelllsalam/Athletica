class JoinRequest {
  const JoinRequest({
    required this.id,
    required this.name,
    this.email = '',
    this.goal = '',
    this.status = 'pending',
    this.createdAt,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String email;
  final String goal;
  final String status;
  final DateTime? createdAt;
  final String? imageAsset;
}
