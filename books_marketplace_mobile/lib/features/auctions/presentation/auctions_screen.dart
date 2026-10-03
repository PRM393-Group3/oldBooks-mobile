import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../sim/application/sim_providers.dart';
import '../../sim/presentation/sim_ticker.dart';
import '../domain/auction.dart';
import 'auction_card.dart';

enum AuctionFilter {
  live,
  register,
  upcoming,
  ended;

  bool matches(Auction a) => switch (this) {
    live => a.status.isRunning,
    register => a.status == AuctionStatus.registrationOpen,
    upcoming => a.status == AuctionStatus.confirmed,
    ended => a.status.isEnded,
  };
}

/// Tab Đấu giá: bộ lọc bốn trạng thái và danh sách phiên.
class AuctionsScreen extends ConsumerStatefulWidget {
  const AuctionsScreen({super.key});

  @override
  ConsumerState<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends ConsumerState<AuctionsScreen> {
  AuctionFilter _filter = AuctionFilter.live;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final now = ref.watch(simNowProvider);
    final list = [
      for (final a in ref.watch(auctionsProvider))
        if (_filter.matches(a)) a,
    ];
    final labels = {
      AuctionFilter.live: l.aucTabLive,
      AuctionFilter.register: l.aucTabRegister,
      AuctionFilter.upcoming: l.aucTabUpcoming,
      AuctionFilter.ended: l.aucTabEnded,
    };

    return SimTicker(
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen + 4,
              AppSpacing.xs,
              AppSpacing.screen + 4,
              AppSpacing.lg,
            ),
            children: [
              Text(
                l.aucTitle,
                style: context.text.headlineMedium?.copyWith(
                  fontSize: 30,
                  letterSpacing: -0.6,
                ),
              ),
              Text(
                l.aucSubtitle,
                style: context.text.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: AppRadius.smAll,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      for (final f in AuctionFilter.values)
                        Expanded(
                          child: _Segment(
                            label: labels[f]!,
                            selected: f == _filter,
                            onTap: () => setState(() => _filter = f),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final a in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AuctionCard(
                    auction: a,
                    now: now,
                    onTap: () => context.push('/auctions/${a.id}'),
                  ),
                ),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Text(
                    l.aucEmpty,
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.textMuted,
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

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        elevation: selected ? 1 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
