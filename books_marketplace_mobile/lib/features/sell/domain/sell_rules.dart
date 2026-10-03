import 'dart:math' as math;

import '../../../core/config/public_config.dart';
import '../../../core/validation/isbn.dart';
import '../../listings/domain/listing_enums.dart';

enum SellMode { fixedPrice, auction }

/// Tình trạng theo SRS (NEW, GOOD, FAIR, WORN) ánh xạ vào [BookCondition].
enum SellCondition {
  isNew('NEW', BookCondition.brandNew),
  good('GOOD', BookCondition.good),
  fair('FAIR', BookCondition.fair),
  worn('WORN', BookCondition.worn);

  const SellCondition(this.code, this.condition);
  final String code;
  final BookCondition condition;
}

/// Giới hạn ảnh tối đa mỗi tin (BR-26). Số ảnh tối thiểu lấy từ cấu hình.
const maxSellPhotos = 10;

const minFixedPrice = 1000;
const minStartingPrice = 10000;

/// Quy tắc xem trước khi đăng bán, lấy từ `GET /config/public` (admin chỉnh
/// được). Số tiền cuối cùng luôn do server tính. Tỉ lệ đổi sang phần chục nghìn
/// (`0.05` là 500) để tính bằng số nguyên, tránh sai số số thực.
class SellRules {
  const SellRules({
    this.minPhotos = 4,
    this.saleFeeBps = 500,
    this.commissionBps = 1000,
    this.participationBps = 200,
    this.participationMin = 10000,
    this.participationMax = 100000,
    this.depositBps = 1000,
    this.stepMinBps = 100,
    this.stepMaxBps = 1000,
    this.stepMinAmount = 5000,
    this.buyNowMultiplierPercent = 150,
    this.shippingSale = 25000,
  });

  /// Giá trị mặc định khi chưa tải được cấu hình.
  static const defaults = SellRules();

  factory SellRules.fromConfig(PublicConfig c) {
    int bps(String key, int fallback) {
      final v = c[key];
      return v == null ? fallback : (v * 10000).round();
    }

    return SellRules(
      minPhotos: c.intOf(PublicConfig.listingPhotosMin) ?? defaults.minPhotos,
      saleFeeBps: bps(PublicConfig.saleFeeRate, defaults.saleFeeBps),
      commissionBps: bps(
        PublicConfig.auctionCommissionRate,
        defaults.commissionBps,
      ),
      participationBps: bps(
        PublicConfig.participationRate,
        defaults.participationBps,
      ),
      participationMin:
          c.intOf(PublicConfig.participationMin) ?? defaults.participationMin,
      participationMax:
          c.intOf(PublicConfig.participationMax) ?? defaults.participationMax,
      depositBps: bps(PublicConfig.depositRate, defaults.depositBps),
      stepMinBps: bps(PublicConfig.stepMinRate, defaults.stepMinBps),
      stepMaxBps: bps(PublicConfig.stepMaxRate, defaults.stepMaxBps),
      stepMinAmount:
          c.intOf(PublicConfig.stepMinAmount) ?? defaults.stepMinAmount,
      buyNowMultiplierPercent: c[PublicConfig.buyNowMinMultiplier] == null
          ? defaults.buyNowMultiplierPercent
          : (c[PublicConfig.buyNowMinMultiplier]! * 100).round(),
      shippingSale:
          c.intOf(PublicConfig.shippingSaleFlat) ?? defaults.shippingSale,
    );
  }

  final int minPhotos;
  final int saleFeeBps;
  final int commissionBps;
  final int participationBps;
  final int participationMin;
  final int participationMax;
  final int depositBps;
  final int stepMinBps;
  final int stepMaxBps;
  final int stepMinAmount;
  final int buyNowMultiplierPercent;
  final int shippingSale;

  /// Phí bán thường (người bán trả), làm tròn xuống.
  int sellerFee(int price) => price * saleFeeBps ~/ 10000;

  /// Hoa hồng đấu giá trên giá thắng/giá khởi điểm.
  int auctionCommission(int price) => price * commissionBps ~/ 10000;

  /// Phí tham gia = giá khởi điểm × tỉ lệ, kẹp giữa min và max.
  int participationFee(int startingPrice) =>
      (startingPrice * participationBps ~/ 10000).clamp(
        participationMin,
        participationMax,
      );

  int deposit(int startingPrice) => startingPrice * depositBps ~/ 10000;

  /// Khoảng bước nhảy hợp lệ (BR-11).
  ({int lo, int hi}) stepRange(int startingPrice) => (
    lo: math.max((startingPrice * stepMinBps + 9999) ~/ 10000, stepMinAmount),
    hi: startingPrice * stepMaxBps ~/ 10000,
  );

