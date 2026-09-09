import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_questions_view.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_response_view.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/check_in_client_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CheckInPreviewRole { coach, client }

class CheckInsPreviewView extends StatelessWidget {
  const CheckInsPreviewView({super.key, this.role = CheckInPreviewRole.coach});
  static const routeName = '/check-ins-preview';
  final CheckInPreviewRole role;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<CheckInsCubit>()..load(),
    child: role == CheckInPreviewRole.coach
        ? const CheckInCoachList()
        : const _ClientPreview(),
  );
}

class _ClientPreview extends StatelessWidget {
  const _ClientPreview();
  @override
  Widget build(BuildContext context) => CheckInPage(
    title: 'Your Check-in',
    actions: [
      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const CheckInsPreviewView()),
        ),
        child: const Text('Coach preview'),
      ),
    ],
    child: BlocBuilder<CheckInsCubit, CheckInsState>(
      builder: (context, state) => switch (state) {
        CheckInsLoading() => const Center(child: CircularProgressIndicator()),
        CheckInsError(:final message) => _StatusMessage(
          message: message,
          onRetry: () => context.read<CheckInsCubit>().load(),
        ),
        CheckInsReady(:final entries, :final questions) =>
          entries.isEmpty
              ? const _StatusMessage(message: 'No check-ins available.')
              : CheckInResponseView(
                  key: ValueKey(entries.first.id),
                  entry: entries.first,
                  questions: questions,
                  coachResponse: false,
                  embedded: true,
                ),
      },
    ),
  );
}

// ScreenUtil rebuilds public widgets when the viewport changes.
class CheckInCoachList extends StatefulWidget {
  const CheckInCoachList({super.key});
  @override
  State<CheckInCoachList> createState() => _CoachListState();
}

class _CoachListState extends State<CheckInCoachList> {
  late final TextEditingController _search;
  CheckInStatus? _filter;
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

  void _load() =>
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
  }

  void _openResponse(CheckIn entry, List<CheckInQuestion> questions) {
    final cubit = context.read<CheckInsCubit>();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: CheckInResponseView(
            entry: entry,
            questions: questions,
            coachResponse: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CheckInPage(
    title: 'Check-Ins',
    actions: [
      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                const CheckInsPreviewView(role: CheckInPreviewRole.client),
          ),
        ),
        child: const Text('Client preview'),
      ),
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
              CheckInsError(:final message) => _StatusMessage(
                message: message,
                onRetry: _load,
              ),
              CheckInsReady(:final entries, :final questions) =>
                entries.isEmpty
                    ? const _StatusMessage(
                        message: 'No clients match your search or filter.',
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                        itemCount: entries.length,
                        separatorBuilder: (_, index) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) => CheckInClientCard(
                          entry: entries[index],
                          onView: () =>
                              _openResponse(entries[index], questions),
                          onSend: () => _openQuestions(state),
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

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center, style: CheckInUi.text(13)),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
