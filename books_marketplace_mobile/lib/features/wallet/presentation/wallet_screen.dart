import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../sim/application/sim_providers.dart';
import '../../sim/presentation/sim_text.dart';
import '../domain/wallet_txn.dart';
import 'wallet_sheets.dart';

/// Tab Ví: số dư, nạp/rút (mô phỏng) và lịch sử giao dịch.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final available = ref.watch(availableBalanceProvider);
    final held = ref.watch(heldBalanceProvider);
    final txns = ref.watch(walletTxnsProvider);
    final now = ref.watch(simNowProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
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
            _BalanceCard(
              available: formatVnd(available, locale),
              held: formatVnd(held, locale),
              total: formatVnd(available + held, locale),
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
            Text(l.walletHistory, style: context.text.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            if (txns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(
                  l.walletNoTransactions,
                  style: context.text.bodyMedium?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            for (final t in txns) _TxnRow(txn: t, now: now, locale: locale),
            const SizedBox(height: AppSpacing.md),
            AppCard(
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
                          'Vietcombank •••• 4821',
                          style: context.text.labelLarge,
                        ),
                      ],
                    ),
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.available,
    required this.held,
    required this.total,
  });

  final String available;
  final String held;
  final String total;

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
                    onPressed: () => showTopupSheet(context),
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
                    onPressed: () => showWithdrawSheet(context),
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
  const _TxnRow({required this.txn, required this.now, required this.locale});

  final WalletTxn txn;
  final DateTime now;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final isCapture = txn.type == TxnType.capture;
    final amountText = isCapture
        ? formatVnd(txn.captured ?? 0, locale)
        : '${txn.amount > 0 ? '+' : '−'}${formatVnd(txn.amount.abs(), locale)}';
    final amountColor = isCapture
        ? colors.textMuted
        : txn.amount > 0
        ? colors.success
        : colors.textPrimary;

    return DecoratedBox(
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
                  Text(txnLabel(l, txn), style: context.text.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${txnTypeLabel(l, txn.type)} · ${agoText(l, now, txn.time)}',
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
              style: context.text.labelLarge?.copyWith(color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
}
