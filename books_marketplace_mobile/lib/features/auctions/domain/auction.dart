import '../../../core/util/json_read.dart';
import '../../listings/domain/listing_enums.dart';

/// Trạng thái phiên (`11-auctions` mục 1, `13-auctions-live-delivery` mục 1).
/// Mã lạ rơi vào [unknown].
enum AuctionStatus {
  awaitingInbound('AWAITING_INBOUND'),
  pendingReview('PENDING_REVIEW'),
  registrationOpen('REGISTRATION_OPEN'),
  notEnoughParticipants('NOT_ENOUGH_PARTICIPANTS'),
  confirmed('CONFIRMED'),
  live('LIVE'),
  buyNowCountdown('BUY_NOW_COUNTDOWN'),
  endedSold('ENDED_SOLD'),
  endedNoBid('ENDED_NO_BID'),
  rejected('REJECTED'),
  cancelled('CANCELLED'),
  convertedToSale('CONVERTED_TO_SALE'),
  returned('RETURNED'),
  unknown('');

  const AuctionStatus(this.api);
  final String api;

  static AuctionStatus fromApi(String? v) => values.firstWhere(
    (s) => s.api == v && s != unknown,
    orElse: () => unknown,
  );

  /// Đang nhận lượt trả giá.
  bool get isRunning => this == live || this == buyNowCountdown;

  bool get isEnded => this == endedSold || this == endedNoBid;

  /// Người bán phải chọn phương án (dời lịch, bán thường, nhận lại sách).
  bool get needsFallback => this == notEnoughParticipants || this == endedNoBid;
}

/// Đăng ký của người xem (`myRegistration.status`).
enum RegistrationStatus {
  active('ACTIVE'),
  confirmed('CONFIRMED'),
  cancelled('CANCELLED'),
  refunded('REFUNDED'),
  completed('COMPLETED'),
  unknown('');

  const RegistrationStatus(this.api);
  final String api;

  static RegistrationStatus? fromApi(String? v) {
    if (v == null) return null;
    return values.firstWhere(
      (s) => s.api == v && s != unknown,
      orElse: () => unknown,
    );
  }

  /// Đăng ký còn hiệu lực (đang giữ phí/cọc).
  bool get isHolding => this == active || this == confirmed;
}

/// Vai trò trong "Phiên của tôi" (`GET /me/auctions?role=`).
enum AuctionRole {
  seller('SELLER'),
  bidder('BIDDER'),
  leading('LEADING'),
  winner('WINNER');

  const AuctionRole(this.api);
  final String api;

  static AuctionRole? fromName(String? v) {
    for (final r in values) {
      if (r.name == v) return r;
    }
    return null;
  }
}

enum BidKind {
  bid('BID'),
  buyNow('BUY_NOW'),
  unknown('');

  const BidKind(this.api);
  final String api;

  static BidKind fromApi(String? v) => values.firstWhere(
    (s) => s.api == v && s != unknown,
    orElse: () => unknown,
  );
}

enum FallbackChoice {
  reschedule('RESCHEDULE'),
  convertToSale('CONVERT_TO_SALE'),
  returnBook('RETURN');

  const FallbackChoice(this.api);
  final String api;
}

enum ReturnOrderStatus {
  awaitingFee('AWAITING_FEE'),
  readyToDispatch('READY_TO_DISPATCH'),
  dispatched('DISPATCHED'),
  unknown('');

  const ReturnOrderStatus(this.api);
  final String api;

  static ReturnOrderStatus fromApi(String? v) => values.firstWhere(
    (s) => s.api == v && s != unknown,
    orElse: () => unknown,
  );
}

/// `AuctionSummaryDto` trong danh sách.
class AuctionSummary {
  const AuctionSummary({
    required this.id,
    required this.title,
    required this.author,
    required this.status,
    required this.startPrice,
    this.thumbnailUrl,
    this.buyNowPrice,
    this.startAt,
    this.registrationClosesAt,
    this.registeredCount = 0,
    this.currentPrice,
    this.endsAt,
    this.myRegistration,
    this.kind = ListingKind.single,
    this.volumeCount = 0,
  });

