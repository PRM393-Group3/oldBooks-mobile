import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../sim/application/sim_providers.dart';
import '../application/my_listings_provider.dart';
import 'sell_text.dart';

/// Tin đăng của tôi: trạng thái duyệt, cần sửa, chờ gửi kho, đã bán.
class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final items = ref.watch(myListingsProvider);
    final now = ref.watch(simNowProvider);

    return AppPage(
      title: l.meMyListings,
      scrollable: false,
      child: items.isEmpty
          ? AppEmptyView(
              icon: Icons.inventory_2_outlined,
              title: l.myListingsEmpty,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen + 4,
                AppSpacing.md,
                AppSpacing.screen + 4,
                AppSpacing.xl,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final m = items[i];
                return AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 72,
                        child: m.photoBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.memory(
                                  Uint8List.fromList(m.photoBytes!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : BookCover(url: null, label: m.title, radius: 6),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    myListingKind(l, locale, m),
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.labelSmall?.copyWith(
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                AppTag(
                                  label: myListingStatusLabel(l, m.status),
                                  tone: myListingStatusTone(m.status),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m.title,
                              style: context.text.titleMedium?.copyWith(
                                fontFamily: AppTypography.serifFamily,
                                fontSize: 15.5,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              myListingNote(l, locale, m, now),
                              style: context.text.labelSmall?.copyWith(
                                color: m.adminReason != null
                                    ? colors.error
                                    : colors.textMuted,
                                height: 1.45,
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
