import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/views/reset_password_view.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_checbox.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_passwor_field.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:athletica/features/auth/presentation/views/widgets/or_divder.dart';
import 'package:athletica/features/auth/presentation/views/widgets/social_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

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
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/sign_in_1.svg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Expanded(
              flex: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAppColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 13),
                                AspectRatio(
                                  aspectRatio: 5,
                                  child: SvgPicture.asset(
                                    'assets/images/dumbel.svg',
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Welcome Back !',
                                  style: AppTextStyles.bold24(context),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Please enter your sign in information',
                                  style: AppTextStyles.meduim11(context),
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
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        textInputAction: TextInputAction.next,
                                        labelText: 'Email',
                                        hintText: 'Enter your email',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                      const SizedBox(height: 10),
                                      CustomPasswordField(
                                        onSaved: (value) {
                                          password = value!;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 11),
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
                                      style: AppTextStyles.meduim12(context),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () => (
                                        Navigator.pushNamed(
                                          context,
                                          ResetPasswordView.routeName,
                                        ),
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: AppTextStyles.medium13(context),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                CustomButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      formKey.currentState!.save();
                                    } else {
                                      setState(() {
                                        autoValidateMode =
                                            AutovalidateMode.always;
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