  factory AuctionSummary.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AuctionSummary(
      id: readString(j, 'id') ?? '',
      title: readString(j, 'title') ?? '',
      author: readString(j, 'author') ?? '',
      thumbnailUrl: readString(j, 'thumbnailUrl'),
      status: AuctionStatus.fromApi(readString(j, 'status')),
      startPrice: readInt(j, 'startPrice') ?? 0,
      buyNowPrice: readInt(j, 'buyNowPrice'),
      startAt: readDate(j, 'startAt'),
      registrationClosesAt: readDate(j, 'registrationClosesAt'),
      registeredCount: readInt(j, 'registeredCount') ?? 0,
      currentPrice: readInt(j, 'currentPrice'),
      endsAt: readDate(j, 'endsAt'),
      myRegistration: RegistrationStatus.fromApi(
        readString(j, 'myRegistration'),
      ),
      kind: ListingKind.fromApi(readString(j, 'kind')),
      volumeCount: readInt(j, 'volumeCount') ?? 0,
    );
  }

  final ListingKind kind;
  final int volumeCount;
  final String id;
  final String title;
  final String author;
  final String? thumbnailUrl;
  final AuctionStatus status;
  final int startPrice;
  final int? buyNowPrice;
  final DateTime? startAt;
  final DateTime? registrationClosesAt;
  final int registeredCount;

  /// Giá hiện tại hoặc giá thắng; `null` khi chưa có lượt.
  final int? currentPrice;

  /// Giờ kết thúc đang áp dụng khi phiên diễn ra.
  final DateTime? endsAt;
  final RegistrationStatus? myRegistration;

  int get displayPrice => currentPrice ?? startPrice;

  /// Mốc đếm ngược hiển thị trên thẻ.
  DateTime? get deadline => switch (status) {
    AuctionStatus.live || AuctionStatus.buyNowCountdown => endsAt,
    AuctionStatus.registrationOpen => registrationClosesAt,
    AuctionStatus.confirmed => startAt,
    _ => null,
  };
}

class AuctionPhoto {
  const AuctionPhoto({required this.url, this.thumbnailUrl});

  factory AuctionPhoto.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AuctionPhoto(
      url: readString(j, 'url') ?? '',
      thumbnailUrl: readString(j, 'thumbnailUrl'),
    );
  }

  final String url;
  final String? thumbnailUrl;
}

class MyRegistration {
  const MyRegistration({
    required this.status,
    this.feeAmount = 0,
    this.depositAmount = 0,
  });

  factory MyRegistration.fromJson(Map<dynamic, dynamic> j) => MyRegistration(
    status:
        RegistrationStatus.fromApi(readString(j, 'status')) ??
        RegistrationStatus.unknown,
    feeAmount: readInt(j, 'feeAmount') ?? 0,
    depositAmount: readInt(j, 'depositAmount') ?? 0,
  );

  final RegistrationStatus status;
  final int feeAmount;
  final int depositAmount;
}

class WarehouseAddress {
  const WarehouseAddress({
    required this.recipient,
    required this.phone,
    required this.address,
  });

  factory WarehouseAddress.fromJson(Map<dynamic, dynamic> j) =>
      WarehouseAddress(
        recipient: readString(j, 'recipient') ?? '',
        phone: readString(j, 'phone') ?? '',
        address: readString(j, 'address') ?? '',
      );

  final String recipient;
  final String phone;
  final String address;
}

/// Lệnh trả sách về người bán (`owner.return`).
class ReturnOrder {
  const ReturnOrder({
    required this.status,
    required this.shippingFee,
    this.reason,
    this.carrier,
    this.trackingNumber,
    this.dispatchedAt,
  });

