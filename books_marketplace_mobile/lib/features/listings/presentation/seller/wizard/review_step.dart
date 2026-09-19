import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import '../../../../../core/util/format.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_page.dart';
import '../../../../../core/widgets/app_section.dart';
import '../../../domain/listing.dart';
import 'wizard_fields.dart';

/// Bước 4: tóm tắt từ dữ liệu server, mỗi khối có nút "Sửa", rồi nộp kiểm định.
class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.listing,
    required this.saving,
    required this.onEdit,
    required this.onSubmit,
  });

  final Listing listing;
  final bool saving;
  final ValueChanged<int> onEdit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final info = listing.bookInfo;
    final auction = listing.auction;

    Widget header(String title, int step) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.titleMedium)),
          TextButton(onPressed: () => onEdit(step), child: Text(l.edit)),
        ],
      ),
    );

    return AppPage(
      bottom: AppButton(
        label: l.submitForInspection,
        icon: Icons.send_outlined,
        loading: saving,
        onPressed: onSubmit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header(l.reviewBookSection, WizardStep.book),
          AppSection(
            children: [
              AppKeyValueRow(label: l.fieldTitle, value: info.title ?? '—'),
              AppKeyValueRow(label: l.fieldAuthor, value: info.author ?? '—'),
              if (listing.category != null)
                AppKeyValueRow(
                  label: l.fieldCategory,
                  value: listing.category!.name,
                ),
              if (info.condition != null)
                AppKeyValueRow(
                  label: l.fieldCondition,
                  value: info.condition!.label(l),
                ),
              if (info.publicationYear != null)
                AppKeyValueRow(
                  label: l.fieldYear,
                  value: '${info.publicationYear}',
                ),
              if (info.language != null)
                AppKeyValueRow(label: l.detailLanguage, value: info.language!),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          header(l.reviewPhotosSection, WizardStep.photos),
          if (listing.images.isEmpty)
            Text(
              l.photosMissing,
              style: context.text.bodySmall?.copyWith(color: colors.error),
            )
          else
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: listing.images.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (_, i) {
                  final img = listing.images[i];
                  return Semantics(
                    image: true,
                    label: l.listingPhotoLabel(
                      img.type.label(l),
                      listing.title,
                    ),
                    excludeSemantics: true,
                    child: ClipRRect(
                      borderRadius: AppRadius.mdAll,
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Image.network(
                          img.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: colors.primaryContainer,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          header(l.reviewSaleSection, WizardStep.sale),
          AppSection(
            children: [
              AppKeyValueRow(
                label: l.saleMethodLabel,
                value: listing.saleMethod?.label(l) ?? '—',
              ),
              if (listing.fixedPrice != null) ...[
                AppKeyValueRow(
                  label: l.fieldPrice,
                  value: formatVnd(listing.fixedPrice!.price, locale),
                ),
                AppKeyValueRow(
                  label: l.fieldQuantity,
                  value: '${listing.fixedPrice!.quantity}',
                ),
              ],
              if (auction != null) ...[
                AppKeyValueRow(
                  label: l.startingPriceLabel,
                  value: formatVnd(auction.startingPrice, locale),
                ),
                AppKeyValueRow(
                  label: l.minIncrementLabel,
                  value: formatVnd(auction.minBidIncrement, locale),
                ),
                AppKeyValueRow(
                  label: l.auctionDuration,
                  value: l.durationDays(auction.durationDays),
                ),
                AppKeyValueRow(
                  label: l.fieldStartMode,
                  value: auction.startMode.label(l),
                ),
                if (auction.scheduledStartAt != null)
                  AppKeyValueRow(
                    label: l.fieldScheduledAt,
                    value: formatDateTime(auction.scheduledStartAt!, locale),
                  ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
