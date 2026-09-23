import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    required this.onSendMessage,
    this.enabled = true,
  });

  final Function(String) onSendMessage;
  final bool enabled;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void _handleSend() {
    final text = _controller.text;
    if (widget.enabled && text.trim().isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled,
                      onSubmitted: (_) => _handleSend(),
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Hi! 😊 Thank you so much',
                        hintStyle: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: widget.enabled ? _handleSend : null,
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
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
