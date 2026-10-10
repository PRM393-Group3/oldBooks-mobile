import 'package:dio/dio.dart';

/// Mã lỗi backend trả về trong `error.code`, cộng vài mã do client tự sinh.
abstract final class ApiErrorCode {
  static const validationFailed = 'VALIDATION_FAILED';
  static const avatarInvalid = 'PROFILE_AVATAR_INVALID';
  static const currentPasswordIncorrect = 'AUTH_CURRENT_PASSWORD_INCORRECT';
  static const passwordUnchanged = 'AUTH_PASSWORD_UNCHANGED';
  static const unsupportedFile = 'STORAGE_UNSUPPORTED_FILE';
  static const unauthorized = 'AUTH_UNAUTHORIZED';
  static const invalidCredentials = 'AUTH_INVALID_CREDENTIALS';
  static const userNotFound = 'USER_NOT_FOUND';
  static const internal = 'INTERNAL_ERROR';
  static const emailTaken = 'AUTH_EMAIL_TAKEN';

  /// Quên mật khẩu/đổi số với tài khoản tạo trước khi bật OTP email.
  static const emailRequired = 'AUTH_EMAIL_REQUIRED';
  static const accountDisabled = 'ACCOUNT_DISABLED';
  static const phoneTaken = 'AUTH_PHONE_TAKEN';
  static const addressNotFound = 'ADDRESS_NOT_FOUND';
  static const deviceNotFound = 'DEVICE_NOT_FOUND';
  static const accountDeletionBlocked = 'ACCOUNT_DELETION_BLOCKED';
  static const userRoleNotAllowed = 'USER_ROLE_NOT_ALLOWED';
  static const invalidRefreshToken = 'AUTH_INVALID_REFRESH_TOKEN';
  static const refreshTokenExpired = 'AUTH_REFRESH_TOKEN_EXPIRED';
  static const refreshTokenReused = 'AUTH_REFRESH_TOKEN_REUSED';
  static const listingIncomplete = 'LISTING_INCOMPLETE';
  static const listingImageInvalid = 'LISTING_IMAGE_INVALID';
  static const listingPhotoInvalid = 'LISTING_PHOTO_INVALID';
  static const categoryInactive = 'CATEGORY_INACTIVE';
  static const listingNotFound = 'LISTING_NOT_FOUND';
  static const listingInvalidState = 'LISTING_INVALID_STATE';
  static const listingSubmissionLimit = 'LISTING_SUBMISSION_LIMIT_REACHED';
  static const listingConcurrentUpdate = 'LISTING_CONCURRENT_UPDATE';
  static const listingAlreadyClaimed = 'LISTING_ALREADY_CLAIMED';
  static const claimRequired = 'INSPECTION_CLAIM_REQUIRED';
  static const categoryNotFound = 'CATEGORY_NOT_FOUND';
  static const notificationNotFound = 'NOTIFICATION_NOT_FOUND';

