import '../../auctions/domain/auction.dart';
import '../../notifications/domain/sim_notification.dart';
import '../../orders/domain/order.dart';
import '../../wallet/domain/wallet_txn.dart';

enum SimToastKind {
  orderCancelled,
  orderCompleted,
  complaintOpened,
  offerAccepted,
  noBooksAvailable,
  sellerShipped,
  deliveryFailed,
  movedToStorage,
  topupOk,
  withdrawRequested,
  rated,
  registered,
  unregistered,
  leading,
  buyNowStarted,
  outbid,
  auctionWon,
}

/// Thông báo nổi ngắn do kho mô phỏng phát ra; [id] tăng dần để UI chỉ hiện một
/// lần mỗi sự kiện.
class SimToast {
  const SimToast({
    required this.id,
    required this.kind,
    this.amount,
    this.text,
  });

  final int id;
  final SimToastKind kind;
  final int? amount;
  final String? text;
}

/// Toàn bộ dữ liệu mô phỏng. Ví, đơn, đấu giá và thông báo tác động lẫn nhau
/// (đặt hàng trừ ví, thắng phiên tạo đơn...) nên nằm chung một kho.
class SimState {
  const SimState({
    required this.now,
    required this.available,
    required this.held,
    required this.orders,
    required this.txns,
    required this.notifications,
    required this.auctions,
    this.reservedListingIds = const {},
    this.toast,
    this.toastSeq = 0,
  });

  final DateTime now;
  final int available;
  final int held;
  final List<Order> orders;
  final List<WalletTxn> txns;
  final List<SimNotification> notifications;
  final List<Auction> auctions;

  /// Tin thật đã có người đặt mua trong phiên này (ẩn khỏi Khám phá).
  final Set<String> reservedListingIds;
  final SimToast? toast;
  final int toastSeq;

  int get total => available + held;

  SimState copyWith({
    DateTime? now,
    int? available,
    int? held,
    List<Order>? orders,
    List<WalletTxn>? txns,
    List<SimNotification>? notifications,
    List<Auction>? auctions,
    Set<String>? reservedListingIds,
    SimToast? toast,
    int? toastSeq,
  }) => SimState(
    now: now ?? this.now,
    available: available ?? this.available,
    held: held ?? this.held,
    orders: orders ?? this.orders,
    txns: txns ?? this.txns,
    notifications: notifications ?? this.notifications,
    auctions: auctions ?? this.auctions,
    reservedListingIds: reservedListingIds ?? this.reservedListingIds,
    toast: toast ?? this.toast,
    toastSeq: toastSeq ?? this.toastSeq,
  );
}

/// Kết quả của một thao tác trên kho mô phỏng.
sealed class SimOutcome {
  const SimOutcome();
}

class SimOk extends SimOutcome {
  const SimOk();
}

/// Số dư khả dụng không đủ; [needed] là số còn thiếu.
class SimInsufficient extends SimOutcome {
  const SimInsufficient(this.needed);
  final int needed;
}

/// Thao tác không hợp lệ ở trạng thái hiện tại (ví dụ phiên đã kết thúc).
class SimRejected extends SimOutcome {
  const SimRejected(this.reason);
  final SimRejectReason reason;
}

enum SimRejectReason {
  notFound,
  invalidState,
  bidTooLow,
  auctionEnded,
  noBooksAvailable,
  invalidAmount,
}