  factory ReturnOrder.fromJson(Map<dynamic, dynamic> j) => ReturnOrder(
    status: ReturnOrderStatus.fromApi(readString(j, 'status')),
    shippingFee: readInt(j, 'shippingFee') ?? 0,
    reason: readString(j, 'reason'),
    carrier: readString(j, 'carrier'),
    trackingNumber: readString(j, 'trackingNumber'),
    dispatchedAt: readDate(j, 'dispatchedAt'),
  );

  final ReturnOrderStatus status;
  final int shippingFee;
  final String? reason;
  final String? carrier;
  final String? trackingNumber;
  final DateTime? dispatchedAt;
}

/// Thông tin chỉ người bán thấy (`owner`).
class AuctionOwnerInfo {
  const AuctionOwnerInfo({
    required this.inboundCode,
    this.inboundDeadlineAt,
    this.inboundAt,
    this.warehouse,
    this.reviewReason,
    this.fallbackDeadlineAt,
    this.rescheduleRemaining = 0,
    this.cancelCause,
    this.convertedListingId,
    this.returnOrder,
  });

  factory AuctionOwnerInfo.fromJson(Map<dynamic, dynamic> j) {
    final warehouse = readMap(j, 'warehouse');
    final ret = readMap(j, 'return');
    return AuctionOwnerInfo(
      inboundCode: readString(j, 'inboundCode') ?? '',
      inboundDeadlineAt: readDate(j, 'inboundDeadlineAt'),
      inboundAt: readDate(j, 'inboundAt'),
      warehouse: warehouse == null
          ? null
          : WarehouseAddress.fromJson(warehouse),
      reviewReason: readString(j, 'reviewReason'),
      fallbackDeadlineAt: readDate(j, 'fallbackDeadlineAt'),
      rescheduleRemaining: readInt(j, 'rescheduleRemaining') ?? 0,
      cancelCause: readString(j, 'cancelCause'),
      convertedListingId: readString(j, 'convertedListingId'),
      returnOrder: ret == null ? null : ReturnOrder.fromJson(ret),
    );
  }

  final String inboundCode;
  final DateTime? inboundDeadlineAt;
  final DateTime? inboundAt;
  final WarehouseAddress? warehouse;
  final String? reviewReason;
  final DateTime? fallbackDeadlineAt;
  final int rescheduleRemaining;

  /// `SELLER_CANCELLED` hoặc `INBOUND_TIMEOUT`.
  final String? cancelCause;
  final String? convertedListingId;
  final ReturnOrder? returnOrder;
}

/// `AuctionLiveDto`: phần đang diễn ra và kết quả của phiên.
class AuctionLive {
  const AuctionLive({
    this.liveAt,
    this.endAt,
    this.buyNowAt,
    this.countdownEndAt,
    this.hardEndAt,
    this.endedAt,
    this.bidCount = 0,
    this.leader,
    this.isLeading = false,
    this.minNextBid = 0,
    this.sequence = 0,
    this.winner,
    this.finalPrice,
    this.isWinner = false,
    this.auctionOrderId,
  });

  factory AuctionLive.fromJson(Map<dynamic, dynamic> j) => AuctionLive(
    liveAt: readDate(j, 'liveAt'),
    endAt: readDate(j, 'endAt'),
    buyNowAt: readDate(j, 'buyNowAt'),
    countdownEndAt: readDate(j, 'countdownEndAt'),
    hardEndAt: readDate(j, 'hardEndAt'),
    endedAt: readDate(j, 'endedAt'),
    bidCount: readInt(j, 'bidCount') ?? 0,
    leader: readString(j, 'leader'),
    isLeading: readBool(j, 'isLeading') ?? false,
    minNextBid: readInt(j, 'minNextBid') ?? 0,
    sequence: readInt(j, 'sequence') ?? 0,
    winner: readString(j, 'winner'),
    finalPrice: readInt(j, 'finalPrice'),
    isWinner: readBool(j, 'isWinner') ?? false,
    auctionOrderId: readString(j, 'auctionOrderId'),
  );

  final DateTime? liveAt;
  final DateTime? endAt;
  final DateTime? buyNowAt;
  final DateTime? countdownEndAt;
  final DateTime? hardEndAt;
  final DateTime? endedAt;
  final int bidCount;

