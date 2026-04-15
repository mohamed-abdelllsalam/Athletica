import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomFormTextField extends StatelessWidget {
  const CustomFormTextField({
    super.key,
    required this.hintText,
    this.suffixIcon,
    required this.keyboardType,
    this.onSaved,
    this.obscureText = false,
    required this.labelText,
    required this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.validator, // Add validator parameter
  });

  final void Function(String)? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final TextInputAction textInputAction;
  final String hintText;
  final String labelText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final void Function(String?)? onSaved;
  final bool obscureText;
  final String? Function(String?)? validator; // Validator type

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onSaved: onSaved,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $hintText';
            }
            return null;
          },
      keyboardType: keyboardType,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        labelText: labelText,
        labelStyle: AppTextStyles.medium15(context).copyWith(
          color: Colors.white,
        ),
        hintText: hintText,
        hintStyle: AppTextStyles.regular13(context).copyWith(
          color: const Color(0xFFC0C0C0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: buildBorder(),
        focusedBorder: buildBorder(),
        enabledBorder: buildBorder(),
      ),
    );
  }

  OutlineInputBorder buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: Color(0xCC206D3E),
        width: 1,
      ),
    );
  }
}
