// ignore_for_file: use_super_parameters
import 'package:dio/dio.dart';

import '../../features/auction_orders/data/auction_order_repository.dart';
import '../../features/auction_orders/domain/auction_order.dart';
import '../../features/auctions/data/auction_repository.dart';
import '../../features/auctions/domain/auction.dart';
import '../../features/listings/data/listing_repository.dart';
import '../network/api_client.dart';
import '../network/api_error.dart';
import '../network/paged_result.dart';
import '../util/server_clock.dart';

/// JSON một phiên theo đúng hình dạng `AuctionDto` của server, để dữ liệu mẫu
/// đi qua cùng đường parse với dữ liệu thật.
Map<String, dynamic> sampleAuctionJson({
  required String id,
  required String title,
  String author = 'Nguyễn Du',
  required String status,
  int startPrice = 500000,
  int bidStep = 20000,
  int? buyNowPrice = 900000,
  int? currentPrice,
  Map<String, dynamic>? myRegistration,
  bool canRegister = false,
  bool buyNowAvailable = false,
  Map<String, dynamic>? owner,
  Map<String, dynamic>? live,
  int registeredCount = 5,
  DateTime? startAt,
  DateTime? registrationClosesAt,
}) {
  final now = ServerClock.now();
  return {
    'id': id,
    'title': title,
    'author': author,
    'categoryId': 'c1',
    'condition': 'GOOD',
    'description': 'Sách hiếm, còn nguyên bìa, đã được kho Oldbook kiểm tra.',
    'status': status,
    'startPrice': startPrice,
    'bidStep': bidStep,
    'buyNowPrice': buyNowPrice,
    'durationMinutes': 120,
    'startAt': (startAt ?? now.add(const Duration(days: 2))).toIso8601String(),
    'registrationClosesAt': registrationClosesAt?.toIso8601String(),
    'participationFee': 10000,
    'deposit': startPrice ~/ 10,
    'registeredCount': registeredCount,
    'photos': const [],
    'seller': {'id': 's1', 'fullName': 'Trần Văn B'},
    'myRegistration': myRegistration,
    'canRegister': canRegister,
    'buyNowAvailable': buyNowAvailable,
    'currentPrice': currentPrice,
    'serverTime': now.toIso8601String(),
    'owner': owner,
    'live': live,
  };
}

AuctionSummary _summaryOf(Auction a) => AuctionSummary(
  id: a.id,
  title: a.title,
  author: a.author,
  status: a.status,
  startPrice: a.startPrice,
  buyNowPrice: a.buyNowPrice,
  startAt: a.startAt,
  registrationClosesAt: a.registrationClosesAt,
  registeredCount: a.registeredCount,
  currentPrice: a.currentPrice,
  endsAt: a.status == AuctionStatus.buyNowCountdown
      ? a.live?.countdownEndAt
      : a.live?.endAt,
  myRegistration: a.myRegistration?.status,
);

/// Kho phiên trong bộ nhớ cho chế độ xem trước và test. Các thao tác thay đổi
/// dữ liệu như server (đăng ký, trả giá, mua ngay), không kiểm tra ví.
class InMemoryAuctionRepository extends AuctionRepository {
  InMemoryAuctionRepository({List<Map<String, dynamic>>? seed})
    : super(ApiClient(Dio())) {
    for (final j in seed ?? previewAuctionSeed()) {
      _items[j['id'] as String] = Map.of(j);
    }
  }

  final Map<String, Map<String, dynamic>> _items = {};
  final Map<String, List<Map<String, dynamic>>> _bids = {};

  /// Lời gọi đã nhận (để test kiểm tra), ví dụ `bid a1 125000 key`.
  final List<String> calls = [];

  /// Lỗi ném ra ở lần gọi ghi kế tiếp (test giả lập lỗi server).
  ApiError? nextError;

  Auction _get(String id) {
    final j = _items[id];
    if (j == null) {
      throw const ApiError(status: 404, code: ApiErrorCode.auctionNotFound);
    }
    j['serverTime'] = ServerClock.now().toIso8601String();
    return Auction.fromJson(j);
  }

  void _throwIfQueued() {
    final e = nextError;
    if (e != null) {
      nextError = null;
      throw e;
    }
  }

