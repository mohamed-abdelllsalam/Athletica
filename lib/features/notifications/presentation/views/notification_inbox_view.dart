import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/features/notifications/domain/entities/inbox_notification.dart';
import 'package:athletica/features/notifications/domain/usecases/notification_inbox.dart';
import 'package:athletica/features/notifications/presentation/cubits/notification_inbox_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationInboxView extends StatefulWidget {
  const NotificationInboxView({super.key, required this.onTap});
  static const routeName = '/notifications';
  final void Function(InboxNotification) onTap;
  @override
  State<NotificationInboxView> createState() => _NotificationInboxViewState();
}

class _NotificationInboxViewState extends State<NotificationInboxView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationInboxCubit>().open();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.primaryAppColor,
    appBar: AppBar(
      title: const Text('Notifications'),
      backgroundColor: AppColors.primaryAppColor,
    ),
    body: BlocBuilder<NotificationInboxCubit, InboxSnapshot>(
      builder: (context, state) {
        if (state.loading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: context.read<NotificationInboxCubit>().refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (state.connectionError || state.badgeConnectionError)
                ConnectionErrorView(
                  compact: state.items.isNotEmpty,
                  onRetry: () =>
                      context.read<NotificationInboxCubit>().refresh(),
                ),
              if ((state.error != null && !state.connectionError) ||
                  (state.badgeError != null && !state.badgeConnectionError))
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Text(
                        state.error ?? state.badgeError!,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: context
                            .read<NotificationInboxCubit>()
                            .refresh,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              if (state.items.isEmpty && state.error == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 96),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              for (final item in state.items)
                _InboxRow(item: item, onTap: () => widget.onTap(item)),
              if (state.loadingMore)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.hasMore)
                TextButton(
                  onPressed: context.read<NotificationInboxCubit>().loadMore,
                  child: const Text('Load more'),
                ),
            ],
          ),
        );
      },
    ),
  );
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({required this.item, required this.onTap});
  final InboxNotification item;
  final VoidCallback onTap;
  String _time(BuildContext context) {
    final date = item.createdAt;
    if (date == null) return '';
    final duration = DateTime.now().difference(date);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    if (duration.inMinutes < 1) return arabic ? 'الآن' : 'Just now';
    if (duration.inHours < 1) {
      return arabic
          ? 'منذ ${duration.inMinutes} دقيقة'
          : '${duration.inMinutes}m ago';
    }
    if (duration.inDays < 1) {
      return arabic
          ? 'منذ ${duration.inHours} ساعة'
          : '${duration.inHours}h ago';
    }
    if (duration.inDays < 7) {
      return arabic ? 'منذ ${duration.inDays} يوم' : '${duration.inDays}d ago';
    }
    return MaterialLocalizations.of(context).formatShortDate(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final name = item.actor?.username;
    final image = item.actor?.profileImage;
    final fallback = CircleAvatar(
      backgroundColor: AppColors.cardBackgroundLight,
      child: Text(
        name != null && name.isNotEmpty
            ? name.characters.first.toUpperCase()
            : '?',
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: item.isRead
            ? AppColors.cardBackground
            : AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 42,
                  height: 42,
                  child:
                      image != null &&
                          const {
                            'http',
                            'https',
                          }.contains(Uri.tryParse(image)?.scheme)
                      ? ClipOval(
                          child: Image.network(
                            image,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null ? child : fallback,
                            errorBuilder: (_, _, _) => fallback,
                          ),
                        )
                      : fallback,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (name != null && name.isNotEmpty)
                        Text(
                          name,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        item.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: item.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.body,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _time(context),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!item.isRead)
                  const Padding(
                    padding: EdgeInsets.only(left: 8, top: 4),
                    child: Icon(
                      Icons.circle,
                      size: 8,
                      color: AppColors.notificationBadge,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
