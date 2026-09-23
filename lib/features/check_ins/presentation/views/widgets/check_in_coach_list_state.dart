import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_history_view.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_questions_view.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/check_in_client_card.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/check_in_coach_list.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckInCoachListState extends State<CheckInCoachList> {
  late final TextEditingController _search;
  CheckInStatus? _filter;
  final Set<String> _sendingIds = {};
  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() =>
      context.read<CheckInsCubit>().load(query: _search.text, filter: _filter);

  Future<void> _openQuestions(CheckInsReady ready) async {
    final cubit = context.read<CheckInsCubit>();
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: CheckInQuestionsView(
            questions: ready.questions,
            clients: ready.entries,
          ),
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _openHistory(CheckIn entry) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckInHistoryView(
          coachClientId: entry.id,
          clientName: entry.clientName,
          clientPhotoUrl: entry.clientPhotoUrl,
        ),
      ),
    );
    if (mounted) await _load();
  }

  /// Direct send: assigns the current template to this client without
  /// opening the recipient picker. Only the tapped card shows a
  /// sending state — other rows stay interactive.
  Future<void> _sendDirect(CheckIn entry) async {
    if (_sendingIds.contains(entry.id)) return;
    setState(() => _sendingIds.add(entry.id));
    bool sent = false;
    String? error;
    try {
      final cubit = context.read<CheckInsCubit>();
      sent = await cubit.assignCheckins([entry.id]);
      if (!mounted) return;
      final current = cubit.state;
      if (!sent) {
        error = current is CheckInsReady && current.message != null
            ? current.message!
            : 'Could not send check-in.';
      }
    } finally {
      if (mounted) setState(() => _sendingIds.remove(entry.id));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent ? 'Check-in sent to ${entry.clientName}.' : error!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CheckInPage(
    title: 'Check-Ins',
    actions: [
      BlocBuilder<CheckInsCubit, CheckInsState>(
        builder: (context, state) => IconButton(
          tooltip: 'Edit questions',
          icon: const CheckInAsset('edit_note'),
          onPressed: state is CheckInsReady
              ? () => _openQuestions(state)
              : null,
        ),
      ),
    ],
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: TextField(
            controller: _search,
            onChanged: (_) => _load(),
            style: CheckInUi.text(12),
            decoration: CheckInUi.input('Search Client').copyWith(
              fillColor: CheckInUi.panel,
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: CheckInAsset('search', size: 20),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              _filterButton('All', null),
              SizedBox(width: 10.w),
              _filterButton('Completed', CheckInStatus.completed),
              SizedBox(width: 10.w),
              _filterButton('Pending', CheckInStatus.pending),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: BlocBuilder<CheckInsCubit, CheckInsState>(
            builder: (context, state) => switch (state) {
              CheckInsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              CheckInsError(:final message) => StatusMessage(
                message: message,
                onRetry: _load,
              ),
              CheckInsReady(:final entries) => RefreshIndicator(
                onRefresh: _load,
                child: entries.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No clients match your search or filter.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                      : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                        itemCount: entries.length,
                        separatorBuilder: (_, index) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) => CheckInClientCard(
                          entry: entries[index],
                          sending: _sendingIds.contains(entries[index].id),
                          onView: () => _openHistory(entries[index]),
                          onSend: () => _sendDirect(entries[index]),
                        ),
                      ),
              ),
            },
          ),
        ),
      ],
    ),
  );

  Widget _filterButton(String label, CheckInStatus? filter) => Expanded(
    child: Semantics(
      selected: _filter == filter,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _filter == filter
              ? CheckInUi.selected
              : CheckInUi.panel,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
        ),
        onPressed: () {
          setState(() => _filter = filter);
          _load();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (filter != null) ...[
              CheckInAsset(
                filter == CheckInStatus.completed ? 'completed' : 'pending',
                size: 14,
              ),
              SizedBox(width: 4.w),
            ],
            Flexible(child: Text(label, style: CheckInUi.text(10))),
          ],
        ),
      ),
    ),
  );
}