  /// Đặt thẳng JSON một phiên (test).
  void put(Map<String, dynamic> json) => _items[json['id'] as String] = json;

  Map<String, dynamic>? raw(String id) => _items[id];

  @override
  Future<PagedResult<AuctionSummary>> list({
    AuctionListFilter filter = (status: null, q: null),
    String? sort,
    required int page,
    required int pageSize,
  }) async {
    final all = [
      for (final id in _items.keys)
        if (filter.status == null || _get(id).status == filter.status)
          _summaryOf(_get(id)),
    ];
    return PagedResult(
      items: all.skip((page - 1) * pageSize).take(pageSize).toList(),
      page: page,
      pageSize: pageSize,
      totalCount: all.length,
    );
  }

  @override
  Future<Auction> get(String id) async => _get(id);

  @override
  Future<PagedResult<Bid>> bids(
    String id, {
    required int page,
    required int pageSize,
  }) async {
    final list = [for (final b in _bids[id] ?? const []) Bid.fromJson(b)];
    return PagedResult(
      items: list.skip((page - 1) * pageSize).take(pageSize).toList(),
      page: page,
      pageSize: pageSize,
      totalCount: list.length,
    );
  }

  @override
  Future<PagedResult<AuctionSummary>> mine({
    required AuctionRole role,
    required int page,
    required int pageSize,
  }) async {
    bool match(Auction a) => switch (role) {
      AuctionRole.seller => a.isSeller,
      AuctionRole.bidder => a.myRegistration != null,
      AuctionRole.leading => a.isLeading && a.status.isRunning,
      AuctionRole.winner => a.live?.isWinner ?? false,
    };
    final all = [
      for (final id in _items.keys)
        if (match(_get(id))) _summaryOf(_get(id)),
    ];
    return PagedResult(
      items: all,
      page: page,
      pageSize: pageSize,
      totalCount: all.length,
    );
  }

  @override
  Future<Auction> register(String id, {required String idempotencyKey}) async {
    calls.add('register $id $idempotencyKey');
    _throwIfQueued();
    final j = _items[id]!;
    j['myRegistration'] = {
      'status': 'ACTIVE',
      'feeAmount': j['participationFee'],
      'depositAmount': j['deposit'],
      'createdAt': ServerClock.now().toIso8601String(),
    };
    j['canRegister'] = false;
    j['registeredCount'] = (j['registeredCount'] as int) + 1;
    return _get(id);
  }

  @override
  Future<Auction> unregister(String id) async {
    calls.add('unregister $id');
    _throwIfQueued();
    final j = _items[id]!;
    j['myRegistration'] = null;
    j['canRegister'] = true;
    j['registeredCount'] = (j['registeredCount'] as int) - 1;
    return _get(id);
  }

  void _applyBid(String id, int amount, {required bool buyNow}) {
    final j = _items[id]!;
    final live = Map<String, dynamic>.of(
      (j['live'] as Map?)?.cast<String, dynamic>() ?? {},
    );
    final step = j['bidStep'] as int;
    live['bidCount'] = ((live['bidCount'] as int?) ?? 0) + 1;
    live['leader'] = 'Ng***n';
    live['isLeading'] = true;
    live['minNextBid'] = amount + step;
    live['sequence'] = ((live['sequence'] as int?) ?? 0) + 1;
    j['currentPrice'] = amount;
    j['live'] = live;
    if (buyNow) {
      final now = ServerClock.now();
      j['status'] = 'BUY_NOW_COUNTDOWN';
      j['buyNowAvailable'] = false;
      live['buyNowAt'] = now.toIso8601String();
      live['countdownEndAt'] = now
          .add(const Duration(minutes: 30))
          .toIso8601String();
      live['hardEndAt'] = now.add(const Duration(hours: 24)).toIso8601String();
    }
    (_bids[id] ??= []).insert(0, {
      'id': 'b${live['sequence']}',
      'amount': amount,
      'kind': buyNow ? 'BUY_NOW' : 'BID',
      'bidder': 'Ng***n',
      'isMine': true,
      'placedAt': ServerClock.now().toIso8601String(),
    });
  }

