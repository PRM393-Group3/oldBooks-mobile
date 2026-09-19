import 'dart:convert';
import 'dart:typed_data';

import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/network/auth_interceptor.dart';
import 'package:books_marketplace_mobile/features/profile/data/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

const _profileJson = {
  'id': 'u1',
  'email': 'a@b.co',
  'fullName': 'Nguyen Van A',
  'phoneNumber': null,
  'avatarUrl': 'http://blob/public/u1/x.png',
  'role': 'Seller',
  'createdAt': '2026-09-19T08:30:18.271413Z',
};

void main() {
  late MemoryTokenStore tokens;
  late FakeAdapter adapter;
  late ProfileRepository repo;
  late List<RequestOptions> seen;

  void setup(ResponseBody Function(RequestOptions) handler) {
    seen = [];
    tokens = MemoryTokenStore(access: 'acc', refresh: 'ref');
    adapter = FakeAdapter((o) {
      seen.add(o);
      return handler(o);
    });
    final plain = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = adapter;
    final api = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(
          tokens: tokens,
          refreshDio: plain,
          onSessionLost: () {},
        ),
      );
    repo = ProfileRepository(ApiClient(api), plain, tokens);
  }

  test(
    'changeAvatar: xin URL, PUT lên Blob không kèm Authorization, xác nhận',
    () async {
      setup((o) {
        if (o.path == '/storage/upload-url') {
          return jsonResponse(
            200,
            okBody({
              'blobName': 'u1/x.png',
              'uploadUrl': 'http://blob/public/u1/x.png?sig=abc',
              'requiredHeaders': {
                'x-ms-blob-type': 'BlockBlob',
                'Content-Type': 'image/png',
              },
            }),
          );
        }
        if (o.uri.host == 'blob') return jsonResponse(201, {});
        return jsonResponse(200, okBody(_profileJson));
      });

      final profile = await repo.changeAvatar(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'avatar.png',
        contentType: 'image/png',
      );

      expect(profile.avatarUrl, contains('x.png'));
      expect(
        seen.map((o) => '${o.method} ${o.uri.host}${o.uri.path}').toList(),
        [
          'POST x/storage/upload-url',
          'PUT blob/public/u1/x.png',
          'PUT x/profile/avatar',
        ],
      );

      final upload = seen[1];
      expect(upload.headers.containsKey('Authorization'), isFalse);
      expect(upload.headers['x-ms-blob-type'], 'BlockBlob');
      expect(upload.headers[Headers.contentLengthHeader], 3);

      final confirm = seen[2];
      expect(confirm.headers['Authorization'], 'Bearer acc');
      expect(confirm.data, {'blobName': 'u1/x.png'});
      expect((seen[0].data as Map)['visibility'], 'Public');
    },
  );

  test(
    'changeAvatar: upload Blob lỗi thì dừng, không gọi bước xác nhận',
    () async {
      setup((o) {
        if (o.path == '/storage/upload-url') {
          return jsonResponse(
            200,
            okBody({
              'blobName': 'u1/x.png',
              'uploadUrl': 'http://blob/public/u1/x.png?sig=abc',
              'requiredHeaders': <String, String>{},
            }),
          );
        }
        return jsonResponse(403, {});
      });

      await expectLater(
        repo.changeAvatar(
          bytes: Uint8List(1),
          fileName: 'a.png',
          contentType: 'image/png',
        ),
        throwsA(
          isA<ApiError>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.uploadFailed,
          ),
        ),
      );
      expect(seen.any((o) => o.path == '/profile/avatar'), isFalse);
    },
  );

  test('changePassword: lưu ngay cặp token mới', () async {
    setup(
      (o) => jsonResponse(
        200,
        okBody({
          'accessToken': 'acc2',
          'accessTokenExpiresAt': '2026-09-19T08:45:00Z',
          'refreshToken': 'ref2',
          'refreshTokenExpiresAt': '2026-09-26T08:30:00Z',
          'user': {
            'id': 'u1',
            'email': 'a@b.co',
            'fullName': 'A',
            'role': 'Buyer',
          },
        }),
      ),
    );

    await repo.changePassword(currentPassword: 'old', newPassword: 'newnewnew');

    expect(tokens.accessToken, 'acc2');
    expect(tokens.refreshToken, 'ref2');
  });

  test('updateProfile: PUT đủ hai trường, số điện thoại null để xóa', () async {
    setup((o) => jsonResponse(200, okBody(_profileJson)));

    await repo.updateProfile(fullName: '  Nguyen Van A  ', phoneNumber: null);

    expect(seen.single.method, 'PUT');
    expect(jsonDecode(jsonEncode(seen.single.data)), {
      'fullName': 'Nguyen Van A',
      'phoneNumber': null,
    });
  });

  test('deleteAvatar chấp nhận 204 không có body', () async {
    setup((o) => ResponseBody.fromString('', 204));
    await repo.deleteAvatar();
    expect(seen.single.method, 'DELETE');
  });

  test('getProfile map role, avatarUrl và createdAt', () async {
    setup((o) => jsonResponse(200, okBody(_profileJson)));
    final p = await repo.getProfile();
    expect(p.role.apiValue, 'Seller');
    expect(p.phoneNumber, isNull);
    expect(p.createdAt.isUtc, isTrue);
  });
}
