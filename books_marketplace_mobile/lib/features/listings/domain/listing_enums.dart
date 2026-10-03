import '../../../core/l10n/app_localizations.dart';

/// Trạng thái tin đăng (`08-listings`, mục 1). Mã lạ rơi vào [unknown].
enum ListingStatus {
  draft('DRAFT'),
  pendingReview('PENDING_REVIEW'),
  needsChanges('NEEDS_CHANGES'),
  rejected('REJECTED'),
  published('PUBLISHED'),
  reserved('RESERVED'),
  sold('SOLD'),
  unpublished('UNPUBLISHED'),
  unknown('');

  const ListingStatus(this.api);
  final String api;

  static ListingStatus fromApi(String? v) => values.firstWhere(
    (s) => s.api == v && s != unknown,
    orElse: () => unknown,
  );

  /// Sửa tự do mọi trường và ảnh.
  bool get isFreelyEditable =>
      this == draft || this == needsChanges || this == unpublished;

  /// Có sửa được không (kể cả `PUBLISHED`: chỉ giá và mô tả có hiệu lực ngay,
  /// phần khác đưa tin về chờ duyệt).
  bool get isEditable => isFreelyEditable || this == published;

  /// Gửi duyệt được: nháp, cần sửa, hoặc đã gỡ (đăng lại).
  bool get canSubmit => isFreelyEditable;

  /// Gỡ được khi đang bán.
  bool get canUnpublish => this == published;

  /// Ai cũng xem được (nhưng chỉ `published` mới mua được).
  bool get isPublic => this == published || this == reserved || this == sold;

  String label(AppLocalizations l) => switch (this) {
    draft => l.statusDraft,
    pendingReview => l.myListingStatusPending,
    needsChanges => l.myListingStatusNeedsChanges,
    rejected => l.statusRejected,
    published => l.statusOnSale,
    reserved => l.statusReserved,
    sold => l.myListingStatusSold,
    unpublished => l.statusUnpublished,
    unknown => l.statusUnknown,
  };
}

enum SaleMethod {
  fixedPrice('FixedPrice'),
  auction('Auction');

  const SaleMethod(this.api);
  final String api;

  static SaleMethod? fromApi(String? v) {
    for (final m in values) {
      if (m.api == v) return m;
    }
    return null;
  }

  String label(AppLocalizations l) =>
      this == fixedPrice ? l.saleFixedPrice : l.saleAuction;
}

/// Tình trạng sách: `NEW` mới, `GOOD` tốt, `FAIR` khá, `WORN` cũ.
enum BookCondition {
  brandNew('NEW'),
  good('GOOD'),
  fair('FAIR'),
  worn('WORN');

  const BookCondition(this.api);
  final String api;

  static BookCondition? fromApi(String? v) {
    for (final c in values) {
      if (c.api == v) return c;
    }
    return null;
  }

  String label(AppLocalizations l) => switch (this) {
    brandNew => l.conditionBrandNew,
    good => l.conditionGood,
    fair => l.conditionFair,
    worn => l.conditionWorn,
  };
}
