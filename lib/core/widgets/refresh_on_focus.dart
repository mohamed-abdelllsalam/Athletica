import 'package:flutter/material.dart';

final appRouteObserver = RouteObserver<ModalRoute<dynamic>>();

/// Refresh existing screens when returning from a route or resuming the app.
class RefreshOnFocus extends StatefulWidget {
  const RefreshOnFocus({
    super.key,
    required this.onRefresh,
    required this.child,
  });
  final VoidCallback onRefresh;
  final Widget child;
  @override
  State<RefreshOnFocus> createState() => _RefreshOnFocusState();
}

class _RefreshOnFocusState extends State<RefreshOnFocus>
    with RouteAware, WidgetsBindingObserver {
  ModalRoute<dynamic>? _route;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      appRouteObserver.unsubscribe(this);
      _route = route;
      if (route != null) appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() => widget.onRefresh();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _route?.isCurrent == true) {
      widget.onRefresh();
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
