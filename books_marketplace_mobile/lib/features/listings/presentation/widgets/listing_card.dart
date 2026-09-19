import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/listing.dart';
import 'listing_format.dart';
import 'listing_status_tag.dart';

/// Thẻ tin đăng dùng chung cho Buyer, Seller và Inspector.
///
/// [footer] chèn thêm nội dung theo ngữ cảnh (ví dụ tag "Quá hạn" ở hàng đợi).
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.showStatus = true,
    this.footer,
  });

  final Listing listing;
  final VoidCallback onTap;
  final bool showStatus;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final price = listingPriceText(listing, l, locale);
    final author = listing.bookInfo.author;

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: colors.divider),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Cover(url: listing.coverImageUrl, label: listing.title),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title.isEmpty ? '—' : listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium,
                    ),
                    if (author != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    if (price != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        price,
                        style: context.text.titleMedium?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                    if (showStatus || footer != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        children: [
                          if (showStatus)
                            ListingStatusTag(status: listing.status),
                          ?footer,
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.label});

  final String? url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final placeholder = Icon(
      Icons.menu_book_rounded,
      color: colors.onPrimaryContainer.withValues(alpha: 0.5),
      size: 32,
    );
    return Semantics(
      image: true,
      label: label,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: Container(
          width: 72,
          height: 96,
          color: colors.primaryContainer,
          alignment: Alignment.center,
          child: url == null
              ? placeholder
              : Image.network(
                  url!,
                  width: 72,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => placeholder,
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : placeholder,
                ),
        ),
      ),
    );
  }
}
