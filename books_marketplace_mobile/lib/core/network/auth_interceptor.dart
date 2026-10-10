import 'dart:math';

import 'package:dio/dio.dart';

import '../storage/token_store.dart';
import 'api_error.dart';
import 'token_refresher.dart';

/// Gắn `Authorization: Bearer` và tự refresh token khi access token hết hạn.
///
/// Dùng [QueuedInterceptor] nên các lỗi 401 được xử lý lần lượt: chỉ có một
/// request refresh tại một thời điểm. Request đến sau thấy token đã đổi thì
/// gửi lại luôn, không refresh lần nữa (refreshToken chỉ dùng được một lần).
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.tokens,
    required this.refreshDio,
    required this.onSessionLost,
    TokenRefresher? refresher,
  }) : refresher = refresher ?? TokenRefresher(tokens: tokens, dio: refreshDio);

  static const _retriedKey = 'auth_retried';

  final TokenStore tokens;

  /// Dio riêng, không gắn interceptor này: dùng để refresh và gửi lại request.
  final Dio refreshDio;

  /// Dùng chung với phần khởi động app để không refresh song song.
  final TokenRefresher refresher;

  /// Endpoint `/auth/*` tự xử lý lỗi xác thực của mình (đăng nhập sai, OTP,
  /// refresh); chỉ `logout` cần Bearer.
  static bool _isAuthPath(String path) =>
      path.startsWith('/auth/') && !path.startsWith('/auth/logout');

  /// Báo cho app biết phiên đã mất (refresh thất bại hoặc token không hợp lệ).
  final void Function() onSessionLost;

  static final _random = Random.secure();

  /// Mã truy vết `[A-Za-z0-9_-]`, tối đa 64 ký tự; trùng `traceId` ở response.
  static String _newCorrelationId() =>
      List.generate(32, (_) => _random.nextInt(16).toRadixString(16)).join();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Correlation-Id'] ??= _newCorrelationId();
    final token = tokens.accessToken;
    if (token != null && !_isAuthPath(options.path)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;

    if (_isAuthPath(request.path)) return handler.next(err);

    // Tài khoản bị khóa: xóa phiên, UI báo tài khoản bị khóa.
    if (err.response?.statusCode == 403 &&
        ApiError.fromDio(err).code == ApiErrorCode.accountLocked) {
      await _loseSession();
      return handler.next(err);
    }

    if (err.response?.statusCode != 401 || request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    // Chỉ `UNAUTHENTICATED` kèm details token/expired mới refresh được; token
    // sai hoặc thiếu thì phải đăng nhập lại.
    final error = ApiError.fromDio(err);
    if (error.isSessionLost) {
      await _loseSession();
      return handler.next(err);
    }
    if (!error.isAccessTokenExpired) return handler.next(err);

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
      await refresher.refresh();
    } on DioException catch (e) {
      // 401/403 từ /auth/refresh (token sai, hết hạn, bị tái sử dụng, tài khoản
      // khóa) nghĩa là phải đăng nhập lại. Lỗi mạng thì giữ phiên để thử lại.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
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
