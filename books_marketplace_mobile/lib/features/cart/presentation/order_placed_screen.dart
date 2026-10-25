import '../../../core/theme/app_typography.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../orders/domain/sale_order.dart';
import '../../orders/presentation/orders_screen.dart';

/// Kết quả đặt hàng: mỗi sách một đơn, kèm trạng thái và số tiền đã giữ.
class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({super.key, required this.orders});

  final List<SaleOrder> orders;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final total = orders.fold<int>(0, (t, o) => t + o.totalAmount);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: AppPage(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xxl,
          AppSpacing.md,
          AppSpacing.md,
        ),
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: l.ckTrackOrders(orders.length),
              onPressed: () => context.go('/me/orders'),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l.ckKeepShopping,
              variant: AppButtonVariant.text,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.successContainer,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Icon(Icons.check, size: 36, color: colors.success),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              header: true,
              child: Text(
                l.ckPlacedCount(orders.length),
                textAlign: TextAlign.center,
                style: context.text.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.ckPlacedBody(formatVnd(total, locale), orders.length),
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final o in orders)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  onTap: () => context.go('/me/orders/${o.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.ckOrderLine(_code(o.id)),
                              style: context.text.labelSmall?.copyWith(
                                color: colors.textMuted,
                                fontFamily: AppTypography.monoFamily,
                                fontVariations: AppTypography.monoSemiBold,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ),
                          AppTag(
                            label: o.status.label(l),
                            tone: orderTone(o.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          SizedBox(
                            width: 36,
                            height: 50,
                            child: BookCover(
                              url: o.book?.thumbnailUrl,
                              label: o.book?.title ?? '',
                              radius: AppRadius.xs,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              o.book?.title ?? '—',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            formatVnd(o.totalAmount, locale),
                            style: context.text.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            AppBanner(
              message: l.ckNotifyHint,
              tone: AppTagTone.accent,
              icon: Icons.notifications_none,
            ),
          ],
        ),
      ),
    );
  }

  /// Mã ngắn dễ đọc từ id đơn (id dài là UUID).
  static String _code(String id) {
    final s = id.replaceAll('-', '').toUpperCase();
    return s.length <= 6 ? s : s.substring(0, 6);
  }
}
