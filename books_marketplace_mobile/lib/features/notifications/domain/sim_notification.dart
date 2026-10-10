enum SimNotificationKind {
  auctionBuyNowCountdown,
  orderDelivered,
  auctionFilled,
  topupOk,
  auctionRegistered,
  outbid,
  auctionWon,
}

/// Thông báo cục bộ sinh từ đơn, ví, đấu giá (mock). Tiêu đề và nội dung dựng
/// theo ngôn ngữ từ [kind] cùng [arg] (tên sách hoặc mã đơn) và [amount].
class SimNotification {
  const SimNotification({
    required this.kind,
    required this.time,
    this.arg,
    this.amount,
    this.read = false,
  });

  final SimNotificationKind kind;
  final DateTime time;
  final String? arg;
  final int? amount;
  final bool read;

  SimNotification markRead() => SimNotification(
    kind: kind,
    time: time,
    arg: arg,
    amount: amount,
    read: true,
  );
}
