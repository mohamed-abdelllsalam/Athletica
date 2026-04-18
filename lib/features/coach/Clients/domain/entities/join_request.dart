class JoinRequest {
  const JoinRequest({
    required this.id,
    required this.name,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String? imageAsset;
}
