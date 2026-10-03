import 'dart:convert';
import 'dart:typed_data';

import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/network/paged_result.dart';
import 'package:books_marketplace_mobile/core/storage/token_store.dart';
import 'package:books_marketplace_mobile/features/categories/data/category_repository.dart';
import 'package:books_marketplace_mobile/features/categories/domain/category.dart';
import 'package:books_marketplace_mobile/features/listings/data/listing_repository.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_input.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_rules.dart';
import 'package:books_marketplace_mobile/features/notifications/data/notification_repository.dart';
import 'package:books_marketplace_mobile/features/notifications/domain/app_notification.dart';
import 'package:dio/dio.dart';

/// TokenStore chạy trong bộ nhớ, không chạm Keychain.
class MemoryTokenStore extends TokenStore {
  MemoryTokenStore({this._access, this._refresh});

  String? _access;
  String? _refresh;

  @override
  String? get accessToken => _access;
  @override
  String? get refreshToken => _refresh;
  @override
  bool get hasSession => _refresh != null;

  @override
  Future<void> load() async {}

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

/// Adapter giả cho Dio: ghi lại các lời gọi và trả lời theo [handler].
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<String> calls = [];

  int count(String path) => calls.where((c) => c.contains(' $path ')).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(
      '${options.method} ${options.path} ${options.headers['Authorization']}',
    );
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(int status, Map<String, dynamic> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

Map<String, dynamic> okBody(Object data) => {
  'success': true,
  'data': data,
  'traceId': 't',
};

Map<String, dynamic> errorBody(
  String code, {
  List<Map<String, String>>? details,
}) => {
  'success': false,
  'error': {'code': code, 'message': 'english message', 'details': ?details},
  'traceId': 'trace-1',
};

// ── Fake repository cho các module đăng bán, kiểm định, thông báo ───────────

Listing fakeListing({
  String id = 'L1',
  ListingStatus status = ListingStatus.draft,
  BookInfo bookInfo = const BookInfo(),
  PersonRef? category,
  PersonRef? seller = const PersonRef(id: 'u1', name: 'Nguyen Van A'),
  SaleMethod? saleMethod,
  FixedPriceConfig? fixedPrice,
  AuctionConfig? auction,
  List<ListingImage> images = const [],
  int submissionCount = 0,
  InspectionSummary? latestInspection,
}) => Listing(
  id: id,
  status: status,
  bookInfo: bookInfo,
  category: category,
  seller: seller,
  saleMethod: saleMethod,
  fixedPrice: fixedPrice,
  auction: auction,
  images: images,
  submissionCount: submissionCount,
  latestInspection: latestInspection,
  updatedAt: DateTime.now(),
);

/// Bộ ảnh đủ 4 góc.
List<ListingImage> fourAngles() => [
  for (final t in ImageType.required)
    ListingImage(url: 'http://blob/public/u1/${t.api}.png', type: t),
];

const completeBookInfo = BookInfo(
  title: 'Nhà giả kim',
  author: 'Paulo Coelho',
  publicationYear: 2013,
  language: 'vi',
  condition: BookCondition.veryGood,
  description: 'Cuốn sách còn rất mới, bìa sạch, không ghi chú, không rách trang nào cả.',
);

class FakeListingRepository extends ListingRepository {
  FakeListingRepository() : super(ApiClient(Dio()));

  final calls = <String>[];
  Listing? stored;
  List<Listing> browseItems = [];
  List<Listing> mineItems = [];
  ApiError? submitError;
  ApiError? saveBookInfoError;

  @override
  Future<ListingRules> rules() async => const ListingRules();

  @override
  Future<Listing> create() async {
    calls.add('create');
    return stored = fakeListing();
  }

  @override
  Future<Listing> get(String id) async {
    calls.add('get:$id');
    return stored ?? fakeListing(id: id);
  }

  @override
  Future<Listing> saveBookInfo(String id, BookInfoInput input) async {
    calls.add('bookInfo');
    if (saveBookInfoError != null) throw saveBookInfoError!;
    final s = stored ?? fakeListing(id: id);
    return stored = fakeListing(
      id: id,
      status: s.status,
      submissionCount: s.submissionCount,
      bookInfo: BookInfo(
        title: input.title,
        author: input.author,
        language: input.language,
        publicationYear: input.publicationYear,
        condition: input.condition,
        description: input.description,
      ),
      category: const PersonRef(id: 'c1', name: 'Tiểu thuyết'),
      saleMethod: s.saleMethod,
      fixedPrice: s.fixedPrice,
      auction: s.auction,
      images: s.images,
    );
  }

  @override
  Future<Listing> saveImages(
    String id,
    List<({String blobName, ImageType type})> images,
  ) async {
    calls.add('images:${images.length}');
    // PUT /images chỉ thay ảnh; các trường khác của tin phải được giữ nguyên,
    // giống hợp đồng thật của backend (mỗi bước chỉ sửa đúng phần của nó).
    final s = stored!;
    return stored = fakeListing(
      id: id,
      status: s.status,
      bookInfo: s.bookInfo,
      category: s.category,
      saleMethod: s.saleMethod,
      fixedPrice: s.fixedPrice,
      auction: s.auction,
      submissionCount: s.submissionCount,
      images: [
        for (final i in images)
          ListingImage(url: 'http://blob/public/${i.blobName}', type: i.type),
      ],
    );
  }

  @override
  Future<Listing> saveSaleMethod(String id, SaleMethodInput input) async {
    calls.add('sale:${input.toJson()['method']}');
    final s = stored!;
    return stored = fakeListing(
      id: id,
      status: s.status,
      submissionCount: s.submissionCount,
      bookInfo: s.bookInfo,
      category: s.category,
      images: s.images,
      saleMethod: input is FixedPriceInput
          ? SaleMethod.fixedPrice
          : SaleMethod.auction,
      fixedPrice: input is FixedPriceInput
          ? FixedPriceConfig(price: input.price, quantity: input.quantity)
          : null,
      auction: input is AuctionInput
          ? AuctionConfig(
              startingPrice: input.startingPrice,
              minBidIncrement: input.minBidIncrement,
              durationDays: input.durationDays,
              startMode: input.startMode,
            )
          : null,
    );
  }

  @override
  Future<({Listing listing, SubmitResult result})> submit(String id) async {
    calls.add('submit');
    if (submitError != null) throw submitError!;
    final s = stored!;
    stored = fakeListing(
      id: id,
      status: ListingStatus.pendingInspection,
      bookInfo: s.bookInfo,
      category: s.category,
      images: s.images,
      saleMethod: s.saleMethod,
      fixedPrice: s.fixedPrice,
      auction: s.auction,
      submissionCount: 1,
    );
    return (
      listing: stored!,
      result: const SubmitResult(estimatedProcessingHours: 24),
    );
  }

  @override
  Future<void> delete(String id) async => calls.add('delete:$id');

  @override
  Future<PagedResult<Listing>> mine({
    ListingStatus? status,
    required int page,
    required int pageSize,
  }) async {
    calls.add('mine:${status?.api}');
    final items = status == null
        ? mineItems
        : mineItems.where((l) => l.status == status).toList();
    return PagedResult(
      items: items,
      page: page,
      pageSize: pageSize,
      totalCount: items.length,
    );
  }

  @override
  Future<Map<ListingStatus, int>> mineSummary() async => {
    ListingStatus.draft: mineItems
        .where((l) => l.status == ListingStatus.draft)
        .length,
  };

  @override
  Future<PagedResult<Listing>> browse({
    String? categoryId,
    required int page,
    required int pageSize,
  }) async => PagedResult(
    items: browseItems,
    page: page,
    pageSize: pageSize,
    totalCount: browseItems.length,
  );
}

class FakeCategoryRepository extends CategoryRepository {
  FakeCategoryRepository() : super(ApiClient(Dio()));

  @override
  Future<List<CategoryNode>> tree() async => const [
    CategoryNode(
      id: 'c0',
      name: 'Văn học',
      children: [CategoryNode(id: 'c1', name: 'Tiểu thuyết')],
    ),
  ];
}

class FakeNotificationRepository extends NotificationRepository {
  FakeNotificationRepository() : super(ApiClient(Dio()));

  int unread = 0;
  List<AppNotification> items = [];
  final calls = <String>[];

  @override
  Future<int> unreadCount() async => unread;

  @override
  Future<PagedResult<AppNotification>> list({
    bool unreadOnly = false,
    required int page,
    required int pageSize,
  }) async => PagedResult(
    items: unreadOnly ? items.where((n) => !n.isRead).toList() : items,
    page: page,
    pageSize: pageSize,
    totalCount: items.length,
  );

  @override
  Future<void> markRead(String id) async {
    calls.add('read:$id');
    items = [for (final n in items) n.id == id ? n.asRead() : n];
    unread = items.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markAllRead() async {
    calls.add('readAll');
    items = [for (final n in items) n.asRead()];
    unread = 0;
  }
}
