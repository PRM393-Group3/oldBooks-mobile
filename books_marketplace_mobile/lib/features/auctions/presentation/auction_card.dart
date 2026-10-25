import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/util/server_clock.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/countdown_text.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../domain/auction.dart';
import 'auction_text.dart';

/// Thẻ phiên trong danh sách (tab Đấu giá, Phiên của tôi).
class AuctionCard extends StatelessWidget {
  const AuctionCard({super.key, required this.auction, required this.onTap});

  final AuctionSummary auction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final a = auction;
    final deadline = a.deadline;
    final reg = a.myRegistration;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                height: 88,
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
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppTag(
                            label: auctionStatusLabel(l, a.status),
                            tone: auctionStatusTone(a.status),
                          ),
                        ),
                        const Spacer(),
                        if (reg != null && reg.isHolding)
                          Text(
                            registrationLabel(l, reg),
                            maxLines: 1,
                            style: context.text.labelSmall?.copyWith(
                              color: colors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      a.title,
                      maxLines: 2,
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
                      '${a.author} · ${l.aucParticipants(a.registeredCount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Bảng giá thu nhỏ: khối tương phản cao gom ánh mắt vào giá và giờ.
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceInverse,
              borderRadius: AppRadius.smAll,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          priceLabel(l, a.status, a.currentPrice != null),
                          style: context.text.labelSmall?.copyWith(
                            color: colors.inverseMuted,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          formatVnd(a.displayPrice, locale),
                          style: context.text.titleMedium?.copyWith(
                            color: colors.onInverse,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (deadline != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timerLabel(l, a.status),
                          style: context.text.labelSmall?.copyWith(
                            color: colors.inverseMuted,
                            fontSize: 11,
                          ),
                        ),
                        Countdown(
                          target: deadline,
                          daysHours: l.remainingDaysHours,
                          builder: (context, left, _) => Text(
                            left,
                            style: TextStyle(
                              fontFamily: AppTypography.monoFamily,
                              fontVariations: AppTypography.monoSemiBold,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: a.status.isRunning && _isUrgent(deadline)
                                  ? colors.inverseUrgent
                                  : colors.onInverse,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Còn dưới 2 phút: đổi sang màu khẩn trên nền tối.
  static bool _isUrgent(DateTime deadline) =>
      deadline.toUtc().difference(ServerClock.now()) <
      const Duration(minutes: 2);
}
