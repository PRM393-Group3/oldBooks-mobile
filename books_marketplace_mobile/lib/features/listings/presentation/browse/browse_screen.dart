import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_paged_list.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../categories/application/category_providers.dart';
import '../../../notifications/application/notification_providers.dart';
import '../../application/listing_providers.dart';
import '../widgets/listing_card.dart';

/// Trang chủ của Buyer và Seller: tin công khai, lọc theo danh mục.
class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  String? _categoryId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = browseListingsProvider(_categoryId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final categories = ref.watch(categoryTreeProvider).value ?? const [];
    final unread = ref.watch(unreadCountProvider).value ?? 0;

    return AppPage(
      title: l.navExplore,
      // Tạm thời: lát 1 thay bằng đầu trang Khám phá theo prototype.
      actions: [
        IconButton(
          tooltip: l.notificationsTitle,
          onPressed: () => context.push('/notifications'),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(unread > 99 ? '99+' : '$unread'),
            child: const Icon(Icons.notifications_none),
          ),
        ),
      ],
      scrollable: false,
      child: AppPagedList(
        value: state,
        onLoadMore: notifier.loadMore,
        onRefresh: notifier.reload,
        header: categories.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _chip(l.categoryAll, _categoryId == null, () {
                        setState(() => _categoryId = null);
                      }),
                      for (final c in categories)
                        _chip(c.name, _categoryId == c.id, () {
                          setState(() => _categoryId = c.id);
                        }),
                    ],
                  ),
                ),
              ),
        empty: AppEmptyView(
          icon: Icons.menu_book_outlined,
          title: l.emptyBrowseTitle,
          message: l.emptyBrowseMessage,
        ),
        itemBuilder: (context, listing) => ListingCard(
          listing: listing,
          showStatus: false,
          onTap: () => context.push('/listings/${listing.id}'),
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: AppSpacing.xs),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}
