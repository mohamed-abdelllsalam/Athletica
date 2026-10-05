import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/notification_inbox.dart';

class NotificationInboxCubit extends Cubit<InboxSnapshot> {
  NotificationInboxCubit(this.inbox) : super(inbox.state) {
    _subscription = inbox.changes.listen((state) {
      if (!isClosed) emit(state);
    });
  }
  final NotificationInbox inbox;
  late final StreamSubscription<InboxSnapshot> _subscription;
  Future<void> open() {
    inbox.setVisible(true);
    return inbox.refresh(visible: true);
  }

  Future<void> refresh() => inbox.refresh(visible: true);
  Future<void> loadMore() => inbox.loadMore();
  Future<void> markRead(String id) => inbox.markRead(id);
  Future<void> markAllRead() => inbox.markAllRead();
  @override
  Future<void> close() async {
    inbox.setVisible(false);
    await _subscription.cancel();
    return super.close();
  }
}
