import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachMessageRequestsViewBody extends StatelessWidget {
  const CoachMessageRequestsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = ChatContactsData.requests;
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
                'Message Requests',
                style: AppTextStyles.semiBold15(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final contact = requests[index];
                  return _RequestItem(
                    contact: contact,
                    onTap: () => Navigator.pushNamed(
                      context,
                      CoachChatView.routeName,
                      arguments: contact,
                    ),
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
              child: Icon(Icons.arrow_back,
                  color: AppColors.textPrimary, size: 24.sp),
            ),
          ),
          Text(
            'Messages requests',
            style: AppTextStyles.semiBold15(context)
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _RequestItem extends StatelessWidget {
  const _RequestItem({required this.contact, required this.onTap});

  final ChatContact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = contact.messages.isNotEmpty
        ? contact.messages.last.text
        : '';
    final time = contact.messages.isNotEmpty
        ? contact.messages.last.time
        : '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundColor: AppColors.surfaceDark,
              child: contact.imageAsset != null
                  ? ClipOval(
                      child: Image.asset(contact.imageAsset!,
                          fit: BoxFit.cover, width: 52.r, height: 52.r))
                  : Icon(Icons.person,
                      color: AppColors.textSecondary, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: AppTextStyles.semiBold15(context)
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    preview,
                    style: AppTextStyles.meduim12(context)
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              time,
              style: AppTextStyles.meduim12(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 22.r,
              height: 22.r,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${contact.messages.length}',
                style: AppTextStyles.semiBold10(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
