import 'coach_delete_request_spam_option.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachDeleteRequestSheet extends StatefulWidget {
  const CoachDeleteRequestSheet({super.key, required this.contact});

  final ChatContact contact;

  @override
  State<CoachDeleteRequestSheet> createState() =>
      _CoachDeleteRequestSheetState();
}

class _CoachDeleteRequestSheetState extends State<CoachDeleteRequestSheet> {
  bool _markAsSpam = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.close,
                color: AppColors.textPrimary,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          CircleAvatar(
            radius: 36.r,
            backgroundColor: AppColors.surfaceDark,
            child: widget.contact.imageAsset != null
                ? ClipOval(
                    child: Image.asset(
                      widget.contact.imageAsset!,
                      fit: BoxFit.cover,
                      width: 72.r,
                      height: 72.r,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: 32.sp,
                  ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Delete Message Request ?',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 20.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Other actions you can take',
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 12.h),
          CoachDeleteRequestSpamOption(
            contactName: widget.contact.name,
            markAsSpam: _markAsSpam,
            onToggle: () => setState(() => _markAsSpam = !_markAsSpam),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Delete',
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