  int minBuyNow(int startingPrice) =>
      startingPrice * buyNowMultiplierPercent ~/ 100;
}

({int lo, int hi}) stepRange(int startingPrice) =>
    SellRules.defaults.stepRange(startingPrice);

int minBuyNow(int startingPrice) => SellRules.defaults.minBuyNow(startingPrice);

int sellerFee(int price) => SellRules.defaults.sellerFee(price);
int auctionCommission(int price) => SellRules.defaults.auctionCommission(price);

/// Thời điểm bắt đầu sớm nhất: 5 ngày gửi kho + 3 ngày đăng ký + 24 giờ (BR-18,
/// BR-07, BR-08).
DateTime earliestAuctionStart(DateTime now) =>
    now.add(const Duration(days: 8, hours: 24));

enum SellError {
  photos,
  title,
  author,
  price,
  startingPrice,
  step,
  buyNow,
  description,
  category,
  isbn,
  year,
}

class SellForm {
  const SellForm({
    this.mode = SellMode.fixedPrice,
    this.photos = 0,
    this.title = '',
    this.author = '',
    this.categoryId,
    this.condition = SellCondition.good,
    this.price = 0,
    this.startingPrice = 0,
    this.step = 0,
    this.buyNow = 0,
    this.durationMinutes = 1440,
    this.description = '',
    this.publisher = '',
    this.publishYear = '',
    this.isbn = '',
    this.defectNotes = '',
  });

  final SellMode mode;
  final int photos;
  final String title;
  final String author;

  /// Thể loại thật từ `GET /categories`; bắt buộc khi bán giá cố định.
  final String? categoryId;
  final SellCondition condition;
  final int price;
  final int startingPrice;
  final int step;

  /// 0 là không dùng mua ngay.
  final int buyNow;
  final int durationMinutes;
  final String description;
  final String publisher;
  final String publishYear;
  final String isbn;
  final String defectNotes;

  bool get isAuction => mode == SellMode.auction;

  SellForm copyWith({
    SellMode? mode,
    int? photos,
    String? title,
    String? author,
    String? Function()? categoryId,
    SellCondition? condition,
    int? price,
    int? startingPrice,
    int? step,
    int? buyNow,
    int? durationMinutes,
    String? description,
    String? publisher,
    String? publishYear,
    String? isbn,
    String? defectNotes,
  }) => SellForm(
    mode: mode ?? this.mode,
    photos: photos ?? this.photos,
    title: title ?? this.title,
    author: author ?? this.author,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    condition: condition ?? this.condition,
    price: price ?? this.price,
    startingPrice: startingPrice ?? this.startingPrice,
    step: step ?? this.step,
    buyNow: buyNow ?? this.buyNow,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    description: description ?? this.description,
    publisher: publisher ?? this.publisher,
    publishYear: publishYear ?? this.publishYear,
    isbn: isbn ?? this.isbn,
    defectNotes: defectNotes ?? this.defectNotes,
  );
}

/// Các lỗi còn tồn tại của form, theo thứ tự hiển thị.
List<SellError> validateSell(
  SellForm f, {
  SellRules rules = SellRules.defaults,
}) {
  final e = <SellError>[];
  if (f.photos < rules.minPhotos) e.add(SellError.photos);
  if (f.title.trim().isEmpty) e.add(SellError.title);
  if (f.author.trim().isEmpty) e.add(SellError.author);
  if (!f.isAuction) {
    if (f.price < minFixedPrice) e.add(SellError.price);
  } else if (f.startingPrice < minStartingPrice) {
    e.add(SellError.startingPrice);
  } else {
    final r = rules.stepRange(f.startingPrice);
    if (f.step < r.lo || f.step > r.hi) e.add(SellError.step);
    if (f.buyNow > 0 && f.buyNow < rules.minBuyNow(f.startingPrice)) {
      e.add(SellError.buyNow);
    }
  }
  if (f.description.trim().isEmpty) e.add(SellError.description);
  if (!f.isAuction) {
    if (f.categoryId == null) e.add(SellError.category);
    if (f.isbn.trim().isNotEmpty && !isValidIsbn(f.isbn)) {
      e.add(SellError.isbn);
    }
    final year = int.tryParse(f.publishYear.trim());
    if (f.publishYear.trim().isNotEmpty &&
        (year == null || year < 1450 || year > DateTime.now().year + 1)) {
      e.add(SellError.year);
    }
  }
  return e;
}
