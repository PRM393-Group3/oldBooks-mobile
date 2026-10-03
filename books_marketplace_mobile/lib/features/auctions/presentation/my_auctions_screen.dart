import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../sim/application/sim_providers.dart';
import '../domain/auction.dart';
import 'auction_text.dart';

/// Vai trò của người dùng trong một phiên đã đăng ký, kèm màu nhấn.
({String text, Color color}) myAuctionRole(
  AppLocalizations l,
  String locale,
  Auction a,
  Color good,
  Color bad,
  Color neutral,
) {
  final price = formatVnd(a.current, locale);
  if (a.won) return (text: l.myAucWon(price), color: good);
  if (a.iAmLeading) return (text: l.myAucLeading(price), color: good);
  if (a.status.isEnded) return (text: l.myAucLost, color: neutral);
  if (a.status.isRunning) return (text: l.myAucOutbid, color: bad);
  return (text: l.myAucRegistered, color: neutral);
}

/// Các phiên người dùng đã đăng ký.
class MyAuctionsScreen extends ConsumerWidget {
  const MyAuctionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final mine = [
      for (final a in ref.watch(auctionsProvider))
        if (a.registered) a,
    ];

    return AppPage(
      title: l.myAuctionsTitle,
      scrollable: false,
      child: mine.isEmpty
          ? AppEmptyView(icon: Icons.gavel_outlined, title: l.myAuctionsEmpty)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen + 4,
                AppSpacing.md,
                AppSpacing.screen + 4,
                AppSpacing.xl,
              ),
              itemCount: mine.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = mine[i];
                final role = myAuctionRole(
                  l,
                  locale,
                  a,
                  colors.success,
                  colors.error,
                  colors.textSecondary,
                );
                return AppCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () => context.push('/auctions/${a.id}'),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 72,
                        child: BookCover(
                          url: null,
                          hue: a.coverHue,
                          label: a.title,
                          radius: 6,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
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
                              style: context.text.titleMedium?.copyWith(
                                fontFamily: AppTypography.serifFamily,
                                fontSize: 15.5,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role.text,
                              style: context.text.labelSmall?.copyWith(
                                color: role.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
