import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachChatInput extends StatefulWidget {
  const CoachChatInput({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<CoachChatInput> createState() => _CoachChatInputState();
}

class _CoachChatInputState extends State<CoachChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(Icons.camera_alt_outlined,
              color: AppColors.textSecondary, size: 26.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _handleSend(),
                      style: AppTextStyles.medium14(context)
                          .copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: AppTextStyles.medium14(context)
                            .copyWith(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),
                  Icon(Icons.attach_file_rounded,
                      color: AppColors.textSecondary, size: 20.sp),
                  SizedBox(width: 8.w),
                  Icon(Icons.image_outlined,
                      color: AppColors.textSecondary, size: 20.sp),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _hasText ? _handleSend : null,
            child: Container(
              width: 42.r,
              height: 42.r,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _hasText ? Icons.send_rounded : Icons.mic_none_rounded,
                color: AppColors.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
