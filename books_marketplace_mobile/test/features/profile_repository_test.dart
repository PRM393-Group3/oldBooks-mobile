import 'dart:convert';
import 'dart:typed_data';

import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/network/auth_interceptor.dart';
import 'package:books_marketplace_mobile/core/network/blob_uploader.dart';
import 'package:books_marketplace_mobile/features/profile/data/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

const _profileJson = {
  'id': 'u1',
  'phone': '+84912345678',
  'fullName': 'Nguyen Van A',
  'avatarUrl': 'http://blob/public/u1/x.png',
  'role': 'USER',
  'status': 'ACTIVE',
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
          'PUT x/me/avatar',
        ],
      );

      final upload = seen[1];
      expect(upload.headers.containsKey('Authorization'), isFalse);
      expect(upload.headers['x-ms-blob-type'], 'BlockBlob');
      expect(upload.headers[Headers.contentLengthHeader], 3);

      final confirm = seen[2];
      expect(confirm.headers['Authorization'], 'Bearer acc');
      expect(confirm.data, {'blobName': 'u1/x.png'});
      expect((seen[0].data as Map)['visibility'], 'PUBLIC');
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
      expect(seen.any((o) => o.path == '/me/avatar'), isFalse);
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
            'phone': '+84912345678',
            'fullName': 'A',
            'role': 'USER',
          },
        }),
      ),
    );

    await repo.changePassword(currentPassword: 'old', newPassword: 'newnewnew');

    expect(tokens.accessToken, 'acc2');
    expect(tokens.refreshToken, 'ref2');
  });

  test('getProfile gọi GET /me', () async {
    setup((o) => jsonResponse(200, okBody(_profileJson)));
    final p = await repo.getProfile();
    expect(seen.single.path, '/me');
    expect(p.phoneNumber, '+84912345678');
    expect(p.role.apiValue, 'USER');
    expect(p.isStaff, isFalse);
  });

  test(
    'updateProfile: PATCH /me chỉ gửi fullName đã cắt khoảng trắng',
    () async {
      setup((o) => jsonResponse(200, okBody(_profileJson)));

      await repo.updateProfile(fullName: '  Nguyen Van A  ');

      expect(seen.single.method, 'PATCH');
      expect(seen.single.path, '/me');
      expect(jsonDecode(jsonEncode(seen.single.data)), {
        'fullName': 'Nguyen Van A',
      });
    },
  );

  test('đổi số: gửi OTP tới số mới rồi xác nhận, token không đổi', () async {
    setup((o) {
      if (o.path == '/me/phone/otp') {
        return jsonResponse(200, okBody({'expiresInSeconds': 300}));
      }
      return jsonResponse(
        200,
        okBody({..._profileJson, 'phone': '+84987654321'}),
      );
    });

    expect(await repo.sendPhoneOtp(phone: '0987654321'), 300);
    final p = await repo.changePhone(phone: '0987654321', otp: '123456');

    expect(p.phoneNumber, '+84987654321');
    expect(seen[0].data, {'phone': '0987654321'});
    expect(seen[1].path, '/me/phone');
    expect(seen[1].data, {'phone': '0987654321', 'otp': '123456'});
    expect(tokens.accessToken, 'acc');
  });

  test('changePassword gọi POST /me/password', () async {
    setup(
      (o) => jsonResponse(
        200,
        okBody({
          'accessToken': 'acc2',
          'accessTokenExpiresAt': '2026-09-19T08:45:00Z',
          'refreshToken': 'ref2',
          'refreshTokenExpiresAt': '2026-09-26T08:30:00Z',
          'user': {'id': 'u1', 'fullName': 'A', 'role': 'USER'},
        }),
      ),
    );
    await repo.changePassword(currentPassword: 'old', newPassword: 'new1new1');
    expect(seen.single.path, '/me/password');
  });

  test('deleteAccount: 204, gửi mật khẩu', () async {
    setup((o) => ResponseBody.fromString('', 204));
    await repo.deleteAccount(password: 'Passw0rd123');
    expect(seen.single.method, 'POST');
    expect(seen.single.path, '/me/delete-account');
    expect(seen.single.data, {'password': 'Passw0rd123'});
  });

  test('deleteAccount bị chặn: giữ danh sách lý do', () async {
    setup(
      (o) => jsonResponse(
        409,
        errorBody(
          ApiErrorCode.accountDeletionBlocked,
          details: [
            {'field': 'wallet', 'message': 'Số dư ví khác 0'},
          ],
        ),
      ),
    );
    await expectLater(
      repo.deleteAccount(password: 'x'),
      throwsA(
        isA<ApiError>().having((e) => e.detailMessages, 'reasons', [
          'Số dư ví khác 0',
        ]),
      ),
    );
  });

  test('deleteAvatar chấp nhận 204 không có body', () async {
    setup((o) => ResponseBody.fromString('', 204));
    await repo.deleteAvatar();
    expect(seen.single.method, 'DELETE');
  });

  test('tệp PRIVATE: gửi visibility PRIVATE và lấy read-url', () async {
    setup((o) {
      if (o.path == '/storage/upload-url') {
        return jsonResponse(
          200,
          okBody({
            'blobName': 'u1/x.pdf',
            'uploadUrl': 'http://blob/private/u1/x.pdf?sig=abc',
            'requiredHeaders': <String, String>{},
          }),
        );
      }
      if (o.uri.host == 'blob') return jsonResponse(201, {});
      return jsonResponse(
        200,
        okBody({'readUrl': 'http://blob/private/u1/x.pdf?sig=r'}),
      );
    });
    final api = ApiClient(
      Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = adapter,
    );
    final plain = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = adapter;

    final blob = await BlobUploader(api, plain).upload(
      bytes: Uint8List(1),
      fileName: 'x.pdf',
      contentType: 'application/pdf',
      visibility: BlobVisibility.private,
    );
    final url = await fetchPrivateReadUrl(api, blob);

    expect((seen.first.data as Map)['visibility'], 'PRIVATE');
    expect(url, contains('sig=r'));
    expect(seen.last.queryParameters, {'blobName': 'u1/x.pdf'});
  });
}
