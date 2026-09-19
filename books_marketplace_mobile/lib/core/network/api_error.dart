import 'package:dio/dio.dart';

/// Mã lỗi backend trả về trong `error.code`, cộng vài mã do client tự sinh.
abstract final class ApiErrorCode {
  static const validationFailed = 'VALIDATION_FAILED';
  static const avatarInvalid = 'PROFILE_AVATAR_INVALID';
  static const currentPasswordIncorrect = 'AUTH_CURRENT_PASSWORD_INCORRECT';
  static const passwordUnchanged = 'AUTH_PASSWORD_UNCHANGED';
  static const unsupportedFile = 'STORAGE_UNSUPPORTED_FILE';
  static const tokenExpired = 'AUTH_TOKEN_EXPIRED';
  static const unauthorized = 'AUTH_UNAUTHORIZED';
  static const invalidCredentials = 'AUTH_INVALID_CREDENTIALS';
  static const userNotFound = 'USER_NOT_FOUND';
  static const internal = 'INTERNAL_ERROR';
  static const emailTaken = 'AUTH_EMAIL_TAKEN';
  static const accountDisabled = 'ACCOUNT_DISABLED';
  static const listingIncomplete = 'LISTING_INCOMPLETE';
  static const listingImageInvalid = 'LISTING_IMAGE_INVALID';
  static const listingNotFound = 'LISTING_NOT_FOUND';
  static const listingInvalidState = 'LISTING_INVALID_STATE';
  static const listingSubmissionLimit = 'LISTING_SUBMISSION_LIMIT_REACHED';
  static const listingConcurrentUpdate = 'LISTING_CONCURRENT_UPDATE';
  static const listingAlreadyClaimed = 'LISTING_ALREADY_CLAIMED';
  static const claimRequired = 'INSPECTION_CLAIM_REQUIRED';
  static const categoryNotFound = 'CATEGORY_NOT_FOUND';
  static const notificationNotFound = 'NOTIFICATION_NOT_FOUND';

  /// Sinh ở client.
  static const network = 'CLIENT_NETWORK_ERROR';
  static const uploadFailed = 'CLIENT_UPLOAD_FAILED';
  static const unknown = 'CLIENT_UNKNOWN_ERROR';
}

/// Lỗi đã chuẩn hóa từ envelope `{ success: false, error: {...}, traceId }`.
///
/// UI chỉ xử lý theo [code] và [fieldErrors]; [message] là tiếng Anh dành cho
/// lập trình viên, không hiển thị cho người dùng.
class ApiError implements Exception {
  const ApiError({
    required this.status,
    required this.code,
    this.message = '',
    this.traceId = '',
    this.fieldErrors = const {},
  });

  /// Lỗi mất kết nối, hết thời gian chờ.
  const ApiError.network() : this(status: 0, code: ApiErrorCode.network);

  const ApiError.uploadFailed()
    : this(status: 0, code: ApiErrorCode.uploadFailed);

  factory ApiError.fromBody(int status, Map<dynamic, dynamic> body) {
    final error = body['error'];
    final details = error is Map ? error['details'] : null;
    return ApiError(
      status: status,
      code:
          (error is Map ? error['code'] : null)?.toString() ??
          ApiErrorCode.unknown,
      message: (error is Map ? error['message'] : null)?.toString() ?? '',
      traceId: body['traceId']?.toString() ?? '',
      fieldErrors: {
        if (details is List)
          for (final d in details)
            if (d is Map && d['field'] != null)
              d['field'].toString(): (d['message'] ?? '').toString(),
      },
    );
  }

  /// Chuyển lỗi của Dio (4xx/5xx, mất mạng, timeout) sang [ApiError].
  factory ApiError.fromDio(DioException e) {
    final response = e.response;
    final data = response?.data;
    if (response != null) {
      if (data is Map && data['success'] == false) {
        return ApiError.fromBody(response.statusCode ?? 0, data);
      }
      return ApiError(
        status: response.statusCode ?? 0,
        code: (response.statusCode ?? 0) >= 500
            ? ApiErrorCode.internal
            : ApiErrorCode.unknown,
      );
    }
    return const ApiError.network();
  }

  final int status;
  final String code;
  final String message;
  final String traceId;

  /// Tên trường JSON (camelCase) → thông điệp, chỉ có khi `VALIDATION_FAILED`.
  final Map<String, String> fieldErrors;

  /// Phiên đăng nhập không còn dùng được, cần về màn hình đăng nhập.
  bool get isSessionLost =>
      code == ApiErrorCode.unauthorized || code == ApiErrorCode.userNotFound;

  /// Trạng thái tin đã đổi ở nơi khác: cần tải lại tin rồi cập nhật giao diện.
  bool get needsReload =>
      code == ApiErrorCode.listingInvalidState ||
      code == ApiErrorCode.listingConcurrentUpdate ||
      code == ApiErrorCode.claimRequired ||
      code == ApiErrorCode.listingAlreadyClaimed;

  @override
  String toString() => 'ApiError($status, $code, trace=$traceId)';
}