  /// Tên người dẫn đầu đã che, ví dụ `Ng***n`.
  final String? leader;
  final bool isLeading;
  final int minNextBid;
  final int sequence;
  final String? winner;
  final int? finalPrice;
  final bool isWinner;

  /// Chỉ người thắng, người bán và admin nhận được.
  final String? auctionOrderId;

  AuctionLive copyWith({
    DateTime? Function()? endAt,
    DateTime? Function()? countdownEndAt,
    DateTime? Function()? hardEndAt,
    int? bidCount,
    String? Function()? leader,
    bool? isLeading,
    int? minNextBid,
    int? sequence,
    String? Function()? winner,
    int? Function()? finalPrice,
  }) => AuctionLive(
    liveAt: liveAt,
    endAt: endAt != null ? endAt() : this.endAt,
    buyNowAt: buyNowAt,
    countdownEndAt: countdownEndAt != null
        ? countdownEndAt()
        : this.countdownEndAt,
    hardEndAt: hardEndAt != null ? hardEndAt() : this.hardEndAt,
    endedAt: endedAt,
    bidCount: bidCount ?? this.bidCount,
    leader: leader != null ? leader() : this.leader,
    isLeading: isLeading ?? this.isLeading,
    minNextBid: minNextBid ?? this.minNextBid,
    sequence: sequence ?? this.sequence,
    winner: winner != null ? winner() : this.winner,
    finalPrice: finalPrice != null ? finalPrice() : this.finalPrice,
    isWinner: isWinner,
    auctionOrderId: auctionOrderId,
  );
}

/// `AuctionDto` của `GET /auctions/{id}`.
/// Một tập của bộ sách trong phiên, kèm ảnh riêng của tập.
class AuctionVolume {
  const AuctionVolume({
    required this.id,
    required this.volumeNo,
    this.title,
    this.photos = const [],
  });

  factory AuctionVolume.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AuctionVolume(
      id: readString(j, 'id') ?? '',
      volumeNo: readInt(j, 'volumeNo') ?? 0,
      title: readString(j, 'title'),
      photos: [for (final p in readList(j, 'photos')) AuctionPhoto.fromJson(p)],
    );
  }

  final String id;
  final int volumeNo;
  final String? title;
  final List<AuctionPhoto> photos;
}

class Auction {
  const Auction({
    required this.id,
    required this.title,
    required this.author,
    required this.status,
    required this.startPrice,
    required this.bidStep,
    this.description = '',
    this.condition,
    this.buyNowPrice,
    this.durationMinutes = 0,
    this.startAt,
    this.registrationClosesAt,
    this.participationFee = 0,
    this.deposit = 0,
    this.registeredCount = 0,
    this.photos = const [],
    this.sellerName = '',
    this.myRegistration,
    this.canRegister = false,
    this.buyNowAvailable = false,
    this.currentPrice,
    this.serverTime,
    this.owner,
    this.live,
    this.kind = ListingKind.single,
    this.volumeCount = 0,
    this.volumes = const [],
  });

