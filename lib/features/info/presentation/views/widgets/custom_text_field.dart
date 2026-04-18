import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.keyboardType,
    required this.onChanged,
  });

  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final _controller = TextEditingController();
  bool _hasValue = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42.h,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 3.w,
            color: _hasValue
                ? const Color(0xFF5273E0)
                : const Color(0xFF4A4949),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: TextField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
        ),
        onChanged: (value) {
          setState(() => _hasValue = value.trim().isNotEmpty);
          widget.onChanged(value);
        },
      ),
    );
  }
}
