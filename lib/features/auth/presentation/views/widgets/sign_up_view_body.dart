import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/validation_utils.dart';
import 'package:athletica/features/auth/domain/entities/auth_status.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:athletica/features/auth/presentation/views/sign_in_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_up_email_verification_otp_view.dart';
import 'package:athletica/features/auth/presentation/views/verify_your_identity_view.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_checbox.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_passwor_field.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:athletica/features/auth/presentation/views/widgets/google_role_picker.dart';
import 'package:athletica/features/auth/presentation/views/widgets/or_divder.dart';
import 'package:athletica/features/auth/presentation/views/widgets/social_login.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/info/presentation/views/info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpViewBody extends StatefulWidget {
  const SignUpViewBody({super.key, this.initialRole = 'Client'});
  final String initialRole;

  @override
  State<SignUpViewBody> createState() => _SignUpViewBodyState();
}

class _SignUpViewBodyState extends State<SignUpViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool agreeToTerms = false;

  void _submit(BuildContext context) {
    if (!formKey.currentState!.validate()) {
      setState(() => autoValidateMode = AutovalidateMode.always);
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the terms & conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cubit = context.read<AuthCubit>();
    if (_selectedRole == 'Coach') {
      cubit.registerTrainer(name: name, email: email, password: password);
    } else {
      cubit.registerClient(name: name, email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.read<AuthCubit>().checkAuthStatus();
        } else if (state is AuthStatusChecked) {
          _navigateByStatus(context, state.status);
        } else if (state is RegisterSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            VerifyYourIdentityView.routeName,
            (route) =>
                route.settings.name == SignInView.routeName || route.isFirst,
            arguments: _emailController.text.trim(),
          );
        } else if (state is EmailVerificationRequired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          Navigator.pushNamed(
            context,
            SignUpEmailVerificationOtpView.routeName,
            arguments: _emailController.text.trim(),
          );
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

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
                          controller: _nameController,
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
                          controller: _emailController,
                          autofillHints: const [AutofillHints.email],
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          labelText: 'Email',
                          textInputAction: TextInputAction.next,
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 16),
                        CustomPasswordField(
                          controller: _passwordController,
                          autofillHints: const [AutofillHints.newPassword],
                          hintText: 'Enter your password',
                          labelText: 'Password',
                          textInputAction: TextInputAction.next,
                          validator: validatePassword,
                        ),
                        const SizedBox(height: 16),
                        CustomPasswordField(
                          controller: _confirmPasswordController,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) =>
                              TextInput.finishAutofillContext(),
                          hintText: 'Confirm your password',
                          labelText: 'Confirm Password',
                          textInputAction: TextInputAction.done,
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
                          setState(() => agreeToTerms = val);
                        },
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'I agree to the terms & conditions',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          onPressed: () => _submit(context),
                          text: 'Sign Up',
                        ),
                  const SizedBox(height: 22),
                  const OrDivider(),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialLogin(
                        onTap: () => context.read<AuthCubit>().signInWithGoogle(
                          pickRole: () => showGoogleRolePicker(context),
                        ),
                        image: 'assets/images/google_logo.svg',
                      ),
                      const SizedBox(width: 30),
                      // SocialLogin(
                      //   onTap: () {},
                      //   image: 'assets/images/facebook_logo.svg',
                      // ),
                      // const SizedBox(width: 30),
                      // SocialLogin(
                      //   onTap: () {},
                      //   image: 'assets/images/apple_logo.svg',
                      // ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateByStatus(BuildContext context, AuthStatus status) {
    final route = switch (status) {
      Unauthenticated() => null,
      ClientProfileIncomplete() => InfoView.routeName,
      CoachProfileIncomplete() => CoachHomeView.routeName,
      ClientReady() => HomeView.routeName,
      CoachReady() => CoachHomeView.routeName,
    };
    if (route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }
}
