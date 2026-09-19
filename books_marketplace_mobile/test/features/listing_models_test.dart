import 'package:books_marketplace_mobile/app/nav_config.dart';
import 'package:books_marketplace_mobile/core/l10n/app_localizations_vi.dart';
import 'package:books_marketplace_mobile/core/network/paged_result.dart';
import 'package:books_marketplace_mobile/core/util/format.dart';
import 'package:books_marketplace_mobile/core/validation/isbn.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/inspection/domain/inspection.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_input.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_rules.dart';
import 'package:books_marketplace_mobile/features/listings/presentation/seller/wizard/wizard_fields.dart';
import 'package:books_marketplace_mobile/features/notifications/domain/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Listing.fromJson', () {
    test('ListingDto đầy đủ', () {
      final l = Listing.fromJson({
        'id': 'L1',
        'status': 'Rejected',
        'saleMethod': 'FixedPrice',
        'seller': {'id': 'u1', 'fullName': 'Nguyen Van A'},
        'category': {'id': 'c1', 'name': 'Tiểu thuyết'},
        'bookInfo': {
          'title': 'Nhà giả kim',
          'author': 'Paulo Coelho',
          'condition': 'VeryGood',
          'coverType': 'Paperback',
          'publicationYear': 2013,
        },
        'fixedPrice': {'price': 120000, 'quantity': 2},
        'images': [
          {
            'id': 'i2',
            'url': 'http://x/public/u1/b.png',
            'type': 'BackCover',
            'displayOrder': 1,
          },
          {
            'id': 'i1',
            'url': 'http://x/public/u1/a.png',
            'type': 'FrontCover',
            'displayOrder': 0,
          },
        ],
        'submissionCount': 2,
        'maxSubmissions': 4,
        'latestInspection': {
          'reportId': 'r1',
          'decision': 'Rejected',
          'reasonCodes': ['BlurryPhotos'],
          'note': 'Ảnh mờ quá',
          'submissionNumber': 2,
          'decidedAt': '2026-09-19T08:30:18Z',
        },
      });

      expect(l.status, ListingStatus.rejected);
      expect(l.saleMethod, SaleMethod.fixedPrice);
      expect(l.title, 'Nhà giả kim');
      expect(l.bookInfo.condition, BookCondition.veryGood);
      expect(l.fixedPrice!.price, 120000);
      expect(l.displayPrice, 120000);
      expect(l.submissionsLeft, 2);
      expect(l.latestInspection!.reasonCodes, ['BlurryPhotos']);
      expect(l.latestInspection!.isApproved, isFalse);
      // Ảnh được sắp theo displayOrder, bìa trước làm ảnh đại diện.
      expect(l.images.first.type, ImageType.frontCover);
      expect(l.coverImageUrl, 'http://x/public/u1/a.png');
    });

    test('dòng danh sách rút gọn, phẳng, thiếu nhiều trường', () {
      final l = Listing.fromJson({
        'id': 'L2',
        'status': 'OnSale',
        'title': 'Sapiens',
        'author': 'Yuval Harari',
        'price': 99000,
        'thumbnailUrl': 'http://x/t.png',
      });

      expect(l.title, 'Sapiens');
      expect(l.bookInfo.author, 'Yuval Harari');
      expect(l.displayPrice, 99000);
      expect(l.coverImageUrl, 'http://x/t.png');
      expect(l.images, isEmpty);
    });

    test('đấu giá: giá hiển thị là giá khởi điểm', () {
      final l = Listing.fromJson({
        'id': 'L3',
        'status': 'Auctioning',
        'saleMethod': 'Auction',
        'auction': {
          'startingPrice': 500000,
          'minBidIncrement': 5000,
          'durationDays': 5,
          'startMode': 'Scheduled',
          'scheduledStartAt': '2026-10-01T03:00:00Z',
          'endsAt': '2026-10-06T03:00:00Z',
        },
      });
      expect(l.displayPrice, 500000);
      expect(l.auction!.startMode, AuctionStartMode.scheduled);
      expect(l.auction!.endsAt!.isUtc, isTrue);
    });

    test('trạng thái lạ không làm hỏng parse', () {
      expect(
        Listing.fromJson({'id': 'x', 'status': 'Whatever'}).status,
        ListingStatus.unknown,
      );
    });

    test('blobName suy từ URL sau /public/', () {
      const azurite = ListingImage(
        url: 'http://127.0.0.1:10000/devstoreaccount1/public/u1/abc.png',
        type: ImageType.spine,
      );
      const prod = ListingImage(
        url: 'https://acct.blob.core.windows.net/public/u1/abc.webp?sv=1',
        type: ImageType.spine,
      );
      const other = ListingImage(
        url: 'http://x/img/abc.png',
        type: ImageType.spine,
      );
      expect(azurite.blobName, 'u1/abc.png');
      expect(prod.blobName, 'u1/abc.webp');
      expect(other.blobName, isNull);
    });

    test('quyền sửa và công khai theo trạng thái', () {
      expect(ListingStatus.draft.isEditable, isTrue);
      expect(ListingStatus.rejected.isEditable, isTrue);
      expect(ListingStatus.pendingInspection.isEditable, isFalse);
      expect(ListingStatus.onSale.isPublic, isTrue);
      expect(ListingStatus.auctioning.isPublic, isTrue);
      expect(ListingStatus.closed.isPublic, isFalse);
    });
  });

  group('ListingRules', () {
    test('mặc định khớp doc', () {
      const r = ListingRules();
      expect(r.maxSubmissions, 4);
      expect(r.minImages, 3);
      expect(r.maxImages, 10);
      expect(r.maxExtraImages, 6);
      expect(r.maxImageBytes, 10 * 1024 * 1024);
      expect(r.auctionDurations, [3, 5, 7, 10]);
    });

    test('đọc từ server, thiếu thì rơi về mặc định', () {
      final r = ListingRules.fromJson({'maxSubmissions': 5, 'minPrice': 20000});
      expect(r.maxSubmissions, 5);
      expect(r.minPrice, 20000);
      expect(r.maxPrice, 50000000);
      expect(ListingRules.fromJson(null).maxImages, 10);
    });

    test('BR-08: bước giá tối thiểu = max(1.000, 1% làm tròn lên)', () {
      const r = ListingRules();
      expect(r.minBidIncrementFor(10000), 1000);
      expect(r.minBidIncrementFor(500000), 5000);
      expect(r.minBidIncrementFor(500001), 5001);
      expect(r.minBidIncrementFor(50000000), 500000);
    });
  });

  group('đầu vào', () {
    test('BookInfoInput: chuỗi trống thành null, ngôn ngữ chữ thường', () {
      const input = BookInfoInput(
        title: '  Nhà giả kim ',
        author: 'Paulo',
        categoryId: 'c1',
        condition: BookCondition.good,
        description: 'mô tả',
        publisher: '  ',
        isbn: '',
        language: 'VI',
        coverType: CoverType.hardcover,
      );
      final j = input.toJson();
      expect(j['title'], 'Nhà giả kim');
      expect(j['publisher'], isNull);
      expect(j['isbn'], isNull);
      expect(j['language'], 'vi');
      expect(j['coverType'], 'Hardcover');
      expect(j['condition'], 'Good');
    });

    test('AuctionInput: chỉ gửi scheduledStartAt khi hẹn giờ, dạng UTC', () {
      final at = DateTime.utc(2026, 10, 1, 3);
      final scheduled = const AuctionInput(
        startingPrice: 500000,
        minBidIncrement: 5000,
        durationDays: 5,
        startMode: AuctionStartMode.scheduled,
      ).toJson();
      expect((scheduled['auction'] as Map)['scheduledStartAt'], isNull);

      final ok = AuctionInput(
        startingPrice: 500000,
        minBidIncrement: 5000,
        durationDays: 5,
        startMode: AuctionStartMode.scheduled,
        scheduledStartAt: at,
      ).toJson();
      expect(
        (ok['auction'] as Map)['scheduledStartAt'],
        '2026-10-01T03:00:00.000Z',
      );

      final now = const AuctionInput(
        startingPrice: 500000,
        minBidIncrement: 5000,
        durationDays: 5,
        startMode: AuctionStartMode.onApproval,
      ).toJson();
      expect((now['auction'] as Map).containsKey('scheduledStartAt'), isFalse);
      expect(now['method'], 'Auction');
    });

    test('FixedPriceInput', () {
      expect(const FixedPriceInput(price: 120000, quantity: 2).toJson(), {
        'method': 'FixedPrice',
        'fixedPrice': {'price': 120000, 'quantity': 2},
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

  group('kiểm định, thông báo', () {
    test('QueueItem: tin phẳng kèm số liệu, hoặc lồng trong listing', () {
      final flat = QueueItem.fromJson({
        'id': 'L1',
        'status': 'PendingInspection',
        'title': 'A',
        'waitingHours': 19.5,
        'isOverdue': true,
      });
      expect(flat.listing.id, 'L1');
      expect(flat.isOverdue, isTrue);
      expect(flat.waitingHours, 19.5);

      final nested = QueueItem.fromJson({
        'listing': {'id': 'L2', 'status': 'InInspection'},
        'claimExpiresAt': '2026-09-19T09:00:00Z',
      });
      expect(nested.listing.id, 'L2');
      expect(nested.claimExpiresAt!.isUtc, isTrue);
    });

    test('QueueFilter so sánh theo giá trị (khóa của family provider)', () {
      expect(
        const QueueFilter(categoryId: 'c', priceFrom: 1),
        const QueueFilter(categoryId: 'c', priceFrom: 1),
      );
      expect(const QueueFilter().isEmpty, isTrue);
    });

    test('RejectReason: nhãn theo mã, mã lạ trả nguyên mã', () {
      final l = AppLocalizationsVi();
      expect(
        RejectReason.labelOf('BlurryPhotos', l),
        'Ảnh không đủ hoặc không rõ',
      );
      expect(RejectReason.labelOf('Mystery', l), 'Mystery');
      expect(RejectReason.values.length, 7);
    });

    test('thông báo: loại đã biết có tiêu đề bản địa hóa', () {
      final n = AppNotification.fromJson({
        'id': 'n1',
        'type': 'ListingApproved',
        'title': 'Your listing was approved',
        'body': 'english body',
        'isRead': false,
        'listingId': 'L1',
        'createdAt': '2026-09-19T08:30:18Z',
      });
      expect(
        n.type.title(AppLocalizationsVi()),
        'Tin đăng của bạn đã được duyệt',
      );
      expect(n.asRead().isRead, isTrue);
      expect(NotificationType.fromApi('Nope'), NotificationType.unknown);
    });
  });

  group('wizard', () {
    test('trường lỗi của server ánh xạ về đúng bước', () {
      expect(stepForField('bookInfo.title'), WizardStep.book);
      expect(stepForField('categoryId'), WizardStep.book);
      expect(stepForField('images'), WizardStep.photos);
      expect(stepForField('images[0].blobName'), WizardStep.photos);
      expect(stepForField('saleMethod'), WizardStep.sale);
      expect(stepForField('fixedPrice.price'), WizardStep.sale);
      expect(stepForField('auction.startingPrice'), WizardStep.sale);
    });

    test('nhãn trường thiếu bằng tiếng Việt, trường lạ giữ nguyên', () {
      final l = AppLocalizationsVi();
      expect(labelForField(l, 'bookInfo.title'), 'Tên sách');
      expect(labelForField(l, 'bookInfo.description'), 'Mô tả');
      expect(labelForField(l, 'images'), 'Ảnh (đủ 4 góc)');
      expect(labelForField(l, 'fixedPrice.price'), 'Giá bán');
      expect(labelForField(l, 'weird.field'), 'weird.field');
    });

    test('khóa lỗi bỏ tiền tố và chữ thường', () {
      expect(fieldKeys({'bookInfo.publicationYear': 'x'}), {
        'publicationyear': 'x',
      });
    });
  });

  group('điều hướng theo vai trò', () {
    List<String> paths(UserRole r) => tabsFor(r).map((t) => t.path).toList();

    test('mỗi vai trò có đúng tab, không quá 5', () {
      expect(paths(UserRole.buyer), ['/home', '/notifications', '/profile']);
      expect(paths(UserRole.seller), [
        '/home',
        '/listings/mine',
        '/notifications',
        '/profile',
      ]);
      expect(paths(UserRole.inspector), [
        '/inspection/queue',
        '/inspection/mine',
        '/notifications',
        '/profile',
      ]);
      expect(paths(UserRole.admin), ['/profile']);
      for (final r in UserRole.values) {
        expect(tabsFor(r).length, lessThanOrEqualTo(5));
      }
    });

    test('màn hình mặc định theo vai trò', () {
      expect(homePathFor(UserRole.buyer), '/home');
      expect(homePathFor(UserRole.seller), '/home');
      expect(homePathFor(UserRole.inspector), '/inspection/queue');
      expect(homePathFor(UserRole.admin), '/profile');
    });

    test('chỉ tab thông báo có badge', () {
      final badged = tabsFor(UserRole.seller).where((t) => t.showsUnreadBadge);
      expect(badged.map((t) => t.path), ['/notifications']);
    });
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
