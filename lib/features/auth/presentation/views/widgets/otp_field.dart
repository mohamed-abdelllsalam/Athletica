import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpField extends StatelessWidget {
  const OtpField({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = screenWidth * 0.12; // Responsive width
    final fieldHeight = 50.0;

    final InputDecoration otpInputDecoration = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(width: 1, color: Color(0xFF72C592)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(width: 1, color: Color(0xFF72C592)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(width: 1, color: Color(0xFF72C592)),
      ),
    );

    Widget buildOtpField() {
      return SizedBox(
        width: fieldWidth,
        height: fieldHeight,
        child: TextFormField(
          onChanged: (value) {
            if (value.length == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: AppTextStyles.bold20(context),
          decoration: otpInputDecoration,
        ),
      );
    }

    return Form(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (_) => buildOtpField(),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Didn’t receive ? ',
                  style: AppTextStyles.medium13(context).copyWith(
                    color: const Color(0xFFA8A8A8),
                  ),
                ),
                TextSpan(
                  text: 'resend in 50 s ',
                  style: AppTextStyles.medium13(context).copyWith(
                    color: const Color(0xFFBEF3D2),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
