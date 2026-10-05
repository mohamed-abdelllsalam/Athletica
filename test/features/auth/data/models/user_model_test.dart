import 'package:athletica/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses access and refresh tokens from a session response', () {
    final session = AuthResponseModel.fromJson({
      'token': 'access-token',
      'refreshToken': 'rotated-refresh-token',
      'user': {
        'id': 'user-id',
        'username': 'athlete',
        'email': 'athlete@example.com',
        'role': 'client',
        'email_verified': true,
      },
    });

    expect(session.token, 'access-token');
    expect(session.refreshToken, 'rotated-refresh-token');
    expect(session.user.primaryRole, 'CLIENT');
  });
}
