import '../../../core/l10n/app_localizations.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_tag.dart';
import '../../orders/domain/order.dart';
import '../../notifications/domain/sim_notification.dart';
import '../../wallet/domain/wallet_txn.dart';
import '../application/sim_state.dart';

/// Chuyển các giá trị của kho mô phỏng sang chuỗi theo ngôn ngữ hiện tại.

String simToastText(AppLocalizations l, String locale, SimToast t) {
  String money() => formatVnd(t.amount ?? 0, locale);
  return switch (t.kind) {
    SimToastKind.orderCancelled => l.toastOrderCancelled(money()),
    SimToastKind.orderCompleted => l.toastOrderCompleted,
    SimToastKind.complaintOpened => l.toastComplaintOpened,
    SimToastKind.offerAccepted => l.toastOfferAccepted(money()),
    SimToastKind.noBooksAvailable => l.toastNoBooks,
    SimToastKind.sellerShipped => l.toastSellerShipped,
    SimToastKind.deliveryFailed => l.toastDeliveryFailed(t.amount ?? 1),
    SimToastKind.movedToStorage => l.toastMovedToStorage,
    SimToastKind.topupOk => l.toastTopupOk(money()),
    SimToastKind.withdrawRequested => l.toastWithdrawRequested(money()),
    SimToastKind.rated => l.toastRated(t.amount ?? 0),
    SimToastKind.registered => l.toastRegistered(money()),
    SimToastKind.unregistered => l.toastUnregistered(money()),
    SimToastKind.leading => l.toastLeading(money()),
    SimToastKind.buyNowStarted => l.toastBuyNowStarted,
    SimToastKind.outbid => l.toastOutbid(t.text ?? '', money()),
    SimToastKind.auctionWon => l.toastAuctionWon(t.text ?? '', money()),
  };
}

String txnLabel(AppLocalizations l, WalletTxn t) {
  final arg = t.arg ?? '';
  return switch (t.reason) {
    TxnReason.topupVietQr => l.txnTopupVietQr,
    TxnReason.holdOrder => l.txnHoldOrder(arg),
    TxnReason.holdOrders => l.txnHoldOrders(int.tryParse(arg) ?? 1),
    TxnReason.holdAuctionRegistration => l.txnHoldAuctionRegistration(arg),
    TxnReason.holdBid => l.txnHoldBid(arg),
    TxnReason.holdBuyNow => l.txnHoldBuyNow(arg),
    TxnReason.holdRedeliveryFee => l.txnHoldRedelivery(arg),
    TxnReason.releaseOrderCancelled => l.txnReleaseOrderCancelled(arg),
    TxnReason.releaseAuctionUnregistered => l.txnReleaseAuctionUnregistered(
      arg,
    ),
    TxnReason.releaseAuctionDeposit => l.txnReleaseAuctionDeposit(arg),
    TxnReason.payoutSale => l.txnPayoutSale(arg),
    TxnReason.captureOrder => l.txnCaptureOrder(arg),
    TxnReason.refundAgreement => l.txnRefundAgreement(arg),
    TxnReason.refundVerdict => l.txnRefundVerdict(arg),
    TxnReason.withdrawRequest => l.txnWithdrawRequest,
  };
}

String txnTypeLabel(AppLocalizations l, TxnType t) => switch (t) {
  TxnType.topup => l.txnTypeTopup,
  TxnType.hold => l.txnTypeHold,
  TxnType.release => l.txnTypeRelease,
  TxnType.payout => l.txnTypePayout,
  TxnType.refund => l.txnTypeRefund,
  TxnType.capture => l.txnTypeCapture,
  TxnType.withdraw => l.txnTypeWithdraw,
};

String orderStatusLabel(AppLocalizations l, OrderStatus s) => switch (s) {
  OrderStatus.paidAwaitingShipment => l.orderStatusPaidAwaitingShipment,
  OrderStatus.shipped => l.orderStatusShipped,
  OrderStatus.delivered => l.orderStatusDelivered,
  OrderStatus.completed => l.orderStatusCompleted,
  OrderStatus.cancelledByBuyer => l.orderStatusCancelled,
  OrderStatus.refunded => l.orderStatusRefunded,
  OrderStatus.partiallyRefunded => l.orderStatusPartiallyRefunded,
  OrderStatus.disputed => l.orderStatusDisputed,
  OrderStatus.readyToShip => l.orderStatusReadyToShip,
  OrderStatus.inDelivery => l.orderStatusInDelivery,
  OrderStatus.inStorage => l.orderStatusInStorage,
  OrderStatus.pickedUp => l.orderStatusPickedUp,
};