  @override
  Future<Auction> placeBid(
    String id, {
    required int amount,
    required String idempotencyKey,
  }) async {
    calls.add('bid $id $amount $idempotencyKey');
    _throwIfQueued();
    final a = _get(id);
    if (amount < a.minNextBid) {
      throw ApiError(
        status: 422,
        code: ApiErrorCode.bidTooLow,
        fieldErrors: {'min_amount': '${a.minNextBid}'},
      );
    }
    _applyBid(id, amount, buyNow: false);
    return _get(id);
  }

  @override
  Future<Auction> buyNow(String id, {required String idempotencyKey}) async {
    calls.add('buyNow $id $idempotencyKey');
    _throwIfQueued();
    final a = _get(id);
    _applyBid(id, a.buyNowPrice ?? 0, buyNow: true);
    return _get(id);
  }

  @override
  Future<String> uploadPhoto(NewPhoto photo) async => 'blob-${photo.fileName}';

  @override
  Future<Auction> create(CreateAuctionInput input) async {
    calls.add('create ${input.title}');
    _throwIfQueued();
    final id = 'new${_items.length + 1}';
    _items[id] = sampleAuctionJson(
      id: id,
      title: input.title,
      author: input.author,
      status: 'AWAITING_INBOUND',
      startPrice: input.startPrice,
      bidStep: input.bidStep,
      buyNowPrice: input.buyNowPrice,
      startAt: input.desiredStartAt,
      owner: _ownerJson('OB7K2M9XQ4'),
    );
    return _get(id);
  }

  @override
  Future<Auction> cancel(String id, {String? reason}) async {
    calls.add('cancel $id');
    _throwIfQueued();
    _items[id]!['status'] = 'CANCELLED';
    return _get(id);
  }

  @override
  Future<Auction> fallback(
    String id, {
    required FallbackChoice choice,
    DateTime? startAt,
    int? price,
  }) async {
    calls.add('fallback $id ${choice.api}');
    _throwIfQueued();
    _items[id]!['status'] = switch (choice) {
      FallbackChoice.reschedule => 'REGISTRATION_OPEN',
      FallbackChoice.convertToSale => 'CONVERTED_TO_SALE',
      FallbackChoice.returnBook => 'RETURNED',
    };
    return _get(id);
  }
}

Map<String, dynamic> _ownerJson(String code) => {
  'inboundCode': code,
  'inboundDeadlineAt': ServerClock.now()
      .add(const Duration(days: 5))
      .toIso8601String(),
  'warehouse': {
    'recipient': 'Kho Oldbook',
    'phone': '0900000002',
    'address': '123 Đường Mẫu, Quận 1, TP. HCM',
  },
  'rescheduleCount': 0,
  'rescheduleRemaining': 1,
};

/// Phiên mẫu ở các trạng thái chính.
List<Map<String, dynamic>> previewAuctionSeed() {
  final now = ServerClock.now();
  String at(Duration d) => now.add(d).toIso8601String();
  const confirmed = {
    'status': 'CONFIRMED',
    'feeAmount': 10000,
    'depositAmount': 50000,
    'createdAt': '2026-10-01T00:00:00Z',
  };
  return [
    sampleAuctionJson(
      id: 'a-live',
      title: 'Truyện Kiều (bản 1925)',
      status: 'LIVE',
      currentPrice: 640000,
      myRegistration: confirmed,
      buyNowAvailable: true,
      live: {
        'liveAt': at(const Duration(minutes: -30)),
        'endAt': at(const Duration(minutes: 42)),
        'bidCount': 6,
        'leader': 'Tr***g',
        'isLeading': false,
        'minNextBid': 660000,
        'sequence': 6,
        'isWinner': false,
      },
    ),
    sampleAuctionJson(
      id: 'a-countdown',
      title: 'Số đỏ (in lần đầu)',
      author: 'Vũ Trọng Phụng',
      status: 'BUY_NOW_COUNTDOWN',
      currentPrice: 900000,
      myRegistration: confirmed,
      live: {
        'endAt': at(const Duration(hours: 1)),
        'buyNowAt': at(const Duration(minutes: -5)),
        'countdownEndAt': at(const Duration(minutes: 25)),
        'hardEndAt': at(const Duration(hours: 23)),
        'bidCount': 9,
        'leader': 'Ng***n',
        'isLeading': true,
        'minNextBid': 920000,
        'sequence': 11,
        'isWinner': false,
      },
    ),
    sampleAuctionJson(
      id: 'a-reg',
      title: 'Vang bóng một thời',
      author: 'Nguyễn Tuân',
      status: 'REGISTRATION_OPEN',
      canRegister: true,
      registrationClosesAt: now.add(const Duration(days: 1)),
    ),
    sampleAuctionJson(
      id: 'a-sold',
      title: 'Dế mèn phiêu lưu ký (1941)',
      author: 'Tô Hoài',
      status: 'ENDED_SOLD',
      currentPrice: 780000,
      myRegistration: {...confirmed, 'status': 'COMPLETED'},
      live: {
        'endedAt': at(const Duration(days: -1)),
        'bidCount': 12,
        'leader': 'Ng***n',
        'isLeading': true,
        'minNextBid': 800000,
        'sequence': 12,
        'winner': 'Ng***n',
        'finalPrice': 780000,
        'isWinner': true,
        'auctionOrderId': 'o-fee',
      },
    ),
    sampleAuctionJson(
      id: 'a-mine',
      title: 'Tắt đèn',
      author: 'Ngô Tất Tố',
      status: 'AWAITING_INBOUND',
      owner: _ownerJson('OB4Q8R2TZ7'),
    ),
  ];
}

