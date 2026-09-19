import '../../../core/l10n/app_localizations.dart';

/// Trạng thái tin đăng (SRS 10.1, phần backend đã hỗ trợ).
enum ListingStatus {
  draft('Draft'),
  pendingInspection('PendingInspection'),
  inInspection('InInspection'),
  rejected('Rejected'),
  onSale('OnSale'),
  auctioning('Auctioning'),
  closed('Closed'),
  unknown('');

  const ListingStatus(this.api);
  final String api;

  static ListingStatus fromApi(String? v) => values.firstWhere(
    (s) => s.api == v && s != unknown,
    orElse: () => unknown,
  );

  /// Chỉ sửa được khi Nháp hoặc Bị từ chối.
  bool get isEditable => this == draft || this == rejected;

  /// Người mua nhìn thấy.
  bool get isPublic => this == onSale || this == auctioning;

  String label(AppLocalizations l) => switch (this) {
    draft => l.statusDraft,
    pendingInspection => l.statusPendingInspection,
    inInspection => l.statusInInspection,
    rejected => l.statusRejected,
    onSale => l.statusOnSale,
    auctioning => l.statusAuctioning,
    closed => l.statusClosed,
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

enum BookCondition {
  likeNew('LikeNew'),
  veryGood('VeryGood'),
  good('Good'),
  fair('Fair'),
  poor('Poor');

  const BookCondition(this.api);
  final String api;

  static BookCondition? fromApi(String? v) {
    for (final c in values) {
      if (c.api == v) return c;
    }
    return null;
  }

  String label(AppLocalizations l) => switch (this) {
    likeNew => l.conditionLikeNew,
    veryGood => l.conditionVeryGood,
    good => l.conditionGood,
    fair => l.conditionFair,
    poor => l.conditionPoor,
  };

  /// Tiêu chí của từng mức, hiện ngay trên màn hình chọn (FR-SEL-06).
  String description(AppLocalizations l) => switch (this) {
    likeNew => l.conditionLikeNewDesc,
    veryGood => l.conditionVeryGoodDesc,
    good => l.conditionGoodDesc,
    fair => l.conditionFairDesc,
    poor => l.conditionPoorDesc,
  };
}

enum CoverType {
  paperback('Paperback'),
  hardcover('Hardcover');

  const CoverType(this.api);
  final String api;

  static CoverType? fromApi(String? v) {
    for (final c in values) {
      if (c.api == v) return c;
    }
    return null;
  }

  String label(AppLocalizations l) =>
      this == paperback ? l.coverPaperback : l.coverHardcover;
}

enum ImageType {
  frontCover('FrontCover'),
  backCover('BackCover'),
  spine('Spine'),
  innerPage('InnerPage');

  const ImageType(this.api);
  final String api;

  /// Bốn góc bắt buộc theo FR-SEL-05, theo thứ tự hiển thị.
  static const required = [frontCover, backCover, spine, innerPage];

  static ImageType? fromApi(String? v) {
    for (final t in values) {
      if (t.api == v) return t;
    }
    return null;
  }

  String label(AppLocalizations l) => switch (this) {
    frontCover => l.imageFrontCover,
    backCover => l.imageBackCover,
    spine => l.imageSpine,
    innerPage => l.imageInnerPage,
  };
}

enum AuctionStartMode {
  onApproval('OnApproval'),
  scheduled('Scheduled');

  const AuctionStartMode(this.api);
  final String api;

  static AuctionStartMode? fromApi(String? v) {
    for (final m in values) {
      if (m.api == v) return m;
    }
    return null;
  }

  String label(AppLocalizations l) =>
      this == onApproval ? l.startOnApproval : l.startScheduled;
}
