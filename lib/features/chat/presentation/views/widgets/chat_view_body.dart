import 'dart:async';
import 'package:athletica/core/widgets/unfocus_on_tap.dart';

import 'package:athletica/core/utils/chat_scroll_anchor.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/chat_date_format.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/chat/domain/entities/chat_message.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_state.dart';
import 'package:athletica/core/widgets/chat_media_bubble.dart';
import 'package:athletica/core/widgets/chat_media_composer.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_cubit.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_state.dart';
import 'package:athletica/features/client_coach/presentation/views/client_coach_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatViewBody extends StatefulWidget {
  const ChatViewBody({super.key});

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody>
    with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  String _myUserId = '';
  final ChatScrollAnchor _scrollAnchor = ChatScrollAnchor();
  String? _latestMessageId;
  bool _followLatest = true;
  bool _forceFollowLatest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController()..addListener(_onScroll);
    unawaited(_loadUserId());
  }

  Future<void> _loadUserId() async {
    final storage = TokenStorageService.instance;
    final id =
        await storage.getClientId() ?? await storage.getTrainerId() ?? '';
    if (mounted) setState(() => _myUserId = id);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<ChatCubit>().resume());
    }
  }

  @override
  void didChangeMetrics() {
    if (!_followLatest) return;
    _scrollToLatest();
  }

  void _scrollToLatest({Duration duration = Duration.zero}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final target = _scrollController.position.minScrollExtent;
      if (duration == Duration.zero) {
        _scrollController.jumpTo(target);
      } else {
        unawaited(
          _scrollController.animateTo(
            target,
            duration: duration,
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  void _onScroll() {
    final state = context.read<ChatCubit>().state;
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      _followLatest =
          position.extentBefore <= position.viewportDimension * 0.25;
    }
    if (_scrollController.hasClients &&
        state is ChatReady &&
        state.hasMore &&
        !state.isLoadingOlder &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
      unawaited(context.read<ChatCubit>().loadOlder());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            _buildAppBar(context),
            SizedBox(height: 16.h),
            Expanded(
              child: UnfocusOnTap(
                child: BlocConsumer<ChatCubit, ChatState>(
                  listenWhen: (previous, current) =>
                      current is ChatReady &&
                      (current.errorMessage != null ||
                          (previous is ChatReady &&
                              previous.isLoadingOlder &&
                              !current.isLoadingOlder) ||
                          (current.messages.isNotEmpty &&
                              ChatMessage.chronological(
                                    current.messages,
                                  ).last.id !=
                                  _latestMessageId)),
                  listener: (context, state) {
                    if (state is! ChatReady) return;
                    final messages = ChatMessage.chronological(state.messages);
                    if (state.errorMessage != null) {
                      _forceFollowLatest = false;
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(content: Text(state.errorMessage!)),
                        );
                    }
                    if (messages.isNotEmpty &&
                        messages.last.id != _latestMessageId) {
                      final isOpening = _latestMessageId == null;
                      final shouldFollow =
                          _latestMessageId == null ||
                          _forceFollowLatest ||
                          _followLatest;
                      final restoreAnchor = shouldFollow
                          ? null
                          : _scrollAnchor.capture(
                              _scrollController,
                              () => mounted,
                            );
                      if (restoreAnchor != null) {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => restoreAnchor(),
                        );
                      }
                      _latestMessageId = messages.last.id;
                      _forceFollowLatest = false;
                      if (shouldFollow) {
                        _scrollToLatest(
                          duration: isOpening
                              ? Duration.zero
                              : const Duration(milliseconds: 180),
                        );
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
                          onPressed: () => unawaited(cubit.open()),
                          child: Text(state.message),
                        ),
                      );
                    }
                    final ready = state as ChatReady;
                    final messages = ChatMessage.chronological(ready.messages);
                    _latestMessageId ??= messages.lastOrNull?.id;
                    _scrollAnchor.retainMessages(
                      messages.map((message) => message.id),
                    );
                    return ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount:
                          messages.length + (ready.isLoadingOlder ? 1 : 0),
                      findChildIndexCallback: (key) {
                        if (key is! ValueKey<String>) return null;
                        final index = messages.indexWhere(
                          (message) => message.id == key.value,
                        );
                        return index < 0 ? null : messages.length - 1 - index;
                      },
                      itemBuilder: (context, index) {
                        if (ready.isLoadingOlder && index == messages.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final messageIndex = messages.length - 1 - index;
                        final message = messages[messageIndex];
                        final isFirst =
                            messageIndex == 0 ||
                            !DateUtils.isSameDay(
                              messages[messageIndex - 1].createdAt,
                              message.createdAt,
                            );
                        return Column(
                          key: ValueKey(message.id),
                          children: [
                            if (isFirst) _dateDivider(message.createdAt),
                            _messageBubble(message),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) => ChatMediaComposer(
                enabled: state is ChatReady && state.canSend,
                sending: state is ChatReady && state.isSending,
                progress: state is ChatReady ? state.uploadProgress : null,
                onCancel: cubit.cancelUpload,
                onSend: (text, attachment) {
                  _forceFollowLatest = true;
                  return cubit.send(text, attachment: attachment);
                },
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _messageBubble(ChatMessage msg) {
    final isMe = msg.isMine(_myUserId);
    return ChatMediaBubble(
      key: _scrollAnchor.keyFor(msg.id),
      content: msg.content,
      type: msg.messageType,
      url: msg.attachmentUrl,
      durationSeconds: msg.attachmentDurationSec,
      isMe: isMe,
      time: formatChatTime(msg.createdAt),
    );
  }

  Widget _dateDivider(DateTime date) => Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: Text(
      formatChatDay(date),
      style: AppTextStyles.meduim12(
        context,
      ).copyWith(color: AppColors.textSecondary),
    ),
  );

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
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, ClientCoachView.routeName),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.cardBackgroundLight,
              child: BlocBuilder<ClientCoachCubit, ClientCoachState>(
                builder: (context, state) {
                  final imageUrl = state is ClientCoachLoaded
                      ? state.coach.imageUrl
                      : null;
                  return imageUrl?.trim().isNotEmpty == true
                      ? ClipOval(
                          child: Image.network(
                            imageUrl!.trim(),
                            fit: BoxFit.cover,
                            width: 40.r,
                            height: 40.r,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 22.sp,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 22.sp,
                        );
                },
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, ClientCoachView.routeName),
            child: BlocBuilder<ClientCoachCubit, ClientCoachState>(
              builder: (context, state) {
                final title = state is ClientCoachLoaded
                    ? state.coach.username
                    : 'Coach';
                return Text(
                  title,
                  style: AppTextStyles.semiBold15(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
