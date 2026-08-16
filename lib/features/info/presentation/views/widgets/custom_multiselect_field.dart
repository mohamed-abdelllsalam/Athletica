import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomMultiselectField extends StatefulWidget {
  const CustomMultiselectField({
    super.key,
    required this.options,
    required this.onChanged,
  });

  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  State<CustomMultiselectField> createState() => _CustomMultiselectFieldState();
}

class _CustomMultiselectFieldState extends State<CustomMultiselectField> {
  final Set<String> _selected = {};

  void _toggle(String option) {
    setState(() {
      if (_selected.contains(option)) {
        _selected.remove(option);
      } else {
        _selected.add(option);
      }
    });
    widget.onChanged(_selected.isEmpty ? null : _selected.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: widget.options.map((option) {
        final isSelected = _selected.contains(option);
        return GestureDetector(
          onTap: () => _toggle(option),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF5273E0)
                    : const Color(0xFF4A4949),
                width: 2.w,
              ),
              borderRadius: BorderRadius.circular(8.r),
              color: isSelected
                  ? const Color(0xFF5273E0).withValues(alpha: 0.15)
                  : Colors.transparent,
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? const Color(0xFF5273E0) : Colors.white70,
                fontSize: 13.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
