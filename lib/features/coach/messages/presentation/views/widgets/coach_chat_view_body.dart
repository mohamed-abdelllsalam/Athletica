import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_block_user_sheet.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_chat_input.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_delete_request_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachChatViewBody extends StatefulWidget {
  const CoachChatViewBody({super.key, required this.contact});

  final ChatContact contact;

  @override
  State<CoachChatViewBody> createState() => _CoachChatViewBodyState();
}

class _CoachChatViewBodyState extends State<CoachChatViewBody> {
  late final List<ChatMessage> _messages;
  bool _accepted = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.contact.messages);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isMe: true,
        time: 'Now',
      ));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _acceptRequest() => setState(() => _accepted = true);

  Future<void> _showDeleteSheet() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CoachDeleteRequestSheet(contact: widget.contact),
    );
    if (confirmed == true && mounted) Navigator.pop(context);
  }

  Future<void> _showBlockSheet() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CoachBlockUserSheet(contact: widget.contact),
    );
    if (confirmed == true && mounted) Navigator.pop(context);
  }

  void _openProfile() {
    Navigator.pushNamed(
      context,
      'coach-contact-profile',
      arguments: widget.contact,
    );
  }

  bool get _isRequest => widget.contact.isRequest && !_accepted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  _buildProfileHeader(context),
                  SizedBox(height: 8.h),
                  _buildTimestamp(context),
                  SizedBox(height: 16.h),
                  ..._messages.map((m) => _CoachChatBubble(
                        message: m,
                        contact: widget.contact,
                      )),
                  if (_isRequest) ...[
                    SizedBox(height: 16.h),
                    _buildUnreadDivider(context),
                    SizedBox(height: 12.h),
                    _buildSecurityNotice(context),
                  ],
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            if (_isRequest)
              _buildRequestActions(context)
            else
              CoachChatInput(onSend: _sendMessage),
            SizedBox(height: 8.h),
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
            child: Icon(Icons.arrow_back,
                color: AppColors.textPrimary, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.surfaceDark,
            child: widget.contact.imageAsset != null
                ? ClipOval(
                    child: Image.asset(widget.contact.imageAsset!,
                        fit: BoxFit.cover, width: 36.r, height: 36.r))
                : Icon(Icons.person,
                    color: AppColors.textSecondary, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Text(
            widget.contact.name,
            style: AppTextStyles.semiBold15(context)
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        CircleAvatar(
          radius: 56.r,
          backgroundColor: AppColors.surfaceDark,
          child: widget.contact.imageAsset != null
              ? ClipOval(
                  child: Image.asset(widget.contact.imageAsset!,
                      fit: BoxFit.cover, width: 112.r, height: 112.r))
              : Icon(Icons.person,
                  color: AppColors.textSecondary, size: 48.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          widget.contact.name,
          style: AppTextStyles.bold20(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: _openProfile,
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'View Profile',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final time = _messages.isNotEmpty ? _messages.first.time : 'Today';
    return Center(
      child: Text(
        time,
        style: AppTextStyles.meduim12(context)
            .copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildUnreadDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(
                color: AppColors.surfaceDark, height: 1, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            'Unread messages',
            style: AppTextStyles.meduim12(context)
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
            child: Divider(
                color: AppColors.surfaceDark, height: 1, thickness: 1)),
      ],
    );
  }

  Widget _buildSecurityNotice(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline,
                  color: AppColors.textSecondary, size: 14.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.meduim12(context)
                        .copyWith(color: AppColors.textSecondary),
                    children: [
                      const TextSpan(
                        text:
                            'Messages are now secured with end-to-end encryption. Only people is this chat can read, listen to, or share them. ',
                      ),
                      TextSpan(
                        text: 'Learn more',
                        style: AppTextStyles.meduim12(context)
                            .copyWith(color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'If you accept ${widget.contact.name} will be able to message you and may see info like your active status and when you\'ve read message',
            style: AppTextStyles.meduim12(context)
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestActions(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: _RequestActionButton(
              label: 'Block',
              color: const Color(0xFFE53935),
              onTap: _showBlockSheet,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _RequestActionButton(
              label: 'Delete',
              color: const Color(0xFFE53935),
              onTap: _showDeleteSheet,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _RequestActionButton(
              label: 'Accept',
              color: AppColors.textPrimary,
              onTap: _acceptRequest,
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
          style:
              AppTextStyles.semiBold15(context).copyWith(color: color),
        ),
      ),
    );
  }
}

class _CoachChatBubble extends StatelessWidget {
  const _CoachChatBubble({
    required this.message,
    required this.contact,
  });

  final ChatMessage message;
  final ChatContact contact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.surfaceDark,
              child: contact.imageAsset != null
                  ? ClipOval(
                      child: Image.asset(contact.imageAsset!,
                          fit: BoxFit.cover,
                          width: 32.r,
                          height: 32.r))
                  : Icon(Icons.person,
                      color: AppColors.textSecondary, size: 16.sp),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: message.isMe
                    ? AppColors.primaryBlue
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: message.isMe
                      ? Radius.circular(16.r)
                      : Radius.circular(4.r),
                  bottomRight: message.isMe
                      ? Radius.circular(4.r)
                      : Radius.circular(16.r),
                ),
              ),
              child: Text(
                message.text,
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
          if (message.isMe) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.surfaceDark,
              child: Icon(Icons.person,
                  color: AppColors.textSecondary, size: 16.sp),
            ),
          ],
        ],
      ),
    );
  }
}
