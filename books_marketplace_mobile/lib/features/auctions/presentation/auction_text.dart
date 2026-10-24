import '../../../core/l10n/app_localizations.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_tag.dart';
import '../domain/auction.dart';

String auctionStatusLabel(AppLocalizations l, AuctionStatus s) => switch (s) {
  AuctionStatus.awaitingInbound => l.aucStatusAwaitingInbound,
  AuctionStatus.pendingReview => l.aucStatusPendingReview,
  AuctionStatus.registrationOpen => l.aucStatusRegistration,
  AuctionStatus.notEnoughParticipants => l.aucStatusNotEnough,
  AuctionStatus.confirmed => l.aucStatusConfirmed,
  AuctionStatus.live => l.aucStatusLive,
  AuctionStatus.buyNowCountdown => l.aucStatusBuyNow,
  AuctionStatus.endedSold => l.aucStatusEnded,
  AuctionStatus.endedNoBid => l.aucStatusNoBid,
  AuctionStatus.rejected => l.aucStatusRejected,
  AuctionStatus.cancelled => l.aucStatusCancelled,
  AuctionStatus.convertedToSale => l.aucStatusConverted,
  AuctionStatus.returned => l.aucStatusReturned,
  AuctionStatus.unknown => l.statusUnknown,
};

AppTagTone auctionStatusTone(AuctionStatus s) => switch (s) {
  AuctionStatus.live || AuctionStatus.buyNowCountdown => AppTagTone.error,
  AuctionStatus.registrationOpen => AppTagTone.success,
  AuctionStatus.confirmed ||
  AuctionStatus.awaitingInbound ||
  AuctionStatus.pendingReview ||
  AuctionStatus.notEnoughParticipants => AppTagTone.warning,
  _ => AppTagTone.neutral,
};

/// Nhãn của giá đang hiển thị.
String priceLabel(AppLocalizations l, AuctionStatus status, bool hasBids) =>
    !hasBids
    ? l.aucPriceStarting
    : status.isEnded
    ? l.aucPriceWinning
    : l.aucPriceCurrent;

/// Nhãn đồng hồ theo trạng thái phiên.
String timerLabel(AppLocalizations l, AuctionStatus s) => switch (s) {
  AuctionStatus.live => l.aucTimerEndsIn,
  AuctionStatus.buyNowCountdown => l.aucTimerCountdown,
  AuctionStatus.registrationOpen => l.aucTimerRegCloses,
  AuctionStatus.confirmed => l.aucTimerStartsIn,
  AuctionStatus.awaitingInbound => l.aucTimerInboundDeadline,
  AuctionStatus.notEnoughParticipants ||
  AuctionStatus.endedNoBid => l.aucTimerFallbackDeadline,
  _ => l.aucTimerEndedAt,
};

/// Thời gian còn lại theo ngôn ngữ (`mm:ss`, `h:mm:ss` hoặc `n ngày h giờ`).
String remainingText(AppLocalizations l, Duration d) => formatRemaining(
  d,
  daysHours: (days, hours) => l.remainingDaysHours(days, hours),
);

String agoText(AppLocalizations l, DateTime now, DateTime t) {
  final s = now.difference(t).inSeconds;
  if (s < 60) return l.agoNow;
  if (s < 3600) return l.agoMinutes(s ~/ 60);
  if (s < 86400) return l.agoHours(s ~/ 3600);
  return l.agoDays(s ~/ 86400);
}

/// Dòng phụ dưới bảng giá.
String? auctionTimerSub(AppLocalizations l, Auction a) => switch (a.status) {
  AuctionStatus.live => l.aucSubLive,
  AuctionStatus.buyNowCountdown when a.live?.hardEndAt != null =>
    l.aucSubCountdown(formatShortDateTime(a.live!.hardEndAt!)),
  AuctionStatus.registrationOpen when a.startAt != null =>
    l.aucSubRegistrationOpen(formatShortDateTime(a.startAt!)),
  AuctionStatus.confirmed when a.startAt != null => l.aucSubConfirmed(
    formatShortDateTime(a.startAt!),
  ),
  _ => null,
};

String leaderText(AppLocalizations l, Auction a) {
  if (!a.hasBids) return l.aucNoBids;
  if (a.isLeading) return l.aucLeaderMe;
  final name = a.status.isEnded ? a.live?.winner : a.live?.leader;
  return name == null ? l.aucNoBids : l.aucLeaderOther(name);
}

String registrationLabel(AppLocalizations l, RegistrationStatus s) =>
    switch (s) {
      RegistrationStatus.active => l.aucRegisteredTag,
      RegistrationStatus.confirmed => l.aucRegConfirmedTag,
      RegistrationStatus.cancelled => l.aucRegCancelledTag,
      RegistrationStatus.refunded => l.aucRegRefundedTag,
      RegistrationStatus.completed => l.aucRegCompletedTag,
      RegistrationStatus.unknown => l.statusUnknown,
    };

String returnStatusLabel(AppLocalizations l, ReturnOrderStatus s) =>
    switch (s) {
      ReturnOrderStatus.awaitingFee => l.aucReturnAwaitingFee,
      ReturnOrderStatus.readyToDispatch => l.aucReturnReady,
      ReturnOrderStatus.dispatched => l.aucReturnDispatched,
      ReturnOrderStatus.unknown => l.statusUnknown,
    };
