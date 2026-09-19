import 'package:dio/dio.dart';

import '../storage/token_store.dart';
import 'api_error.dart';

/// Gắn `Authorization: Bearer` và tự refresh token khi gặp `AUTH_TOKEN_EXPIRED`.
///
/// Dùng [QueuedInterceptor] nên các lỗi 401 được xử lý lần lượt: chỉ có một
/// request refresh tại một thời điểm. Request đến sau thấy token đã đổi thì
/// gửi lại luôn, không refresh lần nữa (refreshToken chỉ dùng được một lần).
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.tokens,
    required this.refreshDio,
    required this.onSessionLost,
  });

  static const _retriedKey = 'auth_retried';

  final TokenStore tokens;

  /// Dio riêng, không gắn interceptor này: dùng để refresh và gửi lại request.
  final Dio refreshDio;

  /// Báo cho app biết phiên đã mất (refresh thất bại hoặc token không hợp lệ).
  final void Function() onSessionLost;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokens.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;

    // Tài khoản bị khóa: doc yêu cầu client đăng xuất.
    if (err.response?.statusCode == 403 &&
        ApiError.fromDio(err).code == ApiErrorCode.accountDisabled) {
      await _loseSession();
      return handler.next(err);
    }

    if (err.response?.statusCode != 401 || request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final code = ApiError.fromDio(err).code;
    if (code == ApiErrorCode.unauthorized) {
      await _loseSession();
      return handler.next(err);
    }
    if (code != ApiErrorCode.tokenExpired) return handler.next(err);

    // Một request khác đã refresh xong trong lúc request này chờ trong hàng đợi.
    final current = tokens.accessToken;
    if (current != null &&
        request.headers['Authorization'] != 'Bearer $current') {
      return _retry(request, current, handler);
    }

    final refreshToken = tokens.refreshToken;
    if (refreshToken == null) {
      await _loseSession();
      return handler.next(err);
    }

    try {
      final response = await refreshDio.post<dynamic>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = (response.data as Map)['data'] as Map;
      await tokens.save(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
    } on DioException catch (e) {
      // Mọi 401 từ /auth/refresh nghĩa là phải đăng nhập lại. Lỗi mạng thì giữ
      // phiên để người dùng thử lại.
      if (e.response?.statusCode == 401) {
        await _loseSession();
        return handler.next(err);
      }
      return handler.next(e);
    }

    return _retry(request, tokens.accessToken!, handler);
  }

  Future<void> _retry(
    RequestOptions request,
    String token,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final response = await refreshDio.fetch<dynamic>(
        request.copyWith(
          headers: {...request.headers, 'Authorization': 'Bearer $token'},
          extra: {...request.extra, _retriedKey: true},
        ),
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<void> _loseSession() async {
    await tokens.clear();
    onSessionLost();
  }
}
