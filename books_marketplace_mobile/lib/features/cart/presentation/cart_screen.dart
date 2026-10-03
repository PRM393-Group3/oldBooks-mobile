import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../profile/application/address_providers.dart';
import '../../sim/application/sim_providers.dart';
import '../../sim/application/sim_state.dart';
import '../../sim/domain/rules.dart';
import '../../wallet/presentation/wallet_sheets.dart';
import '../application/cart_providers.dart';
import '../domain/cart_item.dart';

/// Giỏ hàng: danh sách món, tổng tiền và nút đặt hàng thanh toán bằng ví.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _placeOrder(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> available,
  ) async {
    final outcome = ref.read(simProvider.notifier).placeOrder(available);
    switch (outcome) {
      case SimOk():
        final total = available.fold<int>(
          0,
          (t, i) => t + i.price + shippingFeeFixedPrice,
        );
        ref
            .read(cartProvider.notifier)
            .removeAll(available.map((i) => i.listingId));
        await _showPlaced(context, total, available.length);
      case SimInsufficient(:final needed):
        await showInsufficientSheet(context, needed);
      case SimRejected():
        break;
    }
  }

  Future<void> _showPlaced(BuildContext context, int total, int count) {
    final router = GoRouter.of(context);
    return showAppSheet<void>(
      context,
      builder: (sheet) {
        final l = context.l10n;
        final colors = context.colors;
        final locale = Localizations.localeOf(context).toString();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 26,
                backgroundColor: colors.successContainer,
                child: Icon(Icons.check, color: colors.success, size: 28),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSheetTitle(l.orderPlacedTitle, center: true),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.orderPlacedBody(formatVnd(total, locale), count),
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l.orderPlacedView,
              onPressed: () {
                Navigator.of(sheet).pop();
                router.go('/me/orders');
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l.orderPlacedKeepShopping,
              variant: AppButtonVariant.text,
              onPressed: () {
                Navigator.of(sheet).pop();
                router.go('/home');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final items = ref.watch(cartProvider);
    final reserved = ref.watch(reservedListingIdsProvider);
    final balance = ref.watch(availableBalanceProvider);
    final address = ref.watch(defaultAddressProvider);

    final available = [
      for (final i in items)
        if (!reserved.contains(i.listingId)) i,
    ];
    final subtotal = available.fold<int>(0, (t, i) => t + i.price);
    final shipping = available.length * shippingFeeFixedPrice;
    final total = subtotal + shipping;
    final enough = balance >= total;

    final buttonLabel = available.isEmpty
        ? l.cartNoAvailable
        : enough
        ? l.cartPlaceOrder
        : l.cartInsufficient;

    return _ClearSnackBarsOnOpen(
      child: AppPage(
        title: l.cartTitle,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen + 4,
          AppSpacing.md,
          AppSpacing.screen + 4,
          AppSpacing.lg,
        ),
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  l.cartPayTotal,
                  style: context.text.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  formatVnd(total, locale),
                  style: context.text.headlineMedium?.copyWith(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: buttonLabel,
              onPressed: available.isEmpty
                  ? null
                  : () => _placeOrder(context, ref, available),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CartRow(
                  item: item,
                  unavailable: reserved.contains(item.listingId),
                  priceText: formatVnd(item.price, locale),
                  onRemove: () =>
                      ref.read(cartProvider.notifier).remove(item.listingId),
                ),
              ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: AppSpacing.sm,
                ),
                child: Text(
                  l.cartEmpty,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AppCard(
                onTap: () => context.push('/me/addresses'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.cartShipTo,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      address == null
                          ? l.addrNone
                          : '${address.recipient} · ${address.phone}',
                      style: context.text.labelLarge,
                    ),
                    if (address != null)
                      Text(
                        address.fullLine,
                        style: context.text.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _SummaryRow(
              label: l.cartSubtotal(available.length),
              value: formatVnd(subtotal, locale),
            ),
            const SizedBox(height: AppSpacing.xs),
            _SummaryRow(
              label: l.cartShippingFee(
                formatVnd(shippingFeeFixedPrice, locale),
              ),
              value: formatVnd(shipping, locale),
            ),
            const SizedBox(height: AppSpacing.xs),
            _SummaryRow(
              label: l.cartBalance,
              value: formatVnd(balance, locale),
              valueColor: enough ? colors.success : colors.error,
              bold: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.cartNote,
              style: context.text.labelSmall?.copyWith(
                color: colors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thông báo "Đã thêm vào giỏ" từ màn chi tiết không được che nút đặt hàng.
class _ClearSnackBarsOnOpen extends StatefulWidget {
  const _ClearSnackBarsOnOpen({required this.child});

  final Widget child;

  @override
  State<_ClearSnackBarsOnOpen> createState() => _ClearSnackBarsOnOpenState();
}

class _ClearSnackBarsOnOpenState extends State<_ClearSnackBarsOnOpen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: context.text.bodySmall?.copyWith(
            color: valueColor,
            fontWeight: bold ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({
    required this.item,
    required this.unavailable,
    required this.priceText,
    required this.onRemove,
  });

  final CartItem item;
  final bool unavailable;
  final String priceText;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return Opacity(
      opacity: unavailable ? 0.6 : 1,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              height: 76,
              child: BookCover(
                url: item.coverUrl,
                label: item.title,
                radius: 6,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium?.copyWith(
                      fontFamily: AppTypography.serifFamily,
                      fontSize: 15.5,
                      height: 1.2,
                    ),
                  ),
                  if (item.sellerName != null && item.sellerName!.isNotEmpty)
                    Text(
                      l.cartSeller(item.sellerName!),
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  if (unavailable)
                    Text(
                      l.cartUnavailable,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        priceText,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: onRemove,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 36),
                          foregroundColor: colors.textMuted,
                        ),
                        child: Text(l.cartRemove),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
