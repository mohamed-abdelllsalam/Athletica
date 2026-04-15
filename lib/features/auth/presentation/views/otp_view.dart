import 'package:athletica/features/auth/presentation/views/widgets/otp_view_body.dart';
import 'package:flutter/material.dart';

class OtpView extends StatelessWidget {
  const OtpView({super.key});
  static const String routeName = 'otp';
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
      body: const OtpViewBody(),
    );
  }
}
