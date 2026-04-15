import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  final bool isChecked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth * 0.06;
    final padding = size * 0.15;
    final borderRadius = size * 0.33;

    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: AnimatedContainer(
        width: size,
        height: size,
        duration: const Duration(milliseconds: 100),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1.5, color: Colors.white),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isChecked
            ? Padding(
                padding: EdgeInsets.all(padding),
                child: SvgPicture.asset(
                  'assets/images/Check.svg',
                  fit: BoxFit.contain,
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}
