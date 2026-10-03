import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/util/idempotency.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../application/wallet_limits.dart';
import '../application/wallet_providers.dart';
import '../domain/wallet_models.dart';
import 'topup_sheet.dart';

/// Rút tiền về tài khoản ngân hàng: tiền bị giữ ngay, admin duyệt, rồi chuyển.
Future<void> showWalletWithdrawSheet(BuildContext context) {
  return showAppSheet<void>(context, builder: (_) => const _WithdrawFlow());
}

class _WithdrawFlow extends ConsumerStatefulWidget {
  const _WithdrawFlow();

  @override
  ConsumerState<_WithdrawFlow> createState() => _WithdrawFlowState();
}

class _WithdrawFlowState extends ConsumerState<_WithdrawFlow> {
  final _controller = TextEditingController();
  String? _bankId;
  bool _busy = false;
  String? _error;

  /// Số tiền còn thiếu khi server báo `INSUFFICIENT_BALANCE`, để gợi ý nạp.
  int? _shortBy;

  /// Một key cho mỗi lần bấm "Gửi yêu cầu rút"; giữ khi gửi lại do mạng lỗi.
  String? _key;
  String? _keyFor;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _amount => int.tryParse(_controller.text) ?? 0;

  Future<void> _submit() async {
    final bankId = _bankId;
    if (_busy || bankId == null) return;
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final signature = '$bankId:$_amount';
    if (_keyFor != signature) {
      _key = null;
      _keyFor = signature;
    }
    final key = _key ??= newIdempotencyKey();
    setState(() {
      _busy = true;
      _error = null;
      _shortBy = null;
    });
    try {
      await ref
          .read(walletRepositoryProvider)
          .createWithdrawal(
            amount: _amount,
            bankAccountId: bankId,
            idempotencyKey: key,
          );
      _key = null;
      ref.read(walletProvider.notifier).refresh();
      ref.invalidate(walletTransactionsProvider);
      ref.invalidate(withdrawalsProvider);
      if (!mounted) return;
      final amount = formatVnd(_amount, locale);
      Navigator.of(context).pop();
      AppSnackbar.success(context, l.withdrawCreated(amount));
    } on ApiError catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case ApiErrorCode.insufficientBalance:
          final required = e.detailAmount('required') ?? _amount;
          final available = e.detailAmount('available') ?? 0;
          setState(() {
            _error = l.withdrawNeedHave(
              formatVnd(required, locale),
              formatVnd(available, locale),
            );
            _shortBy = required - available;
          });
        case ApiErrorCode.withdrawBelowMinimum:
          final min =
              e.detailAmount('min_amount') ??
              ref.read(walletLimitsProvider).withdrawMin;
          setState(() => _error = l.withdrawBelowMin(formatVnd(min, locale)));
        default:
          AppSnackbar.apiError(context, e);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final limits = ref.watch(walletLimitsProvider);
    final available = ref.watch(walletProvider).value?.available ?? 0;
    final banks = ref.watch(bankAccountsProvider);
    final accounts = banks.value ?? const <BankAccount>[];
    _bankId ??= accounts.isEmpty ? null : accounts.first.id;

    final amount = _amount;
    final valid =
        _bankId != null && amount >= limits.withdrawMin && amount <= available;
    final (String hint, bool bad) = _error != null
        ? (_error!, true)
        : amount == 0
        ? (l.withdrawHintAvailable(formatVnd(available, locale)), false)
        : amount < limits.withdrawMin
        ? (l.withdrawBelowMin(formatVnd(limits.withdrawMin, locale)), true)
        : amount > available
        ? (l.withdrawHintOver(formatVnd(available, locale)), true)
        : (l.withdrawHintHold(formatVnd(amount, locale)), false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(l.withdrawSheetTitle),
        const SizedBox(height: AppSpacing.md),
        Text(l.withdrawPickBank, style: context.text.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        if (banks.isLoading && accounts.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (accounts.isEmpty)
          Row(
            children: [
              Expanded(
                child: Text(
                  l.withdrawNoBank,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/me/bank-accounts');
                },
                child: Text(l.withdrawAddBank),
              ),
            ],
          )
        else
          RadioGroup<String>(
            groupValue: _bankId,
            onChanged: (v) => setState(() => _bankId = v),
            child: Column(
              children: [
                for (final b in accounts)
                  RadioListTile<String>(
                    value: b.id,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${b.bankName} ${l.bankMasked(b.last4)}'),
                    subtitle: Text(b.holder),
                  ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          enabled: !_busy,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {
            _error = null;
            _shortBy = null;
          }),
          decoration: InputDecoration(hintText: l.withdrawAmountHint),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          hint,
          style: context.text.labelSmall?.copyWith(
            color: bad ? colors.error : colors.textMuted,
          ),
        ),
        if (_shortBy != null && _shortBy! > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                final topup = (_shortBy! + 9999) ~/ 10000 * 10000;
                Navigator.of(context).pop();
                showWalletTopupSheet(context, initialAmount: topup);
              },
              child: Text(l.insufficientTopup(formatVnd(_shortBy!, locale))),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${l.withdrawNote}\n${l.withdrawNoCancel}',
          style: context.text.labelSmall?.copyWith(
            color: colors.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l.withdrawSubmit,
          loading: _busy,
          onPressed: valid ? _submit : null,
        ),
      ],
    );
  }
}
