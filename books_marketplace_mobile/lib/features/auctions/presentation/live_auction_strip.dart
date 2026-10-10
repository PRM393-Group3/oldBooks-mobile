import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../sim/application/sim_providers.dart';
import '../../sim/presentation/sim_ticker.dart';
import 'auction_text.dart';

/// Dải "Đang đấu giá" ở đầu Khám phá: các phiên đang diễn ra, vuốt ngang.
class LiveAuctionStrip extends ConsumerWidget {
  const LiveAuctionStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = [
      for (final a in ref.watch(auctionsProvider))
        if (a.status.isRunning) a,
    ];
    if (live.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final now = ref.watch(simNowProvider);

    return SimTicker(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: colors.auction),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.homeLiveAuctions,
                      style: context.text.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/auctions'),
                    child: Text(l.homeSeeAll),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                ),
                itemCount: live.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final a = live[i];
                  final timer = auctionTimer(l, a, now);
                  return SizedBox(
                    width: 264,
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      onTap: () => context.push('/auctions/${a.id}'),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 62,
                            height: 86,
                            child: BookCover(
                              url: null,
                              hue: a.coverHue,
                              label: a.title,
                              radius: 6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppTag(
                                  label: auctionStatusLabel(l, a),
                                  tone: auctionStatusTone(a),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  a.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleMedium?.copyWith(
                                    fontFamily: AppTypography.serifFamily,
                                    fontSize: 15,
                                    height: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        formatVnd(displayPrice(a), locale),
                                        overflow: TextOverflow.ellipsis,
                                        style: context.text.labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      timer.value,
                                      style: TextStyle(
                                        fontFamily: AppTypography.monoFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: timer.urgent
                                            ? colors.error
                                            : colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
