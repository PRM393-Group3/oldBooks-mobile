import 'package:dio/dio.dart';

import '../storage/token_store.dart';
import '../util/server_clock.dart';

/// Gọi `POST /auth/refresh` và lưu cặp token mới.
///
/// refreshToken chỉ dùng được một lần, nên mọi nơi cần refresh (interceptor,
/// khởi động app) phải đi qua cùng một đối tượng: các lời gọi đồng thời dùng
/// chung một request thay vì tự gửi thêm và bị coi là tái sử dụng token.
class TokenRefresher {
  TokenRefresher({required this.tokens, required this.dio});

  final TokenStore tokens;

  /// Dio không interceptor, không gửi `Authorization`.
  final Dio dio;

  Future<void>? _inFlight;

  /// Ném [DioException] khi server từ chối hoặc mất mạng.
  Future<void> refresh() => _inFlight ??= _run().whenComplete(() {
    _inFlight = null;
  });

  Future<void> _run() async {
    final refreshToken = tokens.refreshToken;
    if (refreshToken == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        type: DioExceptionType.cancel,
      );
    }
    final response = await dio.post<dynamic>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = (response.data as Map)['data'] as Map;
    ServerClock.sync(DateTime.tryParse((data['serverTime'] as String?) ?? ''));
    await tokens.save(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }
}
