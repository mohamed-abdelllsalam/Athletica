import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextareaField extends StatefulWidget {
  const CustomTextareaField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<CustomTextareaField> createState() => _CustomTextareaFieldState();
}

class _CustomTextareaFieldState extends State<CustomTextareaField> {
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
        maxLines: 4,
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
