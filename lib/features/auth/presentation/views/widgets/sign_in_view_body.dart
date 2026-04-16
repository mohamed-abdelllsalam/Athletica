import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_state.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_checbox.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_passwor_field.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:athletica/features/auth/presentation/views/widgets/or_divder.dart';
import 'package:athletica/features/auth/presentation/views/widgets/social_login.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInViewBody extends StatefulWidget {
  const SignInViewBody({super.key});

  @override
  State<SignInViewBody> createState() => _SignInViewBodyState();
}

class _SignInViewBodyState extends State<SignInViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  late String email, password;
  bool isChecked = false;

  void _submit(BuildContext context) {
    if (!formKey.currentState!.validate()) {
      setState(() => autoValidateMode = AutovalidateMode.always);
      return;
    }
    formKey.currentState!.save();
    context.read<AuthCubit>().login(email: email, password: password);
  }

  void _navigateByRole(BuildContext context, String primaryRole) {
    if (primaryRole == 'TRAINER') {
      Navigator.pushReplacementNamed(context, CoachHomeView.routeName);
    } else {
      Navigator.pushReplacementNamed(context, HomeView.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          _navigateByRole(context, state.response.user.primaryRole);
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
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30.h),
                        CustomPasswordField(
                          onSaved: (value) => password = value!,
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
                        onTap: () {},
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
