import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/app_tag.dart';
import '../domain/auction_order.dart';

String auctionOrderStatusLabel(AppLocalizations l, AuctionOrderStatus s) =>
    switch (s) {
      AuctionOrderStatus.awaitingShippingFee => l.aoStatusAwaitingFee,
      AuctionOrderStatus.readyToShip => l.aoStatusReadyToShip,
      AuctionOrderStatus.inDelivery => l.aoStatusInDelivery,
      AuctionOrderStatus.inStorage => l.aoStatusInStorage,
      AuctionOrderStatus.delivered => l.aoStatusDelivered,
      AuctionOrderStatus.pickedUp => l.aoStatusPickedUp,
      AuctionOrderStatus.storageExpired => l.aoStatusStorageExpired,
      AuctionOrderStatus.disputed => l.aoStatusDisputed,
      AuctionOrderStatus.completed => l.aoStatusCompleted,
      AuctionOrderStatus.refunded => l.aoStatusRefunded,
      AuctionOrderStatus.partiallyRefunded => l.aoStatusPartiallyRefunded,
      AuctionOrderStatus.unknown => l.statusUnknown,
    };

AppTagTone auctionOrderStatusTone(AuctionOrderStatus s) => switch (s) {
  AuctionOrderStatus.awaitingShippingFee ||
  AuctionOrderStatus.inStorage ||
  AuctionOrderStatus.storageExpired => AppTagTone.warning,
  AuctionOrderStatus.disputed => AppTagTone.error,
  AuctionOrderStatus.completed ||
  AuctionOrderStatus.delivered ||
  AuctionOrderStatus.pickedUp => AppTagTone.success,
  _ => AppTagTone.neutral,
};

String postExpiryStatusLabel(AppLocalizations l, PostExpiryStatus s) =>
    switch (s) {
      PostExpiryStatus.awaitingDecision => l.aoPeAwaitingDecision,
      PostExpiryStatus.extended => l.aoPeExtended,
      PostExpiryStatus.awaitingLiquidation => l.aoPeAwaitingLiquidation,
      PostExpiryStatus.liquidated => l.aoPeLiquidated,
      PostExpiryStatus.releasedToBuyer => l.aoPeReleased,
      PostExpiryStatus.unknown => l.statusUnknown,
    };
