/// `GET /config/public`: object phẳng `khóa → số` do admin chỉnh trên web.
///
/// Chỉ dùng để xem trước (phí, cọc, số ảnh tối thiểu); số tiền cuối cùng luôn
/// do server tính. Khóa lạ bị bỏ qua, khóa thiếu trả `null` để caller dùng giá
/// trị mặc định an toàn hoặc ẩn bản xem trước.
class PublicConfig {
  const PublicConfig([this.values = const {}]);

  factory PublicConfig.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return PublicConfig({
      for (final e in j.entries)
        if (e.value is num) e.key.toString(): e.value as num,
    });
  }

  final Map<String, num> values;

  bool get isEmpty => values.isEmpty;

  num? operator [](String key) => values[key];

  int? intOf(String key) => values[key]?.toInt();

  Map<String, dynamic> toJson() => values;

  static const saleFeeRate = 'fee.sale.rate';
  static const auctionCommissionRate = 'fee.auction.commissionRate';
  static const participationRate = 'fee.auction.participation.rate';
  static const participationMin = 'fee.auction.participation.min';
  static const participationMax = 'fee.auction.participation.max';
  static const depositRate = 'auction.deposit.rate';
  static const stepMinRate = 'auction.step.minRate';
  static const stepMaxRate = 'auction.step.maxRate';
  static const stepMinAmount = 'auction.step.minAmount';
  static const buyNowMinMultiplier = 'auction.buyNow.minMultiplier';
  static const listingPhotosMin = 'listing.photos.min';
  static const shippingSaleFlat = 'shipping.sale.flatFee';
  static const shippingAuctionFlat = 'shipping.auction.flatFee';
  static const topupMin = 'wallet.topup.minAmount';
  static const topupMax = 'wallet.topup.maxAmount';
  static const withdrawMin = 'wallet.withdraw.minAmount';
}
