import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_questions_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckInQuestionsViewState extends State<CheckInQuestionsView> {
  late final TextEditingController _newQuestion;
  late final TextEditingController _newOptions;
  late final TextEditingController _editQuestion;
  late final List<CheckInQuestion> _questions;
  final Set<String> _selected = {};
  CheckInQuestionType _newType = CheckInQuestionType.TEXT;
  int _nextId = 0;
  String? _draftError;
  String? _editingId;
  String? _editError;

  static String _typeLabel(CheckInQuestionType type) => switch (type) {
        CheckInQuestionType.NUMBER => 'Number',
        CheckInQuestionType.TEXT => 'Text',
        CheckInQuestionType.SINGLE_CHOICE => 'Choice',
        CheckInQuestionType.YES_NO => 'Yes / No',
        CheckInQuestionType.RATING => 'Rating',
        CheckInQuestionType.IMAGE => 'Photo',
      };

  static bool _needsOptions(CheckInQuestionType type) =>
      type == CheckInQuestionType.SINGLE_CHOICE ||
      type == CheckInQuestionType.YES_NO;

  @override
  void initState() {
    super.initState();
    _newQuestion = TextEditingController();
    _newOptions = TextEditingController();
    _editQuestion = TextEditingController();
    _questions = List.of(widget.questions);
  }

  @override
  void dispose() {
    _newQuestion.dispose();
    _newOptions.dispose();
    _editQuestion.dispose();
    super.dispose();
  }

  void _addQuestion() {
    final label = _newQuestion.text.trim();
    if (label.isEmpty) {
      setState(() => _draftError = 'Write a question first.');
      return;
    }
    if (label.length > 500) {
      setState(
        () => _draftError = 'Keep questions within 500 characters.',
      );
      return;
    }
    var options = const <String>[];
    if (_needsOptions(_newType)) {
      final parsed = _newOptions.text
          .split(',')
          .map((option) => option.trim())
          .where((option) => option.isNotEmpty)
          .toList();
      if (_newType == CheckInQuestionType.SINGLE_CHOICE && parsed.length < 2) {
        setState(
          () => _draftError =
              'Add at least two options separated by commas.',
        );
        return;
      }
      options = parsed.isEmpty ? const ['Yes', 'No'] : parsed;
    }
    // Local form draft only; the use case validates the saved template.
    String id;
    do {
      id = 'custom-${_nextId++}';
    } while (_questions.any((question) => question.id == id));
    setState(() {
      _questions.add(
        CheckInQuestion(
          id: id,
          label: label,
          type: _newType,
          options: options,
        ),
      );
      _draftError = null;
      _newQuestion.clear();
      _newOptions.clear();
    });
  }

  void _startEdit(CheckInQuestion question) {
    _editQuestion.text = question.label;
    setState(() {
      _editingId = question.id;
      _editError = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingId = null;
      _editError = null;
    });
  }

  void _applyEdit(String id) {
    final label = _editQuestion.text.trim();
    if (label.isEmpty) {
      setState(() => _editError = 'Write a question first.');
      return;
    }
    if (label.length > 500) {
      setState(
        () => _editError = 'Keep questions within 500 characters.',
      );
      return;
    }
    final index = _questions.indexWhere((question) => question.id == id);
    if (index < 0) {
      _cancelEdit();
      return;
    }
    final current = _questions[index];
    setState(() {
      _questions[index] = CheckInQuestion(
        id: current.id,
        label: label,
        type: current.type,
        coachId: current.coachId,
        options: current.options,
        required: current.required,
        order: current.order,
      );
      _editingId = null;
      _editError = null;
    });
  }

  void _move(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _questions.length) return;
    setState(() {
      final item = _questions.removeAt(index);
      _questions.insert(target, item);
    });
  }

  Future<void> _save() async {
    final cubit = context.read<CheckInsCubit>();
    final success = await cubit.saveQuestions(
      current: widget.questions,
      updated: List.of(_questions),
    );
    if (!mounted || !success) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Template saved.')));
    Navigator.pop(context);
  }

  Future<void> _send() async {
    final sent = await context
        .read<CheckInsCubit>()
        .assignCheckins(_selected.toList());
    if (!mounted || !sent) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Check-in assigned.')));
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
                    child: Text('Recipients', style: CheckInUi.text(12)),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      if (_selected.length == widget.clients.length) {
                        _selected.clear();
                      } else {
                        _selected.addAll(
                          widget.clients.map((entry) => entry.id),
                        );
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
              if (_selected.isNotEmpty) ...[
                SizedBox(height: 12.h),
                BlocBuilder<CheckInsCubit, CheckInsState>(
                  builder: (context, state) {
                    final ready = state is CheckInsReady ? state : null;
                    return CheckInButton(
                      label: ready?.saving == true ? 'Sending…' : 'Send',
                      color: CheckInUi.violet,
                      onPressed:
                          ready == null || ready.saving ? null : _send,
                    );
                  },
                ),
              ],
              const Divider(
                color: CheckInUi.violet,
                indent: 50,
                endIndent: 50,
              ),
              SizedBox(height: 16.h),
              Text('Your Questions:', style: CheckInUi.text(12)),
              SizedBox(height: 12.h),
              for (final (index, question) in _questions.indexed)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: CheckInQuestionRow(
                    index: index + 1,
                    label: _editingId == question.id
                        ? 'Editing question ${index + 1}'
                        : question.label,
                    child: _editingId == question.id
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: TextField(
                                  key: ValueKey('edit-${question.id}'),
                                  controller: _editQuestion,
                                  maxLength: 500,
                                  style: CheckInUi.text(11),
                                  decoration: CheckInUi.input(
                                    'Question text',
                                  ).copyWith(errorText: _editError),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Save edit',
                                onPressed: () => _applyEdit(question.id),
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(28, 28),
                                ),
                                icon: const Icon(
                                  Icons.check,
                                  color: CheckInUi.violet,
                                  size: 18,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Cancel edit',
                                onPressed: _cancelEdit,
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(28, 28),
                                ),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(
                                  _typeLabel(question.type),
                                  style: CheckInUi.text(
                                    9,
                                    color: CheckInUi.violet,
                                  ),
                                ),
                              ),
                              // Single menu button: four direct action buttons
                              // overflow the row's narrow action slot, so the
                              // same edit/reorder/remove actions live here.
                              PopupMenuButton<String>(
                                tooltip: 'Actions for ${question.label}',
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: CheckInUi.violet,
                                  size: 20,
                                ),
                                color: CheckInUi.note,
                                onSelected: (value) {
                                  switch (value) {
                                    case 'up':
                                      _move(index, -1);
                                    case 'down':
                                      _move(index, 1);
                                    case 'edit':
                                      _startEdit(question);
                                    case 'remove':
                                      setState(
                                        () => _questions.removeAt(index),
                                      );
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'up',
                                    enabled: index > 0,
                                    child: Text(
                                      'Move up',
                                      style: CheckInUi.text(11),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'down',
                                    enabled:
                                        index < _questions.length - 1,
                                    child: Text(
                                      'Move down',
                                      style: CheckInUi.text(11),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(
                                      'Edit',
                                      style: CheckInUi.text(11),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'remove',
                                    enabled: _questions.length > 1,
                                    child: Text(
                                      'Remove',
                                      style: CheckInUi.text(11),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              TextField(
                key: const ValueKey('new-question'),
                controller: _newQuestion,
                maxLength: 500,
                decoration: CheckInUi.input(
                  'Write another question',
                ).copyWith(errorText: _draftError),
                style: CheckInUi.text(12),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<CheckInQuestionType>(
                key: const ValueKey('new-question-type'),
                initialValue: _newType,
                decoration: CheckInUi.input('Type'),
                dropdownColor: CheckInUi.note,
                style: CheckInUi.text(12),
                isExpanded: true,
                items: [
                  for (final type in CheckInQuestionType.values)
                    DropdownMenuItem(
                      value: type,
                      child: Text(_typeLabel(type)),
                    ),
                ],
                onChanged: (value) => setState(
                  () => _newType = value ?? CheckInQuestionType.TEXT,
                ),
              ),
              if (_needsOptions(_newType)) ...[
                SizedBox(height: 12.h),
                TextField(
                  key: const ValueKey('new-question-options'),
                  controller: _newOptions,
                  style: CheckInUi.text(12),
                  decoration: CheckInUi.input(
                    'Options separated by commas',
                  ).copyWith(errorText: _draftError),
                ),
              ],
              SizedBox(height: 12.h),
              CheckInButton(
                label: 'Add Another Question',
                color: CheckInUi.question,
                onPressed: _addQuestion,
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
                          style: CheckInUi.text(
                            12,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      CheckInButton(
                        label:
                            ready?.saving == true ? 'Saving…' : 'Save Template',
                        color: CheckInUi.violet,
                        onPressed:
                            ready == null || ready.saving ? null : _save,
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
