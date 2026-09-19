import 'coach_message_request_item.dart';
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
                style: AppTextStyles.semiBold15(
                  context,
                ).copyWith(color: AppColors.textPrimary),
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
                  return CoachMessageRequestItem(
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
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24.sp,
              ),
            ),
          ),
          Text(
            'Messages requests',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
