import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckInResponseView extends StatefulWidget {
  const CheckInResponseView({
    super.key,
    required this.entry,
    required this.questions,
    required this.coachResponse,
    this.embedded = false,
  });
  final CheckIn entry;
  final List<CheckInQuestion> questions;
  final bool coachResponse;
  final bool embedded;
  @override
  State<CheckInResponseView> createState() => _CheckInResponseViewState();
}

class _CheckInResponseViewState extends State<CheckInResponseView> {
  late final Map<String, TextEditingController> _answers;
  late final TextEditingController _notes;
  late final TextEditingController _coachNote;

  @override
  void initState() {
    super.initState();
    _answers = {
      for (final question in widget.questions)
        question.id: TextEditingController(
          text: widget.entry.answers[question.id] ?? '',
        ),
    };
    _notes = TextEditingController(text: widget.entry.additionalNotes);
    _coachNote = TextEditingController(text: widget.entry.coachNote);
  }

  @override
  void dispose() {
    for (final controller in _answers.values) {
      controller.dispose();
    }
    _notes.dispose();
    _coachNote.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await context.read<CheckInsCubit>().saveResponse(
      entry: widget.entry,
      questions: widget.questions,
      answers: {for (final item in _answers.entries) item.key: item.value.text},
      additionalNotes: _notes.text,
      coachNote: _coachNote.text,
      coachResponse: widget.coachResponse,
    );
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved in this preview only. Nothing was sent.'),
        ),
      );
    }
  }

  Widget _answer(CheckInQuestion question) {
    final controller = _answers[question.id]!;
    if (widget.coachResponse) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(7.r),
        decoration: BoxDecoration(
          border: Border.all(color: CheckInUi.violet),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          controller.text.isEmpty ? '—' : controller.text,
          style: CheckInUi.text(11),
        ),
      );
    }
    if (question.type == CheckInQuestionType.yesNo ||
        question.type == CheckInQuestionType.sessions) {
      final options = question.type == CheckInQuestionType.yesNo
          ? ['Yes', 'No']
          : List.generate(15, (i) => '$i');
      return DropdownButtonFormField<String>(
        key: ValueKey(question.id),
        initialValue: options.contains(controller.text)
            ? controller.text
            : null,
        decoration: CheckInUi.input('Choose'),
        dropdownColor: CheckInUi.note,
        style: CheckInUi.text(11),
        isExpanded: true,
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        onChanged: (value) => controller.text = value ?? '',
      );
    }
    return TextField(
      key: ValueKey(question.id),
      controller: controller,
      keyboardType: question.type == CheckInQuestionType.number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: CheckInUi.text(11),
      decoration: CheckInUi.input(
        'Answer',
      ).copyWith(semanticCounterText: question.label),
      maxLength: 160,
      buildCounter:
          (
            _, {
            required currentLength,
            required isFocused,
            required maxLength,
          }) => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CheckInAvatar(size: 65),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(widget.entry.clientName, style: CheckInUi.text(14)),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            widget.coachResponse ? 'Client Responses' : 'Your Responses',
            style: CheckInUi.text(12),
          ),
          SizedBox(height: 14.h),
          if (widget.entry.status == CheckInStatus.pending &&
              widget.coachResponse)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Text(
                'No check-in yet. The client’s responses will appear here.',
                style: CheckInUi.text(12),
              ),
            ),
          for (final (index, question) in widget.questions.indexed)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: CheckInQuestionRow(
                index: index + 1,
                label: question.label,
                child: _answer(question),
              ),
            ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CheckInAsset('edit_note'),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Additional notes', style: CheckInUi.text(10)),
                    SizedBox(height: 6.h),
                    TextField(
                      key: const ValueKey('additional-notes'),
                      controller: _notes,
                      readOnly: widget.coachResponse,
                      minLines: 2,
                      maxLines: 4,
                      maxLength: 1000,
                      style: CheckInUi.text(11, weight: FontWeight.w400),
                      decoration: CheckInUi.input('How are you feeling?'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: CheckInUi.note,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coach Note', style: CheckInUi.text(13)),
                SizedBox(height: 20.h),
                if (widget.coachResponse)
                  TextField(
                    key: const ValueKey('coach-note'),
                    controller: _coachNote,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 1000,
                    style: CheckInUi.text(11),
                    decoration: CheckInUi.input('Write your note…'),
                  )
                else
                  Text(
                    widget.entry.coachNote.isEmpty
                        ? 'Your coach’s response will appear here.'
                        : widget.entry.coachNote,
                    style: CheckInUi.text(11, weight: FontWeight.w400),
                  ),
                SizedBox(height: 20.h),
                BlocBuilder<CheckInsCubit, CheckInsState>(
                  builder: (context, state) {
                    final ready = state is CheckInsReady ? state : null;
                    return Column(
                      children: [
                        if (ready?.message != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                ready!.message!,
                                style: CheckInUi.text(
                                  12,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ),
                          ),
                        CheckInButton(
                          label: ready?.saving == true
                              ? 'Saving…'
                              : 'Save Preview Response',
                          onPressed:
                              ready == null ||
                                  ready.saving ||
                                  (widget.coachResponse &&
                                      widget.entry.status ==
                                          CheckInStatus.pending)
                              ? null
                              : _save,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return widget.embedded
        ? content
        : CheckInPage(
            title: widget.coachResponse ? 'Client Responses' : 'Your Check-in',
            child: content,
          );
  }
}
