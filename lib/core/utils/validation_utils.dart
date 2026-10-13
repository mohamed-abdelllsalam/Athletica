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
  if (password.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return 'Password must include an uppercase letter';
  }
  if (!password.contains(RegExp(r'[a-z]'))) {
    return 'Password must include a lowercase letter';
  }
  return null;
}
