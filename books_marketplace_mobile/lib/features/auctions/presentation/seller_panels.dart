import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/countdown_text.dart';
import '../../wallet/presentation/topup_sheet.dart';
import '../domain/auction.dart';
import 'auction_text.dart';

/// Khối thông tin và thao tác của người bán trên chi tiết phiên (chỉ hiện khi
/// server trả `owner`).
class SellerPanel extends StatelessWidget {
  const SellerPanel({
    super.key,
    required this.auction,
    required this.busy,
    required this.onCancel,
    required this.onFallback,
  });

  final Auction auction;
  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onFallback;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final a = auction;
    final owner = a.owner!;
    final children = <Widget>[];

    switch (a.status) {
      case AuctionStatus.awaitingInbound:
        children
          ..add(InboundCodeCard(owner: owner))
          ..add(const SizedBox(height: AppSpacing.sm))
          ..add(
            AppButton(
              label: l.aucCancel,
              variant: AppButtonVariant.secondary,
              loading: busy,
              onPressed: onCancel,
            ),
          );
      case AuctionStatus.pendingReview:
        children
          ..add(
            _InfoCard(
              title: l.aucPendingReviewTitle,
              body: l.aucPendingReviewBody,
            ),
          )
          ..add(const SizedBox(height: AppSpacing.sm))
          ..add(
            AppButton(
              label: l.aucCancel,
              variant: AppButtonVariant.secondary,
              loading: busy,
              onPressed: onCancel,
            ),
          );
      case AuctionStatus.rejected:
        children.add(
          _InfoCard(
            title: l.aucRejectedTitle,
            body: owner.reviewReason ?? '',
            tone: _Tone.error,
          ),
        );
      case AuctionStatus.cancelled:
        children.add(
          _InfoCard(
            title: l.aucStatusCancelled,
            body: owner.cancelCause == 'INBOUND_TIMEOUT'
                ? l.aucCancelledTimeout
                : l.aucCancelledBySeller,
            tone: _Tone.error,
          ),
        );
      case AuctionStatus.registrationOpen || AuctionStatus.confirmed:
        children.add(
          _InfoCard(
            title: l.aucSellerWaitingTitle,
            body: l.aucParticipants(a.registeredCount),
          ),
        );
      case AuctionStatus.notEnoughParticipants || AuctionStatus.endedNoBid:
        final deadline = owner.fallbackDeadlineAt;
        children
          ..add(
            _InfoCard(
              title: a.status == AuctionStatus.endedNoBid
                  ? l.aucNoBidTitle
                  : l.aucNotEnoughTitle,
              body: l.aucFallbackBody,
              tone: _Tone.warning,
              footer: deadline == null
                  ? null
                  : Countdown(
                      target: deadline,
                      daysHours: l.remainingDaysHours,
                      builder: (context, left, expired) => Text(
                        expired
                            ? l.aucFallbackExpired
                            : l.aucFallbackLeft(left),
                        style: context.text.labelMedium,
                      ),
                    ),
            ),
          )
          ..add(const SizedBox(height: AppSpacing.sm))
          ..add(
            AppButton(label: l.fbTitle, loading: busy, onPressed: onFallback),
          );
      case AuctionStatus.endedSold:
        final orderId = a.live?.auctionOrderId;
        children
          ..add(
            _InfoCard(
              title: l.aucSoldTitle,
              body: l.aucSoldBody(
                formatVnd(a.live?.finalPrice ?? a.displayPrice, locale),
              ),
              tone: _Tone.success,
            ),
          )
          ..addAll([
            if (orderId != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l.aucViewOrder,
                onPressed: () => context.push('/me/auction-orders/$orderId'),
              ),
            ],
          ]);
      case AuctionStatus.convertedToSale:
        final listingId = owner.convertedListingId;
        children
          ..add(_InfoCard(title: l.aucConvertedTitle, body: l.aucConvertedBody))
          ..addAll([
            if (listingId != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l.aucViewListing,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push('/home/book/$listingId'),
              ),
            ],
          ]);
      case AuctionStatus.returned:
        children.add(
          _InfoCard(title: l.aucStatusReturned, body: l.aucReturnedBody),
        );
      case AuctionStatus.live ||
          AuctionStatus.buyNowCountdown ||
          AuctionStatus.unknown:
        break;
    }

    final ret = owner.returnOrder;
    if (ret != null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: AppSpacing.sm));
      }
      children.add(ReturnOrderCard(order: ret));
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.aucSellerSection.toUpperCase(),
            style: AppTypography.overline.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...children,
        ],
      ),
    );
  }
}

