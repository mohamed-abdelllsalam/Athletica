import 'dart:async';

import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/chat_date_format.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/chat/domain/entities/chat_message.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:athletica/features/chat/presentation/cubits/chat_state.dart';
import 'package:athletica/features/chat/presentation/views/widgets/chat_bubble.dart';
import 'package:athletica/features/chat/presentation/views/widgets/chat_input_field.dart';
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
  String? _latestMessageId;
  bool _followLatest = true;
  bool _forceFollowLatest = false;
  double? _olderLoadStartExtent;
  double? _olderLoadStartPixels;
  int? _olderLoadStartCount;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void _onScroll() {
    final state = context.read<ChatCubit>().state;
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      _followLatest =
          position.extentAfter <= position.viewportDimension * 0.25;
    }
    if (_scrollController.hasClients &&
        state is ChatReady &&
        state.hasMore &&
        !state.isLoadingOlder &&
        _scrollController.position.pixels <=
            _scrollController.position.minScrollExtent) {
      _olderLoadStartExtent = _scrollController.position.maxScrollExtent;
      _olderLoadStartPixels = _scrollController.position.pixels;
      _olderLoadStartCount = state.messages.length;
      unawaited(context.read<ChatCubit>().loadOlder());
    }
  }

  void _sendMessage(String text) {
    _forceFollowLatest = true;
    unawaited(context.read<ChatCubit>().send(text));
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
                              _scrollController.position.maxScrollExtent -
                              startExtent;
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
                  if (messages.isNotEmpty &&
                      messages.last.id != _latestMessageId) {
                    final shouldFollow =
                        _latestMessageId == null ||
                        _forceFollowLatest ||
                        _followLatest;
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
                        onPressed: () => unawaited(cubit.open()),
                        child: Text(state.message),
                      ),
                    );
                  }
                  final ready = state as ChatReady;
                  final messages =
                      ChatMessage.chronological(ready.messages);
                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount:
                        messages.length + (ready.isLoadingOlder ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (ready.isLoadingOlder && index == 0) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final messageIndex =
                          index - (ready.isLoadingOlder ? 1 : 0);
                      final message = messages[messageIndex];
                      final isFirst =
                          messageIndex == 0 ||
                          !DateUtils.isSameDay(
                            messages[messageIndex - 1].createdAt,
                            message.createdAt,
                          );
                      return Column(
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
            BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (previous, current) =>
                  previous is ChatReady &&
                      current is ChatReady &&
                      previous.canSend != current.canSend ||
                  previous.runtimeType != current.runtimeType,
              builder: (context, state) => ChatInputField(
                enabled: state is ChatReady && state.canSend,
                onSendMessage: _sendMessage,
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
    return ChatBubble(
      message: msg.content,
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
