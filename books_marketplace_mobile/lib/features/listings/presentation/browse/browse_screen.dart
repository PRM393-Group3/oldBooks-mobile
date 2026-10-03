import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/paging/paged_notifier.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/util/search.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../cart/application/cart_providers.dart';
import '../../../categories/application/category_providers.dart';
import '../../../notifications/application/notification_providers.dart';
import '../../application/listing_providers.dart';
import '../../domain/listing.dart';
import '../widgets/book_tile.dart';

/// Tab Khám phá: tìm kiếm, lọc danh mục, lưới sách đang bán.
///
/// Tìm kiếm lọc trên các lô đã tải (backend chưa có tham số tìm kiếm); bỏ dấu
/// tiếng Việt khi so khớp. Dải "Đang đấu giá" của prototype thêm ở lát Đấu giá.
const _gridGap = 14.0;

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  String? _categoryId;
  String _query = '';

  // Giữ controller ở đây: header được dựng lại khi trạng thái tải đổi, nếu
  // không ô tìm kiếm sẽ mất chữ đã gõ.
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(Listing l, String q) => normalizeSearch(
    '${l.title} ${l.bookInfo.author ?? ''} ${l.bookInfo.isbn ?? ''}',
  ).contains(q);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = browseListingsProvider(_categoryId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final categories = ref.watch(categoryTreeProvider).value ?? const [];
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    final cartCount = ref.watch(cartCountProvider);
    final q = normalizeSearch(_query);

    final header = _Header(
      unread: unread,
      cartCount: cartCount,
      categories: [for (final c in categories) (id: c.id, name: c.name)],
      categoryId: _categoryId,
      searchController: _searchController,
      onCategory: (id) => setState(() => _categoryId = id),
      onQuery: (v) => setState(() => _query = v),
    );

    return Scaffold(
      body: SafeArea(
        child: state.when(
          skipLoadingOnReload: true,
          loading: () => Column(
            children: [
              header,
              const Expanded(child: AppLoadingView()),
            ],
          ),
          error: (e, _) => Column(
            children: [
              header,
              Expanded(
                child: AppErrorView(error: e, onRetry: notifier.reload),
              ),
            ],
          ),
          data: (data) {
            final items = q.isEmpty
                ? data.items
                : data.items.where((x) => _matches(x, q)).toList();
            return RefreshIndicator(
              onRefresh: notifier.reload,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.extentAfter < 300) notifier.loadMore();
                  return false;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: header),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppSpacing.md,
                          AppSpacing.screen,
                          AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                q.isEmpty ? l.resultsNew : l.resultsSearch,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.titleMedium,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              l.resultsCount(items.length),
                              style: context.text.labelSmall?.copyWith(
                                color: context.colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (items.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: q.isNotEmpty
                              ? Text(
                                  l.noSearchResults,
                                  textAlign: TextAlign.center,
                                  style: context.text.bodyMedium?.copyWith(
                                    color: context.colors.textMuted,
                                  ),
                                )
                              : AppEmptyView(
                                  icon: Icons.menu_book_outlined,
                                  title: l.emptyBrowseTitle,
                                  message: l.emptyBrowseMessage,
                                ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screen,
                        ),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            // Chiều cao ô = bìa 3:4 + phần chữ (co theo cỡ chữ).
                            final tileWidth =
                                (constraints.crossAxisExtent - _gridGap) / 2;
                            final textScaler = MediaQuery.textScalerOf(context);
                            final extent =
                                tileWidth * 4 / 3 + textScaler.scale(112);
                            return SliverGrid.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: _gridGap,
                                    mainAxisSpacing: 18,
                                    mainAxisExtent: extent,
                                  ),
                              itemCount: items.length,
                              itemBuilder: (context, i) => BookTile(
                                listing: items[i],
                                onTap: () =>
                                    context.push('/home/book/${items[i].id}'),
                              ),
                            );
                          },
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: _Footer(state: data, onRetry: notifier.loadMore),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onRetry});

  final PagedState<Listing> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!state.loadingMore && !state.loadMoreFailed) {
      return const SizedBox(height: AppSpacing.lg);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: state.loadMoreFailed
            ? TextButton(onPressed: onRetry, child: Text(l.loadMoreFailed))
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.unread,
    required this.cartCount,
    required this.categories,
    required this.categoryId,
    required this.searchController,
    required this.onCategory,
    required this.onQuery,
  });

  final int unread;
  final int cartCount;
  final List<({String id, String name})> categories;
  final String? categoryId;
  final TextEditingController searchController;
  final ValueChanged<String?> onCategory;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.brandName,
                    style: context.text.headlineMedium?.copyWith(
                      fontSize: 30,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                _HeaderPill(
                  label: l.notificationsTitle,
                  badge: unread,
                  onTap: () => context.push('/notifications'),
                ),
                const SizedBox(width: AppSpacing.xs),
                _HeaderPill(
                  label: l.cartButton(cartCount),
                  dark: true,
                  onTap: () => context.push('/cart'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              0,
            ),
            child: TextField(
              controller: searchController,
              onChanged: onQuery,
              textInputAction: TextInputAction.search,
              style: context.text.bodyLarge,
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon: Icon(Icons.search, color: colors.textMuted),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide(color: colors.divider),
                ),
              ),
            ),
          ),
          if (categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  children: [
                    _chip(l.categoryAll, categoryId == null, () {
                      onCategory(null);
                    }),
                    for (final c in categories)
                      _chip(c.name, categoryId == c.id, () => onCategory(c.id)),
                  ],
                ),
              ),
            ),
        ],
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

/// Nút viên nhỏ ở đầu trang: Thông báo (kèm badge) và Giỏ (nền tối).
class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.dark = false,
  });

  final String label;
  final VoidCallback onTap;
  final int badge;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = dark ? colors.background : colors.textPrimary;
    return Material(
      color: dark ? colors.textPrimary : colors.surface,
      shape: StadiumBorder(
        side: dark ? BorderSide.none : BorderSide(color: colors.divider),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: context.text.labelMedium?.copyWith(
                    color: fg,
                    fontSize: 13,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                if (badge > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.auction,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: context.text.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
