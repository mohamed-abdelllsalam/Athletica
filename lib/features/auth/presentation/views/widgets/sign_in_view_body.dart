import 'package:athletica/core/services/user_role_service.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
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
  bool isPasswordVisible = false;
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
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
                ).copyWith(color: Color(0xff4C0DFD)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                'Please enter your sign in information',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: Color(0xFF919191)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AutofillGroup(
                child: Column(
                  children: [
                    CustomFormTextField(
                      onSaved: (value) {
                        email = value!;
                      },
                      onFieldSubmitted: (context) {
                        TextInput.finishAutofillContext();
                      },
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 30.h),
                    CustomPasswordField(
                      onSaved: (value) {
                        password = value!;
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
                      setState(() {
                        isChecked = value;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => (
                      // Navigator.pushNamed(context, ResetPasswordView.routeName),
                    ),
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
              CustomButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    final role =
                        UserRoleService.instance.getRoleByEmail(email);
                    if (role == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account not found. Please sign up.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (role == 'Coach') {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1E1E),
                          title: const Text(
                            'Welcome back, Coach!',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Where would you like to go?',
                            style: TextStyle(color: Color(0xFF919191)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pushNamed(
                                  context,
                                  HomeView.routeName,
                                );
                              },
                              child: const Text('Client Homepage'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pushNamed(
                                  context,
                                  CoachHomeView.routeName,
                                );
                              },
                              child: const Text('Coach Homepage'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.pushNamed(context, HomeView.routeName);
                    }
                  } else {
                    setState(() {
                      autoValidateMode = AutovalidateMode.always;
                    });
                  }
                },
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
                  SizedBox(width: 30),
                  SocialLogin(
                    onTap: () {},
                    image: 'assets/images/facebook_logo.svg',
                  ),
                  SizedBox(width: 30),
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
  }
}