  factory Auction.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    final seller = readMap(j, 'seller');
    final reg = readMap(j, 'myRegistration');
    final owner = readMap(j, 'owner');
    final live = readMap(j, 'live');
    return Auction(
      id: readString(j, 'id') ?? '',
      title: readString(j, 'title') ?? '',
      author: readString(j, 'author') ?? '',
      description: readString(j, 'description') ?? '',
      condition: readString(j, 'condition'),
      status: AuctionStatus.fromApi(readString(j, 'status')),
      startPrice: readInt(j, 'startPrice') ?? 0,
      bidStep: readInt(j, 'bidStep') ?? 0,
      buyNowPrice: readInt(j, 'buyNowPrice'),
      durationMinutes: readInt(j, 'durationMinutes') ?? 0,
      startAt: readDate(j, 'startAt'),
      registrationClosesAt: readDate(j, 'registrationClosesAt'),
      participationFee: readInt(j, 'participationFee') ?? 0,
      deposit: readInt(j, 'deposit') ?? 0,
      registeredCount: readInt(j, 'registeredCount') ?? 0,
      photos: [for (final p in readList(j, 'photos')) AuctionPhoto.fromJson(p)],
      sellerName: seller == null ? '' : readString(seller, 'fullName') ?? '',
      myRegistration: reg == null ? null : MyRegistration.fromJson(reg),
      canRegister: readBool(j, 'canRegister') ?? false,
      buyNowAvailable: readBool(j, 'buyNowAvailable') ?? false,
      currentPrice: readInt(j, 'currentPrice'),
      serverTime: readDate(j, 'serverTime'),
      owner: owner == null ? null : AuctionOwnerInfo.fromJson(owner),
      live: live == null ? null : AuctionLive.fromJson(live),
      kind: ListingKind.fromApi(readString(j, 'kind')),
      volumeCount: readInt(j, 'volumeCount') ?? 0,
      volumes: [
        for (final v in readList(j, 'volumes')) AuctionVolume.fromJson(v),
      ]..sort((a, b) => a.volumeNo.compareTo(b.volumeNo)),
    );
  }

  final ListingKind kind;
  final int volumeCount;

  /// Các tập của bộ sách (rỗng với sách lẻ). `photos` là ảnh chung của cả bộ.
  final List<AuctionVolume> volumes;

  bool get isSet => kind == ListingKind.set;

  final String id;
  final String title;
  final String author;
  final String description;
  final String? condition;
  final AuctionStatus status;
  final int startPrice;
  final int bidStep;
  final int? buyNowPrice;
  final int durationMinutes;
  final DateTime? startAt;
  final DateTime? registrationClosesAt;
  final int participationFee;
  final int deposit;
  final int registeredCount;
  final List<AuctionPhoto> photos;
  final String sellerName;
  final MyRegistration? myRegistration;
  final bool canRegister;
  final bool buyNowAvailable;

  /// `null` khi chưa có lượt.
  final int? currentPrice;
  final DateTime? serverTime;

  /// Chỉ người bán (và admin) nhận được.
  final AuctionOwnerInfo? owner;

  /// `null` trước khi phiên mở.
  final AuctionLive? live;

  bool get isSeller => owner != null;
  int get registrationHold => participationFee + deposit;
  int get displayPrice => currentPrice ?? live?.finalPrice ?? startPrice;
  bool get hasBids => currentPrice != null;
  bool get isLeading => live?.isLeading ?? false;

  /// Mức tối thiểu của lượt kế tiếp: lấy từ server, dự phòng tự tính.
  int get minNextBid {
    final m = live?.minNextBid ?? 0;
    if (m > 0) return m;
    return currentPrice == null ? startPrice : currentPrice! + bidStep;
  }

  /// Đăng ký đã được xác nhận: được trả giá khi phiên mở.
  bool get isConfirmedBidder =>
      myRegistration?.status == RegistrationStatus.confirmed;

  bool get canBid =>
      isConfirmedBidder && !isSeller && status.isRunning && !isLeading;

  bool get canBuyNow =>
      isConfirmedBidder && !isSeller && status.isRunning && buyNowAvailable;

  /// Mốc đếm ngược theo trạng thái hiện tại.
  DateTime? get deadline => switch (status) {
    AuctionStatus.live => live?.endAt,
    AuctionStatus.buyNowCountdown => live?.countdownEndAt,
    AuctionStatus.registrationOpen => registrationClosesAt,
    AuctionStatus.confirmed => startAt,
    AuctionStatus.awaitingInbound => owner?.inboundDeadlineAt,
    AuctionStatus.notEnoughParticipants ||
    AuctionStatus.endedNoBid => owner?.fallbackDeadlineAt,
    _ => null,
  };

  Auction copyWith({
    AuctionStatus? status,
    int? Function()? currentPrice,
    bool? buyNowAvailable,
    AuctionLive? live,
  }) => Auction(
    id: id,
    title: title,
    author: author,
    description: description,
    condition: condition,
    status: status ?? this.status,
    startPrice: startPrice,
    bidStep: bidStep,
    buyNowPrice: buyNowPrice,
    durationMinutes: durationMinutes,
    startAt: startAt,
    registrationClosesAt: registrationClosesAt,
    participationFee: participationFee,
    deposit: deposit,
    registeredCount: registeredCount,
    photos: photos,
    sellerName: sellerName,
    myRegistration: myRegistration,
    canRegister: canRegister,
    buyNowAvailable: buyNowAvailable ?? this.buyNowAvailable,
    currentPrice: currentPrice != null ? currentPrice() : this.currentPrice,
    serverTime: serverTime,
    owner: owner,
    live: live ?? this.live,
    kind: kind,
    volumeCount: volumeCount,
    volumes: volumes,
  );
}

