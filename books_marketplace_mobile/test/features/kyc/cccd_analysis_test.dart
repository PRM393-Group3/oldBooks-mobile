import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/features/kyc/domain/cccd_analysis.dart';
import 'package:books_marketplace_mobile/features/kyc/domain/kyc_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CccdFields.fromJson', () {
    test('đủ ba trường', () {
      final f = CccdFields.fromJson({
        'fullName': 'NGUYEN VAN AN',
        'idNumber': '079203001234',
        'dateOfBirth': '1999-03-05',
      });
      expect(f.fullName, 'NGUYEN VAN AN');
      expect(f.idNumber, '079203001234');
      expect(f.dateOfBirth, DateTime(1999, 3, 5));
      expect(f.isEmpty, isFalse);
    });

    test('null và thiếu trường -> rỗng', () {
      expect(
        CccdFields.fromJson({
          'fullName': null,
          'idNumber': null,
          'dateOfBirth': null,
        }).isEmpty,
        isTrue,
      );
      expect(CccdFields.fromJson(null).isEmpty, isTrue);
    });

    test('giá trị sai định dạng bị bỏ, trường tốt còn lại', () {
      final f = CccdFields.fromJson({
        'fullName': 'A1',
        'idNumber': '12345',
        'dateOfBirth': '1999-02-31',
      });
      expect(f.fullName, isNull);
      expect(f.idNumber, isNull);
      expect(f.dateOfBirth, isNull);
      final g = CccdFields.fromJson({
        'fullName': 'TRAN THI BICH',
        'idNumber': '12345',
        'dateOfBirth': '05/03/1999',
      });
      expect(g.fullName, 'TRAN THI BICH');
      expect(g.idNumber, isNull);
      expect(g.dateOfBirth, isNull);
    });
  });

  group('extractWithFallback', () {
    ApiError err(String code, [int status = 500]) =>
        ApiError(status: status, code: code);

    test('có trường -> dùng, không báo gì', () async {
      final r = await extractWithFallback(
        () async => const CccdFields(idNumber: '079203001234'),
      );
      expect(r.hasFields, isTrue);
      expect(r.notice, KycAiNotice.none);
    });

    test('đọc ra rỗng -> nhập tay, báo nothingRead', () async {
      final r = await extractWithFallback(() async => const CccdFields());
      expect(r.hasFields, isFalse);
      expect(r.fields, isNull);
      expect(r.notice, KycAiNotice.nothingRead);
    });

    for (final code in [
      ApiErrorCode.aiUnavailable,
      'KYC_AI_FAILED',
      ApiErrorCode.kycImageInvalid,
      ApiErrorCode.network,
    ]) {
      test('$code -> nhập tay, im lặng', () async {
        final r = await extractWithFallback(() async => throw err(code));
        expect(r.hasFields, isFalse);
        expect(r.notice, KycAiNotice.none);
      });
    }

    test('RATE_LIMITED -> nhập tay kèm thông báo', () async {
      final r = await extractWithFallback(
        () async => throw err(ApiErrorCode.rateLimited, 429),
      );
      expect(r.hasFields, isFalse);
      expect(r.notice, KycAiNotice.rateLimited);
    });

    test('lỗi lạ cũng không ném ra ngoài', () async {
      final r = await extractWithFallback(() async => throw StateError('x'));
      expect(r.hasFields, isFalse);
    });
  });

  group('SelfieCheck', () {
    test('parse usable=false và issues, bỏ mã lạ', () {
      final c = SelfieCheck.fromJson({
        'usable': false,
        'issues': ['NO_FACE', 'SCREEN_OR_PRINT', 'WHAT'],
      });
      expect(c.usable, isFalse);
      expect(c.issues, [SelfieIssue.noFace, SelfieIssue.screenOrPrint]);
    });

    test('usable=true', () {
      final c = SelfieCheck.fromJson({'usable': true, 'issues': []});
      expect(c.usable, isTrue);
      expect(c.issues, isEmpty);
    });

    test('dữ liệu lạ không chặn người dùng', () {
      expect(SelfieCheck.fromJson(null).usable, isTrue);
      expect(SelfieCheck.fromJson({}).usable, isTrue);
    });

    test('mọi mã backend đều có enum', () {
      for (final code in [
        'NO_FACE',
        'MULTIPLE_FACES',
        'FACE_COVERED',
        'BLURRY_OR_DARK',
        'SCREEN_OR_PRINT',
      ]) {
        expect(SelfieIssue.fromApi(code), isNotNull, reason: code);
      }
    });
  });

  group('checkSelfieWithFallback', () {
    test('kết quả được trả nguyên', () async {
      final c = await checkSelfieWithFallback(
        () async => const SelfieCheck(usable: false),
      );
      expect(c!.usable, isFalse);
    });

    for (final code in [
      ApiErrorCode.aiUnavailable,
      'KYC_AI_FAILED',
      ApiErrorCode.rateLimited,
      ApiErrorCode.network,
    ]) {
      test('$code -> bỏ qua kiểm tra (null)', () async {
        final c = await checkSelfieWithFallback(
          () async => throw ApiError(status: 500, code: code),
        );
        expect(c, isNull);
      });
    }

    test('lỗi lạ -> bỏ qua', () async {
      expect(
        await checkSelfieWithFallback(() async => throw StateError('x')),
        isNull,
      );
    });

    test('KYC_IMAGE_INVALID -> bắt chụp lại', () async {
      final c = await checkSelfieWithFallback(
        () async => throw const ApiError(
          status: 400,
          code: ApiErrorCode.kycImageInvalid,
        ),
      );
      expect(c!.usable, isFalse);
    });
  });

  test('OcrSource.claude gửi CLAUDE', () {
    const info = KycClientInfo(
      ocrSource: OcrSource.claude,
      livenessChallenges: [],
      modelVersion: 'claude',
    );
    expect(info.toJson()['ocrSource'], 'CLAUDE');
    expect(info.toJson()['modelVersion'], 'claude');
  });
}
