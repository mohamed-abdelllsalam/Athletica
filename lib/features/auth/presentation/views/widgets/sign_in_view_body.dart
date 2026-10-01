import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/validation_utils.dart';
import 'package:athletica/features/auth/domain/entities/auth_status.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:athletica/features/auth/presentation/views/reset_password_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_up_email_verification_otp_view.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_checbox.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_passwor_field.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:athletica/features/auth/presentation/views/widgets/google_role_picker.dart';
import 'package:athletica/features/auth/presentation/views/widgets/or_divder.dart';
import 'package:athletica/features/auth/presentation/views/widgets/social_login.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_complete_profile_view.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/info/presentation/views/info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInViewBody extends StatefulWidget {
  const SignInViewBody({
    super.key,
    this.sessionExpired = false,
    this.completeProfileAfterLogin = false,
  });

  final bool sessionExpired;
  final bool completeProfileAfterLogin;

  @override
  State<SignInViewBody> createState() => _SignInViewBodyState();
}

class _SignInViewBodyState extends State<SignInViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  late String email, password;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    // Single client-side notice for expired sessions. Post-frame so the
    // ScaffoldMessenger is ready; shown exactly once per page instance.
    if (widget.sessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Session expired, please login again.'),
              backgroundColor: Colors.red,
            ),
          );
      });
    }
  }

  void _submit(BuildContext context) {
    if (!formKey.currentState!.validate()) {
      setState(() => autoValidateMode = AutovalidateMode.always);
      return;
    }
    formKey.currentState!.save();
    context.read<AuthCubit>().login(email: email, password: password);
  }

  void _navigateByStatus(BuildContext context, AuthStatus status) {
    switch (status) {
      case Unauthenticated():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      case ClientProfileIncomplete():
        Navigator.pushNamedAndRemoveUntil(
          context,
          InfoView.routeName,
          (_) => false,
        );
      case CoachProfileIncomplete():
        _navigateCoach(context);
      case ClientReady():
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeView.routeName,
          (_) => false,
        );
      case CoachReady():
        _navigateCoach(context);
    }
  }

  void _navigateCoach(BuildContext context) {
    // A freshly verified coach completes their profile first; every other
    // coach lands on Coach Home regardless of profile completion.
    final route = widget.completeProfileAfterLogin
        ? CoachCompleteProfileView.routeName
        : CoachHomeView.routeName;
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.read<AuthCubit>().checkAuthStatus();
        } else if (state is AuthStatusChecked) {
          _navigateByStatus(context, state.status);
        } else if (state is EmailVerificationRequired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          Navigator.pushNamed(
            context,
            SignUpEmailVerificationOtpView.routeName,
            arguments: email,
          );
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: formKey,
          autovalidateMode: autoValidateMode,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 145.h),
                  SizedBox(
                    width: 85.w,
                    height: 57.h,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'ATHLETICA',
                    style: AppTextStyles.extraBold45(
                      context,
                    ).copyWith(color: const Color(0xff4C0DFD)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Please enter your sign in information',
                    style: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: const Color(0xFF919191)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  AutofillGroup(
                    child: Column(
                      children: [
                        CustomFormTextField(
                          onSaved: (value) => email = value!,
                          onFieldSubmitted: (_) =>
                              TextInput.finishAutofillContext(),
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                        SizedBox(height: 30.h),
                        CustomPasswordField(
                          onSaved: (value) => password = value!,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      CustomCheckBox(
                        isChecked: isChecked,
                        onChanged: (value) {
                          setState(() => isChecked = value);
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember me',
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            ResetPasswordView.routeName,
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.semiBold15(
                            context,
                          ).copyWith(color: const Color(0xFF5273E0)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          onPressed: () => _submit(context),
                          text: 'Login',
                        ),
                  const SizedBox(height: 31),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
