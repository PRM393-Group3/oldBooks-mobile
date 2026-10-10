import '../../../core/l10n/app_localizations.dart';
import '../../../core/util/json_read.dart';

/// Trạng thái đơn bán thường (`09-orders`). Mã lạ rơi vào [unknown].
enum SaleOrderStatus {
  paidAwaitingShipment('PAID_AWAITING_SHIPMENT'),
  shipped('SHIPPED'),
  delivered('DELIVERED'),
  completed('COMPLETED'),
  cancelledByBuyer('CANCELLED_BY_BUYER'),
  cancelledSellerTimeout('CANCELLED_SELLER_TIMEOUT'),
  disputed('DISPUTED'),
  refunded('REFUNDED'),
  partiallyRefunded('PARTIALLY_REFUNDED'),
  unknown('');

  const SaleOrderStatus(this.api);
  final String api;

  static SaleOrderStatus fromApi(String? v) => values.firstWhere(
    (s) => s.api == v && s != unknown,
    orElse: () => unknown,
  );

  /// Bộ lọc hiển thị trong danh sách.
  static const filters = [
    paidAwaitingShipment,
    shipped,
    delivered,
    completed,
    disputed,
    cancelledByBuyer,
    cancelledSellerTimeout,
    refunded,
    partiallyRefunded,
  ];

  /// Đơn còn phải theo dõi (chưa kết thúc).
  bool get isOpen =>
      this == paidAwaitingShipment ||
      this == shipped ||
      this == delivered ||
      this == disputed;

  String label(AppLocalizations l) => switch (this) {
    paidAwaitingShipment => l.soStatusAwaiting,
    shipped => l.soStatusShipped,
    delivered => l.soStatusDelivered,
    completed => l.soStatusCompleted,
    cancelledByBuyer => l.soStatusCancelledBuyer,
    cancelledSellerTimeout => l.soStatusCancelledTimeout,
    disputed => l.soStatusDisputed,
    refunded => l.soStatusRefunded,
    partiallyRefunded => l.soStatusPartial,
    unknown => l.statusUnknown,
  };
}

/// Vai trò của người dùng trong đơn.
enum OrderRole {
  buyer('BUYER'),
  seller('SELLER');

  const OrderRole(this.api);
  final String api;

  static OrderRole? fromApi(String? v) {
    for (final r in values) {
      if (r.api == v) return r;
    }
    return null;
  }
}

class OrderParty {
  const OrderParty({required this.id, required this.name});

  factory OrderParty.fromJson(Map<dynamic, dynamic> j) => OrderParty(
    id: readString(j, 'id') ?? '',
    name: readString(j, 'fullName') ?? '',
  );

  final String id;
  final String name;
}

/// Bản chụp sách lúc đặt: người bán sửa tin sau đó không đổi đơn.
class OrderBook {
  const OrderBook({
    required this.listingId,
    required this.title,
    this.author,
    this.isbn,
    this.thumbnailUrl,
  });

  factory OrderBook.fromJson(Map<dynamic, dynamic> j) => OrderBook(
    listingId: readString(j, 'listingId') ?? '',
    title: readString(j, 'title') ?? '',
    author: readString(j, 'author'),
    isbn: readString(j, 'isbn'),
    thumbnailUrl: readString(j, 'thumbnailUrl'),
  );

  final String listingId;
  final String title;
  final String? author;
  final String? isbn;
  final String? thumbnailUrl;
}

/// Bản chụp địa chỉ nhận lúc đặt.
class ShippingAddress {
  const ShippingAddress({
    required this.recipientName,
    required this.phone,
    required this.province,
    required this.district,
    required this.ward,
    required this.detail,
  });

  factory ShippingAddress.fromJson(Map<dynamic, dynamic> j) => ShippingAddress(
    recipientName: readString(j, 'recipientName') ?? '',
    phone: readString(j, 'phone') ?? '',
    province: readString(j, 'province') ?? '',
    district: readString(j, 'district') ?? '',
    ward: readString(j, 'ward') ?? '',
    detail: readString(j, 'detail') ?? '',
  );

  final String recipientName;
  final String phone;
  final String province;
  final String district;
  final String ward;
  final String detail;

