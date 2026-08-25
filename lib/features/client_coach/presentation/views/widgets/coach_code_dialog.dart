import 'dart:math' as math;

import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_cubit.dart';
import 'package:athletica/features/client_coach/presentation/cubits/client_coach_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Opens the coach-code dialog where the client enters the 6-character code
/// from their coach to send a connection request.
///
/// The dialog runs on its own [ClientCoachCubit] instance so a failed
/// attempt never changes the state of the screen below it. Tapping outside
/// the dialog closes it. Returns true when the request was sent
/// successfully — callers can use this to refresh their own state.
Future<bool> showCoachCodeDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => BlocProvider(
      create: (_) => sl<ClientCoachCubit>(),
      child: const CoachCodeDialog(),
    ),
  );
  return result ?? false;
}

class CoachCodeDialog extends StatefulWidget {
  const CoachCodeDialog({super.key});

  @override
  State<CoachCodeDialog> createState() => _CoachCodeDialogState();
}

class _CoachCodeDialogState extends State<CoachCodeDialog> {
  static const int _codeLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes =
      List.generate(_codeLength, (_) => FocusNode());

  bool _requestSent = false;
  String _successCoachName = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _codeLength; i++) {
      final index = i;
      _focusNodes[index] = FocusNode(
        onKeyEvent: (_, event) => _handleKeyEvent(event, index),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _isComplete => _code.length == _codeLength;

  void _selectAll(int index) {
    final controller = _controllers[index];
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        index > 0 &&
        _controllers[index].text.isEmpty) {
      _focusNodes[index - 1].requestFocus();
      _selectAll(index - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onChanged(String value, int index) {
    _clearError();

    final cleaned = value
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();

    if (cleaned.isEmpty) {
      _controllers[index].clear();
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
      setState(() {});
      return;
    }

    if (cleaned.length > 1) {
      // Pasted (or typed over) multiple characters: distribute them.
      final maxChars = math.min(cleaned.length, _codeLength - index);
      for (var i = 0; i < maxChars; i++) {
        _controllers[index + i].text = cleaned[i];
        _controllers[index + i].selection =
            const TextSelection.collapsed(offset: 1);
      }
      for (var i = index + maxChars; i < _codeLength; i++) {
        _controllers[i].clear();
      }
      final nextIndex = math.min(index + maxChars, _codeLength - 1);
      FocusScope.of(context).requestFocus(_focusNodes[nextIndex]);
      setState(() {});
      return;
    }

    _controllers[index].text = cleaned;
    _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    if (index < _codeLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    setState(() {});
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
  }

  void _submit() {
    if (!_isComplete) return;
    FocusScope.of(context).unfocus();
    context.read<ClientCoachCubit>().submitToken(_code);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientCoachCubit, ClientCoachState>(
      listenWhen: (previous, current) =>
          current is ClientCoachRequestSent ||
          (current is ClientCoachError && previous is! ClientCoachError),
      listener: (context, state) {
        if (state is ClientCoachRequestSent) {
          setState(() {
            _requestSent = true;
            _successCoachName = state.coachName;
          });
        } else if (state is ClientCoachError) {
          setState(() => _errorMessage = state.message);
        }
      },
      builder: (context, state) {
        final submitting = state is ClientCoachSubmitting;

        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          insetPadding:
              EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          contentPadding: EdgeInsets.all(24.r),
          content: _requestSent
              ? _buildSuccessContent()
              : _buildCodeEntryContent(submitting),
        );
      },
    );
  }

  Widget _buildCodeEntryContent(bool submitting) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter coach code',
          style: AppTextStyles.semiBold15(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        Text(
          'Ask your coach for their 6-character code to send a connection '
          'request.',
          style: AppTextStyles.meduim12(context)
              .copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 20.h),
        AutofillGroup(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _codeLength,
              (index) => _buildCodeBox(index),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: AppTextStyles.meduim12(context)
                .copyWith(color: Colors.redAccent),
          ),
          SizedBox(height: 12.h),
        ],
        SizedBox(
          width: double.infinity,
          height: 44.h,
          child: ElevatedButton(
            onPressed:
                (_isComplete && !submitting) ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              disabledBackgroundColor:
                  AppColors.buttonColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: submitting
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Subscribe',
                    style: AppTextStyles.medium14(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBox(int index) {
    return SizedBox(
      width: 42.w,
      height: 54.h,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.text,
        autofillHints: const [AutofillHints.oneTimeCode],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        textCapitalization: TextCapitalization.characters,
        autocorrect: false,
        enableSuggestions: false,
        maxLength: _codeLength,
        buildCounter: (
          BuildContext context, {
          required int currentLength,
          required int? maxLength,
          required bool isFocused,
        }) =>
            const SizedBox.shrink(),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        ],
        style: AppTextStyles.bold20(context)
            .copyWith(color: AppColors.textPrimary),
        cursorColor: AppColors.primaryBlue,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.primaryBlue),
          ),
          filled: false,
        ),
        onTap: () => _selectAll(index),
        onChanged: (value) => _onChanged(value, index),
        textInputAction: index < _codeLength - 1
            ? TextInputAction.next
            : TextInputAction.done,
      ),
    );
  }

  Widget _buildSuccessContent() {
    final hasName = _successCoachName.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 56.sp,
        ),
        SizedBox(height: 16.h),
        Text(
          'Request Sent!',
          style: AppTextStyles.semiBold15(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        Text(
          hasName
              ? 'Your request was sent to $_successCoachName. '
                  'You can start your nutrition plan once they accept.'
              : 'Your request was sent to your coach. You can start your '
                  'nutrition plan once they accept.',
          textAlign: TextAlign.center,
          style: AppTextStyles.meduim12(context)
              .copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          height: 44.h,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Done',
              style: AppTextStyles.medium14(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
