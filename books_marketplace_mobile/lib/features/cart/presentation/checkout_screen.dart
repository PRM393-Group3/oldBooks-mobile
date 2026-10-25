import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/util/idempotency.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/domain/sale_order.dart';
import '../../profile/application/address_providers.dart';
import '../../profile/domain/address.dart';
import '../../profile/presentation/address_picker.dart';
import '../../sell/application/sell_rules_provider.dart';
import '../../wallet/application/wallet_providers.dart';
import '../../wallet/presentation/topup_sheet.dart';
import '../application/cart_providers.dart';

/// Bước thanh toán: địa chỉ nhận, các sách đã chọn, thanh toán bằng ví.
/// Mỗi sách là một đơn riêng; tất cả hoặc không gì cả.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _addressId;
  bool _busy = false;

  /// Một key cho mỗi lần bấm thanh toán; giữ khi thử lại do mạng lỗi, đổi khi
  /// danh sách tin hoặc địa chỉ đổi (nội dung khác thì phải là hành động mới).
  String? _key;
  String? _keyFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(walletProvider.notifier).refresh();
    });
  }

  Future<void> _place(List<CartLine> lines, Address address) async {
    if (_busy) return;
    final l = context.l10n;
    final ids = [for (final i in lines) i.listingId];
    final signature = '${address.id}:${ids.join(',')}';
    if (_keyFor != signature) {
      _key = null;
      _keyFor = signature;
    }
    final key = _key ??= newIdempotencyKey();

    setState(() => _busy = true);
    try {
      final orders = await ref
          .read(orderRepositoryProvider)
          .checkout(
            listingIds: ids,
            addressId: address.id,
            idempotencyKey: key,
          );
      _key = null;
      ref.read(cartDeselectedProvider.notifier).clear();
      ref.read(cartProvider.notifier).reload();
      ref.read(walletProvider.notifier).refresh();
      ref.invalidate(walletTransactionsProvider);
      refreshOrders(ref);
      if (!mounted) return;
      context.pushReplacement('/order-placed', extra: orders);
    } on ApiError catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case ApiErrorCode.listingNotAvailable:
          ref.read(cartProvider.notifier).reload();
          AppSnackbar.show(
            context,
            l.ckSomeUnavailable,
            type: AppSnackbarType.error,
          );
          context.pop();
        case ApiErrorCode.insufficientBalance:
          await showWalletInsufficientSheet(
            context,
            required: e.detailAmount('required') ?? 0,
            available: e.detailAmount('available') ?? 0,
          );
        case ApiErrorCode.orderOwnListing:
          ref.read(cartProvider.notifier).reload();
          AppSnackbar.apiError(context, e);
        default:
          AppSnackbar.apiError(context, e);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickAddress(List<Address> addresses) async {
    final picked = await pickAddress(
      context,
      addresses,
      selectedId: _addressId,
    );
    if (picked != null && mounted) setState(() => _addressId = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final lines = ref.watch(cartSelectedProvider);
    final addresses = ref.watch(addressesProvider).value ?? const <Address>[];
    final balance = ref.watch(walletProvider).value?.available ?? 0;
    final shippingFee = ref.watch(sellRulesProvider).shippingSale;

    Address? address;
    for (final a in addresses) {
      if (a.id == _addressId) address = a;
    }
    address ??= ref.watch(defaultAddressProvider);

    final subtotal = lines.fold<int>(0, (t, i) => t + i.price);
    final shipping = lines.length * shippingFee;
    final total = subtotal + shipping;
    final enough = balance >= total;

    final buttonLabel = lines.isEmpty
        ? l.ckPlaceEmpty
        : address == null
        ? l.ckNeedAddress
        : enough
        ? l.ckPay(formatVnd(total, locale))
        : l.ckInsufficient;

    return AppPage(
      title: l.ckPayTitle,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      bottom: AppButton(
        label: buttonLabel,
        icon: enough && address != null && lines.isNotEmpty
            ? Icons.lock_outline
            : null,
        loading: _busy,
        onPressed: lines.isEmpty || address == null
            ? null
            : enough
            ? () => _place(lines, address!)
            : () => showWalletInsufficientSheet(
                context,
                required: total,
                available: balance,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            onTap: addresses.isEmpty
                ? () => context.push('/me/addresses')
                : () => _pickAddress(addresses),
            child: Row(
              children: [
                Icon(Icons.place_outlined, color: colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address == null
                            ? l.ckNoAddress
                            : '${address.recipient} · ${address.phone}',
                        style: context.text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
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
                Text(
                  address == null ? l.ckAddAddress : l.ckChange,
                  style: context.text.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < lines.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: colors.divider),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 56,
                          child: BookCover(
                            url: lines[i].thumbnailUrl,
                            label: lines[i].title,
                            radius: AppRadius.xs,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            lines[i].title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelLarge,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          formatVnd(lines[i].price, locale),
                          style: context.text.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l.ckPayWith, style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: colors.primary, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.ckWallet,
                          style: context.text.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          enough
                              ? l.ckWalletAfter(
                                  formatVnd(balance, locale),
                                  formatVnd(balance - total, locale),
                                )
                              : '${l.ckBalance}: ${formatVnd(balance, locale)}',
                          style: context.text.labelSmall?.copyWith(
                            color: enough ? colors.textSecondary : colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: colors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.mdAll,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              child: Column(
                children: [
                  _Row(
                    label: '${l.ckSubtotal} (${l.ckItemsCount(lines.length)})',
                    value: formatVnd(subtotal, locale),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _Row(
                    label: l.ckShipping(
                      lines.length,
                      formatVnd(shippingFee, locale),
                    ),
                    value: formatVnd(shipping, locale),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Divider(height: 1, color: colors.divider),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          l.ckTotal,
                          style: context.text.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        formatVnd(total, locale),
                        style: context.text.titleMedium?.copyWith(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.ckAllOrNothing(lines.length),
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.escrowNote,
            style: context.text.labelSmall?.copyWith(
              color: colors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

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
        Text(value, style: context.text.bodySmall),
      ],
    );
  }
}
