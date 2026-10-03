import '../../sim/domain/rules.dart';

enum AuctionStatus {
  registrationOpen,
  confirmed,
  live,
  buyNowCountdown,
  endedSold,
  endedNoBid;

  bool get isRunning => this == live || this == buyNowCountdown;
  bool get isEnded => this == endedSold || this == endedNoBid;
}

class Bid {
  const Bid({
    required this.who,
    required this.amount,
    required this.time,
    this.mine = false,
  });

  /// Tên đã che (ví dụ `Tr***g`); bỏ qua khi [mine].
  final String who;
  final int amount;
  final DateTime time;
  final bool mine;
}

/// Phiên đấu giá mô phỏng. Giá tính bằng đồng; `buyNow == 0` là không có mua ngay.
class Auction {
  const Auction({
    required this.id,
    required this.title,
    required this.author,
    required this.seller,
    required this.description,
    required this.coverHue,
    required this.status,
    required this.startingPrice,
    required this.step,
    required this.buyNow,
    required this.participants,
    this.minParticipants = 3,
    this.current = 0,
    this.endsAt,
    this.countdownEndsAt,
    this.hardEndsAt,
    this.startsAt,
    this.endedAt,
    this.extendedAt,
    this.registered = false,
    this.won = false,
    this.myHold = 0,
    this.bids = const [],
  });

  final String id;
  final String title;
  final String author;
  final String seller;
  final String description;
  final int coverHue;
  final AuctionStatus status;
  final int startingPrice;
  final int step;
  final int buyNow;
  final int participants;
  final int minParticipants;

  /// 0 khi chưa có lượt trả giá.
  final int current;

  /// Giờ kết thúc phiên đang diễn ra.
  final DateTime? endsAt;

  /// Giờ kết thúc khi đang đếm ngược mua ngay.
  final DateTime? countdownEndsAt;

  /// Hạn muộn nhất của đếm ngược mua ngay.
  final DateTime? hardEndsAt;

  /// Giờ bắt đầu (phiên chưa chạy).
  final DateTime? startsAt;
  final DateTime? endedAt;

  /// Lần gần nhất phiên được gia hạn do trả giá sát giờ.
  final DateTime? extendedAt;
  final bool registered;
  final bool won;

  /// Số tiền của người dùng đang bị giữ cho lượt dẫn đầu.
  final int myHold;
  final List<Bid> bids;

  int get registrationFee => auctionRegistrationFee(startingPrice);
  int get deposit => auctionDeposit(startingPrice);
  int get registrationHold => registrationFee + deposit;
  bool get hasBids => current > 0;
  bool get iAmLeading => bids.isNotEmpty && bids.first.mine;
  String? get leaderName => bids.isEmpty ? null : bids.first.who;

  /// Giá tối thiểu cho lượt trả giá kế tiếp.
  int get minBid => hasBids ? current + step : startingPrice;

  /// Mua ngay còn dùng được: phiên đang diễn ra, có giá mua ngay và chưa vượt.
  bool get buyNowAvailable =>
      status == AuctionStatus.live && buyNow > 0 && current < buyNow;

  /// Giờ cần đếm tới tương ứng với trạng thái hiện tại.
  DateTime? get deadline => switch (status) {
    AuctionStatus.live => endsAt,
    AuctionStatus.buyNowCountdown => countdownEndsAt,
    _ => null,
  };

  /// Hạn đóng đăng ký: 1 ngày trước giờ bắt đầu.
  DateTime? get registrationClosesAt =>
      startsAt?.subtract(const Duration(days: 1));

  Auction copyWith({
    AuctionStatus? status,
    int? participants,
    int? current,
    DateTime? endsAt,
    DateTime? countdownEndsAt,
    DateTime? hardEndsAt,
    DateTime? endedAt,
    DateTime? extendedAt,
    bool? registered,
    bool? won,
    int? myHold,
    List<Bid>? bids,
  }) => Auction(
    id: id,
    title: title,
    author: author,
    seller: seller,
    description: description,
    coverHue: coverHue,
    status: status ?? this.status,
    startingPrice: startingPrice,
    step: step,
    buyNow: buyNow,
    participants: participants ?? this.participants,
    minParticipants: minParticipants,
    current: current ?? this.current,
    endsAt: endsAt ?? this.endsAt,
    countdownEndsAt: countdownEndsAt ?? this.countdownEndsAt,
    hardEndsAt: hardEndsAt ?? this.hardEndsAt,
    startsAt: startsAt,
    endedAt: endedAt ?? this.endedAt,
    extendedAt: extendedAt ?? this.extendedAt,
    registered: registered ?? this.registered,
    won: won ?? this.won,
    myHold: myHold ?? this.myHold,
    bids: bids ?? this.bids,
  );
}
