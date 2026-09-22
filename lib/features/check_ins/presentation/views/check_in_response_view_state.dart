import 'dart:io';

import 'package:athletica/core/utils/check_in_media.dart';
import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_response_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class CheckInResponseViewState extends State<CheckInResponseView> {
  late final Map<String, TextEditingController> _answers;
  final Map<String, File> _images = {};
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _answers = {
      for (final question in widget.questions)
        question.id: TextEditingController(
          text: widget.entry.answers[question.id] ?? '',
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in _answers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await context.read<CheckInsCubit>().saveResponse(
          questions: widget.questions,
          answers: {
            for (final item in _answers.entries) item.key: item.value.text
          },
          imageFiles: Map.of(_images),
        );
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved.')));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage(String questionId, ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      if (!isSupportedCheckInImagePath(picked.path)) {
        _showMessage('Only JPEG, PNG, and WEBP images are allowed.');
        return;
      }
      final file = File(picked.path);
      int size;
      try {
        size = await file.length();
      } catch (_) {
        _showMessage('Could not read the image. Please try another.');
        return;
      }
      if (size > kCheckInMaxImageBytes) {
        _showMessage('Image must be 5 MB or smaller.');
        return;
      }
      setState(() => _images[questionId] = file);
    } catch (_) {
      _showMessage('Could not pick the image. Please try again.');
    }
  }

  Widget _answer(CheckInQuestion question) {
    final controller = _answers[question.id]!;
    if (widget.coachResponse) {
      final text = controller.text;
      final isPhoto = question.type == CheckInQuestionType.IMAGE &&
          (text.startsWith('http://') || text.startsWith('https://'));
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(7.r),
        decoration: BoxDecoration(
          border: Border.all(color: CheckInUi.violet),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: isPhoto
            ? ClipRRect(
                borderRadius: BorderRadius.circular(5.r),
                child: Image.network(
                  text,
                  height: 120.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Text(
                    text,
                    style: CheckInUi.text(11),
                  ),
                ),
              )
            : Text(
                text.isEmpty ? '—' : text,
                style: CheckInUi.text(11),
              ),
      );
    }
    switch (question.type) {
      case CheckInQuestionType.YES_NO:
      case CheckInQuestionType.SINGLE_CHOICE:
        final options = question.options.isNotEmpty
            ? question.options
            : const ['Yes', 'No'];
        return DropdownButtonFormField<String>(
          key: ValueKey(question.id),
          initialValue:
              options.contains(controller.text) ? controller.text : null,
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
      case CheckInQuestionType.RATING:
        final options = List.generate(10, (i) => '${i + 1}');
        return DropdownButtonFormField<String>(
          key: ValueKey(question.id),
          initialValue:
              options.contains(controller.text) ? controller.text : null,
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
      case CheckInQuestionType.IMAGE:
        final picked = _images[question.id];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                border: Border.all(color: CheckInUi.violet),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: picked == null
                  ? Icon(
                      Icons.photo_outlined,
                      color: CheckInUi.violet,
                      size: 24.w,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5.r),
                      child: Image.file(
                        picked,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.broken_image_outlined,
                          color: CheckInUi.violet,
                          size: 24.w,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: ValueKey('pick-gallery-${question.id}'),
                  tooltip: 'Choose from gallery',
                  onPressed: () =>
                      _pickImage(question.id, ImageSource.gallery),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(28, 28),
                  ),
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    color: CheckInUi.violet,
                    size: 18,
                  ),
                ),
                IconButton(
                  key: ValueKey('pick-camera-${question.id}'),
                  tooltip: 'Take a photo',
                  onPressed: () =>
                      _pickImage(question.id, ImageSource.camera),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(28, 28),
                  ),
                  icon: const Icon(
                    Icons.photo_camera_outlined,
                    color: CheckInUi.violet,
                    size: 18,
                  ),
                ),
                if (picked != null)
                  IconButton(
                    key: ValueKey('remove-photo-${question.id}'),
                    tooltip: 'Remove photo',
                    onPressed: () =>
                        setState(() => _images.remove(question.id)),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            ),
          ],
        );
      case CheckInQuestionType.NUMBER:
      case CheckInQuestionType.TEXT:
        return TextField(
          key: ValueKey(question.id),
          controller: controller,
          keyboardType: question.type == CheckInQuestionType.NUMBER
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: CheckInUi.text(11),
          decoration: CheckInUi.input(
            'Answer',
          ).copyWith(semanticCounterText: question.label),
          maxLength: 160,
          buildCounter: (
            _, {
            required currentLength,
            required isFocused,
            required maxLength,
          }) =>
              null,
        );
    }
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
                child: Text(
                  widget.entry.clientName,
                  style: CheckInUi.text(14),
                ),
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
          if (!widget.coachResponse)
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
                          : 'Save Response',
                      onPressed:
                          ready == null || ready.saving ? null : _save,
                    ),
                  ],
                );
              },
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
