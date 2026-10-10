import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
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
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            height: 100,
            child: BookCover(url: a.thumbnailUrl, label: a.title, radius: 7),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 5),
                Text(
                  a.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    fontFamily: AppTypography.serifFamily,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${a.author} · ${l.aucParticipants(a.registeredCount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            priceLabel(l, a.status, a.currentPrice != null),
                            style: context.text.labelSmall?.copyWith(
                              color: colors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            formatVnd(a.displayPrice, locale),
                            style: context.text.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
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
                              color: colors.textMuted,
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
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: a.status.isRunning
                                    ? colors.error
                                    : colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