  String get fullLine => [
    detail,
    ward,
    district,
    province,
  ].where((e) => e.trim().isNotEmpty).join(', ');
}

class Shipment {
  const Shipment({
    required this.carrier,
    required this.trackingNumber,
    this.shippedAt,
  });

  factory Shipment.fromJson(Map<dynamic, dynamic> j) => Shipment(
    carrier: readString(j, 'carrier') ?? '',
    trackingNumber: readString(j, 'trackingNumber') ?? '',
    shippedAt: readDate(j, 'shippedAt'),
  );

  final String carrier;
  final String trackingNumber;
  final DateTime? shippedAt;
}

/// Các nút được phép hiện. Server vẫn kiểm tra lại khi thao tác.
class OrderActions {
  const OrderActions({
    this.canCancel = false,
    this.canShip = false,
    this.canConfirmReceived = false,
    this.canComplete = false,
    this.canComplain = false,
  });

  factory OrderActions.fromJson(Map<dynamic, dynamic> j) => OrderActions(
    canCancel: readBool(j, 'canCancel') ?? false,
    canShip: readBool(j, 'canShip') ?? false,
    canConfirmReceived: readBool(j, 'canConfirmReceived') ?? false,
    canComplete: readBool(j, 'canComplete') ?? false,
    canComplain: readBool(j, 'canComplain') ?? false,
  );

  final bool canCancel;
  final bool canShip;
  final bool canConfirmReceived;
  final bool canComplete;
  final bool canComplain;
}

class OrderTimelineEntry {
  const OrderTimelineEntry({required this.status, this.at, this.note});

  factory OrderTimelineEntry.fromJson(Map<dynamic, dynamic> j) =>
      OrderTimelineEntry(
        status: SaleOrderStatus.fromApi(readString(j, 'status')),
        at: readDate(j, 'at'),
        note: readString(j, 'note'),
      );

  final SaleOrderStatus status;
  final DateTime? at;

  /// Lý do hoặc mã vận đơn.
  final String? note;
}

/// Đơn bán thường. Dùng chung cho `OrderSummaryDto` (danh sách) và `OrderDto`
/// (chi tiết): trường chỉ có ở chi tiết là `null`/rỗng trong danh sách.
class SaleOrder {
  const SaleOrder({
    required this.id,
    required this.status,
    required this.price,
    required this.totalAmount,
    this.shippingFee = 0,
    this.role,
    this.book,
    this.counterpartyName,
    this.buyer,
    this.seller,
    this.shippingAddress,
    this.shipment,
    this.shipDeadlineAt,
    this.deliveredAt,
    this.complaintWindowEndsAt,
    this.completedAt,
    this.cancelledAt,
    this.createdAt,
    this.sellerPayout,
    this.actions = const OrderActions(),
    this.timeline = const [],
    this.complaintId,
    this.checkoutId,
  });

  factory SaleOrder.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    OrderParty? party(String key) {
      final m = readMap(j, key);
      return m == null ? null : OrderParty.fromJson(m);
    }

    final book = readMap(j, 'book');
    final address = readMap(j, 'shippingAddress');
    final shipment = readMap(j, 'shipment');
    final payout = readMap(j, 'sellerPayout');
    final actions = readMap(j, 'actions');

