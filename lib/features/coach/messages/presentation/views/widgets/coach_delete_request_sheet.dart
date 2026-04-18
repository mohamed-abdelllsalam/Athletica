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
              child: Icon(Icons.close,
                  color: AppColors.textPrimary, size: 24.sp),
            ),
          ),
          SizedBox(height: 12.h),
          CircleAvatar(
            radius: 36.r,
            backgroundColor: AppColors.surfaceDark,
            child: widget.contact.imageAsset != null
                ? ClipOval(
                    child: Image.asset(widget.contact.imageAsset!,
                        fit: BoxFit.cover,
                        width: 72.r,
                        height: 72.r),
                  )
                : Icon(Icons.person,
                    color: AppColors.textSecondary, size: 32.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            'Delete Message Request ?',
            style: AppTextStyles.bold20(context)
                .copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 20.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Other actions you can take',
              style: AppTextStyles.meduim12(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mark as Spam',
                        style: AppTextStyles.semiBold15(context)
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Send Future messages from ${widget.contact.name} to spam',
                        style: AppTextStyles.meduim12(context)
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _markAsSpam = !_markAsSpam),
                  child: Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _markAsSpam
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary,
                        width: 2,
                      ),
                      color: _markAsSpam
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                    ),
                    child: _markAsSpam
                        ? Icon(Icons.check,
                            color: AppColors.textPrimary, size: 14.sp)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Delete',
                style: AppTextStyles.semiBold15(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
