import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../sim/application/sim_providers.dart';
import '../../sim/application/sim_state.dart';
import '../../sim/presentation/sim_text.dart';
import '../../sim/presentation/sim_ticker.dart';
import '../../wallet/presentation/wallet_sheets.dart';
import '../domain/auction.dart';
import 'auction_sheets.dart';
import 'auction_text.dart';

/// Chi tiết phiên đấu giá: giá, đồng hồ, lịch sử trả giá và thao tác theo trạng thái.
class AuctionDetailScreen extends ConsumerStatefulWidget {
  const AuctionDetailScreen({super.key, required this.auctionId});

  final String auctionId;

  @override
  ConsumerState<AuctionDetailScreen> createState() =>
      _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  /// Giá người dùng đang chọn; luôn được nâng lên ít nhất bằng giá tối thiểu.
  int _chosen = 0;

  Future<void> _bid(Auction a, int amount) async {
    final l = context.l10n;
    final outcome = ref.read(simProvider.notifier).placeBid(a.id, amount);
    switch (outcome) {
      case SimOk():
        setState(() => _chosen = 0);
      case SimInsufficient(:final needed):
        await showInsufficientSheet(context, needed);
      case SimRejected(:final reason):
        AppSnackbar.show(context, switch (reason) {
          SimRejectReason.auctionEnded => l.aucErrEnded,
          SimRejectReason.bidTooLow => l.aucErrTooLow,
          _ => l.aucErrState,
        }, type: AppSnackbarType.error);
        setState(() => _chosen = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final a = ref.watch(auctionProvider(widget.auctionId));
    if (a == null) {
      return AppPage(
        title: l.aucTitle,
        scrollable: false,
        child: AppEmptyView(icon: Icons.gavel_outlined, title: l.aucNotFound),
      );
    }
    final now = ref.watch(simNowProvider);
    final locale = Localizations.localeOf(context).toString();
    final bidValue = _chosen < a.minBid ? a.minBid : _chosen;

    return SimTicker(
      child: AppPage(
        title: l.aucTitle,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen + 4,
          AppSpacing.xs,
          AppSpacing.screen + 4,
          AppSpacing.lg,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Center(
              child: AppTag(
                label: auctionStatusLabel(l, a),
                tone: auctionStatusTone(a),
              ),
            ),
          ),
        ],
        bottom: _BottomPanel(
          auction: a,
          bidValue: bidValue,
          onDec: () => setState(() {
            _chosen = (bidValue - a.step) < a.minBid
                ? a.minBid
                : bidValue - a.step;
          }),
          onInc: () => setState(() => _chosen = bidValue + a.step),
          onBid: () => _bid(a, bidValue),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(auction: a, locale: locale),
            const SizedBox(height: AppSpacing.md),
            _PriceBoard(auction: a, now: now, locale: locale),
            if (a.status == AuctionStatus.live &&
                a.extendedAt != null &&
                now.difference(a.extendedAt!) <
                    const Duration(seconds: 10)) ...[
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                color: context.colors.warningContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(
                  l.aucExtendedBanner,
                  style: context.text.labelMedium?.copyWith(
                    color: context.colors.onWarningContainer,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _Stats(auction: a, locale: locale),
            const SizedBox(height: AppSpacing.md),
            _BidHistory(auction: a, now: now, locale: locale),
            const SizedBox(height: AppSpacing.md),
            Text(
              a.description,
              style: context.text.bodyMedium?.copyWith(
                height: 1.6,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.auction, required this.locale});

  final Auction auction;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          height: 132,
          child: BookCover(
            url: null,
            hue: auction.coverHue,
            label: auction.title,
            radius: 9,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                auction.title,
                style: context.text.headlineMedium?.copyWith(
                  fontSize: 23,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                auction.author,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l.aucSellerLine(auction.seller, participantsText(l, auction)),
                style: context.text.labelSmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceBoard extends StatelessWidget {
  const _PriceBoard({
    required this.auction,
    required this.now,
    required this.locale,
  });

  final Auction auction;
  final DateTime now;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final timer = auctionTimer(l, auction, now);
    final sub = auctionTimerSub(l, auction);
    final fg = colors.background;
    final timerText = timer.value;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.textPrimary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        priceLabel(l, auction),
                        style: context.text.labelSmall?.copyWith(
                          color: fg.withValues(alpha: 0.7),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formatVnd(displayPrice(auction), locale),
                          style: context.text.headlineMedium?.copyWith(
                            color: fg,
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timer.label,
                      style: context.text.labelSmall?.copyWith(
                        color: fg.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      timerText,
                      style: TextStyle(
                        fontFamily: AppTypography.monoFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: timerText.length > 9 ? 16 : 24,
                        color: timer.urgent ? const Color(0xFFFF9B7A) : fg,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: fg.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 12),
            Text(
              leaderText(l, auction),
              style: context.text.labelMedium?.copyWith(
                color: auction.iAmLeading ? const Color(0xFF9FD8B8) : fg,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(height: 6),
              Text(
                sub,
                style: context.text.labelSmall?.copyWith(
                  color: fg.withValues(alpha: 0.75),
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.auction, required this.locale});

  final Auction auction;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (l.aucStatStart, formatVnd(auction.startingPrice, locale)),
      (l.aucStatStep, formatVnd(auction.step, locale)),
      (
        l.aucStatBuyNow,
        auction.buyNow > 0 ? formatVnd(auction.buyNow, locale) : l.aucNone,
      ),
      (
        l.aucStatFeeDeposit,
        '${formatVnd(auction.registrationFee, locale)} · ${formatVnd(auction.deposit, locale)}',
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.xs,
      crossAxisSpacing: AppSpacing.xs,
      mainAxisExtent: 68,
      children: [
        for (final (label, value) in items)
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelLarge,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BidHistory extends StatelessWidget {
  const _BidHistory({
    required this.auction,
    required this.now,
    required this.locale,
  });

  final Auction auction;
  final DateTime now;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final bids = auction.bids.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.aucBidHistory, style: context.text.titleMedium),
            Text(
              l.aucBidCount(auction.bids.length),
              style: context.text.labelSmall?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (bids.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              l.aucNoBidsYet,
              style: context.text.bodySmall?.copyWith(color: colors.textMuted),
            ),
          ),
        for (var i = 0; i < bids.length; i++)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.divider)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          bids[i].mine ? l.aucBidYou : bids[i].who,
                          style: context.text.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: bids[i].mine
                                ? colors.success
                                : (i > 0
                                      ? colors.textSecondary
                                      : colors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          agoText(l, now, bids[i].time),
                          style: context.text.labelSmall?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatVnd(bids[i].amount, locale),
                    style: context.text.bodySmall?.copyWith(
                      fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                      color: bids[i].mine ? colors.success : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Khối thao tác dính đáy, đổi theo trạng thái phiên và việc đã đăng ký chưa.
class _BottomPanel extends ConsumerWidget {
  const _BottomPanel({
    required this.auction,
    required this.bidValue,
    required this.onDec,
    required this.onInc,
    required this.onBid,
  });

  final Auction auction;
  final int bidValue;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final VoidCallback onBid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final a = auction;
    final hold = formatVnd(a.registrationHold, locale);

    Widget title(String t, {Color? color}) =>
        Text(t, style: context.text.labelLarge?.copyWith(color: color));
    Widget sub(String t) => Text(
      t,
      style: context.text.labelSmall?.copyWith(color: colors.textMuted),
    );

    final running = a.status.isRunning;
    final children = <Widget>[];

    if (a.status == AuctionStatus.registrationOpen && !a.registered) {
      children
        ..add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              sub(l.aucHoldLabel),
              Text(hold, style: context.text.labelLarge),
            ],
          ),
        )
        ..add(const SizedBox(height: 10))
        ..add(
          AppButton(
            label: l.aucRegister,
            onPressed: () => showRegisterSheet(context, a),
          ),
        );
    } else if (a.status == AuctionStatus.registrationOpen) {
      children.add(
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title(l.aucRegisteredTitle, color: colors.success),
                  sub(l.aucRegisteredSub(hold)),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () =>
                  ref.read(simProvider.notifier).unregisterFromAuction(a.id),
              child: Text(l.aucUnregister),
            ),
          ],
        ),
      );
    } else if (a.status == AuctionStatus.confirmed && a.registered) {
      children
        ..add(title(l.aucFilledTitle, color: colors.success))
        ..add(sub(l.aucFilledSub(formatVnd(a.deposit, locale))));
    } else if ((running || a.status == AuctionStatus.confirmed) &&
        !a.registered) {
      children
        ..add(title(l.aucWatchTitle))
        ..add(sub(l.aucWatchSub));
    } else if (running && a.iAmLeading) {
      children.add(
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.successContainer,
            borderRadius: AppRadius.smAll,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: colors.success),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title(l.aucLeadingTitle, color: colors.success),
                      Text(
                        l.aucLeadingSub(formatVnd(a.current, locale)),
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onSuccessContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (running) {
      children
        ..add(
          Row(
            children: [
              _StepButton(
                icon: Icons.remove,
                onTap: onDec,
                enabled: bidValue > a.minBid,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      formatVnd(bidValue, locale),
                      style: context.text.headlineMedium?.copyWith(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    sub(l.aucMinimum(formatVnd(a.minBid, locale))),
                  ],
                ),
              ),
              _StepButton(icon: Icons.add, onTap: onInc, enabled: true),
            ],
          ),
        )
        ..add(const SizedBox(height: 10))
        ..add(
          Row(
            children: [
              Expanded(
                flex: 4,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.auction,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: onBid,
                  child: Text(l.aucBid),
                ),
              ),
              if (a.buyNowAvailable) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.textPrimary),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () => showBuyNowSheet(context, a),
                    child: Text(
                      l.aucBuyNowButton(formatVnd(a.buyNow, locale)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
    } else if (a.status.isEnded) {
      final (String t, Color c, String body) = a.won
          ? (
              l.aucEndedWon,
              colors.success,
              l.aucEndedWonText(formatVnd(a.deposit, locale)),
            )
          : a.registered
          ? (
              l.aucEndedLost,
              colors.textPrimary,
              l.aucEndedLostText(formatVnd(a.deposit, locale)),
            )
          : (
              l.aucEndedGeneric,
              colors.textPrimary,
              l.aucEndedOtherText(formatVnd(a.current, locale)),
            );
      children
        ..add(title(t, color: c))
        ..add(sub(body))
        ..addAll([
          if (a.won)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AppButton(
                label: l.orderPlacedView,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push('/me/orders'),
              ),
            ),
        ]);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(48, 48),
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
        ),
        child: Icon(icon),
      ),
    );
  }
}
