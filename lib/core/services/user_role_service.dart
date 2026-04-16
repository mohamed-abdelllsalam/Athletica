class UserRoleService {
  UserRoleService._();

  static final UserRoleService instance = UserRoleService._();

  final Map<String, String> _emailRoleMap = {};

  void registerUser(String email, String role) {
    _emailRoleMap[email.toLowerCase()] = role;
  }

  String? getRoleByEmail(String email) {
    return _emailRoleMap[email.toLowerCase()];
  }
}
