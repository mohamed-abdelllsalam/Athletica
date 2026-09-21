import 'package:athletica/features/coach/clients/data/models/join_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _imageUrl = 'https://res.cloudinary.com/demo/image/upload/client.jpg';

Map<String, dynamic> _requestShape({Object? profileImage = _imageUrl}) {
  final client = <String, dynamic>{
    'id': 'client-1',
    'user': {'username': 'omar', 'email': 'o@x.com'},
    'goal': 'lose_weight',
  };
  if (profileImage != _absent) client['profile_image'] = profileImage;
  return {
    'id': 'req-1',
    'client': client,
    'status': 'pending',
    'created_at': '2026-09-10T08:00:00Z',
  };
}

void main() {
  group('JoinRequestModel.fromJson (GET /coach/requests profile_image)', () {
    test('parses client.profile_image into imageUrl', () {
      final model = JoinRequestModel.fromJson(_requestShape());

      expect(model.imageUrl, _imageUrl);
      expect(model.id, 'req-1');
      expect(model.name, 'omar');
      expect(model.email, 'o@x.com');
      expect(model.goal, 'lose weight');
      expect(model.toEntity().hasPhoto, isTrue);
      expect(model.toEntity().imageUrl, _imageUrl);
    });

    test('profile_image null results in no image', () {
      final model = JoinRequestModel.fromJson(
        _requestShape(profileImage: null),
      );

      expect(model.imageUrl, isNull);
      expect(model.toEntity().hasPhoto, isFalse);
    });

    test('missing profile_image results in no image', () {
      final model = JoinRequestModel.fromJson(
        _requestShape(profileImage: _absent),
      );

      expect(model.imageUrl, isNull);
      expect(model.toEntity().hasPhoto, isFalse);
    });

    test('empty and literal "null" values are treated as no image', () {
      for (final bad in ['', '   ', 'null', 'NULL']) {
        final model = JoinRequestModel.fromJson(
          _requestShape(profileImage: bad),
        );

        expect(model.imageUrl, isNull, reason: 'value: "$bad"');
        expect(model.toEntity().hasPhoto, isFalse, reason: 'value: "$bad"');
      }
    });

    test('parses int ids without throwing', () {
      final json = _requestShape();
      json['id'] = 7;
      (json['client'] as Map<String, dynamic>)['id'] = 42;

      final model = JoinRequestModel.fromJson(json);

      expect(model.id, '7');
      expect(model.imageUrl, _imageUrl);
    });
  });
}

/// Sentinel distinguishing "key absent" from "key present with null".
const _absent = Object();
