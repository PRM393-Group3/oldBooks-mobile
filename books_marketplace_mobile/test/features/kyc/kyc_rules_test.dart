import 'package:books_marketplace_mobile/features/kyc/domain/kyc_models.dart';
import 'package:books_marketplace_mobile/features/kyc/domain/kyc_rules.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 10, 27);

KycState _state(KycStatus s, {bool canSubmit = true}) =>
    KycState(status: s, canSubmit: canSubmit);

void main() {
  test('isValidIdNumber: đúng 12 chữ số', () {
    expect(isValidIdNumber('012345678901'), isTrue);
    expect(isValidIdNumber(' 012345678901 '), isTrue);
    expect(isValidIdNumber('01234567890'), isFalse);
    expect(isValidIdNumber('0123456789012'), isFalse);
    expect(isValidIdNumber('01234567890a'), isFalse);
  });

  test('parseVnDate', () {
    expect(parseVnDate('05/03/1999', now: _now), DateTime.utc(1999, 3, 5));
    expect(parseVnDate('5-3-1999', now: _now), DateTime.utc(1999, 3, 5));
    expect(parseVnDate('29/02/2000', now: _now), DateTime.utc(2000, 2, 29));
    expect(parseVnDate('29/02/2001', now: _now), isNull);
    expect(parseVnDate('27/10/2026', now: _now), DateTime.utc(2026, 10, 27));
    expect(parseVnDate('28/10/2026', now: _now), isNull);
    expect(parseVnDate('01/01/1890', now: _now), isNull);
    expect(parseVnDate('', now: _now), isNull);
    expect(parseVnDate(null, now: _now), isNull);
  });

  test('định dạng ngày', () {
    expect(formatVnDate(DateTime.utc(1999, 3, 5)), '05/03/1999');
    expect(toApiDate(DateTime.utc(1999, 3, 5)), '1999-03-05');
  });

  test('isAtLeastAge tính đúng ngày sinh nhật', () {
    // Sinh 27/10/2008: tròn 18 vào đúng ngày 27/10/2026.
    expect(isAtLeastAge(DateTime.utc(2008, 10, 27), 18, now: _now), isTrue);
    expect(isAtLeastAge(DateTime.utc(2008, 10, 28), 18, now: _now), isFalse);
    expect(isAtLeastAge(DateTime.utc(2000, 1, 1), 18, now: _now), isTrue);
    expect(isAtLeastAge(DateTime.utc(2000, 1, 1), 30, now: _now), isFalse);
  });

  test('checkKycFields', () {
    final ok = checkKycFields(
      fullName: 'Nguyễn Văn An',
      idNumber: '012345678901',
      dob: '05/03/1999',
      minAge: 18,
      now: _now,
    );
    expect(ok.ok, isTrue);

    final bad = checkKycFields(
      fullName: 'A',
      idNumber: '123',
      dob: '05/03/2015',
      minAge: 18,
      now: _now,
    );
    expect(bad.nameInvalid, isTrue);
    expect(bad.idInvalid, isTrue);
    expect(bad.dob, KycDobProblem.underage);

    expect(
      checkKycFields(
        fullName: 'An Bình',
        idNumber: '012345678901',
        dob: 'xx',
        minAge: 18,
        now: _now,
      ).dob,
      KycDobProblem.invalid,
    );
  });

  group('kycUiPhase (trạng thái -> giao diện)', () {
    test('NONE', () {
      expect(kycUiPhase(_state(KycStatus.none)), KycUiPhase.notStarted);
      expect(
        kycUiPhase(_state(KycStatus.none, canSubmit: false)),
        KycUiPhase.blocked,
      );
    });
    test('PENDING_REVIEW và APPROVED không cho gửi lại', () {
      expect(kycUiPhase(_state(KycStatus.pendingReview)), KycUiPhase.pending);
      expect(kycUiPhase(_state(KycStatus.approved)), KycUiPhase.verified);
    });
    test('REJECTED: gửi lại được hay đang bị giới hạn', () {
      expect(
        kycUiPhase(_state(KycStatus.rejected)),
        KycUiPhase.rejectedCanRetry,
      );
      expect(
        kycUiPhase(_state(KycStatus.rejected, canSubmit: false)),
        KycUiPhase.blocked,
      );
    });
    test('REVOKED', () {
      expect(kycUiPhase(_state(KycStatus.revoked)), KycUiPhase.revoked);
      expect(
        kycUiPhase(_state(KycStatus.revoked, canSubmit: false)),
        KycUiPhase.blocked,
      );
    });
  });
}
