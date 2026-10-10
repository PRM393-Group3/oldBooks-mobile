import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late MemoryTokenStore tokens;
  late FakeAdapter adapter;
  late ApiClient client;
  late int sessionLost;

  Map<String, dynamic> newTokens() => okBody({
    'accessToken': 'new-access',
    'refreshToken': 'new-refresh',
    'accessTokenExpiresAt': '2026-09-19T08:45:00Z',
    'refreshTokenExpiresAt': '2026-09-26T08:30:00Z',
  });

  void setup(ResponseBody Function(RequestOptions) handler) {
    tokens = MemoryTokenStore(access: 'old-access', refresh: 'old-refresh');
    adapter = FakeAdapter(handler);
    sessionLost = 0;
    final refreshDio = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = adapter;
    final apiDio = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = adapter;
    apiDio.interceptors.add(
      AuthInterceptor(
        tokens: tokens,
        refreshDio: refreshDio,
        onSessionLost: () => sessionLost++,
      ),
    );
    client = ApiClient(apiDio);
  }

  Future<dynamic> getProfile() => client.get('/profile', parse: (data) => data);

  test('gắn Bearer vào mọi request', () async {
    setup((o) => jsonResponse(200, okBody({'ok': true})));
    await getProfile();
    expect(adapter.calls.single, 'GET /profile Bearer old-access');
  });

  test(
    'UNAUTHENTICATED + token expired: refresh rồi gửi lại đúng một lần',
    () async {
      setup((o) {
        if (o.path == '/auth/refresh') return jsonResponse(200, newTokens());
        return o.headers['Authorization'] == 'Bearer new-access'
            ? jsonResponse(200, okBody({'ok': true}))
            : jsonResponse(401, expiredBody());
      });

      final result = await getProfile();

      expect(result, {'ok': true});
      expect(tokens.accessToken, 'new-access');
      expect(tokens.refreshToken, 'new-refresh');
      expect(adapter.count('/auth/refresh'), 1);
      expect(sessionLost, 0);
    },
  );

  test('nhiều request cùng hết hạn chỉ refresh một lần', () async {
    setup((o) {
      if (o.path == '/auth/refresh') return jsonResponse(200, newTokens());
      return o.headers['Authorization'] == 'Bearer new-access'
          ? jsonResponse(200, okBody({'ok': true}))
          : jsonResponse(401, expiredBody());
    });

    final results = await Future.wait([
      getProfile(),
      getProfile(),
      getProfile(),
    ]);

    expect(results, everyElement({'ok': true}));
    expect(adapter.count('/auth/refresh'), 1);
  });

  test('refresh bị 401: xóa token, báo mất phiên', () async {
    setup((o) {
      if (o.path == '/auth/refresh') {
        return jsonResponse(401, errorBody('AUTH_REFRESH_TOKEN_REUSED'));
      }
      return jsonResponse(401, expiredBody());
    });

    await expectLater(getProfile(), throwsA(isA<ApiError>()));

    expect(tokens.hasSession, isFalse);
    expect(sessionLost, 1);
  });

  test('AUTH_UNAUTHORIZED: mất phiên ngay, không refresh', () async {
    setup((o) => jsonResponse(401, errorBody(ApiErrorCode.unauthorized)));

    await expectLater(getProfile(), throwsA(isA<ApiError>()));

    expect(adapter.count('/auth/refresh'), 0);
    expect(sessionLost, 1);
  });

  test('mất mạng khi refresh: giữ phiên để thử lại', () async {
    setup((o) {
      if (o.path == '/auth/refresh') {
        throw DioException.connectionError(
          requestOptions: o,
          reason: 'offline',
        );
      }
      return jsonResponse(401, expiredBody());
    });

    await expectLater(
      getProfile(),
      throwsA(
        isA<ApiError>().having((e) => e.code, 'code', ApiErrorCode.network),
      ),
    );

    expect(tokens.refreshToken, 'old-refresh');
    expect(sessionLost, 0);
  });

  test('401 khác (sai mật khẩu đăng nhập) không đụng tới phiên', () async {
    setup((o) => jsonResponse(401, errorBody(ApiErrorCode.invalidCredentials)));

    await expectLater(
      getProfile(),
      throwsA(
        isA<ApiError>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.invalidCredentials,
        ),
      ),
    );

    expect(tokens.hasSession, isTrue);
    expect(sessionLost, 0);
    expect(adapter.count('/auth/refresh'), 0);
  });

  test('VALIDATION_FAILED trả về lỗi theo trường', () async {
    setup(
      (o) => jsonResponse(
        400,
        errorBody(
          ApiErrorCode.validationFailed,
          details: [
            {'field': 'fullName', 'message': 'required'},
          ],
        ),
      ),
    );

    await expectLater(
      getProfile(),
      throwsA(
        isA<ApiError>().having(
          (e) => e.fieldErrors.keys,
          'fields',
          contains('fullName'),
        ),
      ),
    );
  });

  test('UNAUTHENTICATED không có details: token sai, về đăng nhập', () async {
    setup((o) => jsonResponse(401, errorBody(ApiErrorCode.unauthenticated)));

    await expectLater(getProfile(), throwsA(isA<ApiError>()));

    expect(adapter.count('/auth/refresh'), 0);
    expect(sessionLost, 1);
  });

  test('mọi request mang X-Correlation-Id hợp lệ', () async {
    String? id;
    setup((o) {
      id = o.headers['X-Correlation-Id'] as String?;
      return jsonResponse(200, okBody({'ok': true}));
    });
    await getProfile();
    expect(id, matches(RegExp(r'^[A-Za-z0-9_-]{1,64}$')));
  });

  test('refresh bị 403 ACCOUNT_LOCKED: xóa phiên', () async {
    setup((o) {
      if (o.path == '/auth/refresh') {
        return jsonResponse(403, errorBody(ApiErrorCode.accountLocked));
      }
      return jsonResponse(401, expiredBody());
    });

    await expectLater(getProfile(), throwsA(isA<ApiError>()));

    expect(tokens.hasSession, isFalse);
    expect(sessionLost, 1);
  });

  test(
    'endpoint /auth/* không gắn Bearer và không kích hoạt refresh',
    () async {
      setup((o) => jsonResponse(401, errorBody(ApiErrorCode.unauthenticated)));

      await expectLater(
        client.post('/auth/login', body: {}, parse: (d) => d),
        throwsA(isA<ApiError>()),
      );

      expect(adapter.calls.single, 'POST /auth/login null');
      expect(sessionLost, 0);
    },
  );

  test('logout vẫn gắn Bearer', () async {
    setup((o) => ResponseBody.fromString('', 204));
    await client.postNoContent('/auth/logout?all=true', body: {});
    expect(adapter.calls.single, startsWith('POST /auth/logout'));
    expect(adapter.calls.single, endsWith('Bearer old-access'));
  });
}
