import 'package:flutter/material.dart';

class ClientProfileAvatar extends StatelessWidget {
  const ClientProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.size,
    required this.backgroundColor,
    required this.placeholderColor,
    this.borderColor,
    this.borderWidth = 0,
  });

  final String? imageUrl;
  final double size;
  final Color backgroundColor;
  final Color placeholderColor;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null ? child : _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Icon(
    Icons.person,
    color: placeholderColor,
    size: size * 0.54,
  );
}
