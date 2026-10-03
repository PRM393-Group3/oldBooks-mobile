import 'dart:convert';

import 'package:books_marketplace_mobile/core/util/image_picking.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:books_marketplace_mobile/features/orders/presentation/complaint_sheet.dart';
import 'package:books_marketplace_mobile/features/sim/application/sim_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/harness.dart';

// PNG 1x1 hợp lệ để Image.memory giải mã được.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

Future<Harness> _pumpWithBook(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  final h = Harness(UserRole.buyer);
  final book = fakeListing(
    id: 'L1',
    status: ListingStatus.onSale,
    bookInfo: const BookInfo(title: 'Sapiens', author: 'Yuval Noah Harari'),
    saleMethod: SaleMethod.fixedPrice,
    fixedPrice: const FixedPriceConfig(price: 95000, quantity: 1),
  );
  h.listings.browseItems = [book];
  h.listings.stored = book;
  await h.pump(tester, overrides: overrides);
  return h;
}

/// Từ Khám phá: mở sách, thêm vào giỏ, mở giỏ.
Future<void> _addToCartAndOpenCart(WidgetTester tester) async {
  await tester.tap(find.text('Sapiens'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Thêm vào giỏ'));
  await tester.pump();
  await tester.tap(find.text('Giỏ · 1'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('giỏ hiện món, tiền sách, phí ship, tổng và số dư ví', (
    tester,
  ) async {
    await _pumpWithBook(tester);
    await _addToCartAndOpenCart(tester);

    expect(find.text('Giỏ hàng'), findsOneWidget);
    expect(find.text('Sapiens'), findsOneWidget);
    expect(find.text('Tiền sách (1 cuốn)'), findsOneWidget);
    expect(find.text('95.000 ₫'), findsWidgets);
    expect(find.text('120.000 ₫'), findsOneWidget); // tổng thanh toán
    expect(find.text('Phí ship (mỗi đơn 25.000 ₫)'), findsOneWidget);
    expect(find.text('1.250.000 ₫'), findsOneWidget);
    expect(find.text('Đặt hàng · thanh toán bằng ví'), findsOneWidget);
  });

  testWidgets('xóa món khỏi giỏ hiện giỏ trống và khóa nút đặt hàng', (
    tester,
  ) async {
    await _pumpWithBook(tester);
    await _addToCartAndOpenCart(tester);

    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng trống.'), findsOneWidget);
    expect(find.text('Không có sách khả dụng'), findsOneWidget);
  });

  testWidgets(
    'đặt hàng: trừ ví, sheet thành công, xem đơn rồi hủy đơn hoàn tiền',
    (tester) async {
      await _pumpWithBook(tester);
      await _addToCartAndOpenCart(tester);

      await tester.tap(find.text('Đặt hàng · thanh toán bằng ví'));
      await tester.pumpAndSettle();
      expect(find.text('Đặt hàng thành công'), findsOneWidget);
      expect(find.textContaining('120.000 ₫ từ ví cho 1 đơn'), findsOneWidget);

      final container = simContainer(tester);
      expect(container.read(availableBalanceProvider), 1130000);

      await tester.tap(find.text('Xem đơn hàng'));
      await tester.pumpAndSettle();
      expect(find.text('Đơn mua'), findsOneWidget);
      expect(find.text('Chờ người bán gửi'), findsOneWidget);

      await tester.tap(find.text('Sapiens'));
      await tester.pumpAndSettle();
      expect(find.text('Chờ người bán gửi hàng'), findsOneWidget);

      await tester.tap(find.text('Hủy đơn · hoàn 120.000 ₫'));
      await tester.pumpAndSettle();
      expect(find.text('Đã hủy đơn, hoàn 120.000 ₫'), findsOneWidget);
      expect(find.text('Đơn đã hủy'), findsOneWidget);
      expect(container.read(availableBalanceProvider), 1250000);
      expect(find.text('Không có thao tác nào cần làm.'), findsOneWidget);
    },
  );

  testWidgets('thiếu số dư: hiện sheet báo thiếu và nạp đúng số còn thiếu', (
    tester,
  ) async {
    await _pumpWithBook(tester);
    await _addToCartAndOpenCart(tester);
    // Chỉ còn 100.000 khả dụng, thiếu 20.000 → gợi ý nạp tròn 50.000.
    simContainer(tester).read(simProvider.notifier).withdraw(1150000);
    await tester.pump(); // thông báo "đã gửi yêu cầu rút" xuất hiện
    // Tắt nó đi để không che nút đặt hàng.
    ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold).first),
    ).clearSnackBars();
    await tester.pumpAndSettle();
    expect(find.text('Số dư không đủ · nạp thêm'), findsOneWidget);

    await tester.tap(find.text('Số dư không đủ · nạp thêm'));
    await tester.pumpAndSettle();
    expect(find.text('Số dư không đủ'), findsOneWidget);
    expect(find.textContaining('Cần thêm 20.000 ₫'), findsOneWidget);

    await tester.tap(find.text('Nạp 50.000 ₫'));
    await tester.pumpAndSettle();
    expect(find.text('Quét mã để thanh toán'), findsOneWidget);

    await tester.tap(find.text('Mô phỏng: cổng thanh toán xác nhận'));
    await tester.pumpAndSettle();
    expect(find.text('Nạp thành công +50.000 ₫'), findsOneWidget);
    expect(simContainer(tester).read(availableBalanceProvider), 150000);
  });

  testWidgets('tab Ví: số dư, lịch sử và nạp tiền qua VietQR giả', (
    tester,
  ) async {
    await _pumpWithBook(tester);
    await tapTab(tester, 'Ví');

    expect(find.text('Ví Oldbook'), findsOneWidget);
    expect(find.text('1.250.000 ₫'), findsOneWidget);
    expect(find.text('345.000 ₫'), findsOneWidget); // đang giữ
    expect(find.text('1.595.000 ₫'), findsOneWidget); // tổng
    expect(find.text('Nạp tiền qua VietQR'), findsOneWidget);

    await tester.tap(find.text('Nạp tiền'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('500.000 ₫'));
    await tester.pump();
    await tester.tap(find.text('Tạo mã thanh toán · 500.000 ₫'));
    await tester.pumpAndSettle();
    expect(find.text('Quét mã để thanh toán'), findsOneWidget);
    await tester.tap(find.text('Mô phỏng: cổng thanh toán xác nhận'));
    await tester.pumpAndSettle();

    expect(find.text('1.750.000 ₫'), findsOneWidget);
  });

  testWidgets('rút tiền: kiểm tra số tiền rồi giữ chờ duyệt', (tester) async {
    await _pumpWithBook(tester);
    await tapTab(tester, 'Ví');

    await tester.tap(find.text('Rút tiền').first);
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(FilledButton, 'Gửi yêu cầu rút');
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '10000');
    await tester.pump();
    expect(find.text('Tối thiểu 50.000 đ'), findsWidgets);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '2000000');
    await tester.pump();
    expect(find.textContaining('Vượt số dư khả dụng'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '100000');
    await tester.pump();
    expect(find.text('Sẽ giữ 100.000 ₫ chờ duyệt'), findsOneWidget);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('1.150.000 ₫'), findsOneWidget);
    expect(find.textContaining('Yêu cầu rút về Vietcombank'), findsOneWidget);
  });

  testWidgets(
    'khiếu nại đơn đã giao: cần lý do và ảnh, rồi hiện thẻ khiếu nại',
    (tester) async {
      await _pumpWithBook(
        tester,
        overrides: [
          evidencePickerProvider.overrideWithValue(
            () async => PickedImage(_png, 'png', 'image/png'),
          ),
        ],
      );
      await tapTab(tester, 'Tôi');
      await tester.tap(find.text('Đơn mua'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cánh đồng bất tận'));
      await tester.pumpAndSettle();
      expect(find.text('Bạn đã nhận được sách?'), findsOneWidget);

      await tester.tap(find.text('Khiếu nại'));
      await tester.pumpAndSettle();
      expect(find.text('Mở khiếu nại'), findsOneWidget);

      // Thiếu lý do và ảnh thì báo.
      await tester.tap(find.text('Gửi khiếu nại'));
      await tester.pump();
      expect(find.text('Chọn lý do và thêm ít nhất 1 ảnh'), findsOneWidget);

      await tester.tap(find.text('Sách bị hư hỏng'));
      await tester.pump();
      await tester.tap(find.text('+ Thêm ảnh bằng chứng (0/10)'));
      await tester.pumpAndSettle();
      expect(find.text('+ Thêm ảnh bằng chứng (1/10)'), findsOneWidget);

      await tester.tap(find.text('Gửi khiếu nại'));
      await tester.pumpAndSettle();
      expect(find.text('Khiếu nại · Chờ người bán phản hồi'), findsOneWidget);
      expect(find.text('Mô phỏng: người bán đề xuất hoàn 50%'), findsOneWidget);
    },
  );

  testWidgets(
    'đơn đấu giá đang giao: mô phỏng giao thành công rồi khiếu nại chuyển Oldbook',
    (tester) async {
      await _pumpWithBook(tester);
      await tapTab(tester, 'Tôi');
      await tester.tap(find.text('Đơn mua'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Gửi hương cho gió'));
      await tester.pumpAndSettle();
      expect(find.text('Đang giao sách đấu giá'), findsOneWidget);
      expect(find.text('Mô phỏng: giao thất bại'), findsOneWidget);

      await tester.tap(find.text('Mô phỏng: giao thành công'));
      await tester.pumpAndSettle();
      expect(find.text('Bạn đã nhận được sách?'), findsOneWidget);
      expect(find.text('Hài lòng, hoàn tất đơn'), findsOneWidget);
    },
  );
}
