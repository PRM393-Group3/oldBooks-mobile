import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/listing.dart';
import 'listing_format.dart';

/// Ô sách trong lưới Khám phá: bìa 3:4, nhãn tình trạng, tên (serif), tác giả,
/// giá. Không có viền thẻ; chỉ ảnh bìa bo góc như prototype.
class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.listing, required this.onTap});

  final Listing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final condition = listing.bookInfo.condition?.label(l);
    final author = listing.bookInfo.author;
    final price = listingPriceText(listing, l, locale);

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BookCover(
                    url: listing.coverImageUrl,
                    label: listing.title,
                    radius: AppRadius.sm,
                  ),
                  if (condition != null)
                    Positioned(
                      top: AppSpacing.xs,
                      left: AppSpacing.xs,
                      child: BookBadge(label: condition),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              listing.title.isEmpty ? '—' : listing.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleMedium?.copyWith(
                fontFamily: AppTypography.serifFamily,
                fontSize: 16,
                height: 1.2,
              ),
            ),
            if (author != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs),
                child: Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            if (price != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs),
                child: Text(
                  price,
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Ảnh bìa: ảnh mạng, hoặc ô màu xanh nhạt kèm biểu tượng khi chưa có ảnh.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.url,
    required this.label,
    this.radius = AppRadius.sm,
    this.fit = BoxFit.cover,
    this.hue,
  });

  final String? url;
  final String label;
  final double radius;
  final BoxFit fit;

  /// Màu bìa thay thế (0 đến 360) cho dữ liệu mẫu không có ảnh.
  final int? hue;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final placeholder = Center(
      child: Icon(
        Icons.menu_book_rounded,
        color: colors.onPrimaryContainer.withValues(alpha: 0.4),
        size: 36,
      ),
    );
    return Semantics(
      image: true,
      label: label,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: colors.primaryContainer,
          child: url == null
              ? (hue == null
                    ? placeholder
                    : CustomPaint(painter: _HuePainter(hue!)))
              : Image.network(
                  url!,
                  fit: fit,
                  errorBuilder: (_, _, _) => placeholder,
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : placeholder,
                ),
        ),
      ),
    );
  }
}

/// Nhãn nhỏ nền thẻ trên bìa sách (tình trạng).
class BookBadge extends StatelessWidget {
  const BookBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }
}

/// Bìa vẽ sọc chéo hai tông cùng một màu, giống bìa mẫu của prototype.
class _HuePainter extends CustomPainter {
  _HuePainter(this.hue);

  final int hue;

  @override
  void paint(Canvas canvas, Size size) {
    final a = HSLColor.fromAHSL(1, hue.toDouble() % 360, 0.35, 0.87).toColor();
    final b = HSLColor.fromAHSL(1, hue.toDouble() % 360, 0.40, 0.82).toColor();
    canvas.drawRect(Offset.zero & size, Paint()..color = a);
    final paint = Paint()
      ..color = b
      ..strokeWidth = 7;
    const gap = 14.0;
    for (var x = -size.height; x < size.width + size.height; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HuePainter old) => old.hue != hue;
}
