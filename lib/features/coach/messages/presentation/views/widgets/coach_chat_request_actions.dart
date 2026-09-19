import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachChatRequestActions extends StatelessWidget {
  const CoachChatRequestActions({
    super.key,
    required this.onBlock,
    required this.onDelete,
    required this.onAccept,
  });
  final VoidCallback onBlock;
  final VoidCallback onDelete;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: _RequestActionButton(
              label: 'Block',
              color: const Color(0xFFE53935),
              onTap: onBlock,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _RequestActionButton(
              label: 'Delete',
              color: const Color(0xFFE53935),
              onTap: onDelete,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _RequestActionButton(
              label: 'Accept',
              color: AppColors.textPrimary,
              onTap: onAccept,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestActionButton extends StatelessWidget {
  const _RequestActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.semiBold15(context).copyWith(color: color),
        ),
      ),
    );
  }
}
