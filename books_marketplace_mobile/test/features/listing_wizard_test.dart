import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/harness.dart';

/// Ảnh với URL đủ để `blobName` suy ra được, tránh phải mở máy ảnh/thư viện
/// trong test. Cả 4 góc đều có.
List<ListingImage> _readyImages() => [
  for (final t in ImageType.required)
    ListingImage(url: 'http://blob/public/u1/${t.api}.png', type: t),
];

void main() {
  testWidgets(
    'tạo tin mới: gửi trống báo đủ lỗi, điền hợp lệ thì tạo nháp lười và sang bước Ảnh',
    (tester) async {
      final h = Harness(UserRole.seller);
      await h.pump(tester);

      await tapTab(tester, 'Tin của tôi');
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Đăng bán'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng bán sách'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Tiếp'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập Tên sách.'), findsOneWidget);
      expect(find.text('Vui lòng nhập Tác giả.'), findsOneWidget);
      expect(find.text('Vui lòng chọn danh mục.'), findsOneWidget);
      expect(find.text('Vui lòng chọn tình trạng sách.'), findsOneWidget);
      expect(find.text('Mô tả tối thiểu 50 ký tự.'), findsOneWidget);
      expect(
        h.listings.calls,
        isNot(contains('create')),
        reason: 'chưa tạo nháp khi form chưa hợp lệ',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Tên sách'),
        'Nhà giả kim',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Tác giả'),
        'Paulo Coelho',
      );
      await tester.tap(find.text('Chọn danh mục'));
      await tester.pumpAndSettle();
      // "Tiểu thuyết" là con của "Văn học", gấp mặc định; chọn thẳng nút cha.
      await tester.tap(find.text('Văn học'));
      await tester.pumpAndSettle();
      // BookCondition.veryGood; cuộn tới vì nằm dưới màn hình.
      await tester.ensureVisible(find.text('Rất tốt'));
      await tester.tap(find.text('Rất tốt'));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mô tả'),
        'Cuốn sách còn rất mới, bìa sạch, không ghi chú, không rách trang nào cả.',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Năm xuất bản'),
        '2013',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ngôn ngữ (mã 2 chữ cái)'),
        'vi',
      );
      final before = h.listings.calls.length;
      await tester.tap(find.widgetWithText(FilledButton, 'Tiếp'));
      await tester.pumpAndSettle();

      expect(h.listings.calls.skip(before), ['create', 'bookInfo']);
      expect(find.text('Bước 2/4 · Ảnh'), findsOneWidget);
      expect(find.textContaining('Cần 3 đến 10 ảnh'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Tiếp'))
            .onPressed,
        isNull,
        reason: 'chưa đủ ảnh thì nút Tiếp phải khóa',
      );
    },
  );

  testWidgets(
    'tin bị từ chối: mở lại vào bước Thông tin sách, đi hết wizard và nộp thành công',
    (tester) async {
      final h = Harness(UserRole.seller);
      final rejected = fakeListing(
        id: 'L9',
        status: ListingStatus.rejected,
        bookInfo: completeBookInfo,
        category: const PersonRef(id: 'c1', name: 'Tiểu thuyết'),
        saleMethod: SaleMethod.fixedPrice,
        fixedPrice: const FixedPriceConfig(price: 120000, quantity: 2),
        images: _readyImages(),
        submissionCount: 1,
      );
      h.listings.mineItems = [rejected];
      h.listings.stored = rejected;
      await h.pump(tester);

      await tapTab(tester, 'Tin của tôi');
      await tester.tap(find.text('Nhà giả kim'));
      await tester.pumpAndSettle();
      expect(find.text('Còn 3 lần nộp lại'), findsOneWidget);

      await tester.tap(find.text('Sửa và nộp lại'));
      await tester.pumpAndSettle();

      // Tin bị từ chối luôn quay lại bước 1 để soát lại thông tin.
      expect(find.text('Sửa tin đăng'), findsOneWidget);
      expect(find.text('Bước 1/4 · Thông tin sách'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Tên sách'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Tiếp'));
      await tester.pumpAndSettle();
      expect(find.text('Bước 2/4 · Ảnh'), findsOneWidget);
      // Ảnh đã có sẵn từ tin cũ (suy blobName từ URL), không cần chọn lại.
      expect(find.widgetWithText(FilledButton, 'Tiếp'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Tiếp'));
      await tester.pumpAndSettle();
      expect(find.text('Bước 3/4 · Cách bán'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Tiếp'));
      await tester.pumpAndSettle();
      expect(find.text('Bước 4/4 · Xem lại'), findsOneWidget);
      expect(find.text('Nhà giả kim'), findsWidgets);
      expect(find.text('120.000 ₫'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Nộp kiểm định'));
      await tester.pumpAndSettle();

      expect(find.text('Đã nộp kiểm định'), findsOneWidget);
      expect(
        find.text(
          'Dự kiến xử lý trong 24 giờ. Bạn sẽ nhận thông báo khi có kết quả.',
        ),
        findsOneWidget,
      );
      expect(h.listings.calls.last, 'submit');

      await tester.tap(find.widgetWithText(FilledButton, 'Xong'));
      await tester.pumpAndSettle();
      expect(find.text('Sửa tin đăng'), findsNothing, reason: 'đã đóng wizard');
    },
  );

  testWidgets('LISTING_INCOMPLETE: liệt kê mục thiếu, chạm để nhảy đúng bước', (
    tester,
  ) async {
    final h = Harness(UserRole.seller);
    final listing = fakeListing(
      id: 'L9',
      status: ListingStatus.rejected,
      bookInfo: completeBookInfo,
      category: const PersonRef(id: 'c1', name: 'Tiểu thuyết'),
      saleMethod: SaleMethod.fixedPrice,
      fixedPrice: const FixedPriceConfig(price: 120000, quantity: 2),
      images: _readyImages(),
    );
    h.listings.mineItems = [listing];
    h.listings.stored = listing;
    h.listings.submitError = const ApiError(
      status: 400,
      code: ApiErrorCode.listingIncomplete,
      fieldErrors: {'images': 'not enough', 'fixedPrice.price': 'out of range'},
    );
    await h.pump(tester);

    await tapTab(tester, 'Tin của tôi');
    await tester.tap(find.text('Nhà giả kim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sửa và nộp lại'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Tiếp'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.widgetWithText(FilledButton, 'Nộp kiểm định'));
    await tester.pumpAndSettle();

    expect(find.text('Tin đăng còn thiếu'), findsOneWidget);
    expect(find.text('Ảnh (đủ 4 góc)'), findsOneWidget);
    expect(find.text('Giá bán'), findsOneWidget);

    await tester.tap(find.text('Ảnh (đủ 4 góc)'));
    await tester.pumpAndSettle();
    expect(find.text('Bước 2/4 · Ảnh'), findsOneWidget);
  });
}
