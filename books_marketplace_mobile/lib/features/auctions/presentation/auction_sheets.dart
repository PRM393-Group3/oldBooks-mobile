import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../sim/application/sim_providers.dart';
import '../../sim/application/sim_state.dart';
import '../../wallet/presentation/wallet_sheets.dart';
import '../domain/auction.dart';

/// Đăng ký tham gia: hiện phí, cọc và số dư; thiếu tiền thì dẫn tới nạp.
Future<void> showRegisterSheet(BuildContext context, Auction auction) {
  return showAppSheet<void>(
    context,
    builder: (sheet) => Consumer(
      builder: (context, ref, _) {
        final l = context.l10n;
        final colors = context.colors;
        final locale = Localizations.localeOf(context).toString();
        final balance = ref.watch(availableBalanceProvider);
        final enough = balance >= auction.registrationHold;
        final closes = auction.registrationClosesAt;

        Widget row(
          String label,
          String value, {
          Color? color,
          bool bold = false,
        }) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: context.text.bodySmall?.copyWith(
                  color: bold ? null : colors.textSecondary,
                  fontWeight: bold ? FontWeight.w700 : null,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              value,
              style: context.text.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetTitle(l.regSheetTitle),
            const SizedBox(height: 4),
            Text(
              auction.title,
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            row(l.regFee, formatVnd(auction.registrationFee, locale)),
            const SizedBox(height: 10),
            row(l.regDeposit, formatVnd(auction.deposit, locale)),
            const Divider(height: 24),
            row(
              l.regHold,
              formatVnd(auction.registrationHold, locale),
              bold: true,
            ),
            const SizedBox(height: 10),
            row(
              l.regBalance,
              formatVnd(balance, locale),
              color: enough ? colors.success : colors.error,
            ),
            const SizedBox(height: AppSpacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: AppRadius.smAll,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final t in [
                      l.regNote1,
                      l.regNote2,
                      if (closes != null)
                        l.regNote3(formatShortDateTime(closes)),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          t,
                          style: context.text.labelSmall?.copyWith(
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: enough
                  ? l.regConfirm(formatVnd(auction.registrationHold, locale))
                  : l.regInsufficient,
              onPressed: () {
                final outcome = ref
                    .read(simProvider.notifier)
                    .registerForAuction(auction.id);
                Navigator.of(sheet).pop();
                if (outcome is SimInsufficient) {
                  showInsufficientSheet(context, outcome.needed);
                }
              },
            ),
          ],
        );
      },
    ),
  );
}

/// Xác nhận mua ngay giá mua ngay của phiên.
Future<void> showBuyNowSheet(BuildContext context, Auction auction) {
  return showAppSheet<void>(
    context,
    builder: (sheet) => Consumer(
      builder: (context, ref, _) {
        final l = context.l10n;
        final colors = context.colors;
        final locale = Localizations.localeOf(context).toString();
        final price = formatVnd(auction.buyNow, locale);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetTitle(l.buyNowTitle(price)),
            const SizedBox(height: AppSpacing.sm),
            for (final t in [
              l.buyNowNote1(price),
              l.buyNowNote2,
              l.buyNowNote3,
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  t,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.55,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.auction,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
              ),
              onPressed: () {
                final outcome = ref
                    .read(simProvider.notifier)
                    .placeBid(auction.id, auction.buyNow, buyNow: true);
                Navigator.of(sheet).pop();
                if (outcome is SimInsufficient) {
                  showInsufficientSheet(context, outcome.needed);
                }
              },
              child: Text(l.buyNowConfirm),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l.sheetLater,
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(sheet).pop(),
            ),
          ],
        );
      },
    ),
  );
}
