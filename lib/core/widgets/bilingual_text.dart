import 'package:flutter/material.dart';

/// Renders English text on top and Arabic text below in the same field,
/// with proper text direction for each language.
class BilingualText extends StatelessWidget {
  const BilingualText({
    super.key,
    required this.english,
    required this.arabic,
    required this.style,
    this.englishStyle,
    this.arabicStyle,
    this.textAlign,
    this.spacing = 2,
  });

  final String english;
  final String arabic;
  final TextStyle style;
  final TextStyle? englishStyle;
  final TextStyle? arabicStyle;
  final TextAlign? textAlign;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          english,
          style: style.merge(englishStyle),
          textDirection: TextDirection.ltr,
          textAlign: textAlign,
        ),
        SizedBox(height: spacing),
        Text(
          arabic,
          style: style.merge(arabicStyle),
          textDirection: TextDirection.rtl,
          textAlign: textAlign,
        ),
      ],
    );
  }
}
