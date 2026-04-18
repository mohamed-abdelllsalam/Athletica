import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/join_request.dart';
import 'package:athletica/features/coach/clients/domain/entities/join_requests_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachJoinRequestsViewBody extends StatefulWidget {
  const CoachJoinRequestsViewBody({super.key});

  @override
  State<CoachJoinRequestsViewBody> createState() =>
      _CoachJoinRequestsViewBodyState();
}

class _CoachJoinRequestsViewBodyState
    extends State<CoachJoinRequestsViewBody> {
  final List<JoinRequest> _requests = List.of(JoinRequestsData.requests);

  void _accept(JoinRequest request) {
    setState(() => _requests.remove(request));
  }

  void _reject(JoinRequest request) {
    setState(() => _requests.remove(request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Text(
                'Request (${_requests.length})',
                style: AppTextStyles.medium15(context).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  return _RequestTile(
                    request: _requests[index],
                    onAccept: () => _accept(_requests[index]),
                    onReject: () => _reject(_requests[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24.sp,
              ),
            ),
          ),
          Text(
            'Join Requests',
            style: AppTextStyles.semiBold15(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  final JoinRequest request;
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
              child: request.imageAsset != null
                  ? Image.asset(request.imageAsset!, fit: BoxFit.cover)
                  : Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 28.sp,
                    ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              request.name,
              style: AppTextStyles.semiBold15(context).copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _CircleIconButton(
            icon: Icons.close,
            iconColor: AppColors.textPrimary,
            borderColor: AppColors.textSecondary,
            onTap: onReject,
          ),
          SizedBox(width: 10.w),
          _CircleIconButton(
            icon: Icons.check,
            iconColor: AppColors.primaryBlue,
            borderColor: AppColors.primaryBlue,
            onTap: onAccept,
          ),
        ],
      ),
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
  final VoidCallback onTap;

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
