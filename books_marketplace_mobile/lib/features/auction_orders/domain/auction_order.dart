import '../../../core/util/json_read.dart';
import '../../orders/domain/sale_order.dart' show ShippingAddress;

/// Trạng thái đơn của người thắng (`13-auctions-live-delivery` mục 1).
enum AuctionOrderStatus {
  awaitingShippingFee('AWAITING_SHIPPING_FEE'),
  readyToShip('READY_TO_SHIP'),
  inDelivery('IN_DELIVERY'),
  inStorage('IN_STORAGE'),
  delivered('DELIVERED'),
  pickedUp('PICKED_UP'),
  storageExpired('STORAGE_EXPIRED'),
  disputed('DISPUTED'),
  completed('COMPLETED'),
  refunded('REFUNDED'),
  partiallyRefunded('PARTIALLY_REFUNDED'),
  unknown('');

  const AuctionOrderStatus(this.api);
  final String api;

  static AuctionOrderStatus fromApi(String? v) => values.firstWhere(
    (s) => s.api == v && s != unknown,
    orElse: () => unknown,
  );

  bool get isFinished =>
      this == completed || this == refunded || this == partiallyRefunded;

  /// Sách chưa rời kho: còn đổi được địa chỉ.
  bool get canChangeAddress =>
      this == awaitingShippingFee || this == readyToShip;
}

enum PostExpiryStatus {
  awaitingDecision('AWAITING_DECISION'),
  extended('EXTENDED'),
  awaitingLiquidation('AWAITING_LIQUIDATION'),
  liquidated('LIQUIDATED'),
  releasedToBuyer('RELEASED_TO_BUYER'),
  unknown('');

  const PostExpiryStatus(this.api);
  final String api;

  static PostExpiryStatus fromApi(String? v) => values.firstWhere(
    (s) => s.api == v && s != unknown,
    orElse: () => unknown,
  );
}

enum DeliveryResult {
  success('SUCCESS'),
  failed('FAILED'),
  unknown('');

  const DeliveryResult(this.api);
  final String api;

  static DeliveryResult fromApi(String? v) => values.firstWhere(
    (s) => s.api == v && s != unknown,
    orElse: () => unknown,
  );
}

/// Lựa chọn khi sách đang lưu kho.
enum CollectionChoice {
  pickup('PICKUP'),
  redeliver('REDELIVER');

  const CollectionChoice(this.api);
  final String api;

  static CollectionChoice? fromApi(String? v) {
    for (final c in values) {
      if (c.api == v) return c;
    }
    return null;
  }
}

/// Lựa chọn sau khi hết hạn lưu kho.
enum PostExpiryAction {
  extend('EXTEND'),
  pickup('PICKUP'),
  redeliver('REDELIVER');

  const PostExpiryAction(this.api);
  final String api;
}

enum OrderViewerRole {
  buyer('BUYER'),
  seller('SELLER');

  const OrderViewerRole(this.api);
  final String api;

  static OrderViewerRole? fromApi(String? v) {
    for (final r in values) {
      if (r.api == v) return r;
    }
    return null;
  }
}

class DeliveryAttempt {
  const DeliveryAttempt({
    required this.round,
    required this.attemptNo,
    required this.result,
    this.reason,
    this.recordedAt,
  });

  factory DeliveryAttempt.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return DeliveryAttempt(
      round: readInt(j, 'round') ?? 1,
      attemptNo: readInt(j, 'attemptNo') ?? 1,
      result: DeliveryResult.fromApi(readString(j, 'result')),
      reason: readString(j, 'reason'),
      recordedAt: readDate(j, 'recordedAt'),
    );
  }

  final int round;
  final int attemptNo;
  final DeliveryResult result;
  final String? reason;
  final DateTime? recordedAt;
}

class AuctionDelivery {
  const AuctionDelivery({
    this.round = 1,
    this.attemptCount = 0,
    this.failedAttempts = 0,
    this.maxAttempts = 0,
    this.carrier,
    this.trackingNumber,
    this.dispatchedAt,
    this.deliveredAt,
    this.pickedUpAt,
    this.complaintWindowEndsAt,
    this.attempts = const [],
  });

