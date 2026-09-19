import '../../../core/l10n/app_localizations.dart';
import '../../../core/util/json_read.dart';
import '../../listings/domain/listing.dart';

/// Lý do từ chối (FR-INS-10).
enum RejectReason {
  blurryPhotos('BlurryPhotos'),
  descriptionMismatch('DescriptionMismatch'),
  suspectedPirated('SuspectedPirated'),
  prohibitedPublication('ProhibitedPublication'),
  damageBeyondThreshold('DamageBeyondThreshold'),
  wrongCatalogInfo('WrongCatalogInfo'),
  duplicateListing('DuplicateListing');

  const RejectReason(this.api);
  final String api;

  static RejectReason? fromApi(String v) {
    for (final r in values) {
      if (r.api == v) return r;
    }
    return null;
  }

  String label(AppLocalizations l) => switch (this) {
    blurryPhotos => l.reasonBlurryPhotos,
    descriptionMismatch => l.reasonDescriptionMismatch,
    suspectedPirated => l.reasonSuspectedPirated,
    prohibitedPublication => l.reasonProhibitedPublication,
    damageBeyondThreshold => l.reasonDamageBeyondThreshold,
    wrongCatalogInfo => l.reasonWrongCatalogInfo,
    duplicateListing => l.reasonDuplicateListing,
  };

  /// Nhãn cho mã lý do bất kỳ; mã lạ thì trả nguyên mã.
  static String labelOf(String code, AppLocalizations l) =>
      fromApi(code)?.label(l) ?? code;
}

/// Một dòng của hàng đợi kiểm định hoặc danh sách đang giữ.
class QueueItem {
  const QueueItem({
    required this.listing,
    this.waitingHours,
    this.isOverdue = false,
    this.claimExpiresAt,
  });

  factory QueueItem.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    // Dòng có thể là tin phẳng kèm số liệu, hoặc { listing: {...}, ... }.
    final nested = readMap(j, 'listing');
    return QueueItem(
      listing: Listing.fromJson(nested ?? j),
      waitingHours: readDouble(j, 'waitingHours'),
      isOverdue: readBool(j, 'isOverdue') ?? false,
      claimExpiresAt: readDate(j, 'claimExpiresAt'),
    );
  }

  final Listing listing;
  final double? waitingHours;
  final bool isOverdue;
  final DateTime? claimExpiresAt;
}

/// Tin đang được kiểm định kèm thời điểm hết khóa.
class ClaimedListing {
  const ClaimedListing({required this.listing, required this.expiresAt});
  final Listing listing;
  final DateTime expiresAt;
}

class QueueFilter {
  const QueueFilter({this.categoryId, this.priceFrom, this.priceTo});

  final String? categoryId;
  final int? priceFrom;
  final int? priceTo;

  bool get isEmpty =>
      categoryId == null && priceFrom == null && priceTo == null;

  @override
  bool operator ==(Object other) =>
      other is QueueFilter &&
      other.categoryId == categoryId &&
      other.priceFrom == priceFrom &&
      other.priceTo == priceTo;

  @override
  int get hashCode => Object.hash(categoryId, priceFrom, priceTo);
}
