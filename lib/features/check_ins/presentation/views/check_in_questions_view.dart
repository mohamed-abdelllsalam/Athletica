import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckInQuestionsView extends StatefulWidget {
  const CheckInQuestionsView({
    super.key,
    required this.questions,
    required this.clients,
  });
  final List<CheckInQuestion> questions;
  final List<CheckIn> clients;
  @override
  State<CheckInQuestionsView> createState() => _CheckInQuestionsViewState();
}

class _CheckInQuestionsViewState extends State<CheckInQuestionsView> {
  late final TextEditingController _newQuestion;
  late final List<CheckInQuestion> _questions;
  final Set<String> _selected = {};
  int _nextId = 0;
  String? _draftError;

  @override
  void initState() {
    super.initState();
    _newQuestion = TextEditingController();
    _questions = List.of(widget.questions);
  }

  @override
  void dispose() {
    _newQuestion.dispose();
    super.dispose();
  }

  void _addQuestion() {
    final label = _newQuestion.text.trim();
    if (label.isEmpty) {
      setState(() => _draftError = 'Write a question first.');
      return;
    }
    // Local form draft only; the use case validates the saved template.
    String id;
    do {
      id = 'custom-${_nextId++}';
    } while (_questions.any((question) => question.id == id));
    setState(() {
      _questions.add(
        CheckInQuestion(id: id, label: label, type: CheckInQuestionType.text),
      );
      _draftError = null;
      _newQuestion.clear();
    });
  }

  Future<void> _save() async {
    final success = await context.read<CheckInsCubit>().saveQuestions(
      List.of(_questions),
    );
    if (!mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Template saved in this preview only. No questions were sent.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => CheckInPage(
    title: 'Send Questions',
    child: SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Preview recipients', style: CheckInUi.text(12)),
              ),
              TextButton(
                onPressed: () => setState(() {
                  if (_selected.length == widget.clients.length) {
                    _selected.clear();
                  } else {
                    _selected.addAll(widget.clients.map((entry) => entry.id));
                  }
                }),
                child: Text(
                  _selected.length == widget.clients.length &&
                          _selected.isNotEmpty
                      ? 'Clear selection'
                      : 'Select All',
                  style: CheckInUi.text(12, color: CheckInUi.violet),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 98.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.clients.length,
              separatorBuilder: (_, index) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                final client = widget.clients[index];
                final selected = _selected.contains(client.id);
                return Semantics(
                  selected: selected,
                  button: true,
                  label: 'Select ${client.clientName}',
                  child: InkWell(
                    onTap: () => setState(() {
                      if (selected) {
                        _selected.remove(client.id);
                      } else {
                        _selected.add(client.id);
                      }
                    }),
                    child: SizedBox(
                      width: 70.w,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? CheckInUi.violet
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: const CheckInAvatar(),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            client.clientName,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: CheckInUi.text(9),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: CheckInUi.violet, indent: 50, endIndent: 50),
          SizedBox(height: 16.h),
          Text('Your Questions:', style: CheckInUi.text(12)),
          SizedBox(height: 12.h),
          for (final (index, question) in _questions.indexed)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: CheckInQuestionRow(
                index: index + 1,
                label: question.label,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(switch (question.type) {
                        CheckInQuestionType.number => 'Number',
                        CheckInQuestionType.yesNo => 'Yes / No',
                        CheckInQuestionType.sessions => 'Sessions',
                        CheckInQuestionType.text => 'Text',
                      }, style: CheckInUi.text(9, color: CheckInUi.violet)),
                    ),
                    IconButton(
                      tooltip: 'Remove ${question.label}',
                      onPressed: () =>
                          setState(() => _questions.removeAt(index)),
                      icon: const CheckInAsset('delete', size: 16),
                    ),
                  ],
                ),
              ),
            ),
          TextField(
            key: const ValueKey('new-question'),
            controller: _newQuestion,
            maxLength: 160,
            decoration: CheckInUi.input(
              'Write another question',
            ).copyWith(errorText: _draftError),
            style: CheckInUi.text(12),
          ),
          CheckInButton(
            label: 'Add Another Question',
            color: CheckInUi.question,
            onPressed: _questions.length < 20 ? _addQuestion : null,
          ),
          SizedBox(height: 16.h),
          BlocBuilder<CheckInsCubit, CheckInsState>(
            builder: (context, state) {
              final ready = state is CheckInsReady ? state : null;
              return Column(
                children: [
                  if (ready?.message != null)
                    Text(
                      ready!.message!,
                      style: CheckInUi.text(12, color: Colors.orangeAccent),
                    ),
                  CheckInButton(
                    label: ready?.saving == true
                        ? 'Saving…'
                        : 'Save Preview Template',
                    color: CheckInUi.violet,
                    onPressed: ready == null || ready.saving ? null : _save,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}
