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
