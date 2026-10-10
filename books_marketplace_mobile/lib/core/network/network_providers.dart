import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../storage/storage_providers.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';
import 'blob_uploader.dart';
import 'session_events.dart';
import 'token_refresher.dart';

Dio _newDio() => Dio(
  BaseOptions(
    baseUrl: Env.apiRoot,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ),
);

final sessionEventsProvider = Provider<SessionEvents>((ref) {
  final events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
});

/// Dio không interceptor: dùng để refresh token và PUT thẳng lên Blob Storage
/// (bắt buộc không kèm `Authorization`).
final plainDioProvider = Provider<Dio>((ref) => _newDio());

/// Refresh token dùng chung cho interceptor và lúc khởi động app.
final tokenRefresherProvider = Provider<TokenRefresher>(
  (ref) => TokenRefresher(
    tokens: ref.watch(tokenStoreProvider),
    dio: ref.watch(plainDioProvider),
  ),
);

/// Dio gọi backend, có [AuthInterceptor].
final apiDioProvider = Provider<Dio>((ref) {
  final dio = _newDio();
  dio.interceptors.add(
    AuthInterceptor(
      tokens: ref.watch(tokenStoreProvider),
      refreshDio: ref.watch(plainDioProvider),
      onSessionLost: ref.read(sessionEventsProvider).notifyLost,
      refresher: ref.watch(tokenRefresherProvider),
    ),
  );
  return dio;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(apiDioProvider)),
);

/// Tải tệp lên Blob Storage (avatar, ảnh tin đăng).
final blobUploaderProvider = Provider<BlobUploader>(
  (ref) =>
      BlobUploader(ref.watch(apiClientProvider), ref.watch(plainDioProvider)),
);