  factory AuctionDelivery.fromJson(Map<dynamic, dynamic> j) => AuctionDelivery(
    round: readInt(j, 'round') ?? 1,
    attemptCount: readInt(j, 'attemptCount') ?? 0,
    failedAttempts: readInt(j, 'failedAttempts') ?? 0,
    maxAttempts: readInt(j, 'maxAttempts') ?? 0,
    carrier: readString(j, 'carrier'),
    trackingNumber: readString(j, 'trackingNumber'),
    dispatchedAt: readDate(j, 'dispatchedAt'),
    deliveredAt: readDate(j, 'deliveredAt'),
    pickedUpAt: readDate(j, 'pickedUpAt'),
    complaintWindowEndsAt: readDate(j, 'complaintWindowEndsAt'),
    attempts: [
      for (final a in readList(j, 'attempts')) DeliveryAttempt.fromJson(a),
    ],
  );

  final int round;
  final int attemptCount;
  final int failedAttempts;
  final int maxAttempts;
  final String? carrier;
  final String? trackingNumber;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final DateTime? pickedUpAt;
  final DateTime? complaintWindowEndsAt;
  final List<DeliveryAttempt> attempts;
}

class AuctionStorage {
  const AuctionStorage({
    this.startedAt,
    this.expiresAt,
    this.feePerDay = 0,
    this.feeAccrued = 0,
    this.choice,
    this.choiceAt,
  });

  factory AuctionStorage.fromJson(Map<dynamic, dynamic> j) => AuctionStorage(
    startedAt: readDate(j, 'startedAt'),
    expiresAt: readDate(j, 'expiresAt'),
    feePerDay: readInt(j, 'feePerDay') ?? 0,
    feeAccrued: readInt(j, 'feeAccrued') ?? 0,
    choice: CollectionChoice.fromApi(readString(j, 'choice')),
    choiceAt: readDate(j, 'choiceAt'),
  );

  final DateTime? startedAt;
  final DateTime? expiresAt;
  final int feePerDay;
  final int feeAccrued;
  final CollectionChoice? choice;
  final DateTime? choiceAt;
}

class PostExpiry {
  const PostExpiry({
    required this.status,
    this.decisionDeadlineAt,
    this.extensionCount = 0,
    this.extensionMaxTimes = 0,
    this.extensionDays = 0,
    this.extensionFee = 0,
    this.extendedUntil,
    this.choice,
    this.releasedAt,
    this.liquidationAmount,
    this.liquidationFee,
  });

  factory PostExpiry.fromJson(Map<dynamic, dynamic> j) => PostExpiry(
    status: PostExpiryStatus.fromApi(readString(j, 'status')),
    decisionDeadlineAt: readDate(j, 'decisionDeadlineAt'),
    extensionCount: readInt(j, 'extensionCount') ?? 0,
    extensionMaxTimes: readInt(j, 'extensionMaxTimes') ?? 0,
    extensionDays: readInt(j, 'extensionDays') ?? 0,
    extensionFee: readInt(j, 'extensionFee') ?? 0,
    extendedUntil: readDate(j, 'extendedUntil'),
    choice: CollectionChoice.fromApi(readString(j, 'choice')),
    releasedAt: readDate(j, 'releasedAt'),
    liquidationAmount: readInt(j, 'liquidationAmount'),
    liquidationFee: readInt(j, 'liquidationFee'),
  );

  final PostExpiryStatus status;
  final DateTime? decisionDeadlineAt;
  final int extensionCount;
  final int extensionMaxTimes;
  final int extensionDays;
  final int extensionFee;
  final DateTime? extendedUntil;
  final CollectionChoice? choice;
  final DateTime? releasedAt;
  final int? liquidationAmount;
  final int? liquidationFee;

  int get extensionsLeft =>
      (extensionMaxTimes - extensionCount).clamp(0, extensionMaxTimes);

  /// Số tiền thanh lý thực nhận (đã trừ phí).
  int get liquidationNet => (liquidationAmount ?? 0) - (liquidationFee ?? 0);
}

