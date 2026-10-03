import 'dart:convert';

import 'package:books_marketplace_mobile/core/util/image_picking.dart';
import 'package:books_marketplace_mobile/core/util/photo_picker.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/sell/domain/sell_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

Future<void> _openSell(WidgetTester tester) async {
  final h = Harness(UserRole.buyer);
  await h.pump(
    tester,
    overrides: [
      photoPickerProvider.overrideWithValue(
        () async => PickedImage(_png, 'png', 'image/png'),
      ),
    ],
  );
  await tapSellTab(tester);
}

Future<void> _scrollTo(WidgetTester tester, Finder f) => tester
    .scrollUntilVisible(f, 250, scrollable: find.byType(Scrollable).first);

/// Ô nhập theo gợi ý; cuộn tới khi ListView dựng nó rồi nhập.
Future<void> _type(WidgetTester tester, String hint, String text) async {
  final f = find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == hint,
  );
  await tester.scrollUntilVisible(
    f,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.enterText(f, text);
  await tester.pump();
}

void main() {
  group('luật form đăng bán', () {
    test('khoảng bước nhảy: 1% đến 10% giá khởi điểm, tối thiểu 5.000', () {
      expect(stepRange(100000), (lo: 5000, hi: 10000));
      expect(stepRange(1000000), (lo: 10000, hi: 100000));
      expect(minBuyNow(200000), 300000);
    });

    test('validateSell: bán giá cố định', () {
      expect(validateSell(const SellForm()), [
        SellError.photos,
        SellError.title,
        SellError.author,
        SellError.price,
        SellError.description,
      ]);
      const ok = SellForm(
        photos: 4,
        title: 'A',
        author: 'B',
        price: 1000,
        description: 'd',
      );
      expect(validateSell(ok), isEmpty);
      expect(validateSell(ok.copyWith(price: 999)), [SellError.price]);
    });

    test(
      'validateSell: đấu giá kiểm tra giá khởi điểm, bước nhảy, mua ngay',
      () {
        const base = SellForm(
          mode: SellMode.auction,
          photos: 4,
          title: 'A',
          author: 'B',
          description: 'd',
        );
        expect(validateSell(base.copyWith(startingPrice: 9999)), [
          SellError.startingPrice,
        ]);
        expect(validateSell(base.copyWith(startingPrice: 200000, step: 1000)), [
          SellError.step,
        ]);
        expect(
          validateSell(
            base.copyWith(startingPrice: 200000, step: 10000, buyNow: 299999),
          ),
          [SellError.buyNow],
        );
        expect(
          validateSell(
            base.copyWith(startingPrice: 200000, step: 10000, buyNow: 300000),
          ),
          isEmpty,
        );
        expect(
          validateSell(base.copyWith(startingPrice: 200000, step: 10000)),
          isEmpty,
          reason: 'mua ngay là tùy chọn',
        );
      },
    );
  });

  testWidgets('form trống: báo đủ lỗi, không tạo tin', (tester) async {
    await _openSell(tester);
    expect(find.text('Đăng bán'), findsWidgets);
    await _scrollTo(tester, find.text('Gửi duyệt'));
    await tester.tap(find.text('Gửi duyệt'));
    await tester.pumpAndSettle();
    expect(find.text('• Cần ít nhất 4 ảnh (hiện có 0)'), findsOneWidget);
    expect(find.text('• Nhập tên sách'), findsOneWidget);
    expect(find.text('• Giá bán tối thiểu 1.000 đ'), findsOneWidget);
    expect(find.text('Đã gửi duyệt'), findsNothing);
  });

  testWidgets(
    'đăng bán thường: dự tính phí 5%, gửi duyệt, hiện trong Tin của tôi',
    (tester) async {
      await _openSell(tester);
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('+ thêm'));
        await tester.pumpAndSettle();
      }
      expect(find.text('4/10 · tối thiểu 4'), findsOneWidget);

      await _type(tester, 'VD: Số đỏ', 'Mắt biếc');
      await _type(tester, 'VD: Vũ Trọng Phụng', 'Nguyễn Nhật Ánh');
      await _type(tester, 'Tối thiểu 1.000', '100000');
      await _scrollTo(tester, find.text('Dự tính'.toUpperCase()));
      expect(find.text('−5.000 ₫'), findsOneWidget);
      expect(find.text('95.000 ₫'), findsOneWidget);
      expect(find.text('25.000 ₫'), findsOneWidget);

      await _type(
        tester,
        'Năm xuất bản, NXB, ghi chú, trang bị ố…',
        'Bìa mềm, không ghi chú.',
      );
      await _scrollTo(tester, find.text('Gửi duyệt'));
      await tester.tap(find.text('Gửi duyệt'));
      await tester.pumpAndSettle();
      expect(find.text('Đã gửi duyệt'), findsOneWidget);
      expect(find.textContaining('"Mắt biếc"'), findsOneWidget);

      await tester.tap(find.text('Xem tin đăng của tôi'));
      await tester.pumpAndSettle();
      expect(find.text('Mắt biếc'), findsOneWidget);
      expect(find.text('Vừa gửi duyệt · duyệt trong 24 giờ'), findsOneWidget);
      expect(
        find.text('Admin: Ảnh bìa bị mờ, vui lòng chụp lại.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('đấu giá: hiện ghi chú kho, dự tính, nhận mã nhập kho', (
    tester,
  ) async {
    await _openSell(tester);
    await tester.tap(find.text('Đấu giá').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('gửi về kho Oldbook'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('+ thêm'));
      await tester.pumpAndSettle();
    }
    await _type(tester, 'VD: Số đỏ', 'Số đỏ');
    await _type(tester, 'VD: Vũ Trọng Phụng', 'Vũ Trọng Phụng');
    await _type(tester, '≥ 10.000', '200000');
    await _type(tester, '5.000 ₫ – 20.000 ₫', '10000');
    await _scrollTo(tester, find.text('Dự tính'.toUpperCase()));
    expect(find.text('−20.000 ₫'), findsOneWidget);
    expect(find.text('180.000 ₫'), findsOneWidget);

    await _type(tester, 'Năm xuất bản, NXB, ghi chú, trang bị ố…', 'Bản 1938');
    await _scrollTo(tester, find.text('Tạo phiên & nhận mã gửi kho'));
    await tester.tap(find.text('Tạo phiên & nhận mã gửi kho'));
    await tester.pumpAndSettle();
    expect(find.text('Đã tạo phiên đấu giá'), findsOneWidget);
    expect(find.textContaining('OB-IN-'), findsOneWidget);
  });
}
