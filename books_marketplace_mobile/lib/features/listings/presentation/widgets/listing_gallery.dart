import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_image_viewer.dart';
import '../../domain/listing.dart';

/// Thư viện ảnh vuốt ngang; chạm để xem toàn màn hình và phóng to.
class ListingGallery extends StatefulWidget {
  const ListingGallery({super.key, required this.listing});

  final Listing listing;

  @override
  State<ListingGallery> createState() => _ListingGalleryState();
}

class _ListingGalleryState extends State<ListingGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final images = widget.listing.images;
    final labels = [
      for (final i in images)
        l.listingPhotoLabel(i.type.label(l), widget.listing.title),
    ];

    if (images.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: AppRadius.lgAll,
        ),
        child: Icon(
          Icons.menu_book_rounded,
          size: 64,
          color: colors.onPrimaryContainer.withValues(alpha: 0.4),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: SizedBox(
            height: 320,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => Semantics(
                image: true,
                label: labels[i],
                button: true,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => showImageViewer(
                    context,
                    urls: [for (final img in images) img.url],
                    labels: labels,
                    initialIndex: i,
                  ),
                  child: Container(
                    color: colors.surfaceMuted,
                    child: Image.network(
                      images[i].url,
                      fit: BoxFit.contain,
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
        ),
        if (images.length > 1) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < images.length; i++)
                Container(
                  width: i == _index ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == _index ? colors.primary : colors.divider,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
