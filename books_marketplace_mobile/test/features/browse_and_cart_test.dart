import 'package:books_marketplace_mobile/core/util/search.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/cart/application/cart_providers.dart';
import 'package:books_marketplace_mobile/features/cart/domain/cart_item.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/harness.dart';

Listing _book(
  String id,
  String title, {
  String? author,
  String? isbn,
  int price = 50000,
}) => fakeListing(
  id: id,
  status: ListingStatus.onSale,
  bookInfo: BookInfo(
    title: title,
    author: author,
    isbn: isbn,
    condition: BookCondition.good,
  ),
  saleMethod: SaleMethod.fixedPrice,
  fixedPrice: FixedPriceConfig(price: price, quantity: 1),
);

void main() {
  group('normalizeSearch', () {
    test('bỏ dấu tiếng Việt, chữ thường, cắt khoảng trắng', () {
      expect(normalizeSearch('  Nhà Giả Kim '), 'nha gia kim');
      expect(normalizeSearch('Đắc nhân tâm'), 'dac nhan tam');
      expect(
        normalizeSearch('Tôi thấy hoa vàng trên cỏ xanh'),
        'toi thay hoa vang tren co xanh',
      );
      expect(normalizeSearch('Lược sử thời gian'), 'luoc su thoi gian');
      expect(normalizeSearch('Việt Nam sử lược'), 'viet nam su luoc');
      expect(normalizeSearch('ISBN 978-0'), 'isbn 978-0');
    });
  });

  group('giỏ hàng', () {
    test('thêm, chặn trùng, xóa, đếm', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final cart = c.read(cartProvider.notifier);
      const item = CartItem(listingId: 'a', title: 'A', price: 1000);

      expect(cart.add(item), isTrue);
      expect(cart.add(item), isFalse, reason: 'mỗi tin chỉ một cuốn');
      expect(c.read(cartCountProvider), 1);
      expect(c.read(inCartProvider('a')), isTrue);
      expect(c.read(inCartProvider('b')), isFalse);

      cart.remove('a');
      expect(c.read(cartCountProvider), 0);
    });

    test('CartItem.fromListing lấy giá bán và người bán', () {
      final item = CartItem.fromListing(_book('x', 'Sách', price: 77000));
      expect(item.listingId, 'x');
      expect(item.price, 77000);
      expect(item.sellerName, 'Nguyen Van A');
    });
  });

  group('Khám phá', () {
    Future<Harness> pumpHome(WidgetTester tester) async {
      final h = Harness(UserRole.buyer);
      h.listings.browseItems = [
        _book(
          'L1',
          'Nhà giả kim',
          author: 'Paulo Coelho',
          isbn: '9786045337563',
        ),
        _book('L2', 'Sapiens', author: 'Yuval Noah Harari', price: 95000),
      ];
      await h.pump(tester);
      return h;
    }

    testWidgets('lưới hiện tên, tác giả, giá và nhãn tình trạng', (
      tester,
    ) async {
      await pumpHome(tester);
      expect(find.text('Oldbook'), findsOneWidget);
      expect(find.text('Mới đăng'), findsOneWidget);
      expect(find.text('2 cuốn'), findsOneWidget);
      expect(find.text('Nhà giả kim'), findsOneWidget);
      expect(find.text('Paulo Coelho'), findsOneWidget);
      expect(find.text('95.000 ₫'), findsOneWidget);
      expect(find.text('Tốt'), findsWidgets);
      expect(find.text('Giỏ · 0'), findsOneWidget);
    });

    testWidgets('tìm không dấu theo tên, tác giả, ISBN; không thấy thì báo', (
      tester,
    ) async {
      await pumpHome(tester);
      final field = find.byType(TextField);

      await tester.enterText(field, 'nha gia kim');
      await tester.pump();
      expect(find.text('Kết quả tìm kiếm'), findsOneWidget);
      expect(find.text('Nhà giả kim'), findsOneWidget);
      expect(find.text('Sapiens'), findsNothing);
      expect(find.text('1 cuốn'), findsOneWidget);

      await tester.enterText(field, 'harari');
      await tester.pump();
      expect(find.text('Sapiens'), findsOneWidget);

      await tester.enterText(field, '9786045337563');
      await tester.pump();
      expect(find.text('Nhà giả kim'), findsOneWidget);

      await tester.enterText(field, 'zzz');
      await tester.pump();
      expect(
        find.textContaining('Không tìm thấy sách phù hợp'),
        findsOneWidget,
      );
    });

    testWidgets('đổi danh mục không làm mất chữ đã gõ ở ô tìm kiếm', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.enterText(find.byType(TextField), 'sapiens');
      await tester.pump();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Văn học'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'sapiens'), findsOneWidget);
    });
  });

  group('Chi tiết sách', () {
    testWidgets('hiện giá, ship, người bán, thông số; thêm giỏ rồi báo đã có', (
      tester,
    ) async {
      final h = Harness(UserRole.buyer);
      final book = fakeListing(
        id: 'L1',
        status: ListingStatus.onSale,
        bookInfo: const BookInfo(
          title: 'Nhà giả kim',
          author: 'Paulo Coelho',
          publisher: 'NXB Hội Nhà Văn',
          publicationYear: 2017,
          isbn: '9786045337563',
          condition: BookCondition.good,
          defectNotes: 'Gáy hơi cong nhẹ',
          description: 'Giấy còn trắng.',
        ),
        saleMethod: SaleMethod.fixedPrice,
        fixedPrice: const FixedPriceConfig(price: 45000, quantity: 1),
      );
      h.listings.browseItems = [book];
      h.listings.stored = book;
      await h.pump(tester);

      await tester.tap(find.text('Nhà giả kim'));
      await tester.pumpAndSettle();

      Future<void> reveal(Finder f) => tester.scrollUntilVisible(
        f,
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );

      expect(find.text('45.000 ₫'), findsOneWidget);
      expect(find.text('+ ship 25.000 ₫'), findsOneWidget);
      expect(find.text('Nguyen Van A'), findsOneWidget);
      await reveal(find.text('Gáy hơi cong nhẹ'));
      expect(find.text('Gáy hơi cong nhẹ'), findsOneWidget);
      await reveal(find.text('9786045337563'));
      expect(find.text('NXB Hội Nhà Văn'), findsOneWidget);
      expect(find.text('2017'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);

      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pump();
      expect(find.text('Đã thêm vào giỏ'), findsOneWidget);
      expect(find.text('Giỏ · 1'), findsOneWidget);
      expect(find.text('Đã trong giỏ'), findsOneWidget);

      await tester.tap(find.text('Đã trong giỏ'));
      await tester.pump();
      expect(find.text('Sách đã có trong giỏ'), findsOneWidget);
      expect(find.text('Giỏ · 1'), findsOneWidget);
    });

    testWidgets('Mua ngay thêm vào giỏ và mở giỏ', (tester) async {
      final h = Harness(UserRole.buyer);
      final book = _book('L1', 'Sapiens');
      h.listings.browseItems = [book];
      h.listings.stored = book;
      await h.pump(tester);

      await tester.tap(find.text('Sapiens'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mua ngay'));
      await tester.pumpAndSettle();

      expect(find.text('Giỏ hàng'), findsOneWidget);
    });

    testWidgets('tin đấu giá chỉ xem thông tin, không có nút giỏ', (
      tester,
    ) async {
      final h = Harness(UserRole.buyer);
      final auction = fakeListing(
        id: 'A1',
        status: ListingStatus.onSale,
        bookInfo: const BookInfo(title: 'Dế Mèn phiêu lưu ký'),
        saleMethod: SaleMethod.auction,
        auction: const AuctionConfig(
          startingPrice: 200000,
          minBidIncrement: 10000,
          durationDays: 3,
          startMode: AuctionStartMode.onApproval,
        ),
      );
      h.listings.browseItems = [auction];
      h.listings.stored = auction;
      await h.pump(tester);

      await tester.tap(find.text('Dế Mèn phiêu lưu ký'));
      await tester.pumpAndSettle();

      expect(find.text('Thêm vào giỏ'), findsNothing);
      expect(find.text('Mua ngay'), findsNothing);
      expect(find.text('Sách này bán theo hình thức đấu giá.'), findsOneWidget);
    });
  });
}
