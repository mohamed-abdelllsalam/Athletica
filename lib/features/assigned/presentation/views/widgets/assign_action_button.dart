import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssignActionButton extends StatelessWidget {
  const AssignActionButton({
    super.key,
    required this.hasSelection,
    required this.isAssigning,
    required this.onPressed,
  });

  final bool hasSelection;
  final bool isAssigning;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: isAssigning ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color:
                hasSelection ? AppColors.primaryBlue : AppColors.surfaceDark,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: isAssigning
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                hasSelection ? 'Assign' : 'Cancel',
                style: AppTextStyles.semiBold15(context).copyWith(
                  color: hasSelection
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
