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
}
