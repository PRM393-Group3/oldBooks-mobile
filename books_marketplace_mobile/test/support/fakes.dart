import 'dart:convert';
import 'dart:typed_data';

import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/paged_result.dart';
import 'package:books_marketplace_mobile/core/preview/in_memory_listings.dart';
import 'package:books_marketplace_mobile/core/storage/token_store.dart';
import 'package:books_marketplace_mobile/features/categories/data/category_repository.dart';
import 'package:books_marketplace_mobile/features/categories/domain/category.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:books_marketplace_mobile/features/notifications/data/notification_repository.dart';
import 'package:books_marketplace_mobile/features/notifications/domain/app_notification.dart';
import 'package:books_marketplace_mobile/features/orders/data/order_repository.dart';
import 'package:books_marketplace_mobile/features/orders/domain/sale_order.dart';
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

ResponseBody jsonResponse(
  int status,
  Map<String, dynamic> body, {
  Map<String, List<String>> headers = const {},
}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
    ...headers,
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

/// `401 UNAUTHENTICATED` kèm details token/expired: access token hết hạn.
Map<String, dynamic> expiredBody() => errorBody(
  'UNAUTHENTICATED',
  details: [
    {'field': 'token', 'message': 'expired'},
  ],
);

// ── Fake repository cho các module đăng bán, kiểm định, thông báo ───────────

Listing fakeListing({
  String id = 'L1',
  ListingStatus status = ListingStatus.published,
  BookInfo bookInfo = const BookInfo(),
  PersonRef? category,
  SellerInfo? seller = const SellerInfo(id: 's1', name: 'Nguyen Van A'),
  int? price,
  List<ListingPhoto> photos = const [],
  ListingReview? lastReview,
}) => Listing(
  id: id,
  status: status,
  bookInfo: bookInfo,
  category: category,
  seller: seller,
  price: price,
  images: photos,
  lastReview: lastReview,
  publishedAt: DateTime.utc(2026, 9, 20),
  updatedAt: DateTime.now(),
);

/// Bốn ảnh để đủ điều kiện gửi duyệt.
List<ListingPhoto> fourPhotos() => [
  for (var i = 0; i < 4; i++)
    ListingPhoto(
      id: 'p$i',
      url: 'http://blob/public/u1/p$i.jpg',
      thumbnailUrl: 'http://blob/public/u1/p$i-thumb.jpg',
      order: i,
    ),
];

const completeBookInfo = BookInfo(
  title: 'Nhà giả kim',
  author: 'Paulo Coelho',
  publicationYear: 2013,
  condition: BookCondition.good,
  description: 'Cuốn sách còn rất mới, bìa sạch, không ghi chú, không rách trang nào cả.',
);

/// Kho tin trong bộ nhớ với vài tiện ích cho test cũ: `browseItems` đặt danh
/// sách công khai, `stored` thêm/thay một tin.
class FakeListingRepository extends InMemoryListingRepository {
  FakeListingRepository();

  set browseItems(List<Listing> v) => replaceAll(v);

  set stored(Listing? v) {
    if (v != null) upsert(v);
  }
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

  NotificationSettings settings = const NotificationSettings();

  @override
  Future<int> markRead(List<String> ids) async {
    calls.addAll([for (final id in ids) 'read:$id']);
    items = [for (final n in items) ids.contains(n.id) ? n.asRead() : n];
    return unread = items.where((n) => !n.isRead).length;
  }

  @override
  Future<int> markAllRead() async {
    calls.add('readAll');
    items = [for (final n in items) n.asRead()];
    return unread = 0;
  }

  @override
  Future<NotificationSettings> getSettings() async => settings;

  @override
  Future<NotificationSettings> updateSettings({
    bool? marketing,
    bool? auctionWatch,
  }) async {
    calls.add('settings:$marketing:$auctionWatch');
    return settings = settings.copyWith(
      marketing: marketing,
      auctionWatch: auctionWatch,
    );
  }
}

/// Giỏ của server: thêm trùng không đổi gì, xóa không có thì vẫn thành công.
class FakeOrderRepository extends OrderRepository {
  FakeOrderRepository() : super(ApiClient(Dio()));

  final List<String> _ids = [];

  CartData get _data => CartData(
    items: [
      for (final id in _ids) CartLine(listingId: id, title: id, price: 1000),
    ],
    availableSubtotal: _ids.length * 1000,
  );

  @override
  Future<CartData> cart() async => _data;

  @override
  Future<CartData> addToCart(String listingId) async {
    if (!_ids.contains(listingId)) _ids.add(listingId);
    return _data;
  }

  @override
  Future<void> removeFromCart(String listingId) async => _ids.remove(listingId);
}