/// Một lượt trong lịch sử (`AuctionBidDto`).
class Bid {
  const Bid({
    required this.id,
    required this.amount,
    required this.kind,
    required this.bidder,
    required this.isMine,
    this.placedAt,
  });

  factory Bid.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return Bid(
      id: readString(j, 'id') ?? '',
      amount: readInt(j, 'amount') ?? 0,
      kind: BidKind.fromApi(readString(j, 'kind')),
      bidder: readString(j, 'bidder') ?? '',
      isMine: readBool(j, 'isMine') ?? false,
      placedAt: readDate(j, 'placedAt'),
    );
  }

  final String id;
  final int amount;
  final BidKind kind;
  final String bidder;
  final bool isMine;
  final DateTime? placedAt;
}

/// Dữ liệu tạo phiên (`POST /auctions`).
class CreateAuctionInput {
  const CreateAuctionInput({
    required this.title,
    required this.author,
    required this.categoryId,
    required this.condition,
    required this.description,
    required this.startPrice,
    required this.bidStep,
    required this.durationMinutes,
    required this.desiredStartAt,
    required this.photos,
    this.buyNowPrice,
    this.publisher,
    this.publishYear,
    this.isbn,
    this.defectNotes,
    this.kind = ListingKind.single,
    this.volumes = const [],
  });

  final ListingKind kind;

  /// Các tập của bộ sách, mỗi tập kèm tên blob ảnh riêng (đã tải lên).
  final List<AuctionVolumeInput> volumes;
  final String title;
  final String author;
  final String categoryId;

  /// `NEW`, `GOOD`, `FAIR`, `WORN`.
  final String condition;
  final String description;
  final int startPrice;
  final int bidStep;
  final int? buyNowPrice;
  final int durationMinutes;
  final DateTime desiredStartAt;
  final List<String> photos;
  final String? publisher;
  final int? publishYear;
  final String? isbn;
  final String? defectNotes;

  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'author': author.trim(),
    'categoryId': categoryId,
    'condition': condition,
    'description': description.trim(),
    'publisher': ?publisher,
    'publishYear': ?publishYear,
    'isbn': ?isbn,
    'defectNotes': ?defectNotes,
    'startPrice': startPrice,
    'bidStep': bidStep,
    'buyNowPrice': ?buyNowPrice,
    'durationMinutes': durationMinutes,
    'desiredStartAt': desiredStartAt.toUtc().toIso8601String(),
    'photos': photos,
    if (kind == ListingKind.set) ...{
      'kind': kind.api,
      'volumes': [for (final v in volumes) v.toJson()],
    },
  };
}

/// Một tập khi tạo phiên bộ sách.
class AuctionVolumeInput {
  const AuctionVolumeInput({
    required this.volumeNo,
    required this.photos,
    this.title,
  });

  final int volumeNo;
  final String? title;
  final List<String> photos;

  Map<String, dynamic> toJson() => {
    'volumeNo': volumeNo,
    if (title != null && title!.trim().isNotEmpty) 'title': title!.trim(),
    'photos': photos,
  };
}
