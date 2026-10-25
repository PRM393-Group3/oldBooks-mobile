import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../orders/domain/sale_order.dart';
import '../../sell/application/sell_rules_provider.dart';
import '../application/cart_providers.dart';

/// Giỏ hàng (lưu ở server): chọn sách rồi sang bước thanh toán. Mỗi sách tạo
/// một đơn riêng nên tổng tiền cộng phí giao theo từng sách.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ref.read(cartProvider.notifier).reload();
    });
  }

  Future<void> _remove(Iterable<String> ids) async {
    try {
      for (final id in ids) {
        await ref.read(cartProvider.notifier).remove(id);
      }
    } on ApiError catch (e) {
      if (mounted) AppSnackbar.apiError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final cart = ref.watch(cartProvider);
    final off = ref.watch(cartDeselectedProvider);
    final shippingFee = ref.watch(sellRulesProvider).shippingSale;

    final items = cart.value?.items ?? const <CartLine>[];
    final available = [
      for (final i in items)
        if (i.isAvailable) i.listingId,
    ];
    final selected = ref.watch(cartSelectedProvider);
    final subtotal = selected.fold<int>(0, (t, i) => t + i.price);
    final total = subtotal + selected.length * shippingFee;
    final none = selected.isEmpty;
    final bool? allState = none
        ? false
        : selected.length == available.length
        ? true
        : null;

    return AppPage(
      title: '${l.cartTitle} (${items.length})',
      actions: [
        if (!none)
          TextButton(
            onPressed: () => _remove([for (final i in selected) i.listingId]),
            style: TextButton.styleFrom(foregroundColor: colors.error),
            child: Text(l.ckRemoveSelected),
          ),
      ],
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      bottom: items.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AppCheckbox(
                      value: allState,
                      semanticLabel: l.ckAll,
                      onChanged: available.isEmpty
                          ? null
                          : () => ref
                                .read(cartDeselectedProvider.notifier)
                                .setAll(available, on: allState != true),
                    ),
                    Text(l.ckAll, style: context.text.labelLarge),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          none
                              ? l.ckNoneSelected
                              : l.ckSelectedCount(selected.length),
                          style: context.text.labelSmall?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                        Text(
                          formatVnd(total, locale),
                          style: context.text.titleMedium?.copyWith(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: none
                      ? l.ckSelectToPay
                      : l.ckPay(formatVnd(total, locale)),
                  onPressed: none ? null : () => context.push('/checkout'),
                ),
              ],
            ),
      child: cart.when(
        skipLoadingOnReload: true,
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: AppLoadingView(),
        ),
        error: (error, _) => AppErrorView(
          error: error,
          onRetry: () => ref.read(cartProvider.notifier).reload(),
        ),
        data: (_) => items.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxl),
                child: Column(
                  children: [
                    Text(l.ckEmpty, style: context.text.titleLarge),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: l.ckKeepShopping,
                      expanded: false,
                      onPressed: () => context.go('/home'),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppBanner(
                    message: l.ckSeparateOrders,
                    icon: Icons.local_shipping_outlined,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _CartRow(
                        item: item,
                        selected:
                            item.isAvailable && !off.contains(item.listingId),
                        priceText: formatVnd(item.price, locale),
                        onToggle: () => ref
                            .read(cartDeselectedProvider.notifier)
                            .toggle(item.listingId),
                        onRemove: () => _remove([item.listingId]),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({
    required this.item,
    required this.selected,
    required this.priceText,
    required this.onToggle,
    required this.onRemove,
  });

  final CartLine item;
  final bool selected;
  final String priceText;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final sold = !item.isAvailable;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxs,
        AppSpacing.xs,
        AppSpacing.xxs,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          AppCheckbox(
            value: sold ? false : selected,
            semanticLabel: item.title,
            onChanged: sold ? null : onToggle,
          ),
          Opacity(
            opacity: sold ? 0.5 : 1,
            child: SizedBox(
              width: 52,
              height: 72,
              child: BookCover(
                url: item.thumbnailUrl,
                label: item.title,
                radius: AppRadius.xs,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Opacity(
              opacity: sold ? 0.5 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium?.copyWith(
                      fontFamily: AppTypography.serifFamily,
                      fontVariations: AppTypography.serifSemiBold,
                      fontSize: 16,
                      height: 19 / 16,
                    ),
                  ),
                  if (item.author != null)
                    Text(
                      item.author!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    priceText,
                    style: context.text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (sold)
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                child: Text(
                  l.ckUnavailable,
                  style: context.text.labelSmall?.copyWith(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: l.ckRemove,
            onPressed: onRemove,
            icon: Icon(Icons.delete_outline, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
