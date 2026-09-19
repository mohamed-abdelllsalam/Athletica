import 'coach_messages_controls.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/domain/entities/coach_message_preview.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_chat_view.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_message_requests_view.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_message_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachMessagesViewBody extends StatefulWidget {
  const CoachMessagesViewBody({super.key});

  @override
  State<CoachMessagesViewBody> createState() => _CoachMessagesViewBodyState();
}

class _CoachMessagesViewBodyState extends State<CoachMessagesViewBody> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0 = Messages, 1 = Requests
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CoachMessagePreview> get _filtered {
    if (_query.isEmpty) return CoachMessagesData.messages;
    final lower = _query.toLowerCase();
    return CoachMessagesData.messages
        .where((m) => m.name.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CoachMessagesSearch(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildTabRow(context),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: _selectedTab == 0
                  ? _buildMessagesList()
                  : _buildRequestsEmpty(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'Messages',
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTabRow(BuildContext context) {
    return Row(
      children: [
        CoachMessagesTab(
          label: 'Messages',
          isActive: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        SizedBox(width: 20.w),
        CoachMessagesTab(
          label: 'Requests',
          isActive: _selectedTab == 1,
          onTap: () =>
              Navigator.pushNamed(context, CoachMessageRequestsView.routeName),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    final items = _filtered;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          Divider(color: AppColors.surfaceDark, height: 1, thickness: 1),
      itemBuilder: (context, index) {
        final preview = items[index];
        return CoachMessageItem(
          message: preview,
          onTap: () {
            final contact = ChatContactsData.contacts.firstWhere(
              (c) => c.id == preview.id,
              orElse: () => ChatContact(
                id: preview.id,
                name: preview.name,
                imageAsset: preview.imageAsset,
              ),
            );
            Navigator.pushNamed(
              context,
              CoachChatView.routeName,
              arguments: contact,
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsEmpty(BuildContext context) {
    return Center(
      child: Text(
        'No requests',
        style: AppTextStyles.medium15(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
