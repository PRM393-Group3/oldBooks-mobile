import 'package:dio/dio.dart';

import 'api_error.dart';

/// Bọc [Dio] để bóc envelope `{ success, data, traceId }` và ném [ApiError].
///
/// Dio gốc dùng `validateStatus` mặc định (ném lỗi khi 4xx/5xx) để
/// interceptor xác thực bắt được 401 và tự refresh token.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic data) parse,
  }) => _send('GET', path, query: query, parse: parse);

  /// GET có điều kiện (`If-None-Match`). `notModified` là `304`: dùng bản đã
  /// lưu. Ngược lại trả dữ liệu mới cùng `ETag` của response.
  Future<({T? data, String? etag, bool notModified})> getConditional<T>(
    String path, {
    String? etag,
    required T Function(dynamic data) parse,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        path,
        options: Options(
          headers: {'If-None-Match': ?etag},
          validateStatus: (s) => s != null && (s < 300 || s == 304),
        ),
      );
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
    if (response.statusCode == 304) {
      return (data: null, etag: etag, notModified: true);
    }
    final json = response.data;
    if (json is Map && json['success'] == true) {
      return (
        data: parse(json['data']),
        etag: response.headers.value('etag'),
        notModified: false,
      );
    }
    throw ApiError.fromBody(
      response.statusCode ?? 0,
      json is Map ? json : const {},
    );
  }

  /// GET trả cả `data` lẫn `meta` (phân trang `page` hoặc `cursor`).
  Future<T> getWithMeta<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic data, Map<dynamic, dynamic> meta) parse,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(path, queryParameters: query);
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
    final json = response.data;
    if (json is Map && json['success'] == true) {
      final meta = json['meta'];
      return parse(json['data'], meta is Map ? meta : const {});
    }
    throw ApiError.fromBody(
      response.statusCode ?? 0,
      json is Map ? json : const {},
    );
  }

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    required T Function(dynamic data) parse,
  }) => _send('POST', path, body: body, headers: headers, parse: parse);

  Future<T> put<T>(
    String path, {
    Object? body,
    required T Function(dynamic data) parse,
  }) => _send('PUT', path, body: body, parse: parse);

  Future<T> patch<T>(
    String path, {
    Object? body,
    required T Function(dynamic data) parse,
  }) => _send('PATCH', path, body: body, parse: parse);

  /// Endpoint trả `204 No Content`.
  Future<void> postNoContent(String path, {Object? body}) =>
      _send<void>('POST', path, body: body);

  Future<void> deleteNoContent(String path) => _send<void>('DELETE', path);

  Future<T> _send<T>(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic data)? parse,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method, headers: headers),
      );
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }

    if (parse == null) return null as T;
    final json = response.data;
    if (json is Map && json['success'] == true) return parse(json['data']);
    throw ApiError.fromBody(
      response.statusCode ?? 0,
      json is Map ? json : const {},
    );
  }
}
