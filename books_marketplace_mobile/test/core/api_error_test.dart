import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromBody đọc code, traceId và lỗi theo trường', () {
    final e = ApiError.fromBody(400, {
      'success': false,
      'error': {
        'code': 'VALIDATION_FAILED',
        'message': 'invalid',
        'details': [
          {'field': 'phoneNumber', 'message': 'bad phone'},
        ],
      },
      'traceId': 'abc',
    });

    expect(e.status, 400);
    expect(e.code, ApiErrorCode.validationFailed);
    expect(e.traceId, 'abc');
    expect(e.fieldErrors, {'phoneNumber': 'bad phone'});
    expect(e.isSessionLost, isFalse);
  });

  test('fromBody không có details cho ra fieldErrors rỗng', () {
    final e = ApiError.fromBody(404, {
      'error': {'code': 'USER_NOT_FOUND'},
    });
    expect(e.fieldErrors, isEmpty);
    expect(e.isSessionLost, isTrue);
  });

  test('body không phải envelope cho ra mã không xác định', () {
    final e = ApiError.fromBody(400, const {});
    expect(e.code, ApiErrorCode.unknown);
  });

  test('UNAUTHENTICATED: hết hạn (có details token) thì refresh được', () {
    final expired = ApiError.fromBody(401, {
      'error': {
        'code': 'UNAUTHENTICATED',
        'details': [
          {'field': 'token', 'message': 'expired'},
        ],
      },
    });
    final bad = ApiError.fromBody(401, {
      'error': {'code': 'UNAUTHENTICATED'},
    });
    expect(expired.isAccessTokenExpired, isTrue);
    expect(expired.isSessionLost, isFalse);
    expect(bad.isAccessTokenExpired, isFalse);
    expect(bad.isSessionLost, isTrue);
  });

  test('details giữ nguyên danh sách lý do (ACCOUNT_DELETION_BLOCKED)', () {
    final e = ApiError.fromBody(409, {
      'error': {
        'code': 'ACCOUNT_DELETION_BLOCKED',
        'details': [
          {'field': 'wallet', 'message': 'Số dư ví khác 0'},
          {'field': 'orders', 'message': 'Còn đơn hàng đang xử lý'},
        ],
      },
    });
    expect(e.detailMessages, ['Số dư ví khác 0', 'Còn đơn hàng đang xử lý']);
  });

  test('Retry-After: khóa tạm khác khóa của admin', () {
    final temp = ApiError.fromBody(403, {
      'error': {'code': 'ACCOUNT_LOCKED'},
    }, retryAfter: const Duration(minutes: 15));
    final admin = ApiError.fromBody(403, {
      'error': {'code': 'ACCOUNT_LOCKED'},
    });
    expect(temp.isTemporaryLock, isTrue);
    expect(temp.retryAfter, const Duration(minutes: 15));
    expect(admin.isTemporaryLock, isFalse);
  });

  test('mã lỗi refresh là mất phiên', () {
    for (final code in [
      ApiErrorCode.invalidRefreshToken,
      ApiErrorCode.refreshTokenExpired,
      ApiErrorCode.refreshTokenReused,
    ]) {
      expect(ApiError(status: 401, code: code).isSessionLost, isTrue);
    }
  });
}
