import 'package:books_marketplace_mobile/core/widgets/app_button.dart';

import 'dart:convert';

import 'package:books_marketplace_mobile/core/util/image_picking.dart';
import 'package:books_marketplace_mobile/core/util/photo_picker.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/sell/domain/sell_rules.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

Future<Harness> _openSell(WidgetTester tester) async {
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
  return h;
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

/// Bấm "Tiếp tục" của wizard đăng bán và đợi chuyển bước.
Future<void> _next(WidgetTester tester) async {
  final b = find.widgetWithText(AppButton, 'Tiếp tục');
  await tester.ensureVisible(b);
  await tester.tap(b);
  await tester.pumpAndSettle();
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
        SellError.category,
      ]);
      const ok = SellForm(
        photos: 4,
        title: 'A',
        author: 'B',
        price: 1000,
        description: 'd',
        categoryId: 'c0',
      );
      expect(validateSell(ok), isEmpty);
      expect(validateSell(ok.copyWith(price: 999)), [SellError.price]);
      expect(validateSell(ok.copyWith(isbn: '978-0-306-40615-7')), isEmpty);
      expect(validateSell(ok.copyWith(isbn: '123')), [SellError.isbn]);
      expect(validateSell(ok.copyWith(publishYear: '1200')), [SellError.year]);
      expect(validateSell(ok.copyWith(publishYear: '2018')), isEmpty);
    });

    test('validateSell: bán bộ sách kiểm tra số tập và ảnh từng tập', () {
      const ok = SellForm(
        kind: ListingKind.set,
        photos: 1,
        volumeCount: 3,
        title: 'A',
        author: 'B',
        price: 1000,
        description: 'd',
        categoryId: 'c0',
      );
      expect(validateSell(ok), isEmpty);
      expect(validateSell(ok.copyWith(volumeCount: 1)), [SellError.volumes]);
      expect(validateSell(ok.copyWith(volumeCount: 31)), [SellError.volumes]);
      expect(validateSell(ok.copyWith(volumesWithoutPhotos: 1)), [
        SellError.volumePhotos,
      ]);
    });

    test(
      'validateSell: đấu giá kiểm tra giá khởi điểm, bước nhảy, mua ngay',
      () {
        const base = SellForm(
          mode: SellMode.auction,
          photos: 4,
          title: 'A',
          author: 'B',
          categoryId: 'c1',
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
    final h = await _openSell(tester);
    expect(find.text('Đăng bán'), findsWidgets);
    await _next(tester); // Hình thức → Sách
    await _next(tester); // Sách còn thiếu: ở lại và báo lỗi
    // Các dòng lỗi nằm cuối bước; cuộn tới để ListView dựng chúng.
    await _scrollTo(tester, find.text('• Chọn thể loại.'));
    expect(find.text('• Cần ít nhất 4 ảnh (hiện có 0)'), findsOneWidget);
    expect(find.text('• Nhập tên sách'), findsOneWidget);
    expect(find.text('• Chọn thể loại.'), findsOneWidget);
    expect(find.text('Đã gửi duyệt'), findsNothing);
    expect(
      h.listings.calls,
      isNot(contains('create')),
      reason: 'không tạo tin',
    );
  });

  testWidgets(
    'đăng bán thường: dự tính phí 5%, gửi duyệt, hiện trong Tin của tôi',
    (tester) async {
      final h = await _openSell(tester);
      await _next(tester); // Hình thức (giá cố định) → Sách
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('+ thêm'));
        await tester.pumpAndSettle();
      }
      expect(find.text('4/10 · tối thiểu 4'), findsOneWidget);

      await _type(tester, 'VD: Số đỏ', 'Mắt biếc');
      await _type(tester, 'VD: Vũ Trọng Phụng', 'Nguyễn Nhật Ánh');
      await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Văn học'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Văn học'));
      await tester.pump();
      await _type(
        tester,
        'Năm xuất bản, NXB, ghi chú, trang bị ố…',
        'Bìa mềm, không ghi chú.',
      );
      await _next(tester); // Sách → Giá
      await _type(tester, 'Tối thiểu 1.000', '100000');
      await _scrollTo(tester, find.text('Dự tính'.toUpperCase()));
      expect(find.text('−5.000 ₫'), findsOneWidget);
      expect(find.text('95.000 ₫'), findsOneWidget);
      expect(find.text('30.000 ₫'), findsOneWidget);
      await _next(tester); // Giá → Xem lại

      final submit = find.widgetWithText(AppButton, 'Gửi duyệt');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Đã gửi duyệt'), findsOneWidget);
      expect(find.textContaining('"Mắt biếc"'), findsOneWidget);

      // Đã đi đủ các bước của backend theo thứ tự: tạo, tải ảnh, đặt ảnh, gửi duyệt.
      expect(
        h.listings.calls
            .where((c) => !c.startsWith('mine') && !c.startsWith('search'))
            .toList(),
        [
          'create',
          'upload:mine-1:1',
          'upload:mine-1:1',
          'upload:mine-1:1',
          'upload:mine-1:1',
          'photos:mine-1:4',
          'submit:mine-1',
        ],
      );
      expect(h.listings.items.first.status.api, 'PENDING_REVIEW');

      await tester.tap(find.text('Xem tin đăng của tôi'));
      await tester.pumpAndSettle();
      expect(find.text('Mắt biếc'), findsOneWidget);
      expect(find.text('Chờ duyệt'), findsWidgets);
      expect(
        find.text('Đang chờ duyệt, thường trong 24 giờ. Chưa sửa được.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'đấu giá: hiện ghi chú kho, dự tính, tạo phiên nhận mã nhập kho',
    (tester) async {
      final h = await _openSell(tester);
      await tester.tap(find.text('Đấu giá').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('gửi về kho Oldbook'), findsOneWidget);
      await _next(tester); // Hình thức → Sách

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('+ thêm'));
        await tester.pumpAndSettle();
      }
      await _type(tester, 'VD: Số đỏ', 'Số đỏ');
      await _type(tester, 'VD: Vũ Trọng Phụng', 'Vũ Trọng Phụng');
      await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Văn học'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Văn học'));
      await tester.pumpAndSettle();
      await _type(
        tester,
        'Năm xuất bản, NXB, ghi chú, trang bị ố…',
        'Bản 1938',
      );
      await _next(tester); // Sách → Giá
      await _type(tester, '≥ 10.000', '200000');
      await _type(tester, '5.000 ₫ – 20.000 ₫', '10000');
      await _scrollTo(tester, find.text('Dự tính'.toUpperCase()));
      expect(find.text('−20.000 ₫'), findsWidgets);
      expect(find.text('180.000 ₫'), findsWidgets);
      await _next(tester); // Giá → Xem lại
      await _scrollTo(tester, find.text('Tạo phiên & nhận mã gửi kho'));
      // Form đấu giá dài, nút có thể nằm dưới thanh điều hướng: bấm trực tiếp.
      tester
          .widget<AppButton>(
            find.widgetWithText(AppButton, 'Tạo phiên & nhận mã gửi kho'),
          )
          .onPressed!();
      await tester.pumpAndSettle();
      expect(find.text('Đã tạo phiên đấu giá'), findsOneWidget);
      expect(h.auctions.calls.last, 'create Số đỏ');
      expect(find.text('OB7K2M9XQ4'), findsOneWidget);
    },
  );
}
