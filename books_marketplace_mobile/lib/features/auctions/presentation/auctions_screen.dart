import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_paged_list.dart';
import '../../../core/widgets/app_segmented.dart';
import '../../../core/widgets/app_state_views.dart';
import '../application/auction_providers.dart';
import '../domain/auction.dart';
import 'auction_card.dart';

/// Tab Đấu giá: bốn nhóm trạng thái và danh sách phiên công khai.
class AuctionsScreen extends ConsumerStatefulWidget {
  const AuctionsScreen({super.key});

  @override
  ConsumerState<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends ConsumerState<AuctionsScreen> {
  AuctionTab _tab = AuctionTab.live;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final provider = auctionListProvider(_tab);
    final labels = {
      AuctionTab.live: l.aucTabLive,
      AuctionTab.register: l.aucTabRegister,
      AuctionTab.upcoming: l.aucTabUpcoming,
      AuctionTab.ended: l.aucTabEnded,
    };

    return Scaffold(
      body: SafeArea(
        child: AppPagedList<AuctionSummary>(
          value: ref.watch(provider),
          onLoadMore: ref.read(provider.notifier).loadMore,
          onRefresh: ref.read(provider.notifier).reload,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen + 4,
            AppSpacing.xs,
            AppSpacing.screen + 4,
            AppSpacing.lg,
          ),
          separator: const SizedBox(height: AppSpacing.md),
          header: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.aucTitle,
                        style: context.text.headlineMedium?.copyWith(
                          fontSize: 30,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/auctions/mine'),
                      icon: const Icon(Icons.gavel_outlined, size: 18),
                      label: Text(l.myAuctionsShort),
                    ),
                  ],
                ),
                Text(
                  l.aucSubtitle,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppSegmented(
                  labels: [for (final t in AuctionTab.values) labels[t]!],
                  selected: AuctionTab.values.indexOf(_tab),
                  onSelected: (i) =>
                      setState(() => _tab = AuctionTab.values[i]),
                ),
              ],
            ),
          ),
          empty: AppEmptyView(icon: Icons.gavel_outlined, title: l.aucEmpty),
          itemBuilder: (context, a) => AuctionCard(
            auction: a,
            onTap: () => context.push('/auctions/${a.id}'),
          ),
        ),
      ),
    );
  }
}
