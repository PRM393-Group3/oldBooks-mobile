import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_paged_list.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../application/listing_providers.dart';
import '../../domain/listing_enums.dart';
import '../widgets/listing_card.dart';

/// Tab "Tin của tôi": dải chỉ số theo trạng thái, danh sách và nút nổi Đăng bán.
class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  ListingStatus? _filter;

  static const _shown = [
    ListingStatus.draft,
    ListingStatus.pendingInspection,
    ListingStatus.rejected,
    ListingStatus.onSale,
    ListingStatus.auctioning,
    ListingStatus.closed,
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = myListingsProvider(_filter);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final counts = ref.watch(listingSummaryProvider).value ?? const {};

    return AppPage(
      title: l.myListingsTitle,
      scrollable: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/listings/new'),
        icon: const Icon(Icons.add),
        label: Text(l.sellAction),
      ),
      child: AppPagedList(
        value: state,
        onLoadMore: notifier.loadMore,
        onRefresh: () async {
          ref.invalidate(listingSummaryProvider);
          await notifier.reload();
        },
        header: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip(l.filterAll, null),
                for (final s in _shown)
                  _chip(
                    counts[s] == null
                        ? s.label(l)
                        : '${s.label(l)} (${counts[s]})',
                    s,
                  ),
              ],
            ),
          ),
        ),
        empty: AppEmptyView(
          icon: Icons.inventory_2_outlined,
          title: l.emptyMineTitle,
          message: l.emptyMineMessage,
        ),
        itemBuilder: (context, listing) => ListingCard(
          listing: listing,
          onTap: () => context.push(
            listing.status == ListingStatus.draft
                ? '/listings/${listing.id}/edit'
                : '/listings/${listing.id}',
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, ListingStatus? status) => Padding(
    padding: const EdgeInsets.only(right: AppSpacing.xs),
    child: ChoiceChip(
      label: Text(label),
      selected: _filter == status,
      onSelected: (_) => setState(() => _filter = status),
    ),
  );
}
