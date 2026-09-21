class JoinRequest {
  const JoinRequest({
    required this.id,
    required this.name,
    this.email = '',
    this.goal = '',
    this.status = 'pending',
    this.createdAt,
    this.imageAsset,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String email;
  final String goal;
  final String status;
  final DateTime? createdAt;
  final String? imageAsset;

  /// Requester's network photo (`client.profile_image` from
  /// `GET /coach/requests`); null when the API omits it.
  final String? imageUrl;

  bool get hasPhoto {
    final url = imageUrl?.trim();
    return url != null && url.isNotEmpty && url.toLowerCase() != 'null';
  }
}
