import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_questions_view.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_response_view.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/check_in_client_card.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/check_in_coach_list.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckInCoachListState extends State<CheckInCoachList> {
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

  CheckInQuestionType _snapshotType(String raw) {
    try {
      return CheckInQuestionType.values.byName(raw);
    } catch (_) {
      return CheckInQuestionType.TEXT;
    }
  }

  Future<void> _openResponse(
    CheckIn entry,
    List<CheckInQuestion> templateQuestions,
  ) async {
    final cubit = context.read<CheckInsCubit>();
    final submissions = await cubit.coachSubmissions(entry.id);
    if (!mounted) return;
    switch (submissions) {
      case ApiError(:final failure):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
        return;
      case ApiSuccess(data: final items):
        if (items.isEmpty) {
          Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: CheckInResponseView(
                  entry: entry,
                  questions: templateQuestions,
                  coachResponse: true,
                ),
              ),
            ),
          );
          return;
        }
        final detail = await cubit.coachSubmissionDetail(
          coachClientId: entry.id,
          submissionId: items.first.id,
        );
        if (!mounted) return;
        switch (detail) {
          case ApiError(:final failure):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(failure.message)));
          case ApiSuccess(data: final submission):
            final questions = [
              for (final answer in submission.answers)
                CheckInQuestion(
                  id: answer.questionId ??
                      'snapshot-${answer.id}',
                  label: answer.snapshotQuestion.isEmpty
                      ? 'Question'
                      : answer.snapshotQuestion,
                  type: _snapshotType(answer.snapshotType),
                  options: answer.snapshotOptions,
                  required: answer.snapshotRequired,
                  order: answer.snapshotOrder,
                ),
            ];
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: CheckInResponseView(
                    entry: CheckIn(
                      id: submission.id,
                      clientName: submission.clientName.isEmpty
                          ? entry.clientName
                          : submission.clientName,
                      status: CheckInStatus.completed,
                      timeLabel: submission.submittedAt?.toIso8601String() ??
                          entry.timeLabel,
                      answers: {
                        for (final answer in submission.answers)
                          if (answer.questionId != null)
                            answer.questionId!: answer.answerValue,
                      },
                    ),
                    questions: questions,
                    coachResponse: true,
                  ),
                ),
              ),
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) => CheckInPage(
        title: 'Check-Ins',
        actions: [
          BlocBuilder<CheckInsCubit, CheckInsState>(
            builder: (context, state) => IconButton(
              tooltip: 'Edit questions',
              icon: const CheckInAsset('edit_note'),
              onPressed:
                  state is CheckInsReady ? () => _openQuestions(state) : null,
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
                  CheckInsReady(:final entries, :final questions) =>
                    entries.isEmpty
                        ? const StatusMessage(
                            message:
                                'No clients match your search or filter.',
                          )
                        : ListView.separated(
                            padding:
                                EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                            itemCount: entries.length,
                            separatorBuilder: (_, index) =>
                                SizedBox(height: 12.h),
                            itemBuilder: (context, index) =>
                                CheckInClientCard(
                              entry: entries[index],
                              onView: () => _openResponse(
                                entries[index],
                                questions,
                              ),
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
              backgroundColor:
                  _filter == filter ? CheckInUi.selected : CheckInUi.panel,
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
