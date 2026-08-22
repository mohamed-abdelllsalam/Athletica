import 'dart:async';
import 'dart:math' as math;

import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/verification_utils.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:athletica/features/auth/presentation/views/new_password_view.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResetOtpViewBody extends StatefulWidget {
  const ResetOtpViewBody({super.key, this.email = ''});

  final String email;

  @override
  State<ResetOtpViewBody> createState() => _ResetOtpViewBodyState();
}

class _ResetOtpViewBodyState extends State<ResetOtpViewBody> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _countdownTimer;
  int _countdown = 50;
  bool _isResendEnabled = false;

  _ResetOtpViewBodyState() {
    for (var i = 0; i < _focusNodes.length; i++) {
      final index = i;
      _focusNodes[i] = FocusNode(
        onKeyEvent: (_, event) => _handleOtpKeyEvent(event, index),
      );
    }
  }

  String get otpValue => _controllers.map((controller) => controller.text).join();
  bool get isOtpComplete => otpValue.length == 6;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdown = 50;
      _isResendEnabled = false;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdown <= 1) {
        timer.cancel();
        setState(() {
          _countdown = 0;
          _isResendEnabled = true;
        });
        return;
      }

      setState(() {
        _countdown -= 1;
      });
    });
  }

  void _selectAll(int index) {
    final controller = _controllers[index];
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  KeyEventResult _handleOtpKeyEvent(KeyEvent event, int index) {
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

  void _onOtpChanged(String value, int index) {
    if (value.isEmpty) {
      if (index > 0) {
        Future.microtask(() {
          if (!mounted) return;
          _focusNodes[index - 1].requestFocus();
          _selectAll(index - 1);
        });
      }
      return;
    }

    if (value.length > 1) {
      final pasted = value.replaceAll(RegExp(r'\D'), '');
      if (pasted.isEmpty) {
        return;
      }
      final maxChars = math.min(pasted.length, 6 - index);
      for (int i = 0; i < maxChars; i++) {
        _controllers[index + i].text = pasted[i];
        _controllers[index + i].selection = TextSelection.collapsed(offset: 1);
      }

      final nextIndex = math.min(index + maxChars, 5);
      _focusNodes[nextIndex].requestFocus();
      return;
    }

    _controllers[index].text = value;
    _controllers[index].selection = TextSelection.collapsed(offset: 1);
    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _resendCode() {
    if (widget.email.isEmpty) {
      return;
    }
    context.read<AuthCubit>().requestPasswordReset(email: widget.email);
  }

  void _continue() {
    if (!isOtpComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete code.'),
          backgroundColor: Colors.red,
        ),
      );
      final firstEmptyIndex = _controllers.indexWhere((c) => c.text.isEmpty);
      if (firstEmptyIndex != -1) {
        _focusNodes[firstEmptyIndex].requestFocus();
      }
      return;
    }
    Navigator.pushNamed(
      context,
      NewPasswordView.routeName,
      arguments: (email: widget.email, code: otpValue),
    );
  }

  Widget _buildOtpDigitInput(int index) {
    return SizedBox(
      width: 42,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        autofocus: index == 0,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: AppTextStyles.bold20(context).copyWith(color: Colors.white),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF8FA2C8), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF8FA2C8), width: 1.2),
          ),
          filled: false,
        ),
        onTap: () => _selectAll(index),
        onChanged: (value) => _onOtpChanged(value, index),
        onSubmitted: (_) {
          if (index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction:
            index < 5 ? TextInputAction.next : TextInputAction.done,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maskedEmail = maskEmail(widget.email);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ResetRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _startCountdown();
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isResending = state is ResetRequestLoading;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'OTP code verification',
                  style: AppTextStyles.bold24(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Enter the code we sent to ',
                        style: AppTextStyles.medium16(
                          context,
                        ).copyWith(color: const Color(0xFF9E9E9E), height: 1.45),
                      ),
                      TextSpan(
                        text: maskedEmail,
                        style: AppTextStyles.medium16(
                          context,
                        ).copyWith(color: const Color(0xFFd0e3fd)),
                      ),
                      TextSpan(
                        text: ' to reset your password',
                        style: AppTextStyles.medium16(
                          context,
                        ).copyWith(color: const Color(0xFF9E9E9E), height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: AutofillGroup(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => _buildOtpDigitInput(index),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Center(
                  child: GestureDetector(
                    onTap: _isResendEnabled && !isResending
                        ? _resendCode
                        : null,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Didn’t receive ? ',
                            style: TextStyle(color: Color(0xFF9E9E9E)),
                          ),
                          TextSpan(
                            text: _isResendEnabled
                                ? 'resend'
                                : 'resend in $_countdown s',
                            style: TextStyle(
                              color: _isResendEnabled
                                  ? const Color(0xFF8DA2FF)
                                  : const Color(0xFFA6A6A6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                CustomButton(
                  onPressed: _continue,
                  text: 'Continue',
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
