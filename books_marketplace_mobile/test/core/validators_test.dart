import 'package:books_marketplace_mobile/core/l10n/app_localizations_vi.dart';
import 'package:books_marketplace_mobile/core/validation/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final v = Validators(AppLocalizationsVi());

  group('phoneOptional', () {
    test('rỗng là hợp lệ (xóa số)', () {
      expect(v.phoneOptional(''), isNull);
      expect(v.phoneOptional(null), isNull);
    });
    test('chấp nhận 0xxxxxxxxx, 0xxxxxxxxxx và +84', () {
      expect(v.phoneOptional('0901234567'), isNull);
      expect(v.phoneOptional('+84901234567'), isNull);
    });
    test('từ chối số sai định dạng', () {
      expect(v.phoneOptional('12345'), isNotNull);
      expect(v.phoneOptional('090123456'), isNotNull);
      expect(v.phoneOptional('09012345678'), isNotNull);
      expect(v.phoneOptional('0201234567'), isNotNull);
      expect(v.phoneOptional('84901234567'), isNotNull);
      expect(v.phoneOptional('0901 234 567'), isNotNull);
    });
  });

  group('mật khẩu', () {
    test('độ dài 8 đến 72', () {
      expect(v.newPassword('1234567'), isNotNull);
      expect(v.newPassword('12345678'), isNull);
      expect(v.newPassword('a' * 72), isNull);
      expect(v.newPassword('a' * 73), isNotNull);
    });
    test('mật khẩu mới phải khác mật khẩu hiện tại', () {
      final check = v.newPasswordDifferentFrom(() => 'Passw0rd!');
      expect(check('Passw0rd!'), isNotNull);
      expect(check('NewPassw0rd!'), isNull);
    });
    test('nhập lại phải khớp', () {
      final check = v.matches(() => 'abc12345');
      expect(check('abc12345'), isNull);
      expect(check('abc12346'), isNotNull);
    });
  });

  test('họ tên: không rỗng, tối đa 100 ký tự', () {
    expect(v.fullName('   '), isNotNull);
    expect(v.fullName('Nguyễn Văn A'), isNull);
    expect(v.fullName('a' * 101), isNotNull);
  });

  test('email', () {
    expect(v.email(''), isNotNull);
    expect(v.email('abc'), isNotNull);
    expect(v.email('a@b.co'), isNull);
  });

  group('registerPassword (72 byte)', () {
    test('72 ký tự ASCII hợp lệ, 73 thì không', () {
      expect(v.registerPassword('a1${'b' * 70}'), isNull);
      expect(v.registerPassword('a1${'b' * 71}'), isNotNull);
    });
    test('ký tự có dấu tính nhiều byte', () {
      // 'ế' = 3 byte: 1 + 1 + 23*3 = 71 byte hợp lệ, 24*3 = 74 byte thì không.
      expect(v.registerPassword('a1${'ế' * 23}'), isNull);
      expect(v.registerPassword('a1${'ế' * 24}'), isNotNull);
    });
  });

  group('phoneRequired', () {
    test('chỉ nhận di động Việt Nam 10 số', () {
      expect(v.phoneRequired('0912345678'), isNull);
      expect(v.phoneRequired('+84912345678'), isNull);
      expect(v.phoneRequired('0212345678'), isNotNull);
      expect(v.phoneRequired('091234567'), isNotNull);
    });
  });
}
