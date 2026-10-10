import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../domain/auction.dart';
import 'auction_text.dart';

/// Thẻ phiên trong danh sách tab Đấu giá.
class AuctionCard extends StatelessWidget {
  const AuctionCard({
    super.key,
    required this.auction,
    required this.now,
    required this.onTap,
  });

  final Auction auction;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final timer = auctionTimer(l, auction, now);

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            height: 100,
            child: BookCover(
              url: null,
              hue: auction.coverHue,
              label: auction.title,
              radius: 7,
            ),
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
                        label: auctionStatusLabel(l, auction),
                        tone: auctionStatusTone(auction),
                      ),
                    ),
                    const Spacer(),
                    if (auction.registered)
                      Text(
                        l.aucRegisteredTag,
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
                  auction.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    fontFamily: AppTypography.serifFamily,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${auction.author} · ${participantsText(l, auction)}',
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
                            priceLabel(l, auction),
                            style: context.text.labelSmall?.copyWith(
                              color: colors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            formatVnd(displayPrice(auction), locale),
                            style: context.text.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timer.label,
                          style: context.text.labelSmall?.copyWith(
                            color: colors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          timer.value,
                          style: TextStyle(
                            fontFamily: AppTypography.monoFamily,
                            fontSize: 13,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
