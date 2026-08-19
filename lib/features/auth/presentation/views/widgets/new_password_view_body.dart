import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/validation_utils.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:athletica/features/auth/presentation/views/sign_in_view.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_passwor_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NewPasswordViewBody extends StatefulWidget {
  const NewPasswordViewBody({
    super.key,
    required this.email,
    required this.code,
  });

  final String email;
  final String code;

  @override
  State<NewPasswordViewBody> createState() => _NewPasswordViewBodyState();
}

class _NewPasswordViewBodyState extends State<NewPasswordViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  late String password, confirmPassword;

  String? validateConfirmPassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Confirm your password';
    }
    return null;
  }

  void _submit(BuildContext context) {
    if (!formKey.currentState!.validate()) {
      setState(() => autoValidateMode = AutovalidateMode.always);
      return;
    }
    formKey.currentState!.save();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthCubit>().confirmPasswordReset(
          email: widget.email,
          code: widget.code,
          password: password,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset successfully. Please login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            SignInView.routeName,
            (_) => false,
          );
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ResetConfirmLoading;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: NewPasswordForm(
                      formKey: formKey,
                      autoValidateMode: autoValidateMode,
                      onPasswordSaved: (value) => password = value!,
                      onConfirmSaved: (value) => confirmPassword = value!,
                      validateConfirmPassword: validateConfirmPassword,
                    ),
                  ),
                ),
                isLoading
                    ? CustomButton(
                        onPressed: null,
                        text: 'Continue',
                        isLoading: true,
                      )
                    : CustomButton(
                        onPressed: () => _submit(context),
                        text: 'Continue',
                      ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NewPasswordForm extends StatelessWidget {
  const NewPasswordForm({
    super.key,
    required this.formKey,
    required this.autoValidateMode,
    required this.onPasswordSaved,
    required this.onConfirmSaved,
    required this.validateConfirmPassword,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autoValidateMode;
  final void Function(String?) onPasswordSaved;
  final void Function(String?) onConfirmSaved;
  final String? Function(String?) validateConfirmPassword;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autoValidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Create new password',
            style: AppTextStyles.bold24(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Password must be at least 8 characters, include a number and a special character',
            style: AppTextStyles.medium13(context).copyWith(
              color: const Color(0xFF909090),
            ),
          ),
          const SizedBox(height: 29),
          AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Password',
                  style: AppTextStyles.medium16(context).copyWith(
                    color: const Color(0xFF909090),
                  ),
                ),
                const SizedBox(height: 10),
                CustomPasswordField(
                  onSaved: onPasswordSaved,
                  hintText: 'Enter your new password',
                  labelText: 'New Password',
                  validator: validatePassword,
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirm new password',
                  style: AppTextStyles.medium16(context).copyWith(
                    color: const Color(0xFF909090),
                  ),
                ),
                const SizedBox(height: 10),
                CustomPasswordField(
                  onSaved: onConfirmSaved,
                  hintText: 'Confirm your password',
                  labelText: 'Confirm New Password',
                  validator: validateConfirmPassword,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}