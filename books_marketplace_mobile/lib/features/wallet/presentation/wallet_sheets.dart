import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dashed_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../sim/application/sim_providers.dart';

String _locale(BuildContext c) => Localizations.localeOf(c).toString();

/// Làm tròn lên bội của 50.000 đ, dùng để gợi ý số tiền nạp còn thiếu.
int roundUpTopup(int need) => (need + 49999) ~/ 50000 * 50000;

/// Báo thiếu số dư và gợi ý nạp đúng số còn thiếu.
Future<void> showInsufficientSheet(BuildContext context, int needed) {
  return showAppSheet<void>(
    context,
    builder: (sheet) => Consumer(
      builder: (context, ref, _) {
        final l = context.l10n;
        final locale = _locale(context);
        final avail = ref.watch(availableBalanceProvider);
        final topup = roundUpTopup(needed);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetTitle(l.insufficientTitle),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.insufficientBody(
                formatVnd(needed, locale),
                formatVnd(avail, locale),
              ),
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l.insufficientTopup(formatVnd(topup, locale)),
              onPressed: () {
                Navigator.of(sheet).pop();
                showTopupSheet(context, initialAmount: topup);
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l.sheetClose,
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(sheet).pop(),
            ),
          ],
        );
      },
    ),
  );
}

const _topupChoices = [100000, 200000, 500000, 1000000];

/// Nạp tiền mô phỏng cho giỏ hàng/đấu giá (số dư mô phỏng, chưa nối backend).
/// Nạp thật nằm ở `showWalletTopupSheet`. Có [initialAmount] thì vào thẳng bước quét mã.
Future<void> showTopupSheet(BuildContext context, {int? initialAmount}) {
  return showAppSheet<void>(
    context,
    builder: (_) => _TopupBody(initialAmount: initialAmount),
  );
}

class _TopupBody extends ConsumerStatefulWidget {
  const _TopupBody({this.initialAmount});

  final int? initialAmount;

  @override
  ConsumerState<_TopupBody> createState() => _TopupBodyState();
}

class _TopupBodyState extends ConsumerState<_TopupBody> {
  late int _amount = widget.initialAmount ?? 200000;
  late bool _qr = widget.initialAmount != null;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = _locale(context);
    final amountText = formatVnd(_amount, locale);

    if (_qr) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(l.topupScanTitle),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              width: 200,
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: colors.divider),
              ),
              child: Text(
                l.topupQrLabel,
                style: context.text.labelSmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            amountText,
            textAlign: TextAlign.center,
            style: context.text.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l.topupTransferContent,
            textAlign: TextAlign.center,
            style: context.text.labelSmall?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.topupConfirmNote,
            textAlign: TextAlign.center,
            style: context.text.labelSmall?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          AppDashedButton(
            label: l.topupSimConfirm,
            onPressed: () {
              ref.read(simProvider.notifier).topUp(_amount);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(l.topupSheetTitle),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          childAspectRatio: 3.4,
          children: [
            for (final v in _topupChoices)
              _AmountChip(
                label: formatVnd(v, locale),
                selected: v == _amount,
                onTap: () => setState(() => _amount = v),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l.topupSheetNote,
          style: context.text.labelSmall?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l.topupCreateCode(amountText),
          onPressed: () => setState(() => _qr = true),
        ),
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.textPrimary : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smAll,
          side: BorderSide(
            color: selected ? colors.textPrimary : colors.divider,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: Center(
            child: Text(
              label,
              style: context.text.labelLarge?.copyWith(
                color: selected ? colors.background : colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