/// Kho đơn đấu giá trong bộ nhớ.
class InMemoryAuctionOrderRepository extends AuctionOrderRepository {
  InMemoryAuctionOrderRepository({List<Map<String, dynamic>>? seed})
    : super(ApiClient(Dio())) {
    for (final j in seed ?? previewAuctionOrderSeed()) {
      _items[j['id'] as String] = Map.of(j);
    }
  }

  final Map<String, Map<String, dynamic>> _items = {};
  final List<String> calls = [];
  ApiError? nextError;

  void _throwIfQueued() {
    final e = nextError;
    if (e != null) {
      nextError = null;
      throw e;
    }
  }

  AuctionOrder _get(String id) {
    final j = _items[id];
    if (j == null) {
      throw const ApiError(
        status: 404,
        code: ApiErrorCode.auctionOrderNotFound,
      );
    }
    return AuctionOrder.fromJson(j);
  }

  @override
  Future<PagedResult<AuctionOrder>> list({
    OrderViewerRole role = OrderViewerRole.buyer,
    AuctionOrderStatus? status,
    required int page,
    required int pageSize,
  }) async {
    final all = [
      for (final id in _items.keys)
        if (_get(id).viewerRole == role &&
            (status == null || _get(id).status == status))
          _get(id),
    ];
    return PagedResult(
      items: all,
      page: page,
      pageSize: pageSize,
      totalCount: all.length,
    );
  }

  @override
  Future<AuctionOrder> get(String id) async => _get(id);

  @override
  Future<AuctionOrder> setAddress(String id, String addressId) async {
    calls.add('address $id $addressId');
    _throwIfQueued();
    _items[id]!['address'] = {
      'recipientName': 'Nguyễn Minh Anh',
      'phone': '0912345482',
      'province': 'TP. HCM',
      'district': 'Quận 1',
      'ward': 'Bến Nghé',
      'detail': '12 Lê Lợi',
    };
    return _get(id);
  }

  @override
  Future<AuctionOrder> payShippingFee(
    String id, {
    required String idempotencyKey,
  }) async {
    calls.add('fee $id $idempotencyKey');
    _throwIfQueued();
    _items[id]!['shippingFeeHeld'] = true;
    _items[id]!['status'] = 'READY_TO_SHIP';
    return _get(id);
  }

  @override
  Future<AuctionOrder> storageChoice(
    String id,
    CollectionChoice choice, {
    required String idempotencyKey,
  }) async {
    calls.add('storage $id ${choice.api} $idempotencyKey');
    _throwIfQueued();
    final storage = Map<String, dynamic>.of(
      (_items[id]!['storage'] as Map).cast<String, dynamic>(),
    );
    storage['choice'] = choice.api;
    _items[id]!['storage'] = storage;
    return _get(id);
  }

