import 'package:athletica/core/services/user_role_service.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_checbox.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:athletica/features/auth/presentation/views/widgets/or_divder.dart';
import 'package:athletica/features/auth/presentation/views/widgets/social_login.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_complete_profile_view.dart';
import 'package:athletica/features/complete_profile/presentation/views/complete_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpViewBody extends StatefulWidget {
  const SignUpViewBody({super.key});

  @override
  State<SignUpViewBody> createState() => _SignUpViewBodyState();
}

class _SignUpViewBodyState extends State<SignUpViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  late String name, email, phone, password, confirmPassword;
  String? _selectedRole;
  bool agreeToTerms = false;

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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Form(
          key: formKey,
          autovalidateMode: autoValidateMode,
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Text(
                'Sign Up',
                style: AppTextStyles.bold24(
                  context,
                ).copyWith(color: Colors.white),
              ),
              SizedBox(height: 8.h),
              Text(
                'Guide the challenge, inspire the journey',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 26),
              AutofillGroup(
                child: Column(
                  children: [
                    CustomFormTextField(
                      onSaved: (value) => name = value!,
                      onFieldSubmitted: (_) =>
                          TextInput.finishAutofillContext(),
                      autofillHints: const [AutofillHints.name],
                      hintText: 'Your name',
                      keyboardType: TextInputType.text,
                      labelText: 'Name',
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomFormTextField(
                      onSaved: (value) => email = value!,
                      onFieldSubmitted: (_) =>
                          TextInput.finishAutofillContext(),
                      autofillHints: const [AutofillHints.email],
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'Email',
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomFormTextField(
                      onSaved: (value) => phone = value!,
                      onFieldSubmitted: (_) =>
                          TextInput.finishAutofillContext(),
                      autofillHints: const [AutofillHints.telephoneNumber],
                      hintText: 'Phone',
                      keyboardType: TextInputType.phone,
                      labelText: 'Phone',
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.length < 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomFormTextField(
                      onSaved: (value) => password = value!,
                      hintText: 'Enter your password',
                      keyboardType: TextInputType.visiblePassword,
                      labelText: 'Password',
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 16),
                    CustomFormTextField(
                      onSaved: (value) => confirmPassword = value!,
                      hintText: 'Confirm your password',
                      keyboardType: TextInputType.visiblePassword,
                      labelText: 'Confirm Password',
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: AppTextStyles.medium15(
                    context,
                  ).copyWith(color: Colors.white),
                  hintText: 'Select your role',
                  hintStyle: AppTextStyles.regular13(
                    context,
                  ).copyWith(color: const Color(0xFFC0C0C0)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFF919191),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFF919191),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFF919191),
                      width: 1,
                    ),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Coach', child: Text('Coach')),
                  DropdownMenuItem(value: 'Client', child: Text('Client')),
                ],
                onChanged: (value) => setState(() => _selectedRole = value),
                validator: (value) =>
                    value == null ? 'Please select your status' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CustomCheckBox(
                    isChecked: agreeToTerms,
                    onChanged: (val) {
                      setState(() {
                        agreeToTerms = val;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'I agree to the terms & conditions',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              CustomButton(
                onPressed: () {
                  if (!agreeToTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'You must agree to the terms & conditions',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (formKey.currentState!.validate()) {
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

                    UserRoleService.instance.registerUser(
                      email,
                      _selectedRole!,
                    );
                    final route = _selectedRole == 'Coach'
                        ? CoachCompleteProfileView.routeName
                        : CompleteProfileView.routeName;
                    Navigator.pushNamed(context, route);
                  } else {
                    setState(() {
                      autoValidateMode = AutovalidateMode.always;
                    });
                  }
                },
                text: 'Sign Up',
              ),
              const SizedBox(height: 22),
              const OrDivider(),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialLogin(
                    onTap: () {},
                    image: 'assets/images/google_logo.svg',
                  ),
                  const SizedBox(width: 30),
                  SocialLogin(
                    onTap: () {},
                    image: 'assets/images/facebook_logo.svg',
                  ),
                  const SizedBox(width: 30),
                  SocialLogin(
                    onTap: () {},
                    image: 'assets/images/apple_logo.svg',
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
