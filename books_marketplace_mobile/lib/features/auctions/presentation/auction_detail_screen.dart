import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/util/idempotency.dart';
import '../../../core/util/server_clock.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../wallet/application/wallet_providers.dart';
import '../application/auction_live_controller.dart';
import '../application/auction_providers.dart';
import '../domain/auction.dart';
import '../domain/auction_event.dart';
import 'auction_errors.dart';
import 'auction_sheets.dart';
import 'auction_text.dart';
import 'seller_panels.dart';
import '../../listings/presentation/widgets/volume_list.dart';

/// Chi tiết phiên: giá, đồng hồ theo giờ server, lịch sử trả giá cập nhật
/// realtime và thao tác theo trạng thái (đăng ký, trả giá, mua ngay, người bán).
class AuctionDetailScreen extends ConsumerStatefulWidget {
  const AuctionDetailScreen({super.key, required this.auctionId});

  final String auctionId;

  @override
  ConsumerState<AuctionDetailScreen> createState() =>
      _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  /// Giá người dùng đang chọn; luôn được nâng lên ít nhất bằng mức tối thiểu.
  int _chosen = 0;
  bool _busy = false;

  /// Bị `RATE_LIMITED`: khóa nút tới mốc này.
  DateTime? _cooldownUntil;
  Timer? _cooldownTimer;

  final _bidAction = IdempotentAction();
  int? _bidKeyAmount;
  final _buyNowAction = IdempotentAction();
  final _registerAction = IdempotentAction();

  /// Lần dựng gần nhất người dùng có đang dẫn đầu không (để báo bị vượt giá).
  bool _wasLeading = false;
  StreamSubscription<AuctionLiveEvent>? _eventSub;

  AuctionLiveController get _controller =>
      ref.read(auctionLiveProvider(widget.auctionId).notifier);

