import 'package:athletica/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class CustomPasswordField extends StatefulWidget {
  const CustomPasswordField({
    super.key,
    required this.onSaved,
    this.validator,
    this.hintText = 'Enter your password',
    this.labelText = 'Password',
    this.textInputAction = TextInputAction.done,
  });
  final void Function(String?) onSaved;
  final String? Function(String?)? validator;
  final String hintText;
  final String labelText;
  final TextInputAction textInputAction;

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return CustomFormTextField(
      onSaved: widget.onSaved,
      obscureText: isObscure,
      suffixIcon: IconButton(
        onPressed: () {
          isObscure = !isObscure;
          setState(() {});
        },
        icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
      ),
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      labelText: widget.labelText,
      hintText: widget.hintText,
      keyboardType: TextInputType.visiblePassword,
    );
  }
}
