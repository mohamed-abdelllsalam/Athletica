import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42.h,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 3.w, color: Color(0xFF4A4949)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }
}