  @override
  void initState() {
    super.initState();
    _eventSub = _controller.liveEvents.listen(_onLiveEvent);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _onLiveEvent(AuctionLiveEvent e) {
    if (!mounted) return;
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final mine = e.amount != null && e.amount == _controller.myLastAmount;
    if (e.isNewBid && e.amount != null) {
      ref
          .read(auctionBidsProvider(widget.auctionId).notifier)
          .prepend(
            Bid(
              id: 'live-${e.sequence}',
              amount: e.amount!,
              kind: e.name == AuctionEventName.buyNowStarted
                  ? BidKind.buyNow
                  : BidKind.bid,
              bidder: e.bidder ?? '',
              isMine: mine,
              placedAt: e.serverTime ?? ServerClock.now(),
            ),
          );
    }
    if (e.isNewBid && !mine && _wasLeading) {
      AppSnackbar.show(
        context,
        l.aucOutbidToast(formatVnd(e.amount ?? 0, locale)),
        type: AppSnackbarType.error,
      );
      ref.invalidate(walletProvider);
    } else if (e.name == AuctionEventName.extended) {
      AppSnackbar.show(context, l.aucExtendedBanner);
    } else if (e.name == AuctionEventName.buyNowStarted && !mine) {
      AppSnackbar.show(context, l.toastBuyNowStarted);
    } else if (e.name == AuctionEventName.ended) {
      AppSnackbar.show(context, l.aucEndedToast);
      ref.invalidate(walletProvider);
      refreshAuctionLists(ref);
    }
  }

  bool get _coolingDown {
    final until = _cooldownUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  void _coolDown(Duration d) {
    _cooldownTimer?.cancel();
    setState(() => _cooldownUntil = DateTime.now().add(d));
    _cooldownTimer = Timer(d, () {
      if (mounted) setState(() => _cooldownUntil = null);
    });
  }

  /// Chạy một thao tác tạo tiền giữ: khóa nút, xử lý lỗi theo mã, làm mới ví
  /// và danh sách khi xong.
  Future<bool> _run(
    IdempotentAction action,
    Future<void> Function(String key) body,
  ) async {
    if (_busy || _coolingDown) return false;
    setState(() => _busy = true);
    try {
      await body(action.key);
      action.settle();
      ref.invalidate(walletProvider);
      refreshAuctionLists(ref);
      return true;
    } catch (e) {
      action.settle(e);
      if (!mounted) return false;
      await handleAuctionError(
        context,
        e,
        onReload: _controller.refresh,
        onMinAmount: (m) => setState(() => _chosen = m),
        onRateLimited: _coolDown,
      );
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _bid(Auction a, int amount) async {
    if (_busy || _coolingDown) return;
    if (!await confirmBid(context, a, amount) || !mounted) return;
    if (_bidKeyAmount != amount) {
      _bidAction.reset();
      _bidKeyAmount = amount;
    }
    final ok = await _run(
      _bidAction,
      (key) => _controller.placeBid(amount, idempotencyKey: key),
    );
    if (ok && mounted) {
      setState(() => _chosen = 0);
      final locale = Localizations.localeOf(context).toString();
      AppSnackbar.success(
        context,
        context.l10n.toastLeading(formatVnd(amount, locale)),
      );
    }
  }

  Future<void> _buyNow(Auction a) async {
    if (_busy || _coolingDown) return;
    if (!await confirmBuyNow(context, a) || !mounted) return;
    final ok = await _run(
      _buyNowAction,
      (key) => _controller.buyNow(idempotencyKey: key),
    );
    if (ok && mounted) {
      AppSnackbar.success(context, context.l10n.toastBuyNowStarted);
    }
  }

  Future<void> _register(Auction a) async {
    if (_busy) return;
    if (!await confirmRegister(context, a) || !mounted) return;
    final ok = await _run(
      _registerAction,
      (key) => _controller.register(idempotencyKey: key),
    );
    if (ok && mounted) {
      final locale = Localizations.localeOf(context).toString();
      AppSnackbar.success(
        context,
        context.l10n.toastRegistered(formatVnd(a.registrationHold, locale)),
      );
    }
  }

  Future<void> _unregister(Auction a) async {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final ok = await showConfirmDialog(
      context,
      title: l.aucUnregister,
      message: l.aucUnregisterConfirm(formatVnd(a.registrationHold, locale)),
      confirmLabel: l.aucUnregister,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final done = await _run(
      IdempotentAction(),
      (_) => _controller.unregister(),
    );
    if (done && mounted) {
      AppSnackbar.success(
        context,
        l.toastUnregistered(formatVnd(a.registrationHold, locale)),
      );
    }
  }

  Future<void> _cancel(Auction a) async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.aucCancel,
      message: a.status == AuctionStatus.pendingReview
          ? l.aucCancelConfirmInWarehouse
          : l.aucCancelConfirm,
      confirmLabel: l.aucCancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _run(IdempotentAction(), (_) => _controller.cancel());
  }

  Future<void> _fallback(Auction a) async {
    final pick = await pickFallback(context, a);
    if (pick == null || !mounted) return;
    final ok = await _run(
      IdempotentAction(),
      (_) => _controller.fallback(
        pick.choice,
        startAt: pick.startAt,
        price: pick.price,
      ),
    );
    if (ok && mounted) AppSnackbar.success(context, context.l10n.fbDone);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final value = ref.watch(auctionLiveProvider(widget.auctionId));

    return value.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => AppPage(
        title: l.aucTitle,
        scrollable: false,
        child: const AppLoadingView(),
      ),
      error: (e, _) => AppPage(
        title: l.aucTitle,
        scrollable: false,
        child: e is ApiError && e.code == ApiErrorCode.auctionNotFound
            ? AppEmptyView(icon: Icons.gavel_outlined, title: l.aucNotFound)
            : AppErrorView(
                error: e,
                onRetry: () =>
                    ref.invalidate(auctionLiveProvider(widget.auctionId)),
              ),
      ),
      data: _content,
    );
  }

  Widget _content(Auction a) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    _wasLeading = a.isLeading;
    final min = a.minNextBid;
    final bidValue = _chosen < min ? min : _chosen;
    final showHistory = a.live != null || a.status.isRunning;

    return AppPage(
      title: l.aucTitle,
      onRefresh: _controller.refresh,
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
              label: auctionStatusLabel(l, a.status),
              tone: auctionStatusTone(a.status),
            ),
          ),
        ),
      ],
      bottom: a.isSeller
          ? null
          : _BottomPanel(
              auction: a,
              bidValue: bidValue,
              busy: _busy || _coolingDown,
              onDec: () => setState(() {
                _chosen = (bidValue - a.bidStep) < min
                    ? min
                    : bidValue - a.bidStep;
              }),
              onInc: (steps) =>
                  setState(() => _chosen = bidValue + a.bidStep * steps),
              onBid: () => _bid(a, bidValue),
              onBuyNow: () => _buyNow(a),
              onRegister: () => _register(a),
              onUnregister: () => _unregister(a),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(auction: a),
          if (a.isSet) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: SetBadge(volumeCount: a.volumeCount),
            ),
            VolumeList(
              volumes: [
                for (final v in a.volumes)
                  VolumeView(
                    volumeNo: v.volumeNo,
                    title: v.title,
                    thumbnailUrls: [
                      for (final p in v.photos) p.thumbnailUrl ?? p.url,
                    ],
                    urls: [for (final p in v.photos) p.url],
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _PriceBoard(auction: a, onExpired: _controller.refresh),
          if (a.status.isRunning) const _RealtimeChip(),
          if (a.canBid && a.hasBids) ...[
            const SizedBox(height: AppSpacing.sm),
            AppBanner(
              message: l.myAucOutbid,
              tone: AppTagTone.auction,
              icon: Icons.error_outline,
              bold: true,
              liveRegion: true,
            ),
          ],
          if (a.isSeller)
            SellerPanel(
              auction: a,
              busy: _busy,
              onCancel: () => _cancel(a),
              onFallback: () => _fallback(a),
            ),
          const SizedBox(height: AppSpacing.md),
          _Stats(auction: a, locale: locale),
          if (showHistory) ...[
            const SizedBox(height: AppSpacing.md),
            _BidHistory(auctionId: a.id, bidCount: a.live?.bidCount ?? 0),
          ],
          if (a.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              a.description,
              style: context.text.bodyMedium?.copyWith(
                height: 1.6,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final photo = auction.photos.isEmpty ? null : auction.photos.first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          height: 132,
          child: BookCover(
            url: photo?.thumbnailUrl ?? photo?.url,
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
              Row(
                children: [
                  Flexible(
                    child: Text(
                      l.aucSellerLine(
                        auction.sellerName,
                        l.aucParticipants(auction.registeredCount),
                      ),
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                  if (auction.sellerVerified) ...[
                    const SizedBox(width: 4),
                    const VerifiedBadge(size: 14),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Đếm ngược theo giờ server. Hết giờ mà chưa có sự kiện kết thúc thì hiện
/// "Đang chốt…" và tải lại một lần sau 3 giây (lưới an toàn).
class _DeadlineText extends StatefulWidget {
  const _DeadlineText({
    required this.target,
    required this.builder,
    this.onExpired,
  });

  final DateTime target;
  final Widget Function(BuildContext context, Duration left) builder;
  final VoidCallback? onExpired;

  @override
  State<_DeadlineText> createState() => _DeadlineTextState();
}

class _DeadlineTextState extends State<_DeadlineText> {
  Timer? _tick;
  Timer? _expiry;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      _checkExpired();
    });
  }

  @override
  void didUpdateWidget(_DeadlineText old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) {
      _expiry?.cancel();
      _expiry = null;
    }
  }

  void _checkExpired() {
    if (_expiry != null || widget.onExpired == null) return;
    if (widget.target.difference(ServerClock.now()).isNegative) {
      _expiry = Timer(
        const Duration(seconds: 3),
        () => widget.onExpired?.call(),
      );
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _expiry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.target.difference(ServerClock.now());
    return widget.builder(context, left.isNegative ? Duration.zero : left);
  }
}

class _PriceBoard extends StatelessWidget {
  const _PriceBoard({required this.auction, required this.onExpired});

  final Auction auction;
  final VoidCallback onExpired;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final a = auction;
    final sub = auctionTimerSub(l, a);
    final fg = colors.onInverse;
    final muted = colors.inverseMuted;
    final deadline = a.deadline;
    final endedAt = a.live?.endedAt;

    Widget timerValue(String text, {bool urgent = false}) => Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.monoFamily,
        fontVariations: AppTypography.monoSemiBold,
        fontWeight: FontWeight.w600,
        fontSize: text.length > 9 ? 16 : 24,
        color: urgent ? colors.inverseUrgent : fg,
      ),
    );

    final Widget? timer = deadline != null && !a.status.isEnded
        ? _DeadlineText(
            target: deadline,
            onExpired: a.status.isRunning ? onExpired : null,
            builder: (context, left) {
              if (left == Duration.zero && a.status.isRunning) {
                return timerValue(l.aucClosing, urgent: true);
              }
              return timerValue(
                remainingText(l, left),
                urgent: a.status.isRunning && left < const Duration(minutes: 2),
              );
            },
          )
        : endedAt != null
        ? timerValue(formatShortDateTime(endedAt))
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceInverse,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                        priceLabel(l, a.status, a.hasBids),
                        style: context.text.labelSmall?.copyWith(color: muted),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey(a.displayPrice),
                          tween: Tween(begin: 1.12, end: 1),
                          duration: const Duration(milliseconds: 350),
                          builder: (context, scale, child) => Transform.scale(
                            scale: scale,
                            alignment: Alignment.centerLeft,
                            child: child,
                          ),
                          child: Text(
                            formatVnd(a.displayPrice, locale),
                            style: context.text.headlineMedium?.copyWith(
                              color: fg,
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (timer != null) ...[
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timerLabel(l, a.status),
                        style: context.text.labelSmall?.copyWith(color: muted),
                      ),
                      timer,
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: muted.withValues(alpha: 0.35), height: 1),
            const SizedBox(height: 12),
            Text(
              leaderText(l, a),
              style: context.text.labelMedium?.copyWith(
                color: a.isLeading ? colors.inverseLeading : fg,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(height: 6),
              Text(
                sub,
                style: context.text.labelSmall?.copyWith(
                  color: muted,
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

/// Báo mất kết nối realtime khi phiên đang diễn ra.
class _RealtimeChip extends ConsumerWidget {
  const _RealtimeChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected = ref.watch(auctionHubProvider).connected;
    return ValueListenableBuilder<bool>(
      valueListenable: connected,
      builder: (context, ok, _) => ok
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: AppCard(
                color: context.colors.warningContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 18,
                      color: context.colors.onWarningContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.aucRealtimeOffline,
                        style: context.text.labelMedium?.copyWith(
                          color: context.colors.onWarningContainer,
                        ),
                      ),
                    ),
                  ],
                ),
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
    final buyNow = auction.buyNowPrice;
    final items = [
      (l.aucStatStart, formatVnd(auction.startPrice, locale)),
      (l.aucStatStep, formatVnd(auction.bidStep, locale)),
      (
        l.aucStatBuyNow,
        buyNow != null && buyNow > 0 ? formatVnd(buyNow, locale) : l.aucNone,
      ),
      (
        l.aucStatFeeDeposit,
        '${formatVnd(auction.participationFee, locale)} · ${formatVnd(auction.deposit, locale)}',
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

class _BidHistory extends ConsumerWidget {
  const _BidHistory({required this.auctionId, required this.bidCount});

  final String auctionId;
  final int bidCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final provider = auctionBidsProvider(auctionId);
    final state = ref.watch(provider).value;
    final bids = state?.items ?? const <Bid>[];
    final now = ServerClock.now();

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
              l.aucBidCount(bidCount),
              style: context.text.labelSmall?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (state != null && bids.isEmpty)
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
                        Flexible(
                          child: Text(
                            bids[i].isMine ? l.aucBidYou : bids[i].bidder,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: bids[i].isMine
                                  ? colors.success
                                  : (i > 0
                                        ? colors.textSecondary
                                        : colors.textPrimary),
                            ),
                          ),
                        ),
                        if (bids[i].kind == BidKind.buyNow) ...[
                          const SizedBox(width: 6),
                          AppTag(
                            label: l.aucBuyNowTag,
                            tone: AppTagTone.auction,
                          ),
                        ],
                        const SizedBox(width: 10),
                        if (bids[i].placedAt != null)
                          Text(
                            agoText(l, now, bids[i].placedAt!),
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
                      color: bids[i].isMine ? colors.success : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (state != null && state.hasMore)
          Center(
            child: TextButton(
              onPressed: state.loadingMore
                  ? null
                  : ref.read(provider.notifier).loadMore,
              child: Text(l.loadMore),
            ),
          ),
      ],
    );
  }
}

/// Khối thao tác dính đáy, đổi theo trạng thái phiên và đăng ký của người xem.
class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.auction,
    required this.bidValue,
    required this.busy,
    required this.onDec,
    required this.onInc,
    required this.onBid,
    required this.onBuyNow,
    required this.onRegister,
    required this.onUnregister,
  });

  final Auction auction;
  final int bidValue;
  final bool busy;
  final VoidCallback onDec;
  final ValueChanged<int> onInc;
  final VoidCallback onBid;
  final VoidCallback onBuyNow;
  final VoidCallback onRegister;
  final VoidCallback onUnregister;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final a = auction;
    final hold = formatVnd(a.registrationHold, locale);
    final reg = a.myRegistration;

    Widget title(String t, {Color? color}) =>
        Text(t, style: context.text.labelLarge?.copyWith(color: color));
    Widget sub(String t) => Text(
      t,
      style: context.text.labelSmall?.copyWith(color: colors.textMuted),
    );

    final buyNowButton = a.canBuyNow
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.textPrimary),
              minimumSize: const Size.fromHeight(AppSizes.ctaHeight),
            ),
            onPressed: busy ? null : onBuyNow,
            child: Text(
              l.aucBuyNowButton(formatVnd(a.buyNowPrice ?? 0, locale)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : null;

    final children = <Widget>[];
    switch (a.status) {
      case AuctionStatus.registrationOpen:
        if (reg != null && reg.status.isHolding) {
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
                  onPressed: busy ? null : onUnregister,
                  child: Text(l.aucUnregister),
                ),
              ],
            ),
          );
        } else if (a.canRegister) {
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
                loading: busy,
                onPressed: onRegister,
              ),
            );
        } else {
          children.add(sub(l.aucRegistrationUnavailable));
        }
      case AuctionStatus.confirmed:
        if (a.isConfirmedBidder) {
          children
            ..add(title(l.aucFilledTitle, color: colors.success))
            ..add(sub(l.aucFilledSub(formatVnd(a.deposit, locale))));
        } else {
          children
            ..add(title(l.aucWatchTitle))
            ..add(sub(l.aucWatchSub));
        }
      case AuctionStatus.live || AuctionStatus.buyNowCountdown:
        if (!a.isConfirmedBidder) {
          children
            ..add(title(l.aucWatchTitle))
            ..add(sub(l.aucWatchSub));
        } else if (a.isLeading) {
          children.add(
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.successContainer,
                borderRadius: AppRadius.smAll,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
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
                            l.aucLeadingSub(
                              formatVnd(a.currentPrice ?? 0, locale),
                            ),
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
          if (buyNowButton != null) {
            children
              ..add(const SizedBox(height: 10))
              ..add(buyNowButton);
          }
        } else {
          children
            ..add(
              Row(
                children: [
                  _StepButton(
                    icon: Icons.remove,
                    onTap: onDec,
                    enabled: bidValue > a.minNextBid,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            formatVnd(bidValue, locale),
                            style: context.text.headlineMedium?.copyWith(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        sub(l.aucMinimum(formatVnd(a.minNextBid, locale))),
                      ],
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add,
                    onTap: () => onInc(1),
                    enabled: true,
                  ),
                ],
              ),
            )
            ..add(const SizedBox(height: 6))
            ..add(
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                children: [
                  for (final n in const [1, 2, 5])
                    ActionChip(
                      label: Text('+${formatVnd(a.bidStep * n, locale)}'),
                      onPressed: () => onInc(n),
                    ),
                ],
              ),
            )
            ..add(const SizedBox(height: 6))
            ..add(
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.auction,
                        foregroundColor: colors.onAuction,
                        minimumSize: const Size.fromHeight(AppSizes.ctaHeight),
                      ),
                      onPressed: busy ? null : onBid,
                      child: busy
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.onAuction,
                              ),
                            )
                          : Text(l.aucBid),
                    ),
                  ),
                  if (buyNowButton != null) ...[
                    const SizedBox(width: 10),
                    Expanded(flex: 5, child: buyNowButton),
                  ],
                ],
              ),
            );
        }
      case AuctionStatus.endedSold || AuctionStatus.endedNoBid:
        final live = a.live;
        final orderId = live?.auctionOrderId;
        final price = formatVnd(live?.finalPrice ?? a.displayPrice, locale);
        if (live?.isWinner ?? false) {
          children
            ..add(title(l.aucEndedWon, color: colors.success))
            ..add(sub(l.aucEndedWonText(formatVnd(a.deposit, locale))));
        } else if (reg != null) {
          children
            ..add(title(l.aucEndedLost))
            ..add(sub(l.aucEndedLostText(formatVnd(a.deposit, locale))));
        } else if (a.status == AuctionStatus.endedNoBid) {
          children.add(title(l.aucStatusNoBid));
        } else {
          children
            ..add(title(l.aucEndedGeneric))
            ..add(sub(l.aucEndedOtherText(price)));
        }
        if (orderId != null) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AppButton(
                label: l.aucViewOrder,
                onPressed: () => context.push('/me/auction-orders/$orderId'),
              ),
            ),
          );
        }
      default:
        return const SizedBox.shrink();
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
