import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/auth/presentation/views/widgets/new_password_view_body.dart';
import 'package:flutter/material.dart';

class NewPasswordView extends StatelessWidget {
  const NewPasswordView({super.key});
  static const routeName = 'new_password_view';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Column(
        children: [
          NewPasswordViewBody(),
          Spacer(),
          CustomButton(
            onPressed: () {},
            text: 'Continue',
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
