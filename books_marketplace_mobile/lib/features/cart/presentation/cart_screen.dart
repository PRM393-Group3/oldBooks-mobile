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
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
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

/// Giỏ hàng (lưu ở server): danh sách món, địa chỉ nhận, tổng tiền và đặt hàng
/// bằng số dư ví. Mỗi tin tạo một đơn riêng; tất cả hoặc không gì cả.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  String? _addressId;
  bool _busy = false;

  /// Tin server báo không còn bán (`LISTING_NOT_AVAILABLE`), đánh dấu thêm.
  Set<String> _flagged = const {};

  /// Một key cho mỗi lần bấm "Đặt hàng"; giữ khi thử lại do mạng lỗi, đổi khi
  /// danh sách tin hoặc địa chỉ đổi (nội dung khác thì phải là hành động mới).
  String? _key;
  String? _keyFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ref.read(cartProvider.notifier).reload();
      ref.read(walletProvider.notifier).refresh();
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

    setState(() {
      _busy = true;
      _flagged = const {};
    });
    try {
      final orders = await ref
          .read(orderRepositoryProvider)
          .checkout(
            listingIds: ids,
            addressId: address.id,
            idempotencyKey: key,
          );
      _key = null;
      ref.read(cartProvider.notifier).reload();
      ref.read(walletProvider.notifier).refresh();
      ref.invalidate(walletTransactionsProvider);
      refreshOrders(ref);
      if (!mounted) return;
      final total = orders.fold<int>(0, (t, o) => t + o.totalAmount);
      await _showPlaced(total, orders.length);
    } on ApiError catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case ApiErrorCode.listingNotAvailable:
          setState(() => _flagged = e.detailMessages.toSet());
          ref.read(cartProvider.notifier).reload();
          AppSnackbar.show(
            context,
            l.ckSomeUnavailable,
            type: AppSnackbarType.error,
          );
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

  Future<void> _showPlaced(int total, int count) {
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
            AppSheetTitle(l.ckPlacedTitle, center: true),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.ckPlacedBody(formatVnd(total, locale), count),
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l.ckViewOrders,
              onPressed: () {
                Navigator.of(sheet).pop();
                router.go('/me/orders');
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l.ckKeepShopping,
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
    final cart = ref.watch(cartProvider);
    final addresses = ref.watch(addressesProvider).value ?? const <Address>[];
    final balance = ref.watch(walletProvider).value?.available ?? 0;
    final shippingFee = ref.watch(sellRulesProvider).shippingSale;

    final data = cart.value ?? const CartData();
    final lines = [
      for (final i in data.items)
        if (i.isAvailable && !_flagged.contains(i.listingId)) i,
    ];
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
        ? l.ckPlace
        : l.ckInsufficient;

    return AppPage(
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
                l.ckTotal,
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
        data: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in data.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CartRow(
                  item: item,
                  unavailable:
                      !item.isAvailable || _flagged.contains(item.listingId),
                  priceText: formatVnd(item.price, locale),
                  onRemove: () async {
                    try {
                      await ref
                          .read(cartProvider.notifier)
                          .remove(item.listingId);
                    } on ApiError catch (e) {
                      if (context.mounted) AppSnackbar.apiError(context, e);
                    }
                  },
                ),
              ),
            if (data.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: AppSpacing.sm,
                ),
                child: Text(
                  l.ckEmpty,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AppCard(
                onTap: addresses.isEmpty
                    ? () => context.push('/me/addresses')
                    : () => _pickAddress(addresses),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.ckAddress,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      address == null
                          ? l.ckNoAddress
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
              label: '${l.ckSubtotal} (${lines.length})',
              value: formatVnd(subtotal, locale),
            ),
            const SizedBox(height: AppSpacing.xs),
            _SummaryRow(
              label: l.ckShipping(lines.length, formatVnd(shippingFee, locale)),
              value: formatVnd(shipping, locale),
            ),
            const SizedBox(height: AppSpacing.xs),
            _SummaryRow(
              label: l.ckBalance,
              value: formatVnd(balance, locale),
              valueColor: enough ? colors.success : colors.error,
              bold: true,
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
      ),
    );
  }
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

  final CartLine item;
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
                url: item.thumbnailUrl,
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
                  if (item.author != null)
                    Text(
                      item.author!,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  if (unavailable)
                    Text(
                      l.ckUnavailable,
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
                        child: Text(l.ckRemove),
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
