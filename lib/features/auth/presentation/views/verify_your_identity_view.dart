import 'package:athletica/features/auth/presentation/views/widgets/verify_your_identity_view_body.dart';
import 'package:flutter/material.dart';

class VerifyYourIdentityView extends StatelessWidget {
  const VerifyYourIdentityView({super.key, this.email = ''});

  final String email;
  static const String routeName = 'verifyYourIdentityView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: VerifyYourIdentityViewBody(email: email),
    );
  }
}
