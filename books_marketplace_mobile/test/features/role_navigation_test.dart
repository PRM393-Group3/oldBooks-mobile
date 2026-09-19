import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/inspection/domain/inspection.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:books_marketplace_mobile/features/notifications/domain/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/harness.dart';

Finder tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  testWidgets('Buyer: 3 tab, không có Tin của tôi, vào Trang chủ', (
    tester,
  ) async {
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

    expect(tab('Trang chủ'), findsOneWidget);
    expect(tab('Thông báo'), findsOneWidget);
    expect(tab('Hồ sơ'), findsOneWidget);
    expect(tab('Tin của tôi'), findsNothing);
    expect(tab('Hàng đợi'), findsNothing);
    // Trang chủ hiện tin công khai và chip danh mục.
    expect(find.text('Sapiens'), findsOneWidget);
    expect(find.text('99.000 ₫'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Văn học'), findsOneWidget);
  });

  testWidgets('Seller: 4 tab kèm Tin của tôi và nút nổi Đăng bán', (
    tester,
  ) async {
    final h = Harness(UserRole.seller);
    h.listings.mineItems = [
      fakeListing(
        id: 'L2',
        status: ListingStatus.rejected,
        bookInfo: const BookInfo(title: 'Đắc nhân tâm'),
      ),
    ];
    await h.pump(tester);
    expect(tab('Tin của tôi'), findsOneWidget);
    expect(tab('Hàng đợi'), findsNothing);

    await tapTab(tester, 'Tin của tôi');
    expect(find.text('Đắc nhân tâm'), findsOneWidget);
    expect(find.text('Bị từ chối'), findsWidgets); // tag trên thẻ (và chip lọc)
    expect(
      find.widgetWithText(FloatingActionButton, 'Đăng bán'),
      findsOneWidget,
    );
  });

  testWidgets('Inspector: vào Hàng đợi, có tab Đang giữ, không có Trang chủ', (
    tester,
  ) async {
    final h = Harness(UserRole.inspector);
    h.inspection.queueItems = [
      QueueItem(
        listing: fakeListing(
          id: 'L3',
          status: ListingStatus.pendingInspection,
          bookInfo: const BookInfo(title: 'Dune'),
        ),
        waitingHours: 20,
        isOverdue: true,
      ),
      QueueItem(
        listing: fakeListing(
          id: 'L4',
          status: ListingStatus.pendingInspection,
          bookInfo: const BookInfo(title: '1984'),
        ),
        waitingHours: 2,
      ),
    ];
    await h.pump(tester);

    expect(tab('Hàng đợi'), findsOneWidget);
    expect(tab('Đang giữ'), findsOneWidget);
    expect(tab('Trang chủ'), findsNothing);
    expect(find.text('Dune'), findsOneWidget);
    expect(
      find.text('Quá hạn'),
      findsOneWidget,
      reason: 'chỉ tin chờ quá 18 giờ',
    );
    expect(find.text('Chờ 20 giờ'), findsOneWidget);
    expect(find.text('Chờ 2 giờ'), findsOneWidget);
  });

  testWidgets(
    'Admin: chỉ có Hồ sơ, không có thanh điều hướng, có ghi chú cổng web',
    (tester) async {
      final h = Harness(UserRole.admin);
      await h.pump(tester);

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Quản trị viên'), findsOneWidget);
      expect(find.text('Chức năng quản trị nằm ở cổng web.'), findsOneWidget);
    },
  );

  testWidgets('badge thông báo chưa đọc hiện trên tab, ẩn khi bằng 0', (
    tester,
  ) async {
    final h = Harness(UserRole.seller);
    h.notifications.unread = 3;
    await h.pump(tester);
    expect(
      find.descendant(of: find.byType(NavigationBar), matching: find.text('3')),
      findsOneWidget,
    );

    final h0 = Harness(UserRole.seller);
    await h0.pump(tester);
    expect(find.byType(Badge), findsNothing);
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

    await tapTab(tester, 'Thông báo');
    expect(find.text('Tin đăng của bạn bị từ chối'), findsOneWidget);
    expect(
      find.text('english body'),
      findsNothing,
      reason: 'loại đã biết dùng chuỗi bản địa hóa',
    );

    await tester.tap(find.text('Tin đăng của bạn bị từ chối'));
    await tester.pumpAndSettle();

    expect(h.notifications.calls, ['read:n1']);
    expect(find.text('Nhà giả kim'), findsWidgets, reason: 'mở chi tiết tin');
  });

  testWidgets('thông báo rỗng hiện trạng thái trống', (tester) async {
    final h = Harness(UserRole.buyer);
    await h.pump(tester);
    await tapTab(tester, 'Thông báo');
    expect(find.text('Chưa có thông báo'), findsOneWidget);
  });
}
