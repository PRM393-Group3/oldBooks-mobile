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
        status: ListingStatus.onSale,
        bookInfo: const BookInfo(title: 'Sapiens', author: 'Yuval'),
        saleMethod: SaleMethod.fixedPrice,
        fixedPrice: const FixedPriceConfig(price: 99000, quantity: 1),
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

  testWidgets('nút + Bán mở Tin của tôi kèm nút Đăng bán', (tester) async {
    final h = Harness(UserRole.seller);
    h.listings.mineItems = [
      fakeListing(
        id: 'L2',
        status: ListingStatus.rejected,
        bookInfo: const BookInfo(title: 'Đắc nhân tâm'),
      ),
    ];
    await h.pump(tester);

    await tapSellTab(tester);
    expect(find.text('Đắc nhân tâm'), findsOneWidget);
    expect(find.text('Bị từ chối'), findsWidgets);
    expect(
      find.widgetWithText(FloatingActionButton, 'Đăng bán'),
      findsOneWidget,
    );
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
    // 3 chưa đọc từ backend cộng 2 thông báo mô phỏng chưa đọc.
    expect(find.text('5'), findsOneWidget);

    final h0 = Harness(UserRole.seller);
    await h0.pump(tester);
    expect(
      find.text('2'),
      findsOneWidget,
      reason: 'chỉ còn thông báo mô phỏng',
    );
  });

  testWidgets('thông báo: tiêu đề bản địa hóa, chạm để đánh dấu đã đọc', (
    tester,
  ) async {
    final h = Harness(UserRole.seller);
    h.notifications.unread = 1;
    h.notifications.items = [
      const AppNotification(
        id: 'n1',
        type: NotificationType.listingRejected,
        title: 'Your listing was rejected',
        body: 'english body',
        isRead: false,
        listingId: 'L1',
      ),
    ];
    h.listings.stored = fakeListing(
      id: 'L1',
      status: ListingStatus.rejected,
      bookInfo: completeBookInfo,
    );
    await h.pump(tester);

    await tester.tap(find.text('Thông báo'));
    await tester.pumpAndSettle();
    expect(find.text('Tin đăng của bạn bị từ chối'), findsOneWidget);
    expect(
      find.text('english body'),
      findsNothing,
      reason: 'loại đã biết dùng chuỗi bản địa hóa',
    );
    expect(
      find.byType(BottomNavigationBar),
      findsNothing,
      reason: 'mở phủ lên thanh tab',
    );

    await tester.tap(find.text('Tin đăng của bạn bị từ chối'));
    await tester.pumpAndSettle();

    expect(h.notifications.calls, ['read:n1']);
    expect(find.text('Nhà giả kim'), findsWidgets, reason: 'mở chi tiết tin');
  });

  testWidgets('không có thông báo backend vẫn thấy thông báo mô phỏng', (tester) async {
    final h = Harness(UserRole.buyer);
    await h.pump(tester);
    await tester.tap(find.text('Thông báo'));
    await tester.pumpAndSettle();
    // Không có thông báo từ backend; vẫn thấy các thông báo mô phỏng.
    expect(find.text('Nạp tiền thành công'), findsOneWidget);
    expect(find.text('Đơn OB-24790 đã giao'), findsOneWidget);
  });
}