/// Mã nhập kho: hiển thị to, sao chép được, kèm địa chỉ kho và hạn gửi.
class InboundCodeCard extends StatelessWidget {
  const InboundCodeCard({super.key, required this.owner});

  final AuctionOwnerInfo owner;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final warehouse = owner.warehouse;
    final deadline = owner.inboundDeadlineAt;

    Future<void> copy(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) AppSnackbar.success(context, l.copied);
    }

    return AppCard(
      color: colors.warningContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.sellDoneCode,
            style: context.text.labelSmall?.copyWith(
              color: colors.onWarningContainer,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  owner.inboundCode,
                  style: TextStyle(
                    fontFamily: AppTypography.monoFamily,
                    fontVariations: AppTypography.monoSemiBold,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: l.copy,
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => copy(owner.inboundCode),
              ),
            ],
          ),
          Text(
            l.aucInboundHint,
            style: context.text.labelSmall?.copyWith(
              color: colors.onWarningContainer,
              height: 1.5,
            ),
          ),
          if (deadline != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Countdown(
              target: deadline,
              daysHours: l.remainingDaysHours,
              builder: (context, left, expired) => Text(
                expired ? l.aucInboundExpired : l.aucInboundLeft(left),
                style: context.text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (warehouse != null) ...[
            const Divider(height: 20),
            Text(l.aucWarehouse, style: context.text.labelLarge),
            const SizedBox(height: 2),
            Text(
              '${warehouse.recipient} · ${warehouse.phone}\n${warehouse.address}',
              style: context.text.bodySmall?.copyWith(height: 1.5),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => copy(
                  '${owner.inboundCode}\n${warehouse.recipient} · ${warehouse.phone}\n${warehouse.address}',
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: Text(l.aucCopyShipping),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Lệnh trả sách về người bán.
class ReturnOrderCard extends StatelessWidget {
  const ReturnOrderCard({super.key, required this.order});

  final ReturnOrder order;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final awaitingFee = order.status == ReturnOrderStatus.awaitingFee;
    return _InfoCard(
      title: '${l.aucReturnTitle} · ${returnStatusLabel(l, order.status)}',
      body: switch (order.status) {
        ReturnOrderStatus.awaitingFee => l.aucReturnFeeNeeded(
          formatVnd(order.shippingFee, locale),
        ),
        ReturnOrderStatus.dispatched => l.aucReturnTracking(
          order.carrier ?? '',
          order.trackingNumber ?? '',
        ),
        _ => l.aucReturnFee(formatVnd(order.shippingFee, locale)),
      },
      tone: awaitingFee ? _Tone.warning : _Tone.neutral,
      footer: awaitingFee
          ? Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => showWalletTopupSheet(
                  context,
                  initialAmount: order.shippingFee,
                ),
                child: Text(l.walletTopup),
              ),
            )
          : null,
    );
  }
}

enum _Tone { neutral, success, warning, error }

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    this.tone = _Tone.neutral,
    this.footer,
  });

  final String title;
  final String body;
  final _Tone tone;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color? bg, Color fg) = switch (tone) {
      _Tone.neutral => (null, colors.textPrimary),
      _Tone.success => (colors.successContainer, colors.onSuccessContainer),
      _Tone.warning => (colors.warningContainer, colors.onWarningContainer),
      _Tone.error => (colors.errorContainer, colors.onErrorContainer),
    };
    return AppCard(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.text.labelLarge?.copyWith(color: fg)),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              body,
              style: context.text.bodySmall?.copyWith(color: fg, height: 1.5),
            ),
          ],
          if (footer != null) ...[const SizedBox(height: 6), footer!],
        ],
      ),
    );
  }
}
