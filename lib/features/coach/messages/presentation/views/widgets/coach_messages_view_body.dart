import 'coach_messages_controls.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/messages/domain/entities/coach_message_preview.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_chat_view.dart';
import 'package:athletica/features/coach/messages/presentation/views/widgets/coach_message_item.dart';
import 'package:athletica/features/coach/messages/presentation/models/coach_chat_route_args.dart';
import 'package:athletica/features/coach/messages/presentation/cubits/coach_messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachMessagesViewBody extends StatefulWidget {
  const CoachMessagesViewBody({super.key});

  @override
  State<CoachMessagesViewBody> createState() => _CoachMessagesViewBodyState();
}

class _CoachMessagesViewBodyState extends State<CoachMessagesViewBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CoachMessagePreview> _filtered(List<CoachMessagePreview> messages) {
    if (_query.isEmpty) return messages;
    final lower = _query.toLowerCase();
    return messages.where((m) => m.name.toLowerCase().contains(lower)).toList();
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
            SizedBox(height: 16.h),
            Expanded(
              child: BlocBuilder<CoachMessagesCubit, CoachMessagesState>(
                builder: (context, state) => switch (state) {
                  CoachMessagesLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  CoachMessagesFailure(:final message) => Center(
                    child: TextButton(
                      onPressed: () =>
                          context.read<CoachMessagesCubit>().load(),
                      child: Text(message),
                    ),
                  ),
                  CoachMessagesLoaded(:final messages) => _buildMessagesList(
                    _filtered(messages),
                  ),
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

  Widget _buildMessagesList(List<CoachMessagePreview> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No messages yet.',
          style: AppTextStyles.medium15(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      );
    }
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
          onTap: () async {
            await Navigator.pushNamed(
              context,
              CoachChatView.routeName,
              arguments: CoachChatRouteArgs(
                clientId: preview.clientId ?? preview.id,
                clientName: preview.name,
                clientImageUrl: preview.imageUrl,
                conversationId: preview.conversationId,
                coachClientId: preview.coachClientId,
              ),
            );
            if (context.mounted) {
              context.read<CoachMessagesCubit>().load();
            }
          },
        );
      },
    );
  }
}
