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

  test('AUTH_UNAUTHORIZED là mất phiên, AUTH_TOKEN_EXPIRED thì chưa', () {
    expect(
      const ApiError(
        status: 401,
        code: ApiErrorCode.unauthorized,
      ).isSessionLost,
      isTrue,
    );
    expect(
      const ApiError(
        status: 401,
        code: ApiErrorCode.tokenExpired,
      ).isSessionLost,
      isFalse,
    );
  });
}
