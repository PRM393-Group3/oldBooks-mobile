import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/app_tag.dart';
import '../domain/complaint_case.dart';

String caseReasonLabel(AppLocalizations l, CaseReason r) => switch (r) {
  CaseReason.notAsDescribed => l.cpReasonNotAsDescribed,
  CaseReason.damaged => l.cpReasonDamaged,
  CaseReason.wrongItem => l.cpReasonWrongItem,
  CaseReason.other => l.cpReasonOther,
};

String caseStatusLabel(AppLocalizations l, CaseStatus s) => switch (s) {
  CaseStatus.open => l.cpStatusOpen,
  CaseStatus.sellerResponded => l.cpStatusResponded,
  CaseStatus.escalated => l.cpStatusEscalated,
  CaseStatus.agreed => l.cpStatusAgreed,
  CaseStatus.resolved => l.cpStatusResolved,
  CaseStatus.unknown => l.statusUnknown,
};

AppTagTone caseStatusTone(CaseStatus s) => switch (s) {
  CaseStatus.open || CaseStatus.sellerResponded => AppTagTone.warning,
  CaseStatus.escalated => AppTagTone.info,
  CaseStatus.agreed || CaseStatus.resolved => AppTagTone.success,
  CaseStatus.unknown => AppTagTone.neutral,
};

String caseAuthorLabel(AppLocalizations l, CaseAuthorRole r) => switch (r) {
  CaseAuthorRole.buyer => l.cpAuthorBuyer,
  CaseAuthorRole.seller => l.cpAuthorSeller,
  CaseAuthorRole.admin => l.cpAuthorAdmin,
  CaseAuthorRole.system => l.cpAuthorSystem,
  CaseAuthorRole.unknown => '',
};

/// Tiêu đề dòng diễn biến; tin nhắn không có tiêu đề (hiện tên người gửi).
String? caseEntryTitle(AppLocalizations l, CaseEntryKind k) => switch (k) {
  CaseEntryKind.opened => l.cpEntryOpened,
  CaseEntryKind.sellerResponse => l.cpEntrySellerResponse,
  CaseEntryKind.buyerDecision => l.cpEntryBuyerDecision,
  CaseEntryKind.escalated => l.cpEntryEscalated,
  CaseEntryKind.resolved => l.cpEntryResolved,
  CaseEntryKind.message || CaseEntryKind.unknown => null,
};

String? escalationText(AppLocalizations l, String? cause) => switch (cause) {
  'SELLER_TIMEOUT' => l.cpEscSellerTimeout,
  'BUYER_REJECTED' => l.cpEscBuyerRejected,
  'BUYER_TIMEOUT' => l.cpEscBuyerTimeout,
  'AUCTION' => l.cpEscAuction,
  _ => null,
};