AppTagTone orderStatusTone(OrderStatus s) => switch (s) {
  OrderStatus.delivered || OrderStatus.pickedUp => AppTagTone.success,
  OrderStatus.paidAwaitingShipment ||
  OrderStatus.readyToShip => AppTagTone.warning,
  OrderStatus.shipped || OrderStatus.inDelivery => AppTagTone.info,
  OrderStatus.disputed || OrderStatus.inStorage => AppTagTone.error,
  _ => AppTagTone.neutral,
};

String orderKindLabel(AppLocalizations l, Order o) =>
    o.isAuction ? l.orderKindAuction : l.orderKindSale;

String remainingText(AppLocalizations l, Duration d) => formatRemaining(
  d,
  daysHours: (days, hours) => l.remainingDaysHours(days, hours),
);

String complaintStatusLabel(AppLocalizations l, ComplaintStatus s) =>
    switch (s) {
      ComplaintStatus.open => l.complaintStatusOpen,
      ComplaintStatus.sellerResponded => l.complaintStatusSellerResponded,
      ComplaintStatus.escalated => l.complaintStatusEscalated,
      ComplaintStatus.agreed => l.complaintStatusAgreed,
      ComplaintStatus.resolved => l.complaintStatusResolved,
    };

String complaintReasonLabel(AppLocalizations l, ComplaintReason r) =>
    switch (r) {
      ComplaintReason.notAsDescribed => l.complaintReasonNotAsDescribed,
      ComplaintReason.damaged => l.complaintReasonDamaged,
      ComplaintReason.wrongItem => l.complaintReasonWrongItem,
      ComplaintReason.other => l.complaintReasonOther,
    };

/// "vừa xong", "5 phút trước"... so với [now].
String agoText(AppLocalizations l, DateTime now, DateTime t) {
  final s = now.difference(t).inSeconds;
  if (s < 60) return l.agoNow;
  if (s < 3600) return l.agoMinutes(s ~/ 60);
  if (s < 86400) return l.agoHours(s ~/ 3600);
  return l.agoDays(s ~/ 86400);
}

/// Kiểu thông báo nổi (màu đi kèm biểu tượng) theo loại sự kiện.
AppSnackbarType simToastType(SimToastKind k) => switch (k) {
  SimToastKind.orderCompleted ||
  SimToastKind.topupOk ||
  SimToastKind.leading ||
  SimToastKind.registered ||
  SimToastKind.auctionWon ||
  SimToastKind.offerAccepted => AppSnackbarType.success,
  SimToastKind.outbid ||
  SimToastKind.complaintOpened ||
  SimToastKind.noBooksAvailable ||
  SimToastKind.deliveryFailed ||
  SimToastKind.movedToStorage => AppSnackbarType.error,
  _ => AppSnackbarType.info,
};

/// Tiêu đề và nội dung của thông báo mô phỏng theo ngôn ngữ hiện tại.
({String title, String body}) simNotificationText(
  AppLocalizations l,
  String locale,
  SimNotification n,
) {
  final arg = n.arg ?? '';
  final amount = formatVnd(n.amount ?? 0, locale);
  return switch (n.kind) {
    SimNotificationKind.auctionBuyNowCountdown => (
      title: l.simNotifBuyNowTitle(arg),
      body: l.simNotifBuyNowBody,
    ),
    SimNotificationKind.orderDelivered => (
      title: l.simNotifDeliveredTitle(arg),
      body: l.simNotifDeliveredBody,
    ),
    SimNotificationKind.auctionFilled => (
      title: l.simNotifFilledTitle(arg),
      body: l.simNotifFilledBody(amount),
    ),
    SimNotificationKind.topupOk => (
      title: l.simNotifTopupTitle,
      body: l.simNotifTopupBody(amount),
    ),
    SimNotificationKind.auctionRegistered => (
      title: l.simNotifRegisteredTitle,
      body: l.simNotifRegisteredBody(arg, amount),
    ),
    SimNotificationKind.outbid => (
      title: l.simNotifOutbidTitle,
      body: l.simNotifOutbidBody(arg, amount),
    ),
    SimNotificationKind.auctionWon => (
      title: l.simNotifWonTitle(arg),
      body: l.simNotifWonBody(amount),
    ),
  };
}