  @override
  Future<AuctionOrder> postExpiry(
    String id,
    PostExpiryAction action, {
    required String idempotencyKey,
  }) async {
    calls.add('postExpiry $id ${action.api} $idempotencyKey');
    _throwIfQueued();
    final pe = Map<String, dynamic>.of(
      (_items[id]!['postExpiry'] as Map).cast<String, dynamic>(),
    );
    if (action == PostExpiryAction.extend) {
      pe['status'] = 'EXTENDED';
      pe['extensionCount'] = (pe['extensionCount'] as int) + 1;
      pe['extendedUntil'] = ServerClock.now()
          .add(Duration(days: pe['extensionDays'] as int))
          .toIso8601String();
    } else {
      pe['choice'] = action.api;
    }
    _items[id]!['postExpiry'] = pe;
    return _get(id);
  }
}

/// JSON một đơn theo hình dạng `AuctionOrderDto`.
Map<String, dynamic> sampleAuctionOrderJson({
  required String id,
  required String status,
  String viewerRole = 'BUYER',
  bool shippingFeeHeld = false,
  Map<String, dynamic>? address,
  Map<String, dynamic>? storage,
  Map<String, dynamic>? postExpiry,
  Map<String, dynamic>? delivery,
  int? commission,
}) {
  final now = ServerClock.now();
  return {
    'id': id,
    'auctionId': 'a-sold',
    'bookTitle': 'Dế mèn phiêu lưu ký (1941)',
    'thumbnailUrl': null,
    'status': status,
    'viewerRole': viewerRole,
    'finalPrice': 780000,
    'shippingFee': 30000,
    'shippingFeeHeld': shippingFeeHeld,
    'shippingFeeUnpaid': 0,
    'shippingFeeDueAt': now.add(const Duration(days: 2)).toIso8601String(),
    'depositAmount': 50000,
    'address': address,
    'delivery':
        delivery ??
        {
          'round': 1,
          'attemptCount': 0,
          'failedAttempts': 0,
          'maxAttempts': 3,
          'attempts': const [],
        },
    'storage': storage,
    'postExpiry': postExpiry,
    'complaintId': null,
    'commission': commission,
    'createdAt': now.add(const Duration(days: -1)).toIso8601String(),
  };
}

const _sampleOrderAddress = {
  'recipientName': 'Nguyễn Minh Anh',
  'phone': '0912345482',
  'province': 'TP. HCM',
  'district': 'Quận 1',
  'ward': 'Bến Nghé',
  'detail': '12 Lê Lợi',
};

List<Map<String, dynamic>> previewAuctionOrderSeed() {
  final now = ServerClock.now();
  String at(Duration d) => now.add(d).toIso8601String();
  return [
    sampleAuctionOrderJson(id: 'o-fee', status: 'AWAITING_SHIPPING_FEE'),
    sampleAuctionOrderJson(
      id: 'o-storage',
      status: 'IN_STORAGE',
      address: _sampleOrderAddress,
      storage: {
        'startedAt': at(const Duration(days: -2)),
        'expiresAt': at(const Duration(days: 5)),
        'feePerDay': 5000,
        'feeAccrued': 10000,
      },
      delivery: {
        'round': 1,
        'attemptCount': 3,
        'failedAttempts': 3,
        'maxAttempts': 3,
        'carrier': 'GHN',
        'trackingNumber': 'GHN123456',
        'attempts': [
          for (var i = 1; i <= 3; i++)
            {
              'round': 1,
              'attemptNo': i,
              'result': 'FAILED',
              'reason': 'Không liên lạc được người nhận',
              'recordedAt': at(Duration(days: -5 + i)),
            },
        ],
      },
    ),
    sampleAuctionOrderJson(
      id: 'o-expired',
      status: 'STORAGE_EXPIRED',
      address: _sampleOrderAddress,
      postExpiry: {
        'status': 'AWAITING_DECISION',
        'decisionDeadlineAt': at(const Duration(days: 3)),
        'extensionCount': 0,
        'extensionMaxTimes': 2,
        'extensionDays': 7,
        'extensionFee': 35000,
      },
    ),
    sampleAuctionOrderJson(
      id: 'o-sold',
      status: 'IN_DELIVERY',
      viewerRole: 'SELLER',
      commission: 78000,
    ),
  ];
}