    // Dòng danh sách phẳng (bookTitle...) thay vì lồng trong `book`.
    final flatTitle = readString(j, 'bookTitle');
    return SaleOrder(
      id: readString(j, 'id') ?? '',
      checkoutId: readString(j, 'checkoutId'),
      status: SaleOrderStatus.fromApi(readString(j, 'status')),
      role: OrderRole.fromApi(readString(j, 'role')),
      book: book != null
          ? OrderBook.fromJson(book)
          : (flatTitle != null
                ? OrderBook(
                    listingId: '',
                    title: flatTitle,
                    author: readString(j, 'bookAuthor'),
                    thumbnailUrl: readString(j, 'thumbnailUrl'),
                  )
                : null),
      price: readInt(j, 'price') ?? 0,
      shippingFee: readInt(j, 'shippingFee') ?? 0,
      totalAmount: readInt(j, 'totalAmount') ?? 0,
      counterpartyName: readString(j, 'counterpartyName'),
      buyer: party('buyer'),
      seller: party('seller'),
      shippingAddress: address == null
          ? null
          : ShippingAddress.fromJson(address),
      shipment: shipment == null ? null : Shipment.fromJson(shipment),
      shipDeadlineAt: readDate(j, 'shipDeadlineAt'),
      deliveredAt: readDate(j, 'deliveredAt'),
      complaintWindowEndsAt: readDate(j, 'complaintWindowEndsAt'),
      completedAt: readDate(j, 'completedAt'),
      cancelledAt: readDate(j, 'cancelledAt'),
      createdAt: readDate(j, 'createdAt'),
      sellerPayout: payout == null
          ? null
          : {
              for (final e in payout.entries)
                if (e.value is num) e.key.toString(): (e.value as num).toInt(),
            },
      actions: actions == null
          ? const OrderActions()
          : OrderActions.fromJson(actions),
      timeline: [
        for (final t in readList(j, 'timeline'))
          if (t is Map<dynamic, dynamic>) OrderTimelineEntry.fromJson(t),
      ],
      complaintId: readString(j, 'complaintId'),
    );
  }

  final String id;
  final String? checkoutId;
  final SaleOrderStatus status;
  final OrderRole? role;
  final OrderBook? book;
  final int price;
  final int shippingFee;
  final int totalAmount;

  /// Người bán nếu mình mua, người mua nếu mình bán (dòng danh sách).
  final String? counterpartyName;
  final OrderParty? buyer;
  final OrderParty? seller;
  final ShippingAddress? shippingAddress;
  final Shipment? shipment;

  /// Hạn người bán gửi hàng.
  final DateTime? shipDeadlineAt;
  final DateTime? deliveredAt;

  /// Hết hạn này mà không ai bấm thì đơn tự hoàn tất.
  final DateTime? complaintWindowEndsAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;

  /// Chỉ người bán thấy; các khoản số nguyên (giá, phí, ship, thực nhận).
  final Map<String, int>? sellerPayout;
  final OrderActions actions;
  final List<OrderTimelineEntry> timeline;

  /// Khác `null` khi đơn đã có khiếu nại.
  final String? complaintId;

  String get title => book?.title ?? '';
  bool get isBuyer => role == OrderRole.buyer;
  bool get isSeller => role == OrderRole.seller;
}

/// Giỏ hàng trên server, dùng chung giữa các thiết bị.
class CartData {
  const CartData({
    this.items = const [],
    this.availableSubtotal = 0,
    this.unavailableCount = 0,
  });

  factory CartData.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return CartData(
      items: [
        for (final i in readList(j, 'items'))
          if (i is Map<dynamic, dynamic>) CartLine.fromJson(i),
      ],
      availableSubtotal: readInt(j, 'availableSubtotal') ?? 0,
      unavailableCount: readInt(j, 'unavailableCount') ?? 0,
    );
  }

  final List<CartLine> items;

  /// Chỉ cộng tin còn khả dụng, chưa gồm phí ship.
  final int availableSubtotal;
  final int unavailableCount;

  List<CartLine> get available => [
    for (final i in items)
      if (i.isAvailable) i,
  ];
}

class CartLine {
  const CartLine({
    required this.listingId,
    required this.title,
    required this.price,
    this.author,
    this.thumbnailUrl,
    this.sellerId,
    this.listingStatus,
    this.isAvailable = true,
    this.addedAt,
  });

  factory CartLine.fromJson(Map<dynamic, dynamic> j) => CartLine(
    listingId: readString(j, 'listingId') ?? '',
    title: readString(j, 'title') ?? '',
    author: readString(j, 'author'),
    price: readInt(j, 'price') ?? 0,
    thumbnailUrl: readString(j, 'thumbnailUrl'),
    sellerId: readString(j, 'sellerId'),
    listingStatus: readString(j, 'listingStatus'),
    isAvailable: readBool(j, 'isAvailable') ?? true,
    addedAt: readDate(j, 'addedAt'),
  );

  final String listingId;
  final String title;
  final String? author;
  final int price;
  final String? thumbnailUrl;
  final String? sellerId;
  final String? listingStatus;

  /// `false` khi tin không còn `PUBLISHED`: hiển thị mờ, cho xóa, không cho đặt.
  final bool isAvailable;
  final DateTime? addedAt;
}
