import '../../../core/util/json_read.dart';

/// Loại thông báo đã biết (`type` của server, UPPER_SNAKE_CASE). Danh sách tăng
/// dần theo giai đoạn nên mọi mã lạ rơi vào [unknown]: vẫn hiển thị `title` và
/// `body` mặc định, không crash.
enum NotificationType {
  accountLocked('ACCOUNT_LOCKED'),
  accountUnlocked('ACCOUNT_UNLOCKED'),
  passwordChanged('PASSWORD_CHANGED'),
  topupSucceeded('TOPUP_SUCCEEDED'),
  withdrawalApproved('WITHDRAWAL_APPROVED'),
  withdrawalRejected('WITHDRAWAL_REJECTED'),
  withdrawalPaid('WITHDRAWAL_PAID'),
  withdrawalFailed('WITHDRAWAL_FAILED'),
  listingApproved('LISTING_APPROVED'),
  listingChangesRequested('LISTING_CHANGES_REQUESTED'),
  listingRejected('LISTING_REJECTED'),
  listingUnpublished('LISTING_UNPUBLISHED'),
  orderNew('ORDER_NEW'),
  orderShipped('ORDER_SHIPPED'),
  orderDelivered('ORDER_DELIVERED'),
  orderCompleted('ORDER_COMPLETED'),
  orderCancelledByBuyer('ORDER_CANCELLED_BY_BUYER'),
  orderTimeoutBuyer('ORDER_TIMEOUT_BUYER'),
  orderTimeoutSeller('ORDER_TIMEOUT_SELLER'),
  orderShipReminder('ORDER_SHIP_REMINDER'),
  complaintOpened('COMPLAINT_OPENED'),
  complaintSellerResponded('COMPLAINT_SELLER_RESPONDED'),
  complaintEscalated('COMPLAINT_ESCALATED'),
  complaintMessage('COMPLAINT_MESSAGE'),
  complaintResolved('COMPLAINT_RESOLVED'),
  // Đấu giá, giai đoạn 6a: tạo phiên, đăng ký.
  auctionInboundReceived('AUCTION_INBOUND_RECEIVED'),
  auctionApproved('AUCTION_APPROVED'),
  auctionRejected('AUCTION_REJECTED'),
  auctionInboundTimeout('AUCTION_INBOUND_TIMEOUT'),
  auctionConfirmed('AUCTION_CONFIRMED'),
  auctionNotEnough('AUCTION_NOT_ENOUGH'),
  auctionRegistrationRefunded('AUCTION_REGISTRATION_REFUNDED'),
  auctionFallbackTimeout('AUCTION_FALLBACK_TIMEOUT'),
  returnFeeNeeded('RETURN_FEE_NEEDED'),
  returnReady('RETURN_READY'),
  returnDispatched('RETURN_DISPATCHED'),
  // Giai đoạn 6b: phiên trực tiếp.
  auctionStarted('AUCTION_STARTED'),
  auctionOutbid('AUCTION_OUTBID'),
  auctionBuyNowStarted('AUCTION_BUY_NOW_STARTED'),
  auctionWon('AUCTION_WON'),
  auctionLost('AUCTION_LOST'),
  auctionSold('AUCTION_SOLD'),
  auctionEndedNoBid('AUCTION_ENDED_NO_BID'),
  // Giai đoạn 6c: đơn của người thắng.
  auctionShippingFeeNeeded('AUCTION_SHIPPING_FEE_NEEDED'),
  auctionShippingFeeDeferred('AUCTION_SHIPPING_FEE_DEFERRED'),
  auctionOrderDispatched('AUCTION_ORDER_DISPATCHED'),
  auctionDeliveryFailed('AUCTION_DELIVERY_FAILED'),
  auctionInStorage('AUCTION_IN_STORAGE'),
  auctionOrderDelivered('AUCTION_ORDER_DELIVERED'),
  auctionOrderCompleted('AUCTION_ORDER_COMPLETED'),
  auctionStorageExpired('AUCTION_STORAGE_EXPIRED'),
  auctionStorageExtended('AUCTION_STORAGE_EXTENDED'),
  auctionAwaitingLiquidation('AUCTION_AWAITING_LIQUIDATION'),
  auctionLiquidationNeedsAdmin('AUCTION_LIQUIDATION_NEEDS_ADMIN'),
  auctionLiquidated('AUCTION_LIQUIDATED'),
  auctionReleasedToBuyer('AUCTION_RELEASED_TO_BUYER'),
  unknown('');

