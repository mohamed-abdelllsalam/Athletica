import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/chat/presentation/views/widgets/chat_bubble.dart';
import 'package:athletica/features/chat/presentation/views/widgets/chat_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatViewBody extends StatefulWidget {
  const ChatViewBody({super.key});

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello, hope you\'re doing well. Are you ready to begin the process',
      'isMe': false,
      'avatarVisible': true,
    },
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'avatarVisible': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            _buildAppBar(context),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return ChatBubble(
                    message: msg['text'] as String,
                    isMe: msg['isMe'] as bool,
                    avatarVisible: msg['avatarVisible'] as bool,
                  );
                },
              ),
            ),
            ChatInputField(onSendMessage: _sendMessage),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
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
            radius: 20.r,
            backgroundColor: AppColors.cardBackgroundLight,
            child: Icon(
              Icons.person,
              color: AppColors.textSecondary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Ahmed Abdo',
            style: AppTextStyles.semiBold15(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
