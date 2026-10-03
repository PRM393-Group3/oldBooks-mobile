import 'dart:convert';

import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/features/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late MemoryTokenStore tokens;
  late FakeAdapter adapter;
  late AuthRepository repo;
  late List<RequestOptions> sent;

  Map<String, dynamic> sessionJson() => {
    'accessToken': 'a1',
    'accessTokenExpiresAt': '2026-10-03T07:40:36.000Z',
    'refreshToken': 'r1',
    'refreshTokenExpiresAt': '2026-11-02T07:25:36.000Z',
    'serverTime': '2026-10-03T07:25:36.500Z',
    'user': {
      'id': 'u1',
      'phone': '+84912345678',
      'fullName': 'Nguyễn Văn A',
      'avatarUrl': null,
      'role': 'USER',
      'status': 'ACTIVE',
      'createdAt': '2026-10-03T07:25:36.100Z',
    },
  };

  void setup(ResponseBody Function(RequestOptions) handler) {
    tokens = MemoryTokenStore(access: 'old-a', refresh: 'old-r');
    sent = [];
    adapter = FakeAdapter((o) {
      sent.add(o);
      return handler(o);
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = adapter;
    repo = AuthRepository(ApiClient(dio), tokens);
  }

  test('sendOtp gửi purpose và trả expiresInSeconds của server', () async {
    setup((o) => jsonResponse(200, okBody({'expiresInSeconds': 180})));

    final expires = await repo.sendOtp(
      phone: '0912345678',
      purpose: OtpPurpose.resetPassword,
    );

    expect(expires, 180);
    expect(sent.single.data, {
      'phone': '0912345678',
      'purpose': 'RESET_PASSWORD',
    });
  });

  test('sendOtp 429 mang Retry-After', () async {
    setup(
      (o) => jsonResponse(
        429,
        errorBody(ApiErrorCode.rateLimited),
        headers: {
          'retry-after': ['1800'],
        },
      ),
    );

    await expectLater(
      repo.sendOtp(phone: '0912345678', purpose: OtpPurpose.register),
      throwsA(
        isA<ApiError>().having(
          (e) => e.retryAfter,
          'retryAfter',
          const Duration(minutes: 30),
        ),
      ),
    );
  });

  test('register gửi acceptTerms và lưu cặp token', () async {
    setup((o) => jsonResponse(201, okBody(sessionJson())));

    final session = await repo.register(
      phone: '0912345678',
      otp: '123456',
      password: 'Passw0rd123',
      fullName: 'Nguyễn Văn A',
      acceptTerms: true,
    );

    expect((sent.single.data as Map)['acceptTerms'], isTrue);
    expect(tokens.accessToken, 'a1');
    expect(tokens.refreshToken, 'r1');
    expect(session.user.phone, '+84912345678');
    expect(session.user.status, 'ACTIVE');
    expect(session.user.createdAt, isNotNull);
    expect(session.serverTime, isNotNull);
  });

  test('login khóa tạm: ApiError có Retry-After', () async {
    setup(
      (o) => jsonResponse(
        403,
        errorBody(ApiErrorCode.accountLocked),
        headers: {
          'retry-after': ['900'],
        },
      ),
    );

    await expectLater(
      repo.login(phone: '0912345678', password: 'x'),
      throwsA(isA<ApiError>().having((e) => e.isTemporaryLock, 'lock', true)),
    );
  });

  test('logout mặc định thu hồi thiết bị này, luôn xóa token', () async {
    setup((o) => ResponseBody.fromString('', 204));

    await repo.logout();

    expect(sent.single.path, '/auth/logout');
    expect(jsonDecode(jsonEncode(sent.single.data)), {'refreshToken': 'old-r'});
    expect(tokens.hasSession, isFalse);
  });

  test('logout allDevices dùng ?all=true và vẫn xóa token khi lỗi', () async {
    setup((o) => jsonResponse(500, errorBody(ApiErrorCode.internal)));

    await repo.logout(allDevices: true);

    expect(sent.single.path, '/auth/logout?all=true');
    expect(tokens.hasSession, isFalse);
  });
}
