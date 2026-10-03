import '../../sim/domain/rules.dart';

enum OrderType { sale, auction }

enum OrderStatus {
  // Bán thường
  paidAwaitingShipment,
  shipped,
  // Đấu giá (kho Oldbook giao)
  readyToShip,
  inDelivery,
  inStorage,
  pickedUp,
  // Chung
  delivered,
  completed,
  cancelledByBuyer,
  disputed,
  refunded,
  partiallyRefunded;

  /// Đơn còn phải theo dõi (tính vào "Đơn đang mua").
  bool get isOpen => switch (this) {
    completed || cancelledByBuyer || refunded || partiallyRefunded => false,
    _ => true,
  };

  /// Người mua đã cầm sách và đang trong cửa sổ khiếu nại.
  bool get isReceived => this == delivered || this == pickedUp;
}

enum ComplaintStatus { open, sellerResponded, escalated, agreed, resolved }

enum ComplaintReason { notAsDescribed, damaged, wrongItem, other }

class Complaint {
  const Complaint({required this.status, required this.reason, this.offer});

  final ComplaintStatus status;
  final ComplaintReason reason;

  /// Số tiền người bán đề xuất hoàn.
  final int? offer;

  Complaint copyWith({ComplaintStatus? status, int? offer}) => Complaint(
    status: status ?? this.status,
    reason: reason,
    offer: offer ?? this.offer,
  );
}

class Order {
  const Order({
    required this.id,
    required this.type,
    required this.title,
    required this.seller,
    required this.price,
    required this.ship,
    required this.status,
    required this.placedAt,
    this.listingId,
    this.author,
    this.coverUrl,
    this.coverHue,
    this.shippedAt,
    this.deliveredAt,
    this.completedAt,
    this.storageAt,
    this.carrier,
    this.tracking,
    this.attempt = 0,
    this.deposit = 0,
    this.complaint,
    this.stars = 0,
  });

  final String id;
  final OrderType type;
  final String? listingId;
  final String title;
  final String? author;
  final String seller;
  final String? coverUrl;

  /// Màu bìa thay thế khi dữ liệu mẫu không có ảnh (0 đến 360).
  final int? coverHue;
  final int price;
  final int ship;
  final OrderStatus status;
  final DateTime placedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final DateTime? storageAt;
  final String? carrier;
  final String? tracking;

  /// Lần giao hiện tại (đơn đấu giá).
  final int attempt;

  /// Cọc đang giữ cho đơn đấu giá; hoàn khi người mua nhận sách.
  final int deposit;
  final Complaint? complaint;
  final int stars;

  bool get isAuction => type == OrderType.auction;
  int get total => price + ship;

  /// Hạn người bán gửi hàng (đơn bán thường).
  DateTime get shipDeadline => sellerShipDeadline(placedAt);

  /// Hạn khiếu nại; `null` nếu chưa giao.
  DateTime? get complaintDeadlineAt =>
      deliveredAt == null ? null : complaintDeadline(deliveredAt!);

  Order copyWith({
    OrderStatus? status,
    int? ship,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? completedAt,
    DateTime? storageAt,
    String? carrier,
    String? tracking,
    int? attempt,
    Complaint? complaint,
    int? stars,
  }) => Order(
    id: id,
    type: type,
    listingId: listingId,
    title: title,
    author: author,
    seller: seller,
    coverUrl: coverUrl,
    coverHue: coverHue,
    price: price,
    ship: ship ?? this.ship,
    status: status ?? this.status,
    placedAt: placedAt,
    shippedAt: shippedAt ?? this.shippedAt,
    deliveredAt: deliveredAt ?? this.deliveredAt,
    completedAt: completedAt ?? this.completedAt,
    storageAt: storageAt ?? this.storageAt,
    carrier: carrier ?? this.carrier,
    tracking: tracking ?? this.tracking,
    attempt: attempt ?? this.attempt,
    deposit: deposit,
    complaint: complaint ?? this.complaint,
    stars: stars ?? this.stars,
  );
}
