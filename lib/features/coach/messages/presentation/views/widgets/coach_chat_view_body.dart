import 'dart:async';

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
  String? _latestMessageId;
  bool _followLatest = true;
  bool _forceFollowLatest = false;
  double? _olderLoadStartExtent;
  double? _olderLoadStartPixels;
  int? _olderLoadStartCount;

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.contact.messages);
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
    if (widget.chatArgs != null) unawaited(_loadUserId());
    if (widget.chatArgs == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,
          );
        }
      });
    }
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
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    _followLatest = position.extentAfter <= position.viewportDimension * 0.25;
    if (widget.chatArgs != null &&
        position.pixels <= position.minScrollExtent) {
      final chatState = context.read<ChatCubit>().state;
      if (chatState is ChatReady &&
          chatState.hasMore &&
          !chatState.isLoadingOlder) {
        _olderLoadStartExtent = position.maxScrollExtent;
        _olderLoadStartPixels = position.pixels;
        _olderLoadStartCount = chatState.messages.length;
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
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendBackendMessage(String text) {
    _forceFollowLatest = true;
    unawaited(context.read<ChatCubit>().send(text));
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
              child: widget.chatArgs == null
                  ? _buildLegacyMessages()
                  : _buildBackendMessages(),
            ),
            _isRequest
                ? CoachChatRequestActions(
                    onBlock: _showBlockSheet,
                    onDelete: _showDeleteSheet,
                    onAccept: _acceptRequest,
                  )
                : widget.chatArgs == null
                ? CoachChatInput(onSend: _sendMessage)
                : CoachChatInput(
                    onSend: _sendBackendMessage,
                  ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyMessages() => ListView(
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
    ],
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
      if (_olderLoadStartExtent != null &&
          _olderLoadStartPixels != null &&
          !state.isLoadingOlder) {
        final startExtent = _olderLoadStartExtent!;
        final startPixels = _olderLoadStartPixels!;
        final startCount = _olderLoadStartCount!;
        _olderLoadStartExtent = null;
        _olderLoadStartPixels = null;
        _olderLoadStartCount = null;
        if (state.messages.length > startCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final extentDelta =
                  _scrollController.position.maxScrollExtent - startExtent;
              final target = startPixels + extentDelta;
              _scrollController.jumpTo(
                target
                    .clamp(
                      _scrollController.position.minScrollExtent,
                      _scrollController.position.maxScrollExtent,
                    )
                    .toDouble(),
              );
            }
          });
        }
      }
      if (messages.isNotEmpty && messages.last.id != _latestMessageId) {
        final shouldFollow =
            _latestMessageId == null || _forceFollowLatest || _followLatest;
        _latestMessageId = messages.last.id;
        _forceFollowLatest = false;
        if (shouldFollow) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
              );
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
      return ListView(
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
              CoachChatBubble(
                message: ChatMessage(
                  text: message.content,
                  isMe: mine,
                  time: message.createdAt.toIso8601String(),
                ),
              ),
            ];
          }),
          SizedBox(height: 16.h),
        ],
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
