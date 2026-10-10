enum MyListingStatus {
  published,
  pendingReview,
  needsChanges,
  awaitingInbound,
  sold,
}

/// Tin đăng của người dùng ở phía bán (mô phỏng cho tới khi nối backend).
class MyListing {
  const MyListing({
    required this.id,
    required this.title,
    required this.status,
    required this.isAuction,
    required this.price,
    required this.createdAt,
    this.views = 0,
    this.adminReason,
    this.inboundCode,
    this.inboundDeadline,
    this.received,
    this.photoBytes,
  });

  final String id;
  final String title;
  final MyListingStatus status;
  final bool isAuction;

  /// Giá bán, hoặc giá khởi điểm nếu đấu giá.
  final int price;
  final DateTime createdAt;
  final int views;
  final String? adminReason;
  final String? inboundCode;
  final DateTime? inboundDeadline;

  /// Số tiền đã nhận sau phí (tin đã bán).
  final int? received;

  /// Ảnh bìa người dùng vừa chọn; tin mẫu không có.
  final List<int>? photoBytes;

  /// Tin còn "đang đăng" (tính vào số liệu ở tab Tôi).
  bool get isActive => status != MyListingStatus.sold;
}
