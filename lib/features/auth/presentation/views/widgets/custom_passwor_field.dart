import 'package:athletica/features/auth/presentation/views/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class CustomPasswordField extends StatefulWidget {
  const CustomPasswordField({super.key, required this.onSaved});
  final void Function(String?) onSaved;

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
      textInputAction: TextInputAction.done,
      labelText: 'Password',
      hintText: 'Enter your password',
      keyboardType: TextInputType.visiblePassword,
    );
  }
}
