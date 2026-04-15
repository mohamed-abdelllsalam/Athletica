import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SocialLogin extends StatelessWidget {
  const SocialLogin({
    super.key,
    required this.onTap,
    required this.image,
  });
  final void Function() onTap;
  final String image;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: SvgPicture.asset(image),
        ),
      ],
    );
  }
}
