import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/validation_utils.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:athletica/features/auth/presentation/views/reset_otp_view.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResetPasswordViewBody extends StatefulWidget {
  const ResetPasswordViewBody({super.key});

  @override
  State<ResetPasswordViewBody> createState() => _ResetPasswordViewBodyState();
}

class _ResetPasswordViewBodyState extends State<ResetPasswordViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!formKey.currentState!.validate()) {
      setState(() => autoValidateMode = AutovalidateMode.always);
      return;
    }
    context
        .read<AuthCubit>()
        .requestPasswordReset(email: emailController.text.trim());
  }

  void _onRequestSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.isEmpty ? 'A reset link has been sent' : message,
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pushNamed(
      context,
      ResetOtpView.routeName,
      arguments: emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ResetRequestSuccess) {
          _onRequestSuccess(context, state.message);
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ResetRequestLoading;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reset your password', style: AppTextStyles.bold24(context)),
              const SizedBox(height: 12),
              Text(
                'Enter your email address and we will send you a link to reset your password',
                style: AppTextStyles.medium13(
                  context,
                ).copyWith(color: const Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 29),
              Text(
                'Email Address',
                style: AppTextStyles.medium16(
                  context,
                ).copyWith(color: const Color(0xFFEAFBF1)),
              ),
              const SizedBox(height: 15),
              Form(
                key: formKey,
                autovalidateMode: autoValidateMode,
                child: TextFormField(
                  controller: emailController,
                  autofillHints: const [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.regular16(
                    context,
                  ).copyWith(color: Colors.white),
                  validator: validateEmail,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        width: 1,
                        color: const Color(0xCC206D3E),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    hintText: 'Enter your email',
                    hintStyle: AppTextStyles.regular16(context).copyWith(),
                  ),
                ),
              ),
              const Spacer(),
              CustomButton(
                onPressed: () => _submit(context),
                text: 'Continue',
                isLoading: isLoading,
              ),
              SizedBox(height: 7.h),
            ],
          ),
        );
      },
    );
  }
}