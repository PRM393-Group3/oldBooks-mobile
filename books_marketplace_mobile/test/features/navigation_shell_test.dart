import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:books_marketplace_mobile/features/notifications/domain/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/harness.dart';

void main() {
  testWidgets('mọi người dùng thấy 5 tab và vào Khám phá', (tester) async {
    final h = Harness(UserRole.buyer);
    h.listings.browseItems = [
      fakeListing(
        id: 'L1',
        status: ListingStatus.published,
        bookInfo: const BookInfo(title: 'Sapiens', author: 'Yuval'),
        price: 99000,
      ),
    ];
    await h.pump(tester);

    for (final label in ['Khám phá', 'Đấu giá', 'Ví', 'Tôi']) {
      expect(tabFinder(label), findsOneWidget, reason: label);
    }
    expect(
      find.descendant(
        of: find.byType(Scaffold),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
      reason: 'nút + Bán ở giữa',
    );
    expect(find.text('Sapiens'), findsOneWidget);
    expect(find.text('99.000 ₫'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Văn học'), findsOneWidget);
  });

  testWidgets('Đấu giá và Ví mở đúng màn hình', (tester) async {
    final h = Harness(UserRole.buyer);
    await h.pump(tester);

    await tapTab(tester, 'Đấu giá');
    expect(
      find.text('Sách đã được kiểm tra tại kho Oldbook trước khi lên sàn'),
      findsOneWidget,
    );
    await tapTab(tester, 'Ví');
    expect(find.text('Ví Oldbook'), findsOneWidget);
  });

  testWidgets('Admin cũng thấy đủ 5 tab và ghi chú cổng web ở tab Tôi', (
    tester,
  ) async {
    final h = Harness(UserRole.admin);
    await h.pump(tester);

    expect(tabFinder('Khám phá'), findsOneWidget);
    await tapTab(tester, 'Tôi');
    expect(find.text('Quản trị viên'), findsOneWidget);
    expect(find.text('Chức năng quản trị nằm ở cổng web.'), findsOneWidget);
  });

  testWidgets('chạm lại tab đang mở không làm mất thanh điều hướng', (
    tester,
  ) async {
    final h = Harness(UserRole.buyer);
    await h.pump(tester);
    await tapTab(tester, 'Khám phá');
    expect(tabFinder('Khám phá'), findsOneWidget);
  });

  testWidgets('badge thông báo chưa đọc hiện ở nút Thông báo, ẩn khi bằng 0', (
    tester,
  ) async {
    final h = Harness(UserRole.seller);
    h.notifications.unread = 3;
    await h.pump(tester);
    expect(find.text('3'), findsOneWidget);

    final h0 = Harness(UserRole.seller);
    await h0.pump(tester);
    expect(find.text('0'), findsNothing, reason: 'không hiện badge số 0');
  });

  testWidgets(
    'thông báo: hiển thị nguyên văn của server, chạm để đánh dấu đã đọc',
    (tester) async {
      final h = Harness(UserRole.seller);
      h.notifications.unread = 2;
      h.notifications.items = [
        const AppNotification(
          id: 'n1',
          type: NotificationType.accountLocked,
          title: 'Tài khoản đã bị khóa',
          body: 'Lý do: Vi phạm quy định cộng đồng.',
          isRead: false,
        ),
        const AppNotification(
          id: 'n2',
          type: NotificationType.unknown,
          title: 'Loại thông báo mới',
          body: 'Nội dung từ giai đoạn sau.',
          isRead: false,
        ),
      ];
      await h.pump(tester);

      await tester.tap(find.text('Thông báo'));
      await tester.pumpAndSettle();
      expect(find.text('Tài khoản đã bị khóa'), findsOneWidget);
      expect(find.text('Lý do: Vi phạm quy định cộng đồng.'), findsOneWidget);
      expect(
        find.text('Loại thông báo mới'),
        findsOneWidget,
        reason: 'type lạ vẫn hiển thị title/body, không crash',
      );
      expect(
        find.byType(BottomNavigationBar),
        findsNothing,
        reason: 'mở phủ lên thanh tab',
      );

      await tester.tap(find.text('Tài khoản đã bị khóa'));
      await tester.pumpAndSettle();

      expect(h.notifications.calls, ['read:n1']);
    },
  );

  testWidgets('thông báo đấu giá: chạm mở đúng phiên, ẩn loại chỉ cho admin', (
    tester,
  ) async {
    final h = Harness(UserRole.buyer);
    h.notifications.items = [
      const AppNotification(
        id: 'n1',
        type: NotificationType.auctionOutbid,
        title: 'Bạn đã bị vượt giá',
        body: '',
        isRead: true,
        data: {'auctionId': 'a-live'},
      ),
      const AppNotification(
        id: 'n2',
        type: NotificationType.auctionLiquidationNeedsAdmin,
        title: 'Cần admin thanh lý',
        body: '',
        isRead: true,
        data: {'auctionOrderId': 'o1'},
      ),
    ];
    await h.pump(tester);
    await tester.tap(find.text('Thông báo'));
    await tester.pumpAndSettle();
    expect(find.text('Cần admin thanh lý'), findsNothing);

    await tester.tap(find.text('Bạn đã bị vượt giá'));
    await tester.pumpAndSettle();
    expect(find.text('Truyện Kiều (bản 1925)'), findsOneWidget);
  });
}
