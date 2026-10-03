import 'dart:math' as math;

import '../../listings/domain/listing_enums.dart';

enum SellMode { fixedPrice, auction }

/// Tình trạng theo SRS (NEW, GOOD, FAIR, WORN) ánh xạ vào [BookCondition].
enum SellCondition {
  isNew('NEW', BookCondition.likeNew),
  good('GOOD', BookCondition.good),
  fair('FAIR', BookCondition.fair),
  worn('WORN', BookCondition.poor);

  const SellCondition(this.code, this.condition);
  final String code;
  final BookCondition condition;
}

const sellCategoryKeys = [
  'literature',
  'history',
  'children',
  'science',
  'foreign',
];

/// Giới hạn ảnh mỗi tin (BR-26).
const minSellPhotos = 4;
const maxSellPhotos = 10;

const minFixedPrice = 1000;
const minStartingPrice = 10000;

/// Giá mua ngay tối thiểu so với giá khởi điểm (BR-15), nhân 10 để tránh số thực.
const buyNowMinMultiplierTimes10 = 15;

/// Hoa hồng người bán: 5% bán thường (BR-01), 10% đấu giá (BR-02).
const saleFeePercent = 5;
const auctionCommissionPercent = 10;

/// Khoảng bước nhảy hợp lệ (BR-11): 1% đến 10% giá khởi điểm, tối thiểu 5.000.
({int lo, int hi}) stepRange(int startingPrice) =>
    (lo: math.max((startingPrice + 99) ~/ 100, 5000), hi: startingPrice ~/ 10);

int minBuyNow(int startingPrice) =>
    startingPrice * buyNowMinMultiplierTimes10 ~/ 10;

int sellerFee(int price) => price * saleFeePercent ~/ 100;
int auctionCommission(int price) => price * auctionCommissionPercent ~/ 100;

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
}

class SellForm {
  const SellForm({
    this.mode = SellMode.fixedPrice,
    this.photos = 0,
    this.title = '',
    this.author = '',
    this.categoryKey = 'literature',
    this.condition = SellCondition.good,
    this.price = 0,
    this.startingPrice = 0,
    this.step = 0,
    this.buyNow = 0,
    this.durationMinutes = 1440,
    this.description = '',
  });

  final SellMode mode;
  final int photos;
  final String title;
  final String author;
  final String categoryKey;
  final SellCondition condition;
  final int price;
  final int startingPrice;
  final int step;

  /// 0 là không dùng mua ngay.
  final int buyNow;
  final int durationMinutes;
  final String description;

  bool get isAuction => mode == SellMode.auction;

  SellForm copyWith({
    SellMode? mode,
    int? photos,
    String? title,
    String? author,
    String? categoryKey,
    SellCondition? condition,
    int? price,
    int? startingPrice,
    int? step,
    int? buyNow,
    int? durationMinutes,
    String? description,
  }) => SellForm(
    mode: mode ?? this.mode,
    photos: photos ?? this.photos,
    title: title ?? this.title,
    author: author ?? this.author,
    categoryKey: categoryKey ?? this.categoryKey,
    condition: condition ?? this.condition,
    price: price ?? this.price,
    startingPrice: startingPrice ?? this.startingPrice,
    step: step ?? this.step,
    buyNow: buyNow ?? this.buyNow,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    description: description ?? this.description,
  );
}

/// Các lỗi còn tồn tại của form, theo thứ tự hiển thị.
List<SellError> validateSell(SellForm f) {
  final e = <SellError>[];
  if (f.photos < minSellPhotos) e.add(SellError.photos);
  if (f.title.trim().isEmpty) e.add(SellError.title);
  if (f.author.trim().isEmpty) e.add(SellError.author);
  if (!f.isAuction) {
    if (f.price < minFixedPrice) e.add(SellError.price);
  } else if (f.startingPrice < minStartingPrice) {
    e.add(SellError.startingPrice);
  } else {
    final r = stepRange(f.startingPrice);
    if (f.step < r.lo || f.step > r.hi) e.add(SellError.step);
    if (f.buyNow > 0 && f.buyNow < minBuyNow(f.startingPrice)) {
      e.add(SellError.buyNow);
    }
  }
  if (f.description.trim().isEmpty) e.add(SellError.description);
  return e;
}
