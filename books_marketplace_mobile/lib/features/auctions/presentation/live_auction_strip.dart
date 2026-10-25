import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/countdown_text.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../application/auction_providers.dart';
import 'auction_text.dart';

/// Dải "Đang đấu giá" ở đầu Khám phá: các phiên đang diễn ra, vuốt ngang.
/// Chỉ là ảnh chụp (không realtime); kéo làm mới trang chủ để cập nhật.
class LiveAuctionStrip extends ConsumerWidget {
  const LiveAuctionStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveAuctionStripProvider).value ?? const [];
    if (live.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
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
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              itemCount: live.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final a = live[i];
                final deadline = a.deadline;
                return SizedBox(
                  width: 248,
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    onTap: () => context.push('/auctions/${a.id}'),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          height: 76,
                          child: BookCover(
                            url: a.thumbnailUrl,
                            label: a.title,
                            radius: AppRadius.xs,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                a.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.titleMedium?.copyWith(
                                  fontFamily: AppTypography.serifFamily,
                                  fontVariations: AppTypography.serifSemiBold,
                                  fontSize: 16,
                                  height: 19 / 16,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                priceLabel(l, a.status, a.currentPrice != null),
                                style: context.text.labelSmall?.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                              Text(
                                formatVnd(a.displayPrice, locale),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (deadline != null) ...[
                                const SizedBox(height: AppSpacing.xxs),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: colors.auctionContainer,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          size: 14,
                                          color: colors.onAuctionContainer,
                                        ),
                                        const SizedBox(width: AppSpacing.xxs),
                                        Countdown(
                                          target: deadline,
                                          daysHours: l.remainingDaysHours,
                                          builder: (context, left, _) => Text(
                                            left,
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTypography.monoFamily,
                                              fontVariations:
                                                  AppTypography.monoSemiBold,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: colors.onAuctionContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }
}
