import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/notifications/domain/usecases/notification_inbox.dart';
import 'package:athletica/features/notifications/presentation/views/notification_inbox_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

/// A separate accessible inbox target; chat unread is never part of this count.
class NotificationBadgeButton extends StatelessWidget {
  const NotificationBadgeButton({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final inbox = GetIt.instance<NotificationInbox>();
    return StreamBuilder<InboxSnapshot>(
      stream: inbox.changes,
      initialData: inbox.state,
      builder: (context, snapshot) {
        final count = snapshot.data?.unread ?? 0;
        final label = count > 99 ? '99+' : '$count';
        final badgeError = snapshot.data?.badgeError;
        return Semantics(
          button: true,
          label:
              'Notifications, $count unread${badgeError == null ? '' : ', count could not be refreshed'}',
          child: Tooltip(
            message: badgeError ?? 'Notifications',
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  Navigator.pushNamed(context, NotificationInboxView.routeName),
              child: Container(
                constraints: compact
                    ? const BoxConstraints(minWidth: 48, minHeight: 48)
                    : null,
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: compact
                      ? const Color(0xFF333333)
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
                      size: 20.sp,
                    ),
                    if (count > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.r,
                            vertical: 2.r,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.notificationBadge,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
