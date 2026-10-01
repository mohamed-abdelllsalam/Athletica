import 'dart:async';
import 'package:athletica/core/widgets/unfocus_on_tap.dart';

import 'package:athletica/core/utils/chat_scroll_anchor.dart';
import 'package:athletica/core/widgets/chat_media_bubble.dart';
import 'package:athletica/core/widgets/chat_media_composer.dart';

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
import 'package:athletica/features/coach/messages/presentation/models/coach_chat_route_args.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_client_detail_view.dart';
import 'package:athletica/features/chat/domain/entities/chat_message.dart'
    as chat;
import 'package:athletica/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_state.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/chat_date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachChatViewBody extends StatefulWidget {
  const CoachChatViewBody({super.key, required this.contact, this.chatArgs});

  final ChatContact contact;
  final CoachChatRouteArgs? chatArgs;

  @override
  State<CoachChatViewBody> createState() => _CoachChatViewBodyState();
}

class _CoachChatViewBodyState extends State<CoachChatViewBody>
    with WidgetsBindingObserver {
  late final List<ChatMessage> _messages;
  bool _accepted = false;
  late final ScrollController _scrollController;
  String _myUserId = '';
  final ChatScrollAnchor _scrollAnchor = ChatScrollAnchor();
  String? _latestMessageId;
  bool _followLatest = true;
  bool _forceFollowLatest = false;

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.contact.messages);
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
    if (widget.chatArgs != null) unawaited(_loadUserId());
  }

  Future<void> _loadUserId() async {
    final role = await TokenStorageService.instance.getRole();
    final storage = TokenStorageService.instance;
    final id = role == 'TRAINER'
        ? await storage.getTrainerId()
        : await storage.getClientId();
    if (mounted) setState(() => _myUserId = id ?? '');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.chatArgs != null) {
      unawaited(context.read<ChatCubit>().resume());
    }
  }

  @override
  void didChangeMetrics() {
    if (!_followLatest) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    _followLatest = position.extentBefore <= position.viewportDimension * 0.25;
    if (widget.chatArgs != null &&
        position.pixels >= position.maxScrollExtent) {
      final chatState = context.read<ChatCubit>().state;
      if (chatState is ChatReady &&
          chatState.hasMore &&
          !chatState.isLoadingOlder) {
        unawaited(context.read<ChatCubit>().loadOlder());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
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
          _scrollController.position.minScrollExtent,
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
    final args = widget.chatArgs;
    if (args != null) {
      Navigator.pushNamed(
        context,
        CoachClientDetailView.routeName,
        arguments: {
          'clientId': args.clientId,
          'clientName': args.clientName,
          'coachClientId': args.coachClientId,
        },
      );
      return;
    }

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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: UnfocusOnTap(
                child: widget.chatArgs == null
                    ? _buildLegacyMessages()
                    : _buildBackendMessages(),
              ),
            ),
            _isRequest
                ? CoachChatRequestActions(
                    onBlock: _showBlockSheet,
                    onDelete: _showDeleteSheet,
                    onAccept: _acceptRequest,
                  )
                : widget.chatArgs == null
                ? CoachChatInput(onSend: _sendMessage)
                : BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      final cubit = context.read<ChatCubit>();
                      return ChatMediaComposer(
                        enabled: state is ChatReady && state.canSend,
                        sending: state is ChatReady && state.isSending,
                        progress: state is ChatReady
                            ? state.uploadProgress
                            : null,
                        onCancel: cubit.cancelUpload,
                        onSend: (text, attachment) {
                          _forceFollowLatest = true;
                          return cubit.send(text, attachment: attachment);
                        },
                      );
                    },
                  ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyMessages() => ListView(
    reverse: true,
    controller: _scrollController,
    physics: const BouncingScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    children: [
      CoachChatProfileHeader(
        contact: widget.contact,
        imageUrl: widget.chatArgs?.clientImageUrl,
        onOpenProfile: _openProfile,
      ),
      SizedBox(height: 8.h),
      _buildTimestamp(context),
      SizedBox(height: 16.h),
      ..._messages.map((message) => CoachChatBubble(message: message)),
      if (_isRequest) ...[
        SizedBox(height: 16.h),
        _buildUnreadDivider(context),
        SizedBox(height: 12.h),
        CoachChatSecurityNotice(contact: widget.contact),
      ],
      SizedBox(height: 16.h),
    ].reversed.toList(),
  );

  Widget _buildBackendMessages() => BlocConsumer<ChatCubit, ChatState>(
    listenWhen: (previous, current) {
      if (current is! ChatReady) return false;
      if (current.errorMessage != null &&
          (previous is! ChatReady ||
              previous.errorMessage != current.errorMessage)) {
        return true;
      }
      return (previous is ChatReady &&
              previous.isLoadingOlder &&
              !current.isLoadingOlder) ||
          (current.messages.isNotEmpty &&
              chat.ChatMessage.chronological(current.messages).last.id !=
                  _latestMessageId);
    },
    listener: (context, state) {
      if (state is! ChatReady) return;
      if (state.errorMessage != null) {
        _forceFollowLatest = false;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      }
      final messages = chat.ChatMessage.chronological(state.messages);
      if (messages.isNotEmpty && messages.last.id != _latestMessageId) {
        final isOpening = _latestMessageId == null;
        final shouldFollow =
            _latestMessageId == null || _forceFollowLatest || _followLatest;
        final restoreAnchor = shouldFollow
            ? null
            : _scrollAnchor.capture(_scrollController, () => mounted);
        if (restoreAnchor != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => restoreAnchor());
        }
        _latestMessageId = messages.last.id;
        _forceFollowLatest = false;
        if (shouldFollow) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              if (isOpening) {
                _scrollController.jumpTo(
                  _scrollController.position.minScrollExtent,
                );
              } else {
                unawaited(
                  _scrollController.animateTo(
                    _scrollController.position.minScrollExtent,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                  ),
                );
              }
            }
          });
        }
      }
    },
    builder: (context, state) {
      if (state is ChatInitial || state is ChatLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is ChatFailureState) {
        return Center(
          child: TextButton(
            onPressed: () => unawaited(context.read<ChatCubit>().open()),
            child: Text(state.message),
          ),
        );
      }
      final ready = state as ChatReady;
      final messages = chat.ChatMessage.chronological(ready.messages);
      _latestMessageId ??= messages.lastOrNull?.id;
      _scrollAnchor.retainMessages(messages.map((message) => message.id));
      return ListView(
        reverse: true,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          CoachChatProfileHeader(
            contact: widget.contact,
            imageUrl: widget.chatArgs?.clientImageUrl,
            onOpenProfile: _openProfile,
          ),
          SizedBox(height: 8.h),
          _buildBackendTimestamp(messages),
          SizedBox(height: 16.h),
          if (ready.isLoadingOlder)
            const Center(child: CircularProgressIndicator()),
          ...messages.indexed.expand((entry) {
            final (index, message) = entry;
            final mine = message.isMine(_myUserId);
            final priorDayDiffers =
                index == 0 ||
                !DateUtils.isSameDay(
                  messages[index - 1].createdAt,
                  message.createdAt,
                );
            return [
              if (priorDayDiffers)
                _buildDateDivider(formatChatDay(message.createdAt)),
              ChatMediaBubble(
                key: _scrollAnchor.keyFor(message.id),
                type: message.messageType,
                content: message.content,
                url: message.attachmentUrl,
                durationSeconds: message.attachmentDurationSec,
                isMe: mine,
                time: formatChatTime(message.createdAt),
              ),
            ];
          }),
          SizedBox(height: 16.h),
        ].reversed.toList(),
      );
    },
  );

  Widget _buildBackendTimestamp(List<chat.ChatMessage> messages) => Center(
    child: Text(
      messages.isEmpty ? 'Today' : formatChatDay(messages.first.createdAt),
      style: AppTextStyles.meduim12(
        context,
      ).copyWith(color: AppColors.textSecondary),
    ),
  );

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
          GestureDetector(
            onTap: _openProfile,
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.surfaceDark,
              backgroundImage:
                  widget.chatArgs?.clientImageUrl?.trim().isNotEmpty == true
                  ? NetworkImage(widget.chatArgs!.clientImageUrl!.trim())
                  : null,
              child: widget.chatArgs?.clientImageUrl?.trim().isNotEmpty == true
                  ? null
                  : widget.contact.imageAsset != null
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
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: _openProfile,
            child: Text(
              widget.contact.name,
              style: AppTextStyles.semiBold15(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final time = _messages.isNotEmpty
        ? formatChatDayText(_messages.first.time)
        : 'Today';
    return Center(
      child: Text(
        time,
        style: AppTextStyles.meduim12(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildDateDivider(String date) => Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: Center(
      child: Text(
        date,
        style: AppTextStyles.meduim12(
          context,
        ).copyWith(color: AppColors.textSecondary),
      ),
    ),
  );

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
