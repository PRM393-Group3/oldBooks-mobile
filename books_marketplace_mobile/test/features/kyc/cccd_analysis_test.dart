import 'package:books_marketplace_mobile/features/kyc/domain/cccd_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 10, 27);

void main() {
  group('parseCccd', () {
    test('đọc đủ ba dòng', () {
      final f = parseCccd(
        'FULL_NAME: NGUYỄN VĂN AN\nID_NUMBER: 012345678901\nDATE_OF_BIRTH: 05/03/1999',
        now: _now,
      )!;
      expect(f.fullName, 'NGUYỄN VĂN AN');
      expect(f.idNumber, '012345678901');
      expect(f.dateOfBirth, DateTime.utc(1999, 3, 5));
    });

    test('chịu chữ thừa, in đậm markdown và khoảng trắng trong số', () {
      final f = parseCccd(
        'Sure! Here is what I read:\n**FULL_NAME:** Trần Thị Bình\n'
        '- ID_NUMBER: 0123 4567 8901\n* DATE_OF_BIRTH: 1-2-2000\nHope it helps.',
        now: _now,
      )!;
      expect(f.fullName, 'Trần Thị Bình');
      expect(f.idNumber, '012345678901');
      expect(f.dateOfBirth, DateTime.utc(2000, 2, 1));
    });

    test('UNKNOWN và giá trị rỗng thành null', () {
      final f = parseCccd(
        'FULL_NAME: UNKNOWN\nID_NUMBER: 012345678901\nDATE_OF_BIRTH: n/a',
        now: _now,
      )!;
      expect(f.fullName, isNull);
      expect(f.idNumber, '012345678901');
      expect(f.dateOfBirth, isNull);
    });

    test('số CCCD sai độ dài bị bỏ', () {
      expect(
        parseCccd(
          'ID_NUMBER: 12345678901\nFULL_NAME: An Bình',
          now: _now,
        )!.idNumber,
        isNull,
      );
      expect(
        parseCccd(
          'ID_NUMBER: 1234567890123\nFULL_NAME: An Bình',
          now: _now,
        )!.idNumber,
        isNull,
      );
    });

    test('ngày sinh không có thật, ở tương lai hoặc quá cổ bị bỏ', () {
      for (final d in ['31/02/1999', '01/01/2030', '01/01/1850', 'abc']) {
        final f = parseCccd(
          'FULL_NAME: An Bình\nDATE_OF_BIRTH: $d',
          now: _now,
        )!;
        expect(f.dateOfBirth, isNull, reason: d);
      }
    });

    test('họ tên có chữ số bị bỏ', () {
      final f = parseCccd(
        'FULL_NAME: NGUYEN 123\nID_NUMBER: 012345678901',
        now: _now,
      )!;
      expect(f.fullName, isNull);
    });

    test('trả null khi rỗng hoặc không đọc được trường nào', () {
      expect(parseCccd('', now: _now), isNull);
      expect(parseCccd('I cannot read this image.', now: _now), isNull);
      expect(
        parseCccd(
          'FULL_NAME: UNKNOWN\nID_NUMBER: UNKNOWN\nDATE_OF_BIRTH: UNKNOWN',
          now: _now,
        ),
        isNull,
      );
    });
  });

  group('previewCccd (đang sinh dần)', () {
    test('dòng chưa xuống dòng chưa được tính, trừ khi đã xong', () {
      const partial = 'FULL_NAME: NGUYỄN VĂN AN\nID_NUMBER: 0123456789';
      expect(previewCccd(partial, now: _now).fullName, 'NGUYỄN VĂN AN');
      expect(previewCccd(partial, now: _now).idNumber, isNull);

      const full = 'FULL_NAME: NGUYỄN VĂN AN\nID_NUMBER: 012345678901';
      expect(previewCccd(full, now: _now).idNumber, isNull);
      expect(previewCccd(full, done: true, now: _now).idNumber, '012345678901');
    });
  });
}
