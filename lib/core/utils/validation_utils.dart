String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  if (!value.contains('@')) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  final hasMinLength = password.length >= 8;
  final hasUppercase = password.contains(RegExp(r'[A-Z]'));
  final hasNumber = password.contains(RegExp(r'[0-9]'));
  final hasSpecialChar = password.contains(RegExp(r'[!@#\$&*~]'));

  if (!hasMinLength || !hasUppercase || !hasNumber || !hasSpecialChar) {
    return '8+ chars, uppercase, number & special char';
  }
  return null;
}