/// `AuctionOrderDto`.
class AuctionOrder {
  const AuctionOrder({
    required this.id,
    required this.auctionId,
    required this.bookTitle,
    required this.status,
    this.thumbnailUrl,
    this.viewerRole,
    this.finalPrice = 0,
    this.shippingFee = 0,
    this.shippingFeeHeld = false,
    this.shippingFeeUnpaid = 0,
    this.shippingFeeDueAt,
    this.depositAmount = 0,
    this.address,
    this.delivery = const AuctionDelivery(),
    this.storage,
    this.postExpiry,
    this.complaintId,
    this.commission,
    this.completedAt,
    this.createdAt,
  });

  factory AuctionOrder.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    final address = readMap(j, 'address');
    final delivery = readMap(j, 'delivery');
    final storage = readMap(j, 'storage');
    final postExpiry = readMap(j, 'postExpiry');
    return AuctionOrder(
      id: readString(j, 'id') ?? '',
      auctionId: readString(j, 'auctionId') ?? '',
      bookTitle: readString(j, 'bookTitle') ?? '',
      thumbnailUrl: readString(j, 'thumbnailUrl'),
      status: AuctionOrderStatus.fromApi(readString(j, 'status')),
      viewerRole: OrderViewerRole.fromApi(readString(j, 'viewerRole')),
      finalPrice: readInt(j, 'finalPrice') ?? 0,
      shippingFee: readInt(j, 'shippingFee') ?? 0,
      shippingFeeHeld: readBool(j, 'shippingFeeHeld') ?? false,
      shippingFeeUnpaid: readInt(j, 'shippingFeeUnpaid') ?? 0,
      shippingFeeDueAt: readDate(j, 'shippingFeeDueAt'),
      depositAmount: readInt(j, 'depositAmount') ?? 0,
      address: address == null ? null : ShippingAddress.fromJson(address),
      delivery: delivery == null
          ? const AuctionDelivery()
          : AuctionDelivery.fromJson(delivery),
      storage: storage == null ? null : AuctionStorage.fromJson(storage),
      postExpiry: postExpiry == null ? null : PostExpiry.fromJson(postExpiry),
      complaintId: readString(j, 'complaintId'),
      commission: readInt(j, 'commission'),
      completedAt: readDate(j, 'completedAt'),
      createdAt: readDate(j, 'createdAt'),
    );
  }

  final String id;
  final String auctionId;
  final String bookTitle;
  final String? thumbnailUrl;
  final AuctionOrderStatus status;
  final OrderViewerRole? viewerRole;
  final int finalPrice;
  final int shippingFee;

  /// Đã giữ phí ship cho lần giao sắp tới.
  final bool shippingFeeHeld;

  /// Phí ship chưa thu, sẽ trừ vào cọc.
  final int shippingFeeUnpaid;
  final DateTime? shippingFeeDueAt;
  final int depositAmount;

  /// Người bán luôn nhận `null`.
  final ShippingAddress? address;
  final AuctionDelivery delivery;
  final AuctionStorage? storage;
  final PostExpiry? postExpiry;
  final String? complaintId;

  /// Chỉ người bán nhận được.
  final int? commission;
  final DateTime? completedAt;
  final DateTime? createdAt;

  bool get isBuyer => viewerRole != OrderViewerRole.seller;

  /// Người mua đang phải làm gì đó (chấm đỏ trong danh sách).
  bool get needsBuyerAction {
    if (!isBuyer) return false;
    return switch (status) {
      AuctionOrderStatus.awaitingShippingFee =>
        address == null || !shippingFeeHeld,
      AuctionOrderStatus.inStorage => storage?.choice == null,
      AuctionOrderStatus.storageExpired =>
        postExpiry?.status == PostExpiryStatus.awaitingDecision,
      _ => false,
    };
  }

  /// Còn trong hạn khiếu nại tại thời điểm [now].
  bool canComplainAt(DateTime now) {
    if (!isBuyer || complaintId != null) return false;
    if (status != AuctionOrderStatus.delivered &&
        status != AuctionOrderStatus.pickedUp) {
      return false;
    }
    final end = delivery.complaintWindowEndsAt;
    return end == null || now.isBefore(end);
  }
}
