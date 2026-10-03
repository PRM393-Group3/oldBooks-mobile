enum TxnType { topup, hold, release, payout, refund, capture, withdraw }

/// Lý do giao dịch, dùng để dựng nhãn theo ngôn ngữ hiện tại (không lưu chuỗi
/// đã dịch). [arg] là mã đơn hoặc tên sách tùy loại.
enum TxnReason {
  topupVietQr,
  holdOrder,
  holdOrders,
  holdAuctionRegistration,
  holdBid,
  holdBuyNow,
  holdRedeliveryFee,
  releaseOrderCancelled,
  releaseAuctionUnregistered,
  releaseAuctionDeposit,
  payoutSale,
  captureOrder,
  refundAgreement,
  refundVerdict,
  withdrawRequest,
}

class WalletTxn {
  const WalletTxn({
    required this.type,
    required this.reason,
    required this.amount,
    required this.time,
    this.arg,
    this.captured,
  });

  final TxnType type;
  final TxnReason reason;

  /// Dương là tiền vào ví khả dụng, âm là tiền ra.
  final int amount;
  final DateTime time;
  final String? arg;

  /// Chỉ với [TxnType.capture]: số tiền chốt từ khoản đang giữ (không đổi số dư
  /// khả dụng).
  final int? captured;
}
