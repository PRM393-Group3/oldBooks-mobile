import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/sim/application/sim_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

Future<Harness> _open(WidgetTester tester) async {
  final h = Harness(UserRole.buyer);
  await h.pump(tester);
  return h;
}

Future<void> _reveal(WidgetTester tester, Finder f) => tester
    .scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);

void main() {
  testWidgets('Khám phá có dải Đang đấu giá, chạm mở chi tiết phiên', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('Đang đấu giá'), findsOneWidget);
    await tester.tap(find.text('Dế Mèn phiêu lưu ký (in 1957)').first);
    await tester.pumpAndSettle();
    expect(find.text('Lịch sử trả giá'), findsOneWidget);
    expect(find.text('Dẫn đầu: Tr***g'), findsOneWidget);
  });

  testWidgets('tab Đấu giá: lọc bốn trạng thái', (tester) async {
    await _open(tester);
    await tapTab(tester, 'Đấu giá');
    expect(find.text('Dế Mèn phiêu lưu ký (in 1957)'), findsOneWidget);
    expect(find.text('Số đỏ (in lần đầu 1938)'), findsOneWidget);
    expect(find.text('Truyện Kiều (chú giải 1979)'), findsNothing);

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();
    expect(find.text('Truyện Kiều (chú giải 1979)'), findsOneWidget);
    expect(find.text('Tắt đèn (in 1953)'), findsOneWidget);

    await tester.tap(find.text('Sắp tới'));
    await tester.pumpAndSettle();
    expect(find.text('Bỉ vỏ (in 1961)'), findsOneWidget);

    await tester.tap(find.text('Đã xong'));
    await tester.pumpAndSettle();
    expect(find.text('Gửi hương cho gió (in 1945)'), findsOneWidget);
  });

  testWidgets(
    'trả giá: mặc định giá tối thiểu, tăng giảm theo bước, đang dẫn đầu',
    (tester) async {
      await _open(tester);
      await tapTab(tester, 'Đấu giá');
      await tester.tap(find.text('Dế Mèn phiêu lưu ký (in 1957)'));
      await tester.pumpAndSettle();

      expect(find.text('290.000 ₫'), findsOneWidget);
      expect(find.text('Tối thiểu 290.000 ₫'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('300.000 ₫'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('290.000 ₫'), findsOneWidget);
      // Không giảm dưới giá tối thiểu.
      expect(
        tester
            .widget<OutlinedButton>(
              find.ancestor(
                of: find.byIcon(Icons.remove),
                matching: find.byType(OutlinedButton),
              ),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.text('Trả giá'));
      await tester.pumpAndSettle();
      expect(find.text('Bạn đang dẫn đầu'), findsWidgets);
      expect(find.text('Bạn đang dẫn đầu với 290.000 ₫'), findsOneWidget);
      final c = simContainer(tester);
      expect(c.read(auctionProvider('a1'))!.current, 290000);
      expect(c.read(availableBalanceProvider), 1250000 - 290000);
    },
  );

  testWidgets('mua ngay: hiện sheet xác nhận rồi chuyển sang đếm ngược', (
    tester,
  ) async {
    await _open(tester);
    await tapTab(tester, 'Đấu giá');
    await tester.tap(find.text('Dế Mèn phiêu lưu ký (in 1957)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mua ngay 450.000 ₫'));
    await tester.pumpAndSettle();
    expect(find.text('Mua ngay với giá 450.000 ₫?'), findsOneWidget);

    await tester.tap(find.text('Xác nhận mua ngay'));
    await tester.pumpAndSettle();
    expect(find.text('Đếm ngược mua ngay'), findsWidgets);
    expect(find.text('Bạn đang dẫn đầu'), findsWidgets);
  });

  testWidgets('đăng ký phiên: sheet phí và cọc, giữ tiền, rồi hủy hoàn lại', (
    tester,
  ) async {
    await _open(tester);
    await tapTab(tester, 'Đấu giá');
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Truyện Kiều (chú giải 1979)'));
    await tester.pumpAndSettle();

    expect(find.text('Đăng ký tham gia'), findsOneWidget);
    await tester.tap(find.text('Đăng ký tham gia'));
    await tester.pumpAndSettle();
    expect(find.text('Đăng ký tham gia phiên'), findsOneWidget);
    expect(
      find.text('10.000 ₫'),
      findsWidgets,
    ); // phí 2% kẹp sàn? 300.000 → 6.000 → 10.000
    expect(find.text('30.000 ₫'), findsWidgets); // cọc 10%
    expect(find.text('Xác nhận · giữ 40.000 ₫'), findsOneWidget);

    await tester.tap(find.text('Xác nhận · giữ 40.000 ₫'));
    await tester.pumpAndSettle();
    expect(find.text('Bạn đã đăng ký'), findsOneWidget);
    final c = simContainer(tester);
    expect(c.read(availableBalanceProvider), 1250000 - 40000);

    // Tắt thông báo "đã đăng ký" đang che nút ở đáy màn hình.
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first))
        .clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hủy đăng ký'));
    await tester.pumpAndSettle();
    expect(find.text('Đăng ký tham gia'), findsOneWidget);
    expect(c.read(availableBalanceProvider), 1250000);
  });

  testWidgets(
    'phiên đã thắng: báo thắng, mở Đơn mua; Tôi có Phiên tôi tham gia',
    (tester) async {
      await _open(tester);
      await tapTab(tester, 'Tôi');
      await tester.ensureVisible(find.text('Phiên tôi tham gia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Phiên tôi tham gia'));
      await tester.pumpAndSettle();
      expect(find.text('Đã thắng · 520.000 ₫'), findsOneWidget);
      expect(find.text('Đang dẫn đầu · 1.230.000 ₫'), findsNothing);
      expect(find.text('Đã bị vượt giá'), findsWidgets);

      await tester.tap(find.text('Gửi hương cho gió (in 1945)'));
      await tester.pumpAndSettle();
      expect(find.text('Bạn đã thắng phiên này'), findsOneWidget);
      await _reveal(tester, find.text('Lịch sử trả giá'));
      expect(find.text('Bạn'), findsWidgets);
    },
  );
}