  const NotificationType(this.api);
  final String api;

  static NotificationType fromApi(String? v) => values.firstWhere(
    (t) => t.api == v && t != unknown,
    orElse: () => unknown,
  );

  /// Thông báo về tin đăng: bấm vào mở chi tiết tin (`data.listingId`).
  bool get isListing => switch (this) {
    listingApproved ||
    listingChangesRequested ||
    listingRejected ||
    listingUnpublished => true,
    _ => false,
  };

  bool get isOrder => api.startsWith('ORDER_');

  /// Mọi thông báo của phiên đấu giá, đơn đấu giá và lệnh trả sách.
  bool get isAuction => api.startsWith('AUCTION_') || api.startsWith('RETURN_');

  /// Chỉ dành cho admin: mobile bỏ qua (không hiện, không điều hướng).
  bool get isAdminOnly => this == auctionLiquidationNeedsAdmin;

  /// Mở thẳng chi tiết đơn đấu giá.
  bool get opensAuctionOrder => switch (this) {
    auctionShippingFeeNeeded ||
    auctionShippingFeeDeferred ||
    auctionOrderDispatched ||
    auctionDeliveryFailed ||
    auctionInStorage ||
    auctionOrderDelivered ||
    auctionOrderCompleted ||
    auctionStorageExpired ||
    auctionStorageExtended ||
    auctionAwaitingLiquidation ||
    auctionLiquidated ||
    auctionReleasedToBuyer => true,
    _ => false,
  };

  /// Mở chi tiết phiên rồi tới đơn (người thắng, người bán).
  bool get opensAuctionThenOrder => this == auctionWon || this == auctionSold;
  bool get isComplaint => api.startsWith('COMPLAINT_');

  /// Thông báo về ví: bấm vào mở tab Ví.
  bool get isWallet => switch (this) {
    topupSucceeded ||
    withdrawalApproved ||
    withdrawalRejected ||
    withdrawalPaid ||
    withdrawalFailed => true,
    _ => false,
  };
}

/// `NotificationDto`. `title` và `body` do server tạo sẵn bằng tiếng Việt, client
/// hiển thị nguyên văn, không tự ghép chuỗi.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.data,
    this.createdAt,
  });

  factory AppNotification.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AppNotification(
      id: readString(j, 'id') ?? '',
      type: NotificationType.fromApi(readString(j, 'type')),
      title: readString(j, 'title') ?? '',
      body: readString(j, 'body') ?? '',
      isRead: readBool(j, 'isRead') ?? false,
      data: readMap(j, 'data'),
      createdAt: readDate(j, 'createdAt'),
    );
  }

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;

  /// Dữ liệu điều hướng (id đơn, phiên, yêu cầu nạp/rút...) hoặc `null`.
  final Map<dynamic, dynamic>? data;
  final DateTime? createdAt;

  /// `data.orderId` của thông báo đơn hàng và khiếu nại.
  String? get orderId => data == null ? null : readString(data!, 'orderId');

  /// `data.complaintId` của thông báo khiếu nại.
  String? get complaintId =>
      data == null ? null : readString(data!, 'complaintId');

  /// Id tin đăng trong `data`, nếu có (dùng cho deep link ở giai đoạn sau).
  String? get listingId => data == null ? null : readString(data!, 'listingId');

  /// `data.auctionId` của thông báo đấu giá.
  String? get auctionId => data == null ? null : readString(data!, 'auctionId');

  /// `data.auctionOrderId` của thông báo đơn đấu giá.
  String? get auctionOrderId =>
      data == null ? null : readString(data!, 'auctionOrderId');

  AppNotification asRead() => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    isRead: true,
    data: data,
    createdAt: createdAt,
  );
}

/// `GET /me/notification-settings`. Chỉ tắt được push của các nhóm này; thông
/// báo giao dịch, bảo mật và tiền luôn gửi.
class NotificationSettings {
  const NotificationSettings({this.marketing = true, this.auctionWatch = true});

  factory NotificationSettings.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return NotificationSettings(
      marketing: readBool(j, 'marketing') ?? true,
      auctionWatch: readBool(j, 'auctionWatch') ?? true,
    );
  }

  final bool marketing;
  final bool auctionWatch;

  NotificationSettings copyWith({bool? marketing, bool? auctionWatch}) =>
      NotificationSettings(
        marketing: marketing ?? this.marketing,
        auctionWatch: auctionWatch ?? this.auctionWatch,
      );
}
