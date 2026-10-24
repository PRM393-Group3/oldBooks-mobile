import 'package:books_marketplace_mobile/app/nav_config.dart';
import 'package:books_marketplace_mobile/core/network/paged_result.dart';
import 'package:books_marketplace_mobile/core/util/format.dart';
import 'package:books_marketplace_mobile/core/validation/isbn.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_query.dart';
import 'package:books_marketplace_mobile/features/notifications/domain/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Listing.fromJson', () {
    test('ListingDto đầy đủ', () {
      final l = Listing.fromJson({
        'id': 'L1',
        'title': 'Đắc Nhân Tâm',
        'author': 'Dale Carnegie',
        'category': {
          'id': 'c1',
          'name': 'Văn học',
          'slug': 'van-hoc',
          'isActive': true,
          'displayOrder': 10,
        },
        'condition': 'GOOD',
        'price': 85000,
        'description': 'Còn mới 90%.',
        'publisher': 'NXB Tổng hợp',
        'publishYear': 2018,
        'isbn': '9780671027032',
        'defectNotes': 'Góc bìa cong',
        'status': 'PUBLISHED',
        'photos': [
          {
            'id': 'p2',
            'url': 'http://blob/public/u1/b.jpg',
            'thumbnailUrl': 'http://blob/public/u1/b-thumb.jpg',
            'width': 2048,
            'height': 1365,
            'order': 1,
          },
          {
            'id': 'p1',
            'url': 'http://blob/public/u1/a.jpg',
            'thumbnailUrl': 'http://blob/public/u1/a-thumb.jpg',
            'order': 0,
          },
        ],
        'seller': {
          'id': 'u9',
          'fullName': 'Nguyen Seller',
          'avatarUrl': null,
          'averageRating': null,
          'completedOrders': 0,
        },
        'publishedAt': '2026-10-03T08:26:22Z',
        'lastReview': {
          'decision': 'REQUEST_CHANGES',
          'reason': 'Ảnh mờ',
          'createdAt': '2026-10-03T09:00:00Z',
        },
        'claim': null,
      });

      expect(l.id, 'L1');
      expect(l.status, ListingStatus.published);
      expect(l.title, 'Đắc Nhân Tâm');
      expect(l.price, 85000);
      expect(l.fixedPrice!.price, 85000);
      expect(l.bookInfo.condition, BookCondition.good);
      expect(l.bookInfo.publicationYear, 2018);
      expect(l.category!.name, 'Văn học');
      expect(l.seller!.name, 'Nguyen Seller');
      expect(l.seller!.averageRating, isNull, reason: 'ẩn khi null');
      expect(l.images.map((p) => p.id), ['p1', 'p2'], reason: 'theo order');
      expect(l.coverImageUrl, 'http://blob/public/u1/a-thumb.jpg');
      expect(l.images.first.blobName, 'u1/a.jpg');
      expect(l.lastReview!.reason, 'Ảnh mờ');
      expect(
        l.reviewReason,
        isNull,
        reason: 'chỉ hiện lý do khi cần sửa hoặc bị từ chối',
      );
    });

    test('lý do duyệt chỉ hiện với NEEDS_CHANGES và REJECTED', () {
      Listing with_(String status) => Listing.fromJson({
        'id': 'x',
        'status': status,
        'lastReview': {'decision': 'REJECT', 'reason': 'Vi phạm'},
      });
      expect(with_('NEEDS_CHANGES').reviewReason, 'Vi phạm');
      expect(with_('REJECTED').reviewReason, 'Vi phạm');
      expect(with_('PUBLISHED').reviewReason, isNull);
    });

    test('ListingSummaryDto rút gọn: thumbnail làm bìa, categoryId', () {
      final l = Listing.fromJson({
        'id': 'L2',
        'title': 'Sapiens',
        'author': 'Harari',
        'price': 95000,
        'condition': 'FAIR',
        'categoryId': 'c9',
        'thumbnailUrl': 'http://blob/public/u1/t.jpg',
        'status': 'PUBLISHED',
        'publishedAt': '2026-10-03T08:26:22Z',
      });
      expect(l.coverImageUrl, 'http://blob/public/u1/t.jpg');
      expect(l.category!.id, 'c9');
      expect(l.images, isEmpty);
      expect(
        Listing.fromJson({'id': 'x', 'status': 'DRAFT'}).coverImageUrl,
        isNull,
        reason: 'thumbnailUrl null khi chưa có ảnh',
      );
    });

    test('trạng thái lạ không làm hỏng parse', () {
      final l = Listing.fromJson({'id': 'x', 'status': 'FUTURE'});
      expect(l.status, ListingStatus.unknown);
      expect(l.title, '');
      expect(l.price, isNull);
    });

    test('quyền sửa, gửi duyệt, gỡ và công khai theo trạng thái', () {
      expect(ListingStatus.draft.isFreelyEditable, isTrue);
      expect(ListingStatus.needsChanges.canSubmit, isTrue);
      expect(ListingStatus.unpublished.canSubmit, isTrue);
      expect(ListingStatus.published.isEditable, isTrue);
      expect(ListingStatus.published.canSubmit, isFalse);
      expect(ListingStatus.published.canUnpublish, isTrue);
      for (final s in [
        ListingStatus.pendingReview,
        ListingStatus.rejected,
        ListingStatus.reserved,
        ListingStatus.sold,
      ]) {
        expect(s.isEditable, isFalse, reason: s.api);
        expect(s.canUnpublish, isFalse, reason: s.api);
      }
      expect(ListingStatus.reserved.isPublic, isTrue);
      expect(ListingStatus.draft.isPublic, isFalse);
    });
  });

  group('ListingQuery', () {
    test('chỉ gửi tham số đã đặt, sort mặc định thì bỏ', () {
      expect(const ListingQuery().toQuery(pageSize: 20), {'pageSize': 20});
      final q = const ListingQuery(
        q: ' dac nhan ',
        categoryId: 'c1',
        condition: BookCondition.good,
        minPrice: 1000,
        maxPrice: 90000,
        sort: ListingSort.priceAsc,
      );
      expect(q.toQuery(cursor: 'abc', pageSize: 20), {
        'q': 'dac nhan',
        'categoryId': 'c1',
        'condition': 'GOOD',
        'minPrice': 1000,
        'maxPrice': 90000,
        'sort': 'price_asc',
        'pageSize': 20,
        'cursor': 'abc',
      });
      expect(q.activeFilters, 3);
    });

    test('so sánh theo giá trị (khóa family), cắt khoảng trắng từ khóa', () {
      expect(const ListingQuery(q: 'a '), const ListingQuery(q: 'a'));
      expect(
        const ListingQuery(q: 'a').hashCode,
        const ListingQuery(q: 'a ').hashCode,
      );
      expect(
        const ListingQuery(q: 'a'),
        isNot(const ListingQuery(q: 'a', sort: ListingSort.priceDesc)),
      );
    });

    test('ListingDraftInput: bỏ trường null, giữ chuỗi rỗng để xóa', () {
      const input = ListingDraftInput(
        title: ' Sách ',
        condition: BookCondition.worn,
        price: 5000,
        publisher: '',
      );
      expect(input.toJson(), {
        'title': 'Sách',
        'condition': 'WORN',
        'price': 5000,
        'publisher': '',
      });
    });
  });

  group('ISBN', () {
    test('ISBN-13 và ISBN-10 hợp lệ', () {
      expect(isValidIsbn('978-0-306-40615-7'), isTrue);
      expect(isValidIsbn('9780306406157'), isTrue);
      expect(isValidIsbn('0-306-40615-2'), isTrue);
      expect(isValidIsbn('080442957X'), isTrue);
      expect(isValidIsbn('0-8044-2957-x'), isTrue);
    });
    test('sai checksum, sai độ dài, ký tự lạ', () {
      expect(isValidIsbn('978-0-306-40615-8'), isFalse);
      expect(isValidIsbn('0306406153'), isFalse);
      expect(isValidIsbn('12345'), isFalse);
      expect(isValidIsbn('abcdefghij'), isFalse);
      expect(isValidIsbn(''), isFalse);
    });
  });

  group('PagedResult', () {
    test('mảng trần: còn trang sau nếu trang đầy', () {
      final full = PagedResult<int>.fromJson(
        List.generate(20, (i) => i),
        (j) => j as int,
        page: 1,
        pageSize: 20,
      );
      expect(full.hasMore, isTrue);
      final short = PagedResult<int>.fromJson(
        [1, 2],
        (j) => j as int,
        page: 1,
        pageSize: 20,
      );
      expect(short.hasMore, isFalse);
    });

    test('object có items và tổng số', () {
      final r = PagedResult<int>.fromJson(
        {'items': List.generate(20, (i) => i), 'totalCount': 45},
        (j) => j as int,
        page: 2,
        pageSize: 20,
      );
      expect(r.totalCount, 45);
      expect(r.hasMore, isTrue); // 2 * 20 < 45
      final last = PagedResult<int>.fromJson(
        {
          'items': [1],
          'total': 41,
        },
        (j) => j as int,
        page: 3,
        pageSize: 20,
      );
      expect(last.hasMore, isFalse); // 3 * 20 >= 41
    });

    test('dữ liệu lạ cho ra danh sách rỗng', () {
      final r = PagedResult<int>.fromJson(
        null,
        (j) => j as int,
        page: 1,
        pageSize: 20,
      );
      expect(r.items, isEmpty);
      expect(r.hasMore, isFalse);
    });
  });

  group('thông báo', () {
    test('thông báo: đọc type, data, và an toàn với type lạ', () {
      final n = AppNotification.fromJson({
        'id': 'n1',
        'type': 'TOPUP_SUCCEEDED',
        'title': 'Nạp tiền thành công',
        'body': 'Bạn đã nạp 100.000đ.',
        'data': {'topupId': 't1'},
        'isRead': false,
        'createdAt': '2026-09-19T08:30:18Z',
      });
      expect(n.type, NotificationType.topupSucceeded);
      expect(n.type.isWallet, isTrue);
      expect(n.data!['topupId'], 't1');
      expect(n.asRead().isRead, isTrue);
      expect(n.asRead().data, n.data);
      expect(NotificationType.fromApi('NOPE'), NotificationType.unknown);
      expect(
        AppNotification.fromJson({'id': 'x', 'type': 'FUTURE_TYPE'}).type,
        NotificationType.unknown,
      );
    });
  });

  test('thanh điều hướng: 5 tab cố định, nút Bán ở giữa', () {
    expect(appTabs.map((t) => t.path), [
      '/home',
      '/auctions',
      '/sell',
      '/wallet',
      '/me',
    ]);
    expect(appTabs.length, lessThanOrEqualTo(5));
    expect(appTabs.where((t) => t.isAction).map((t) => t.path), ['/sell']);
    expect(appTabs[appTabs.length ~/ 2].isAction, isTrue);
  });

  test('định dạng tiền và đồng hồ', () {
    expect(formatVnd(120000, 'vi'), '120.000 ₫');
    expect(formatVnd(120000, 'en'), '120,000 ₫');
    expect(formatCountdown(const Duration(minutes: 29, seconds: 5)), '29:05');
    expect(
      formatCountdown(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
    expect(formatCountdown(const Duration(seconds: -5)), '00:00');
  });
}
