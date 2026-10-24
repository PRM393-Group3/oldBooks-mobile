import '../../../core/util/json_read.dart';
import 'auction.dart';

/// Tên sự kiện realtime của hub `/hubs/auctions`.
abstract final class AuctionEventName {
  static const started = 'auction.started';
  static const bidPlaced = 'bid.placed';
  static const extended = 'auction.extended';
  static const buyNowStarted = 'buynow.started';
  static const countdownReset = 'countdown.reset';
  static const ended = 'auction.ended';

  static const all = [
    started,
    bidPlaced,
    extended,
    buyNowStarted,
    countdownReset,
    ended,
  ];
}

/// Payload chung của mọi sự kiện (`AuctionLiveEventDto`). Đây là trạng thái
/// đầy đủ của phiên: cập nhật cả màn hình từ bất kỳ sự kiện nào; [name] chỉ
/// dùng cho hiệu ứng và toast.
class AuctionLiveEvent {
  const AuctionLiveEvent({
    required this.name,
    required this.auctionId,
    required this.sequence,
    required this.status,
    this.serverTime,
    this.currentPrice,
    this.leader,
    this.bidCount = 0,
    this.endAt,
    this.countdownEndAt,
    this.hardEndAt,
    this.buyNowAvailable = false,
    this.minNextBid = 0,
    this.amount,
    this.bidder,
    this.winner,
    this.finalPrice,
  });

  factory AuctionLiveEvent.fromJson(String name, Map<dynamic, dynamic> j) =>
      AuctionLiveEvent(
        name: name,
        auctionId: readString(j, 'auctionId') ?? '',
        sequence: readInt(j, 'sequence') ?? 0,
        serverTime: readDate(j, 'serverTime'),
        status: AuctionStatus.fromApi(readString(j, 'status')),
        currentPrice: readInt(j, 'currentPrice'),
        leader: readString(j, 'leader'),
        bidCount: readInt(j, 'bidCount') ?? 0,
        endAt: readDate(j, 'endAt'),
        countdownEndAt: readDate(j, 'countdownEndAt'),
        hardEndAt: readDate(j, 'hardEndAt'),
        buyNowAvailable: readBool(j, 'buyNowAvailable') ?? false,
        minNextBid: readInt(j, 'minNextBid') ?? 0,
        amount: readInt(j, 'amount'),
        bidder: readString(j, 'bidder'),
        winner: readString(j, 'winner'),
        finalPrice: readInt(j, 'finalPrice'),
      );

  final String name;
  final String auctionId;
  final int sequence;
  final DateTime? serverTime;
  final AuctionStatus status;
  final int? currentPrice;
  final String? leader;
  final int bidCount;
  final DateTime? endAt;
  final DateTime? countdownEndAt;
  final DateTime? hardEndAt;
  final bool buyNowAvailable;
  final int minNextBid;

  /// Lượt vừa trả (`bid.placed`, `buynow.started`).
  final int? amount;
  final String? bidder;
  final String? winner;
  final int? finalPrice;

  /// Sự kiện báo có lượt trả giá mới (của mình hoặc người khác).
  bool get isNewBid =>
      name == AuctionEventName.bidPlaced ||
      name == AuctionEventName.countdownReset ||
      name == AuctionEventName.buyNowStarted;
}

/// Gộp một sự kiện vào phiên. Bỏ qua sự kiện có `sequence` không mới hơn
/// [lastSequence] (sự kiện giao ít nhất một lần, có thể trùng hoặc đến trễ).
///
/// Không đổi `isLeading`, `isWinner`, `auctionOrderId`: payload không mang các
/// trường riêng của người xem, controller tự xử lý.
Auction reduceLive(Auction a, AuctionLiveEvent e, {required int lastSequence}) {
  if (e.sequence <= lastSequence) return a;
  final live = (a.live ?? const AuctionLive()).copyWith(
    endAt: () => e.endAt,
    countdownEndAt: () => e.countdownEndAt,
    hardEndAt: () => e.hardEndAt,
    bidCount: e.bidCount,
    leader: () => e.leader,
    minNextBid: e.minNextBid,
    sequence: e.sequence,
    winner: () => e.winner,
    finalPrice: () => e.finalPrice,
  );
  return a.copyWith(
    status: e.status,
    currentPrice: () => e.currentPrice,
    buyNowAvailable: e.buyNowAvailable,
    live: live,
  );
}
