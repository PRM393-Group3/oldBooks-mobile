import '../../../core/util/json_read.dart';

/// Giới hạn nghiệp vụ lấy từ `GET /listings/rules` (SRS chương 6).
///
/// Doc chưa nêu tên trường, nên mỗi giá trị đọc theo vài tên có thể có và rơi
/// về giá trị trong doc nếu thiếu. Cần đối chiếu với Swagger khi backend chạy.
class ListingRules {
  const ListingRules({
    this.maxSubmissions = 4,
    this.estimatedProcessingHours = 24,
    this.claimMinutes = 30,
    this.overdueHours = 18,
    this.minImages = 3,
    this.maxImages = 10,
    this.maxImageMegabytes = 10,
    this.minPrice = 10000,
    this.maxPrice = 50000000,
    this.minQuantity = 1,
    this.maxQuantity = 99,
    this.minBidFloor = 1000,
    this.minBidPercent = 1,
    this.auctionDurations = const [3, 5, 7, 10],
    this.minDescriptionLength = 50,
    this.minRejectNoteLength = 10,
  });

  factory ListingRules.fromJson(dynamic json) {
    if (json is! Map) return const ListingRules();
    const d = ListingRules();
    int pick(List<String> keys, int fallback) {
      for (final k in keys) {
        final v = readInt(json, k);
        if (v != null) return v;
      }
      return fallback;
    }

    final durations = readList(
      json,
      'auctionDurationDays',
    ).whereType<num>().map((n) => n.toInt()).toList();

    return ListingRules(
      maxSubmissions: pick([
        'maxSubmissions',
        'submissionLimit',
      ], d.maxSubmissions),
      estimatedProcessingHours: pick([
        'estimatedProcessingHours',
        'inspectionSlaHours',
      ], d.estimatedProcessingHours),
      claimMinutes: pick([
        'claimLockMinutes',
        'claimMinutes',
        'inspectionLockMinutes',
      ], d.claimMinutes),
      overdueHours: pick(['overdueAfterHours', 'overdueHours'], d.overdueHours),
      minImages: pick(['minImages', 'minImageCount'], d.minImages),
      maxImages: pick(['maxImages', 'maxImageCount'], d.maxImages),
      maxImageMegabytes: pick([
        'maxImageSizeMb',
        'maxImageMegabytes',
      ], d.maxImageMegabytes),
      minPrice: pick(['minPrice', 'priceMin'], d.minPrice),
      maxPrice: pick(['maxPrice', 'priceMax'], d.maxPrice),
      minQuantity: pick(['minQuantity'], d.minQuantity),
      maxQuantity: pick(['maxQuantity'], d.maxQuantity),
      minBidFloor: pick([
        'minBidIncrementFloor',
        'minBidIncrementMin',
      ], d.minBidFloor),
      minBidPercent: pick(['minBidIncrementPercent'], d.minBidPercent),
      auctionDurations: durations.isEmpty ? d.auctionDurations : durations,
      minDescriptionLength: pick([
        'minDescriptionLength',
        'descriptionMinLength',
      ], d.minDescriptionLength),
      minRejectNoteLength: pick([
        'minRejectNoteLength',
        'rejectNoteMinLength',
      ], d.minRejectNoteLength),
    );
  }

  final int maxSubmissions;
  final int estimatedProcessingHours;
  final int claimMinutes;
  final int overdueHours;
  final int minImages;
  final int maxImages;
  final int maxImageMegabytes;
  final int minPrice;
  final int maxPrice;
  final int minQuantity;
  final int maxQuantity;
  final int minBidFloor;
  final int minBidPercent;
  final List<int> auctionDurations;
  final int minDescriptionLength;
  final int minRejectNoteLength;

  int get maxImageBytes => maxImageMegabytes * 1024 * 1024;

  /// Số ảnh thêm tối đa ngoài 4 góc bắt buộc.
  int get maxExtraImages => maxImages - 4;

  /// BR-08: bước giá tối thiểu = max(sàn, 1% giá khởi điểm làm tròn lên).
  int minBidIncrementFor(int startingPrice) {
    final percent = (startingPrice * minBidPercent + 99) ~/ 100;
    return percent > minBidFloor ? percent : minBidFloor;
  }
}
