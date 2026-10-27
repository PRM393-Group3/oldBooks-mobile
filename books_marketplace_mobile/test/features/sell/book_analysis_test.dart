import 'package:books_marketplace_mobile/features/sell/ai/book_analysis.dart';
import 'package:books_marketplace_mobile/features/sell/domain/sell_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('đọc đúng hai dòng chuẩn', () {
    final r = parseBookAnalysis(
      'CONDITION: FAIR\nDESCRIPTION: Bìa hơi cong, gáy còn chắc, vài trang ố nhẹ.',
    )!;
    expect(r.condition, SellCondition.fair);
    expect(r.description, 'Bìa hơi cong, gáy còn chắc, vài trang ố nhẹ.');
  });

  test('chịu được chữ thường và có dấu ngoặc kép', () {
    final r = parseBookAnalysis(
      'condition: good\ndescription: "Sách sạch, bìa còn đẹp."',
    )!;
    expect(r.condition, SellCondition.good);
    expect(r.description, 'Sách sạch, bìa còn đẹp.');
  });

  test('thiếu mô tả thì dùng câu mặc định', () {
    final r = parseBookAnalysis('CONDITION: WORN')!;
    expect(r.condition, SellCondition.worn);
    expect(r.description, isNotEmpty);
  });

  test('chỉ có mã trần vẫn nhận', () {
    expect(parseBookAnalysis('NEW')!.condition, SellCondition.isNew);
  });

  test('không có mã hợp lệ thì null', () {
    expect(parseBookAnalysis('I cannot see the book'), isNull);
    expect(parseBookAnalysis('   '), isNull);
  });

  group('đủ thông tin sách', () {
    const full =
        'TITLE: Dế Mèn phiêu lưu ký\nAUTHOR: Tô Hoài\nPUBLISHER: Kim Đồng\n'
        'YEAR: 2019\nCONDITION: GOOD\nDEFECTS: Góc bìa hơi cong\n'
        'DESCRIPTION: Bìa còn đẹp, gáy chắc.';

    test('đọc đủ các trường', () {
      final r = parseBookAnalysis(full)!;
      expect(r.title, 'Dế Mèn phiêu lưu ký');
      expect(r.author, 'Tô Hoài');
      expect(r.publisher, 'Kim Đồng');
      expect(r.year, 2019);
      expect(r.condition, SellCondition.good);
      expect(r.defects, 'Góc bìa hơi cong');
      expect(r.description, 'Bìa còn đẹp, gáy chắc.');
    });

    test('UNKNOWN và NONE thành null', () {
      final r = parseBookAnalysis(
        'TITLE: UNKNOWN\nAUTHOR: unknown\nPUBLISHER: N/A\nYEAR: UNKNOWN\n'
        'CONDITION: NEW\nDEFECTS: NONE\nDESCRIPTION: Sách như mới, sạch sẽ.',
      )!;
      expect(r.title, isNull);
      expect(r.author, isNull);
      expect(r.publisher, isNull);
      expect(r.year, isNull);
      expect(r.defects, isNull);
    });

    test('năm vô lý bị bỏ', () {
      expect(parseBookAnalysis('YEAR: 3050\nCONDITION: GOOD')!.year, isNull);
    });

    test('tên sách chứa "New" không bị nhận là tình trạng khi thiếu mã', () {
      final r = parseBookAnalysis('TITLE: The New Earth\nSách tốt, bìa sạch.')!;
      expect(r.condition, SellCondition.good);
      expect(r.title, 'The New Earth');
    });

    test('xem trước chỉ hiện dòng đã viết xong', () {
      final p = previewBookAnalysis('TITLE: Dế Mèn\nAUTHOR: Tô Ho');
      expect(p.title, 'Dế Mèn');
      expect(p.author, isNull);
      expect(previewBookAnalysis('TITLE: ').isEmpty, isTrue);
    });

    test('xem trước hiện dần mô tả khi đang sinh', () {
      final p = previewBookAnalysis('CONDITION: FAIR\nDESCRIPTION: Bìa cô');
      expect(p.condition, SellCondition.fair);
      expect(p.description, 'Bìa cô');
    });
  });

  vietnameseTests();
}

void vietnameseTests() {
  group('trả lời tiếng Việt không theo định dạng', () {
    test('"còn tốt" là GOOD, dùng câu trả lời làm mô tả', () {
      final r = parseBookAnalysis('Sách còn khá tốt, bìa sạch.')!;
      expect(r.condition, SellCondition.good);
      expect(r.description, 'Sách còn khá tốt, bìa sạch.');
    });

    test('dấu hiệu hư hại nặng hơn thắng', () {
      expect(
        parseBookAnalysis('Bìa bị rách, nhiều trang ố vàng.')!.condition,
        SellCondition.worn,
      );
      expect(
        parseBookAnalysis('Sách tốt nhưng các trang hơi ố.')!.condition,
        SellCondition.fair,
      );
    });

    test('"số" không bị nhận nhầm là "ố"', () {
      expect(parseBookAnalysis('Đây là số 5 của bộ truyện.'), isNull);
    });

    test('"như mới" là NEW', () {
      expect(
        parseBookAnalysis('Sách như mới.')!.condition,
        SellCondition.isNew,
      );
    });
  });
}