  // Mã lỗi theo BE-SRS v1.1, mục 7.
  static const validationError = 'VALIDATION_ERROR';
  static const unauthenticated = 'UNAUTHENTICATED';
  static const forbidden = 'FORBIDDEN';
  static const accountLocked = 'ACCOUNT_LOCKED';
  static const notFound = 'NOT_FOUND';
  static const invalidState = 'INVALID_STATE';
  static const idempotencyConflict = 'IDEMPOTENCY_CONFLICT';
  static const idempotencyInProgress = 'IDEMPOTENCY_IN_PROGRESS';
  static const topupOutOfRange = 'TOPUP_AMOUNT_OUT_OF_RANGE';
  static const paymentGatewayUnavailable = 'PAYMENT_GATEWAY_UNAVAILABLE';
  static const paymentProviderUnknown = 'PAYMENT_PROVIDER_UNKNOWN';
  static const orderNotFound = 'ORDER_NOT_FOUND';
  static const orderOwnListing = 'ORDER_OWN_LISTING';
  static const cartOwnListing = 'CART_OWN_LISTING';
  static const cartFull = 'CART_FULL';
  static const complaintNotFound = 'COMPLAINT_NOT_FOUND';
  static const complaintAttachmentInvalid = 'COMPLAINT_ATTACHMENT_INVALID';
  static const topupNotFound = 'TOPUP_NOT_FOUND';
  static const withdrawalNotFound = 'WITHDRAWAL_NOT_FOUND';
  static const bankAccountNotFound = 'BANK_ACCOUNT_NOT_FOUND';
  static const bankAccountLimit = 'BANK_ACCOUNT_LIMIT_REACHED';
  static const bankAccountDuplicate = 'BANK_ACCOUNT_DUPLICATE';
  static const listingNotAvailable = 'LISTING_NOT_AVAILABLE';
  static const insufficientBalance = 'INSUFFICIENT_BALANCE';
  static const otpInvalid = 'OTP_INVALID';
  static const otpExpired = 'OTP_EXPIRED';
  static const auctionNotRegistered = 'AUCTION_NOT_REGISTERED';
  static const auctionRegistrationClosed = 'AUCTION_REGISTRATION_CLOSED';
  static const auctionSellerCannotBid = 'AUCTION_SELLER_CANNOT_BID';
  static const bidTooLow = 'BID_TOO_LOW';
  static const alreadyLeading = 'ALREADY_LEADING';
  static const auctionEnded = 'AUCTION_ENDED';
  static const auctionNotLive = 'AUCTION_NOT_LIVE';
  static const buyNowUnavailable = 'BUY_NOW_UNAVAILABLE';
  static const complaintWindowClosed = 'COMPLAINT_WINDOW_CLOSED';
  static const withdrawBelowMinimum = 'WITHDRAW_BELOW_MINIMUM';
  static const rateLimited = 'RATE_LIMITED';
  static const upstreamError = 'UPSTREAM_ERROR';
  static const serviceUnavailable = 'SERVICE_UNAVAILABLE';

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
    this.detailMessages = const [],
    this.retryAfter,
  });

  /// Lỗi mất kết nối, hết thời gian chờ.
  const ApiError.network() : this(status: 0, code: ApiErrorCode.network);

  const ApiError.uploadFailed()
    : this(status: 0, code: ApiErrorCode.uploadFailed);

  factory ApiError.fromBody(
    int status,
    Map<dynamic, dynamic> body, {
    Duration? retryAfter,
  }) {
    final error = body['error'];
    final details = error is Map ? error['details'] : null;
    return ApiError(
      status: status,
      retryAfter: retryAfter,
      code:
          (error is Map ? error['code'] : null)?.toString() ??
          ApiErrorCode.unknown,
      message: (error is Map ? error['message'] : null)?.toString() ?? '',
      traceId:
          body['traceId']?.toString() ??
          (error is Map ? error['request_id']?.toString() : null) ??
          '',
      detailMessages: [
        if (details is List)
          for (final d in details)
            if (d is Map && (d['message'] ?? '').toString().isNotEmpty)
              d['message'].toString(),
      ],
      fieldErrors: {
        if (details is List)
          for (final d in details)
            if (d is Map && d['field'] != null)
              d['field'].toString(): (d['message'] ?? '').toString(),
        // BE-SRS: details có thể là object { trường: thông điệp }.
        if (details is Map)
          for (final e in details.entries)
            if (e.value is String) e.key.toString(): e.value as String,
      },
    );
  }

  /// Chuyển lỗi của Dio (4xx/5xx, mất mạng, timeout) sang [ApiError].
  factory ApiError.fromDio(DioException e) {
    final response = e.response;
    final data = response?.data;
    if (response != null) {
      final retryAfter = _parseRetryAfter(
        response.headers.value('retry-after'),
      );
      if (data is Map && (data['success'] == false || data['error'] is Map)) {
        return ApiError.fromBody(
          response.statusCode ?? 0,
          data,
          retryAfter: retryAfter,
        );
      }
      return ApiError(
        status: response.statusCode ?? 0,
        retryAfter: retryAfter,
        code: (response.statusCode ?? 0) >= 500
            ? ApiErrorCode.internal
            : ApiErrorCode.unknown,
      );
    }
    return const ApiError.network();
  }

  /// Header `Retry-After` (giây). Chỉ có với `429` và khóa đăng nhập tạm.
  static Duration? _parseRetryAfter(String? raw) {
    final seconds = int.tryParse(raw?.trim() ?? '');
    return seconds == null || seconds < 0 ? null : Duration(seconds: seconds);
  }

  final int status;
  final String code;
  final String message;
  final String traceId;

  /// Số tiền trong `details` dạng `{field, message: "<số>"}` (ví dụ `required`,
  /// `available`, `min_amount` của `INSUFFICIENT_BALANCE`/`WITHDRAW_BELOW_MINIMUM`).
  int? detailAmount(String field) => int.tryParse(fieldErrors[field] ?? '');

  /// Mọi `details[].message`, theo thứ tự. Với `ACCOUNT_DELETION_BLOCKED` đây
  /// là danh sách lý do (một lý do một phần tử, không gắn với trường nào).
  final List<String> detailMessages;

  /// Thời gian chờ server yêu cầu trước khi thử lại, nếu có.
  final Duration? retryAfter;

  /// Tên trường JSON (camelCase) → thông điệp, chỉ có khi `VALIDATION_FAILED`.
  final Map<String, String> fieldErrors;

  /// `401 UNAUTHENTICATED` kèm `details[{field: token, message: expired}]`: access
  /// token hết hạn, refresh được. Không có details nghĩa là token sai/thiếu.
  bool get isAccessTokenExpired =>
      code == ApiErrorCode.unauthenticated && fieldErrors['token'] == 'expired';

  /// Phiên đăng nhập không còn dùng được, cần về màn hình đăng nhập.
  bool get isSessionLost =>
      code == ApiErrorCode.unauthorized ||
      (code == ApiErrorCode.unauthenticated && !isAccessTokenExpired) ||
      code == ApiErrorCode.invalidRefreshToken ||
      code == ApiErrorCode.refreshTokenExpired ||
      code == ApiErrorCode.refreshTokenReused ||
      code == ApiErrorCode.userNotFound;

  /// Khóa đăng nhập tạm do nhập sai nhiều lần (có `Retry-After`). Không có
  /// header nghĩa là admin đã khóa tài khoản.
  bool get isTemporaryLock =>
      code == ApiErrorCode.accountLocked && retryAfter != null;

  /// Trạng thái tin đã đổi ở nơi khác: cần tải lại tin rồi cập nhật giao diện.
  bool get needsReload =>
      code == ApiErrorCode.listingInvalidState ||
      code == ApiErrorCode.invalidState ||
      code == ApiErrorCode.listingNotAvailable ||
      code == ApiErrorCode.listingConcurrentUpdate ||
      code == ApiErrorCode.claimRequired ||
      code == ApiErrorCode.listingAlreadyClaimed;

  @override
  String toString() => 'ApiError($status, $code, trace=$traceId)';
}
