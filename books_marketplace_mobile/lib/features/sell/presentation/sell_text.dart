import '../../../core/l10n/app_localizations.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_tag.dart';
import '../domain/my_listing.dart';
import '../domain/sell_rules.dart';

String sellConditionLabel(AppLocalizations l, SellCondition c) =>
    c.condition.label(l);

String sellErrorText(
  AppLocalizations l,
  String locale,
  SellError e,
  SellForm f, {
  SellRules rules = SellRules.defaults,
}) => switch (e) {
  SellError.photos => l.sellErrPhotos(f.photos),
  SellError.title => l.sellErrTitle,
  SellError.author => l.sellErrAuthor,
  SellError.price => l.sellErrPrice,
  SellError.startingPrice => l.sellErrStart,
  SellError.step => l.sellErrStep(
    formatVnd(rules.stepRange(f.startingPrice).lo, locale),
    formatVnd(rules.stepRange(f.startingPrice).hi, locale),
  ),
  SellError.buyNow => l.sellErrBuyNow(
    formatVnd(rules.minBuyNow(f.startingPrice), locale),
  ),
  SellError.description => l.sellErrDesc,
  SellError.category => l.sellErrCategory,
  SellError.isbn => l.sellErrIsbn,
  SellError.year => l.sellErrIsbn,
};

String myListingStatusLabel(AppLocalizations l, MyListingStatus s) =>
    switch (s) {
      MyListingStatus.published => l.myListingStatusPublished,
      MyListingStatus.pendingReview => l.myListingStatusPending,
      MyListingStatus.needsChanges => l.myListingStatusNeedsChanges,
      MyListingStatus.awaitingInbound => l.myListingStatusAwaitingInbound,
      MyListingStatus.sold => l.myListingStatusSold,
    };

AppTagTone myListingStatusTone(MyListingStatus s) => switch (s) {
  MyListingStatus.published => AppTagTone.success,
  MyListingStatus.pendingReview => AppTagTone.warning,
  MyListingStatus.needsChanges => AppTagTone.error,
  MyListingStatus.awaitingInbound => AppTagTone.warning,
  MyListingStatus.sold => AppTagTone.neutral,
};

String myListingKind(AppLocalizations l, String locale, MyListing m) {
  final price = formatVnd(m.price, locale);
  return m.isAuction
      ? l.myListingKindAuction(price)
      : l.myListingKindFixed(price);
}

String myListingNote(
  AppLocalizations l,
  String locale,
  MyListing m,
  DateTime now,
) {
  switch (m.status) {
    case MyListingStatus.published:
      return l.myListingNotePublished(
        now.difference(m.createdAt).inDays,
        '${m.views}',
      );
    case MyListingStatus.pendingReview:
      final hours = now.difference(m.createdAt).inHours;
      return hours < 1
          ? l.myListingNotePendingNow
          : l.myListingNotePending(hours);
    case MyListingStatus.needsChanges:
      return l.myListingNoteNeedsChanges(m.adminReason ?? '');
    case MyListingStatus.awaitingInbound:
      return l.myListingNoteInbound(
        formatShortDateTime(m.inboundDeadline ?? now),
        m.inboundCode ?? '',
      );
    case MyListingStatus.sold:
      return l.myListingNoteSold(formatVnd(m.received ?? 0, locale));
  }
}
