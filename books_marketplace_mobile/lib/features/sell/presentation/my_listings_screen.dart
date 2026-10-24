import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_paged_list.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/application/listing_providers.dart';
import '../../listings/domain/listing.dart';
import '../../listings/domain/listing_enums.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../application/my_listings_provider.dart';

/// Các tab theo trạng thái. `null` là tất cả (gồm cả tin `RESERVED`, không có
/// tab riêng).
const _tabs = <ListingStatus?>[
  null,
  ListingStatus.published,
  ListingStatus.pendingReview,
  ListingStatus.needsChanges,
  ListingStatus.draft,
  ListingStatus.unpublished,
  ListingStatus.sold,
  ListingStatus.rejected,
];

/// Tin đăng của tôi theo trạng thái: lý do khi cần sửa/bị từ chối, sửa, gửi
/// duyệt, gỡ tin.
class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String label(ListingStatus? s) => switch (s) {
      null => l.filterAll,
      ListingStatus.published => l.mlTabPublished,
      ListingStatus.pendingReview => l.mlTabPending,
      ListingStatus.needsChanges => l.mlTabChanges,
      ListingStatus.draft => l.mlTabDraft,
      ListingStatus.unpublished => l.mlTabUnpublished,
      ListingStatus.sold => l.mlTabSold,
      _ => l.mlTabRejected,
    };
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.meMyListings),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final s in _tabs) Tab(text: label(s))],
          ),
        ),
        body: TabBarView(
          children: [for (final s in _tabs) _StatusList(status: s)],
        ),
      ),
    );
  }
}

class _StatusList extends ConsumerWidget {
  const _StatusList({required this.status});

  final ListingStatus? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final provider = myListingsProvider(status);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return AppPagedList<Listing>(
      value: state,
      onLoadMore: notifier.loadMore,
      onRefresh: () async {
        refreshMyListings(ref);
        await notifier.reload();
      },
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen + 4,
        AppSpacing.md,
        AppSpacing.screen + 4,
        AppSpacing.xl,
      ),
      separator: const SizedBox(height: 12),
      // Phiên đấu giá của người bán nằm ở "Phiên của tôi" (tab Đang bán).
      header: status == null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => context.push('/auctions/mine?tab=seller'),
                child: Row(
                  children: [
                    const Icon(Icons.gavel_outlined, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        l.mlAuctionsLink,
                        style: context.text.labelLarge,
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            )
          : null,
      empty: AppEmptyView(
        icon: Icons.inventory_2_outlined,
        title: l.myListingsEmpty,
      ),
      itemBuilder: (context, listing) => _ListingCard(listing: listing),
    );
  }
}

AppTagTone _tone(ListingStatus s) => switch (s) {
  ListingStatus.published => AppTagTone.success,
  ListingStatus.pendingReview => AppTagTone.warning,
  ListingStatus.needsChanges || ListingStatus.rejected => AppTagTone.error,
  ListingStatus.reserved => AppTagTone.info,
  _ => AppTagTone.neutral,
};

class _ListingCard extends ConsumerStatefulWidget {
  const _ListingCard({required this.listing});

  final Listing listing;

  @override
  ConsumerState<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends ConsumerState<_ListingCard> {
  bool _busy = false;

  Future<void> _run(
    Future<Object?> Function() action,
    String successMessage,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      refreshMyListings(ref);
      ref.invalidate(listingDetailProvider(widget.listing.id));
      if (mounted) AppSnackbar.success(context, successMessage);
    } on ApiError catch (e) {
      // Trạng thái đã đổi ở nơi khác: tải lại danh sách để hiện đúng.
      if (e.needsReload) refreshMyListings(ref);
      if (mounted) AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unpublish() async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.mlUnpublishTitle,
      message: l.mlUnpublishBody,
      confirmLabel: l.mlUnpublish,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _run(
      () => ref.read(listingRepositoryProvider).unpublish(widget.listing.id),
      l.mlUnpublished,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final m = widget.listing;
    final status = m.status;
    final reason = m.reviewReason;
    final note = switch (status) {
      ListingStatus.pendingReview => l.mlPendingNote,
      ListingStatus.reserved => l.mlReservedNote,
      ListingStatus.rejected when reason == null => l.mlRejectedFinal,
      _ => null,
    };

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/home/book/${m.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                height: 72,
                child: BookCover(
                  url: m.coverImageUrl,
                  label: m.title,
                  radius: 6,
                ),
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
                            m.price == null ? '—' : formatVnd(m.price!, locale),
                            style: context.text.labelSmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                        AppTag(label: status.label(l), tone: _tone(status)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.title.isEmpty ? '—' : m.title,
                      style: context.text.titleMedium?.copyWith(
                        fontFamily: AppTypography.serifFamily,
                        fontSize: 15.5,
                        height: 1.2,
                      ),
                    ),
                    if (reason != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l.mlReason(reason),
                        style: context.text.labelSmall?.copyWith(
                          color: colors.error,
                          height: 1.45,
                        ),
                      ),
                    ],
                    if (note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        note,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.textMuted,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (status.isEditable || status.canUnpublish)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Wrap(
                spacing: AppSpacing.xs,
                children: [
                  if (status.isEditable)
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => context.push('/me/listings/${m.id}/edit'),
                      child: Text(l.mlEdit),
                    ),
                  if (status.canSubmit)
                    FilledButton(
                      onPressed: _busy
                          ? null
                          : () => _run(
                              () => ref
                                  .read(listingRepositoryProvider)
                                  .submit(m.id),
                              l.mlSubmitted,
                            ),
                      child: Text(switch (status) {
                        ListingStatus.needsChanges => l.mlResubmit,
                        ListingStatus.unpublished => l.mlRepublish,
                        _ => l.mlSubmit,
                      }),
                    ),
                  if (status.canUnpublish)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: colors.error,
                      ),
                      onPressed: _busy ? null : _unpublish,
                      child: Text(l.mlUnpublish),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
