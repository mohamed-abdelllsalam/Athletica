import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class NewPasswordViewBody extends StatefulWidget {
  const NewPasswordViewBody({super.key});

  @override
  State<NewPasswordViewBody> createState() => _NewPasswordViewBodyState();
}

class _NewPasswordViewBodyState extends State<NewPasswordViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  late String password, confirmPassword;

  String? validatePassword(String? value) {
    final password = value ?? '';
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#\$&*~]'));

    if (!hasMinLength || !hasUppercase || !hasNumber || !hasSpecialChar) {
      return '8+ chars, uppercase, number & special char';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
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
                  CustomFormTextField(
                    onSaved: (value) => password = value!,
                    hintText: 'Enter your new password',
                    keyboardType: TextInputType.visiblePassword,
                    labelText: 'New Password',
                    textInputAction: TextInputAction.next,
                    obscureText: true,
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
                  CustomFormTextField(
                    onSaved: (value) => confirmPassword = value!,
                    hintText: 'Confirm your password',
                    keyboardType: TextInputType.visiblePassword,
                    labelText: 'Confirm New Password',
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Confirm your password';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
