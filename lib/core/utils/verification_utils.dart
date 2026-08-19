String maskEmail(String? email) {
  if (email == null || email.trim().isEmpty) {
    return 'your email';
  }

  final trimmed = email.trim();
  final atIndex = trimmed.indexOf('@');
  if (atIndex <= 0) {
    return trimmed;
  }

  final localPart = trimmed.substring(0, atIndex);
  final domain = trimmed.substring(atIndex);

  if (localPart.length <= 3) {
    return '${localPart.replaceRange(0, localPart.length, '*' * localPart.length)}$domain';
  }

  final visibleStart = localPart.substring(0, 3);
  final visibleEnd = localPart.substring(localPart.length - 2);
  final maskedMiddle = '*' * (localPart.length - 5);
  return '$visibleStart$maskedMiddle$visibleEnd$domain';
}
