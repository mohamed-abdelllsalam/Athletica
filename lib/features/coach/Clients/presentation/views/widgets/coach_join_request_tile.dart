import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:athletica/features/coach/clients/domain/entities/join_request.dart';

class CoachJoinRequestTile extends StatelessWidget {
  const CoachJoinRequestTile({
    super.key,
    required this.request,
    required this.busy,
    required this.actionInFlight,
    required this.onAccept,
    required this.onReject,
  });

  final JoinRequest request;
  final bool busy;
  final bool actionInFlight;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40.r),
            child: Container(
              width: 54.r,
              height: 54.r,
              color: AppColors.surfaceDark,
              child: _RequestAvatar(request: request),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  style: AppTextStyles.semiBold15(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                if (request.goal.isNotEmpty)
                  Text(
                    request.goal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.meduim11(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          _CircleIconButton(
            icon: Icons.close,
            iconColor: AppColors.textPrimary,
            borderColor: AppColors.textSecondary,
            onTap: actionInFlight ? null : onReject,
          ),
          SizedBox(width: 10.w),
          _CircleIconButton(
            icon: busy ? Icons.hourglass_top : Icons.check,
            iconColor: AppColors.primaryBlue,
            borderColor: AppColors.primaryBlue,
            onTap: busy || actionInFlight ? null : onAccept,
          ),
        ],
      ),
    );
  }
}

/// Requester avatar: network photo first, then the legacy local asset,
/// then the person placeholder (also on network-image failure).
class _RequestAvatar extends StatelessWidget {
  const _RequestAvatar({required this.request});

  final JoinRequest request;

  @override
  Widget build(BuildContext context) {
    if (request.hasPhoto) {
      return Image.network(
        request.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => const _PlaceholderIcon(),
      );
    }
    if (request.imageAsset != null) {
      return Image.asset(request.imageAsset!, fit: BoxFit.cover);
    }
    return const _PlaceholderIcon();
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.person,
      color: AppColors.textSecondary,
      size: 28.sp,
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Icon(icon, color: iconColor, size: 18.sp),
      ),
    );
  }
}
