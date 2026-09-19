import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/util/format.dart';
import '../../../../core/widgets/app_section.dart';
import '../../domain/listing.dart';

/// Thông tin sách, mô tả, khuyết điểm và cấu hình đấu giá. Dùng chung cho chi
/// tiết tin và màn hình kiểm định để hai nơi luôn hiển thị giống nhau.
class ListingInfoBlock extends StatelessWidget {
  const ListingInfoBlock({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final info = listing.bookInfo;
    final auction = listing.auction;

    final rows = <Widget>[
      if (info.author != null)
        AppKeyValueRow(label: l.detailAuthor, value: info.author!),
      if (listing.category != null)
        AppKeyValueRow(label: l.detailCategory, value: listing.category!.name),
      if (info.publisher != null)
        AppKeyValueRow(label: l.detailPublisher, value: info.publisher!),
      if (info.publicationYear != null)
        AppKeyValueRow(label: l.detailYear, value: '${info.publicationYear}'),
      if (info.language != null)
        AppKeyValueRow(label: l.detailLanguage, value: info.language!),
      if (info.pageCount != null)
        AppKeyValueRow(label: l.detailPages, value: '${info.pageCount}'),
      if (info.coverType != null)
        AppKeyValueRow(label: l.detailCover, value: info.coverType!.label(l)),
      if (info.condition != null)
        AppKeyValueRow(
          label: l.detailCondition,
          value: info.condition!.label(l),
        ),
      if (info.isbn != null)
        AppKeyValueRow(label: l.fieldIsbn, value: info.isbn!),
      if (listing.fixedPrice != null)
        AppKeyValueRow(
          label: l.detailQuantity,
          value: '${listing.fixedPrice!.quantity}',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (auction != null) ...[
          AppSection(
            title: l.auctionSection,
            children: [
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
              if (auction.startsAt != null)
                AppKeyValueRow(
                  label: l.auctionStarts,
                  value: formatDateTime(auction.startsAt!, locale),
                ),
              if (auction.endsAt != null)
                AppKeyValueRow(
                  label: l.auctionEnds,
                  value: formatDateTime(auction.endsAt!, locale),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (rows.isNotEmpty) AppSection(title: l.bookDetails, children: rows),
        if (info.description != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(l.description, style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(info.description!, style: context.text.bodyMedium),
        ],
        if (info.defectNotes != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(l.defectNotesTitle, style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(info.defectNotes!, style: context.text.bodyMedium),
        ],
      ],
    );
  }
}
