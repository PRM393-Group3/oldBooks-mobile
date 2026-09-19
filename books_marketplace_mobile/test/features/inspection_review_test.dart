import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/inspection/domain/inspection.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/harness.dart';

void main() {
  testWidgets('hàng đợi: chạm tin thì nhận khóa và mở màn kiểm định', (
    tester,
  ) async {
    final h = Harness(UserRole.inspector);
    final listing = fakeListing(
      id: 'L1',
      status: ListingStatus.pendingInspection,
      bookInfo: completeBookInfo,
      images: fourAngles(),
    );
    h.inspection.queueItems = [QueueItem(listing: listing, waitingHours: 5)];
    h.inspection.claimable = listing;
    h.inspection.claimExpiresAt = DateTime.now().add(
      const Duration(minutes: 30),
    );
    await h.pump(tester);

    await tester.tap(find.text('Nhà giả kim'));
    await tester.pumpAndSettle();

    expect(h.inspection.calls, ['claim:L1']);
    expect(find.text('Kiểm định'), findsOneWidget);
    expect(find.textContaining('Còn'), findsOneWidget);
    expect(find.text('Người bán khai báo'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Duyệt'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Từ chối'), findsOneWidget);
  });

  testWidgets('duyệt tin: xác nhận rồi quay lại hàng đợi, không còn tin đó', (
    tester,
  ) async {
    final h = Harness(UserRole.inspector);
    final listing = fakeListing(
      id: 'L1',
      status: ListingStatus.pendingInspection,
      bookInfo: completeBookInfo,
      images: fourAngles(),
    );
    h.inspection.queueItems = [QueueItem(listing: listing)];
    h.inspection.claimable = listing;
    h.inspection.claimExpiresAt = DateTime.now().add(
      const Duration(minutes: 30),
    );
    await h.pump(tester);

    await tester.tap(find.text('Nhà giả kim'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt'));
    await tester.pumpAndSettle();
    expect(find.text('Duyệt tin đăng'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Sách đạt yêu cầu');
    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt').last);
    await tester.pumpAndSettle();

    expect(h.inspection.calls, ['claim:L1', 'approve:Sách đạt yêu cầu']);
    expect(find.text('Đã duyệt tin'), findsOneWidget);
    expect(
      find.text('Kiểm định'),
      findsNothing,
      reason: 'đã quay lại hàng đợi',
    );

    // Hàng đợi được làm mới: tin vừa duyệt không còn.
    h.inspection.queueItems = [];
    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text('Hàng đợi trống'), findsOneWidget);
  });

  testWidgets('từ chối: bắt buộc lý do và ghi chú tối thiểu 10 ký tự', (
    tester,
  ) async {
    final h = Harness(UserRole.inspector);
    final listing = fakeListing(
      id: 'L1',
      status: ListingStatus.pendingInspection,
      bookInfo: completeBookInfo,
      images: fourAngles(),
    );
    h.inspection.queueItems = [QueueItem(listing: listing)];
    h.inspection.claimable = listing;
    h.inspection.claimExpiresAt = DateTime.now().add(
      const Duration(minutes: 30),
    );
    await h.pump(tester);

    await tester.tap(find.text('Nhà giả kim'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Từ chối'));
    await tester.pumpAndSettle();

    final submitInSheet = find.widgetWithText(FilledButton, 'Từ chối').last;
    await tester.tap(submitInSheet);
    await tester.pumpAndSettle();
    expect(find.text('Hãy chọn ít nhất một lý do.'), findsOneWidget);
    expect(find.text('Ghi chú tối thiểu 10 ký tự.'), findsOneWidget);
    expect(h.inspection.calls, ['claim:L1']);

    await tester.tap(find.text('Ảnh không đủ hoặc không rõ'));
    await tester.enterText(find.byType(TextField), 'Ảnh mờ, chụp lại giúp');
    await tester.tap(submitInSheet);
    await tester.pumpAndSettle();

    expect(h.inspection.calls, [
      'claim:L1',
      'reject:BlurryPhotos:Ảnh mờ, chụp lại giúp',
    ]);
    expect(find.text('Đã từ chối tin'), findsOneWidget);
  });

  testWidgets('INSPECTION_CLAIM_REQUIRED: báo hết khóa, phải nhận lại', (
    tester,
  ) async {
    final h = Harness(UserRole.inspector);
    final listing = fakeListing(
      id: 'L1',
      status: ListingStatus.inInspection,
      bookInfo: completeBookInfo,
      images: fourAngles(),
    );
    h.inspection.queueItems = [QueueItem(listing: listing)];
    h.inspection.claimable = listing;
    h.inspection.claimExpiresAt = DateTime.now().add(
      const Duration(minutes: 30),
    );
    h.inspection.decisionError = const ApiError(
      status: 409,
      code: ApiErrorCode.claimRequired,
    );
    await h.pump(tester);

    await tester.tap(find.text('Nhà giả kim'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Duyệt').last);
    await tester.pumpAndSettle();

    // Banner cố định báo hết khóa (không phải snackbar, để không che nút).
    expect(
      find.text('Khóa đã hết hạn. Hãy nhận lại tin để tiếp tục.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Nhận lại tin'), findsOneWidget);

    h.inspection.decisionError = null;
    await tester.tap(find.widgetWithText(FilledButton, 'Nhận lại tin'));
    await tester.pumpAndSettle();

    expect(h.inspection.calls.where((c) => c.startsWith('claim')).length, 2);
    expect(find.widgetWithText(FilledButton, 'Duyệt'), findsOneWidget);
  });

  testWidgets('tab Đang giữ: hiện đồng hồ đếm ngược của tin đang cầm', (
    tester,
  ) async {
    final h = Harness(UserRole.inspector);
    h.inspection.claimable = fakeListing(
      id: 'L1',
      status: ListingStatus.inInspection,
      bookInfo: const BookInfo(title: 'Dune'),
    );
    h.inspection.claimExpiresAt = DateTime.now().add(
      const Duration(minutes: 12),
    );
    await h.pump(tester);

    await tapTab(tester, 'Đang giữ');
    expect(find.text('Dune'), findsOneWidget);
    // Vài mili giây trôi qua giữa lúc tạo dữ liệu và lúc vẽ, nên chỉ so khớp
    // mẫu "mm:ss để quyết định" quanh mốc 12 phút, không so đúng từng giây.
    final tag = find.textContaining(RegExp(r'^Còn 1[12]:\d\d để quyết định$'));
    expect(tag, findsOneWidget);
  });
}
