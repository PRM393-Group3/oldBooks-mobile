import '../../../core/l10n/app_localizations.dart';

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
