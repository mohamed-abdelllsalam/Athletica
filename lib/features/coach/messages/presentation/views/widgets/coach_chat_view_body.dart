import 'coach_chat_bubble.dart';
import 'coach_chat_profile_header.dart';
import 'coach_chat_security_notice.dart';
import 'coach_chat_request_actions.dart';
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
      _messages.add(ChatMessage(text: text, isMe: true, time: 'Now'));
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
                  CoachChatProfileHeader(
                    contact: widget.contact,
                    onOpenProfile: _openProfile,
                  ),
                  SizedBox(height: 8.h),
                  _buildTimestamp(context),
                  SizedBox(height: 16.h),
                  ..._messages.map(
                    (m) => CoachChatBubble(message: m, contact: widget.contact),
                  ),
                  if (_isRequest) ...[
                    SizedBox(height: 16.h),
                    _buildUnreadDivider(context),
                    SizedBox(height: 12.h),
                    CoachChatSecurityNotice(contact: widget.contact),
                  ],
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            if (_isRequest)
              CoachChatRequestActions(
                onBlock: _showBlockSheet,
                onDelete: _showDeleteSheet,
                onAccept: _acceptRequest,
              )
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
            child: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.surfaceDark,
            child: widget.contact.imageAsset != null
                ? ClipOval(
                    child: Image.asset(
                      widget.contact.imageAsset!,
                      fit: BoxFit.cover,
                      width: 36.r,
                      height: 36.r,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: 18.sp,
                  ),
          ),
          SizedBox(width: 10.w),
          Text(
            widget.contact.name,
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final time = _messages.isNotEmpty ? _messages.first.time : 'Today';
    return Center(
      child: Text(
        time,
        style: AppTextStyles.meduim12(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildUnreadDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.surfaceDark, height: 1, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            'Unread messages',
            style: AppTextStyles.meduim12(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.surfaceDark, height: 1, thickness: 1),
        ),
      ],
    );
  }
}
