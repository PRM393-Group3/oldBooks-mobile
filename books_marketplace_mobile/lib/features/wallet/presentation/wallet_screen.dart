import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_state_views.dart';
import '../application/wallet_providers.dart';
import '../domain/wallet_models.dart';
import 'topup_sheet.dart';
import 'withdraw_sheet.dart';

/// Tab Ví: số dư thật từ backend, nạp/rút, sao kê và tài khoản ngân hàng.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  LedgerType? _filter;

  Future<void> _refresh() async {
    ref.invalidate(walletTransactionsProvider);
    ref.invalidate(bankAccountsProvider);
    await ref.read(walletProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final wallet = ref.watch(walletProvider);
    final txns = ref.watch(walletTransactionsProvider(_filter));
    final banks = ref.watch(bankAccountsProvider).value ?? const [];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen + 4,
              AppSpacing.xs,
              AppSpacing.screen + 4,
              AppSpacing.lg,
            ),
            children: [
              Text(
                l.walletTitle,
                style: context.text.headlineMedium?.copyWith(
                  fontSize: 30,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              wallet.when(
                skipLoadingOnReload: true,
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: AppLoadingView(),
                ),
                error: (error, _) => AppErrorView(
                  error: error,
                  onRetry: () => ref.read(walletProvider.notifier).refresh(),
                ),
                data: (w) => _BalanceCard(
                  available: formatVnd(w.available, locale),
                  held: formatVnd(w.held, locale),
                  total: formatVnd(w.total, locale),
                  hasHeld: w.held > 0,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.walletNote,
                style: context.text.labelSmall?.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.walletHistory,
                      style: context.text.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/wallet/history'),
                    child: Text(l.walletMoreHistory),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final t in <LedgerType?>[null, ...LedgerType.filters])
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: ChoiceChip(
                          label: Text(
                            t == null
                                ? l.walletHistoryFilterAll
                                : ledgerLabel(l, t),
                          ),
                          selected: _filter == t,
                          onSelected: (_) => setState(() => _filter = t),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              txns.when(
                skipLoadingOnReload: true,
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: AppLoadingView(),
                ),
                error: (error, _) => AppErrorView(
                  error: error,
                  onRetry: () => ref
                      .read(walletTransactionsProvider(_filter).notifier)
                      .reload(),
                ),
                data: (state) => Column(
                  children: [
                    if (state.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        child: Text(
                          l.walletNoTransactions,
                          style: context.text.bodyMedium?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    for (final t in state.items)
                      _TxnRow(txn: t, locale: locale),
                    if (state.hasMore || state.loadingMore)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: state.loadingMore
                            ? const AppLoadingView()
                            : TextButton(
                                onPressed: ref
                                    .read(
                                      walletTransactionsProvider(_filter)
                                          .notifier,
                                    )
                                    .loadMore,
                                child: Text(l.walletLoadMore),
                              ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                onTap: () => context.push('/me/bank-accounts'),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.walletPayoutAccount,
                            style: context.text.labelSmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            banks.isEmpty
                                ? l.bankEmpty
                                : '${banks.first.bankName} ${l.bankMasked(banks.first.last4)}',
                            style: context.text.labelLarge,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${banks.length}/$maxBankAccounts',
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
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

/// Nhãn loại dòng sao kê; mã lạ hiển thị nhãn chung.
String ledgerLabel(AppLocalizations l, LedgerType t) => switch (t) {
  LedgerType.topup => l.walletLedgerTopup,
  LedgerType.withdraw => l.walletLedgerWithdraw,
  LedgerType.hold => l.walletLedgerHold,
  LedgerType.release => l.walletLedgerRelease,
  LedgerType.payout => l.walletLedgerPayout,
  LedgerType.refund => l.walletLedgerRefund,
  LedgerType.compensation => l.walletLedgerCompensation,
  LedgerType.capture => l.walletLedgerCapture,
  LedgerType.fee => l.walletLedgerFee,
  LedgerType.unknown => l.walletLedgerOther,
};

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.available,
    required this.held,
    required this.total,
    required this.hasHeld,
  });

  final String available;
  final String held;
  final String total;
  final bool hasHeld;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final fg = colors.onPrimary;

    Widget stat(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: fg.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: context.text.titleMedium?.copyWith(color: fg)),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.walletAvailable,
              style: context.text.labelSmall?.copyWith(
                color: fg.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              available,
              style: context.text.headlineMedium?.copyWith(
                color: fg,
                fontSize: 34,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                stat(l.walletHeld, held),
                const SizedBox(width: AppSpacing.lg),
                stat(l.walletTotal, total),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.background,
                      foregroundColor: colors.textPrimary,
                      minimumSize: const Size(0, 46),
                    ),
                    onPressed: () => showWalletTopupSheet(context),
                    child: Text(l.walletTopup),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: fg,
                      side: BorderSide(color: fg.withValues(alpha: 0.4)),
                      minimumSize: const Size(0, 46),
                    ),
                    onPressed: () => showWalletWithdrawSheet(context),
                    child: Text(l.walletWithdraw),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn, required this.locale});

  final WalletTransaction txn;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final positive = txn.amount > 0;
    final amountText =
        '${positive ? '+' : '−'}${formatVnd(txn.amount.abs(), locale)}';

    // Điều hướng theo đối tượng liên quan; loại lạ thì không làm gì.
    final id = txn.referenceId;
    final route = switch (txn.referenceType) {
      'TOPUP' || 'WITHDRAWAL' => '/wallet/history',
      'ORDER' when id != null => '/me/orders/$id',
      'COMPLAINT' when id != null => '/me/complaints/$id',
      _ => null,
    };

    return InkWell(
      onTap: route == null ? null : () => context.push(route),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.divider)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ledgerLabel(l, txn.type),
                      style: context.text.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (txn.createdAt != null)
                          formatDateTime(txn.createdAt!, locale),
                        l.walletBalanceAfter(
                          formatVnd(txn.balanceAfter, locale),
                        ),
                      ].join(' · '),
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                amountText,
                style: context.text.labelLarge?.copyWith(
                  color: positive ? colors.success : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
