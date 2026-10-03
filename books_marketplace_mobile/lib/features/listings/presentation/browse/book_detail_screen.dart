import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/util/format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image_viewer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../cart/application/cart_providers.dart';
import '../../../cart/domain/cart_item.dart';
import '../../../cart/domain/fees.dart';
import '../../application/listing_providers.dart';
import '../../domain/listing.dart';
import '../../domain/listing_enums.dart';
import '../widgets/book_tile.dart';
import '../widgets/listing_format.dart';

/// Chi tiết sách cho người mua: ảnh, giá, người bán, thông số, nút giỏ/mua.
///
/// Đánh giá người bán và số đơn hoàn tất của prototype chưa có trong `ListingDto`
/// nên không hiển thị. Tin đấu giá chỉ xem thông tin; phiên đấu giá thật ở tab
/// Đấu giá.
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listingDetailProvider(listingId));
    return Scaffold(
      body: SafeArea(
        child: state.when(
          loading: () => const Column(
            children: [
              _TopBar(),
              Expanded(child: AppLoadingView()),
            ],
          ),
          error: (e, _) => Column(
            children: [
              const _TopBar(),
              Expanded(
                child: AppErrorView(
                  error: e,
                  onRetry: () =>
                      ref.invalidate(listingDetailProvider(listingId)),
                ),
              ),
            ],
          ),
          data: (listing) => _Detail(listing: listing),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final count = ref.watch(cartCountProvider);
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Row(
          children: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => context.pop(),
              icon: const Icon(Icons.chevron_left, size: 32),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: OutlinedButton(
                onPressed: () => context.push('/cart'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  shape: const StadiumBorder(),
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.divider),
                  backgroundColor: colors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Text(l.cartButton(count)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.listing});

  final Listing listing;

  bool get _purchasable =>
      listing.saleMethod != SaleMethod.auction && listing.fixedPrice != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final info = listing.bookInfo;
    final price = listingPriceText(listing, l, locale);
    final sellerName = listing.seller?.name;

    final specs = <(String, String)>[
      if (info.condition != null) (l.detailCondition, info.condition!.label(l)),
      if (info.defectNotes != null) (l.defectNotesTitle, info.defectNotes!),
      if (info.publisher != null) (l.detailPublisher, info.publisher!),
      if (info.publicationYear != null)
        (l.detailYear, '${info.publicationYear}'),
      if (info.isbn != null) (l.fieldIsbn, info.isbn!),
    ];

    return Column(
      children: [
        const _TopBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen + 4,
              0,
              AppSpacing.screen + 4,
              AppSpacing.lg,
            ),
            children: [
              _Gallery(listing: listing),
              const SizedBox(height: AppSpacing.md),
              if (info.condition != null || listing.category != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.successContainer,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Text(
                        [
                          ?info.condition?.label(l),
                          ?listing.category?.name,
                        ].join(' · '),
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onSuccessContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                listing.title.isEmpty ? '—' : listing.title,
                style: context.text.headlineMedium?.copyWith(
                  height: 1.1,
                  letterSpacing: -0.3,
                ),
              ),
              if (info.author != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    info.author!,
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              if (price != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 10,
                    children: [
                      Text(
                        price,
                        style: context.text.headlineMedium?.copyWith(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_purchasable)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            l.shipPlus(
                              formatVnd(shippingFeeFixedPrice, locale),
                            ),
                            style: context.text.bodySmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (sellerName != null && sellerName.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _SellerCard(name: sellerName),
              ],
              if (specs.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                for (final (k, v) in specs) _SpecRow(label: k, value: v),
              ],
              if (info.description != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  info.description!,
                  style: context.text.bodyMedium?.copyWith(
                    height: 1.6,
                    color: colors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                _purchasable ? l.escrowNote : l.auctionListingNote,
                style: context.text.labelSmall?.copyWith(
                  color: colors.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        if (_purchasable) _ActionBar(listing: listing),
      ],
    );
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.listing});

  final Listing listing;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final images = widget.listing.images;

    if (images.isEmpty) {
      return SizedBox(
        height: 300,
        child: BookCover(
          url: widget.listing.coverImageUrl,
          label: widget.listing.title,
          radius: AppRadius.md,
        ),
      );
    }

    final labels = [
      for (final i in images)
        l.listingPhotoLabel(i.type.label(l), widget.listing.title),
    ];
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => Semantics(
                image: true,
                button: true,
                label: labels[i],
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => showImageViewer(
                    context,
                    urls: [for (final img in images) img.url],
                    labels: labels,
                    initialIndex: i,
                  ),
                  child: ColoredBox(
                    color: colors.primaryContainer,
                    child: Image.network(
                      images[i].url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.broken_image_outlined,
                        color: colors.textMuted,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    Container(
                      width: i == _index ? 16 : 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        color: i == _index
                            ? colors.textPrimary
                            : colors.textPrimary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => String.fromCharCode(w.runes.first).toUpperCase())
        .take(2)
        .join();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.surfaceMuted,
              child: Text(
                initials,
                style: context.text.labelMedium?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(name, style: context.text.labelLarge)),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.text.bodySmall?.copyWith(color: colors.textMuted),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: context.text.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final inCart = ref.watch(inCartProvider(listing.id));
    final cart = ref.read(cartProvider.notifier);
    final item = CartItem.fromListing(listing);

    return Material(
      color: colors.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: inCart ? l.inCart : l.addToCart,
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      final added = cart.add(item);
                      AppSnackbar.show(
                        context,
                        added ? l.addedToCart : l.alreadyInCart,
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: l.buyNow,
                    onPressed: () {
                      cart.add(item);
                      context.push('/cart');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
