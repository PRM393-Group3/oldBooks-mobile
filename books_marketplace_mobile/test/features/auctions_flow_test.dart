import 'package:books_marketplace_mobile/app/app_router.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/features/auctions/domain/auction_event.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

Future<Harness> _open(WidgetTester tester) async {
  final h = Harness(UserRole.buyer);
  await h.pump(tester);
  return h;
}

Future<void> _go(WidgetTester tester, String path) async {
  appContainer(tester).read(routerProvider).push(path);
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, Finder f) => tester
    .scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);

void main() {
  testWidgets('tab Đấu giá: bốn nhóm trạng thái từ server', (tester) async {
    await _open(tester);
    await tapTab(tester, 'Đấu giá');
    expect(find.text('Truyện Kiều (bản 1925)'), findsOneWidget);
    expect(find.text('Số đỏ (in lần đầu)'), findsOneWidget);
    expect(find.text('Vang bóng một thời'), findsNothing);

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();
    expect(find.text('Vang bóng một thời'), findsOneWidget);

    await tester.tap(find.text('Đã xong'));
    await tester.pumpAndSettle();
    expect(find.text('Dế mèn phiêu lưu ký (1941)'), findsOneWidget);
  });

  testWidgets('trả giá: mặc định minNextBid, xác nhận tạm giữ, thành dẫn đầu', (
    tester,
  ) async {
    final h = await _open(tester);
    await _go(tester, '/auctions/a-live');

    expect(find.text('Tối thiểu 660.000 ₫'), findsOneWidget);
    expect(find.text('660.000 ₫'), findsOneWidget);
    expect(find.text('Dẫn đầu: Tr***g'), findsOneWidget);

    await tester.tap(find.text('Trả giá'));
    await tester.pumpAndSettle();
    expect(find.text('Trả giá 660.000 ₫?'), findsOneWidget);
    expect(find.text('Sẽ tạm giữ'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Trả giá').last);
    await tester.pumpAndSettle();
    expect(h.auctions.calls.last, startsWith('bid a-live 660000 '));
    expect(find.text('Bạn đang dẫn đầu'), findsWidgets);
    expect(find.text('Trả giá'), findsNothing);
  });

  testWidgets('BID_TOO_LOW: điền lại ô giá theo min_amount', (tester) async {
    final h = await _open(tester);
    await _go(tester, '/auctions/a-live');
    h.auctions.nextError = const ApiError(
      status: 422,
      code: ApiErrorCode.bidTooLow,
      fieldErrors: {'min_amount': '700000'},
    );

    await tester.tap(find.text('Trả giá'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Trả giá').last);
    await tester.pumpAndSettle();
    expect(find.text('700.000 ₫'), findsOneWidget);
    expect(find.text('Giá thấp hơn mức tối thiểu 700.000 ₫.'), findsOneWidget);
  });

  testWidgets('realtime: lượt mới của người khác cập nhật giá và lịch sử', (
    tester,
  ) async {
    final h = await _open(tester);
    await _go(tester, '/auctions/a-live');
    // Server đã ghi lượt mới; màn hình sẽ tải lại để xác nhận dẫn đầu.
    final raw = h.auctions.raw('a-live')!;
    raw['currentPrice'] = 680000;
    raw['live'] = {
      ...(raw['live'] as Map).cast<String, dynamic>(),
      'sequence': 7,
      'leader': 'Ho***a',
      'minNextBid': 700000,
      'bidCount': 7,
    };
    h.hub.emit(
      AuctionLiveEvent.fromJson(AuctionEventName.bidPlaced, {
        'auctionId': 'a-live',
        'sequence': 7,
        'status': 'LIVE',
        'currentPrice': 680000,
        'leader': 'Ho***a',
        'bidCount': 7,
        'endAt': DateTime.now()
            .toUtc()
            .add(const Duration(minutes: 40))
            .toIso8601String(),
        'buyNowAvailable': true,
        'minNextBid': 700000,
        'amount': 680000,
        'bidder': 'Ho***a',
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tối thiểu 700.000 ₫'), findsOneWidget);
    expect(find.text('Dẫn đầu: Ho***a'), findsOneWidget);
    await _reveal(tester, find.text('680.000 ₫').last);
    expect(find.text('Ho***a'), findsOneWidget);
  });

  testWidgets('đăng ký: sheet ghi phí + cọc, xác nhận thì đã đăng ký', (
    tester,
  ) async {
    final h = await _open(tester);
    await _go(tester, '/auctions/a-reg');
    await tester.tap(find.text('Đăng ký tham gia'));
    await tester.pumpAndSettle();
    expect(find.textContaining('60.000 ₫'), findsWidgets);
    await tester.tap(find.textContaining('Xác nhận'));
    await tester.pumpAndSettle();
    expect(h.auctions.calls.last, startsWith('register a-reg '));
    expect(find.text('Bạn đã đăng ký'), findsOneWidget);
  });

  testWidgets('người bán: thấy mã nhập kho, không có nút trả giá', (
    tester,
  ) async {
    await _open(tester);
    await _go(tester, '/auctions/a-mine');
    expect(find.text('OB4Q8R2TZ7'), findsOneWidget);
    expect(find.text('Hủy phiên'), findsOneWidget);
    expect(find.text('Trả giá'), findsNothing);
  });

  testWidgets('phiên của tôi có bốn tab theo vai trò', (tester) async {
    await _open(tester);
    await _go(tester, '/auctions/mine');
    for (final t in ['Đang bán', 'Đã tham gia', 'Đang dẫn đầu', 'Đã thắng']) {
      expect(find.text(t), findsOneWidget);
    }
    await tester.tap(find.text('Đã thắng'));
    await tester.pumpAndSettle();
    expect(find.text('Dế mèn phiêu lưu ký (1941)'), findsOneWidget);
  });

  testWidgets('đơn chờ phí ship chưa có địa chỉ: bắt chọn địa chỉ trước', (
    tester,
  ) async {
    final h = await _open(tester);
    await _go(tester, '/me/auction-orders/o-fee');
    expect(find.text('Chưa có địa chỉ giao'), findsOneWidget);
    expect(find.text('Nạp và thanh toán phí ship'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Chọn địa chỉ').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(RadioListTile<String>).first);
    await tester.pumpAndSettle();
    expect(h.auctionOrders.calls.last, startsWith('address o-fee '));
    expect(find.text('Chưa có địa chỉ giao'), findsNothing);

    await tester.tap(find.text('Nạp và thanh toán phí ship'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giữ 30.000 ₫'));
    await tester.pumpAndSettle();
    expect(h.auctionOrders.calls.last, startsWith('fee o-fee '));
    expect(find.text('Kho đang chuẩn bị gửi'), findsOneWidget);
  });

  testWidgets('lưu kho: hai lựa chọn; hết hạn: gia hạn còn N lần', (
    tester,
  ) async {
    final h = await _open(tester);
    await _go(tester, '/me/auction-orders/o-storage');
    expect(find.text('Sách đang lưu kho'), findsOneWidget);
    expect(find.text('Nhận tại kho'), findsOneWidget);
    expect(find.text('Giao lại'), findsOneWidget);

    await _go(tester, '/me/auction-orders/o-expired');
    expect(find.text('Gia hạn 35.000 ₫ (còn 2 lần)'), findsOneWidget);
    await tester.tap(find.text('Gia hạn 35.000 ₫ (còn 2 lần)'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
    await tester.pumpAndSettle();
    expect(
      h.auctionOrders.calls.last,
      startsWith('postExpiry o-expired EXTEND '),
    );
    expect(find.text('Đã gia hạn lưu kho'), findsOneWidget);
  });

  testWidgets('người bán xem đơn: có hoa hồng, không có thao tác', (
    tester,
  ) async {
    await _open(tester);
    await _go(tester, '/me/auction-orders/o-sold');
    expect(find.text('Hoa hồng'), findsOneWidget);
    expect(find.text('Khiếu nại'), findsNothing);
    expect(find.text('Chọn địa chỉ'), findsNothing);
  });
}
