import '../../../core/l10n/app_localizations.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_tag.dart';
import '../../sim/domain/rules.dart';
import '../../sim/presentation/sim_text.dart';
import '../domain/auction.dart';

String auctionStatusLabel(AppLocalizations l, Auction a) => switch (a.status) {
  AuctionStatus.live => l.aucStatusLive,
  AuctionStatus.buyNowCountdown => l.aucStatusBuyNow,
  AuctionStatus.registrationOpen => l.aucStatusRegistration,
  AuctionStatus.confirmed => l.aucStatusConfirmed,
  AuctionStatus.endedSold => l.aucStatusEnded,
  AuctionStatus.endedNoBid => l.aucStatusNoBid,
};

AppTagTone auctionStatusTone(Auction a) => switch (a.status) {
  AuctionStatus.live || AuctionStatus.buyNowCountdown => AppTagTone.error,
  AuctionStatus.registrationOpen => AppTagTone.success,
  AuctionStatus.confirmed => AppTagTone.warning,
  _ => AppTagTone.neutral,
};

String participantsText(AppLocalizations l, Auction a) =>
    a.status == AuctionStatus.registrationOpen
    ? l.aucParticipantsMin(a.participants, '${a.minParticipants}')
    : l.aucParticipants(a.participants);

String priceLabel(AppLocalizations l, Auction a) => a.hasBids
    ? (a.status.isEnded ? l.aucPriceWinning : l.aucPriceCurrent)
    : l.aucPriceStarting;

int displayPrice(Auction a) => a.hasBids ? a.current : a.startingPrice;

/// Nhãn và giá trị đồng hồ của phiên tại thời điểm [now].
({String label, String value, bool urgent}) auctionTimer(
  AppLocalizations l,
  Auction a,
  DateTime now,
) {
  String dur(DateTime t) => remainingText(l, t.difference(now));
  switch (a.status) {
    case AuctionStatus.live:
      final r = a.endsAt!.difference(now);
      return (
        label: l.aucTimerEndsIn,
        value: dur(a.endsAt!),
        urgent: r < antiSnipingWindow,
      );
    case AuctionStatus.buyNowCountdown:
      return (
        label: l.aucTimerCountdown,
        value: dur(a.countdownEndsAt!),
        urgent: true,
      );
    case AuctionStatus.registrationOpen:
      return (
        label: l.aucTimerRegCloses,
        value: dur(a.registrationClosesAt!),
        urgent: false,
      );
    case AuctionStatus.confirmed:
      return (
        label: l.aucTimerStartsIn,
        value: dur(a.startsAt!),
        urgent: false,
      );
    case AuctionStatus.endedSold || AuctionStatus.endedNoBid:
      return (
        label: l.aucTimerEndedAt,
        value: formatShortDateTime(a.endedAt ?? now),
        urgent: false,
      );
  }
}

String? auctionTimerSub(AppLocalizations l, Auction a) => switch (a.status) {
  AuctionStatus.live => l.aucSubLive,
  AuctionStatus.buyNowCountdown => l.aucSubCountdown(
    formatShortDateTime(a.hardEndsAt!),
  ),
  AuctionStatus.registrationOpen => l.aucSubRegistration(
    formatShortDateTime(a.startsAt!),
    '${a.minParticipants}',
  ),
  AuctionStatus.confirmed => l.aucSubConfirmed(
    formatShortDateTime(a.startsAt!),
  ),
  _ => null,
};

String leaderText(AppLocalizations l, Auction a) => !a.hasBids
    ? l.aucNoBids
    : a.iAmLeading
    ? l.aucLeaderMe
    : l.aucLeaderOther(a.leaderName ?? '');
