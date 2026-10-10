import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../wallet/application/wallet_providers.dart';
import '../../wallet/domain/wallet_models.dart';
import '../application/profile_controller.dart';

/// Tài khoản ngân hàng nhận tiền rút (tối đa 3). Số tài khoản chỉ hiện dạng che.
class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final state = ref.watch(bankAccountsProvider);
    final notifier = ref.read(bankAccountsProvider.notifier);
    final list = state.value ?? const <BankAccount>[];
    final full = list.length >= maxBankAccounts;

    return AppPage(
      title: l.bankTitle,
      scrollable: false,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (full)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                l.bankLimit,
                style: context.text.labelSmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ),
          AppButton(
            label: l.bankAdd,
            icon: Icons.add,
            onPressed: full || state.isLoading
                ? null
                : () => showBankSheet(context),
          ),
        ],
      ),
      child: state.when(
        skipLoadingOnReload: true,
        loading: () => const AppLoadingView(),
        error: (error, _) =>
            AppErrorView(error: error, onRetry: notifier.reload),
        data: (list) => list.isEmpty
            ? AppEmptyView(
                icon: Icons.account_balance_outlined,
                title: l.bankEmpty,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen + 4,
                  AppSpacing.md,
                  AppSpacing.screen + 4,
                  AppSpacing.md,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final b = list[i];
                  return AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${b.bankName} ${l.bankMasked(b.last4)}',
                                style: context.text.labelLarge,
                              ),
                              Text(
                                b.holder,
                                style: context.text.labelSmall?.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l.addrDelete,
                          icon: Icon(Icons.delete_outline, color: colors.error),
                          onPressed: () async {
                            final ok = await showConfirmDialog(
                              context,
                              title: l.bankDeleteTitle,
                              message: '${b.bankName} ${l.bankMasked(b.last4)}',
                              confirmLabel: l.addrDelete,
                              destructive: true,
                            );
                            if (!ok || !context.mounted) return;
                            try {
                              await notifier.remove(b.id);
                            } on ApiError catch (e) {
                              if (context.mounted) {
                                AppSnackbar.apiError(context, e);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

Future<void> showBankSheet(BuildContext context) =>
    showAppSheet<void>(context, builder: (_) => const _BankForm());

class _BankForm extends ConsumerStatefulWidget {
  const _BankForm();

  @override
  ConsumerState<_BankForm> createState() => _BankFormState();
}

class _BankFormState extends ConsumerState<_BankForm> {
  final _key = GlobalKey<FormState>();
  final _number = TextEditingController();
  late final _holder = TextEditingController(
    text: ref.read(profileControllerProvider).value?.fullName,
  );

  String? _bankCode;
  bool _saving = false;
  String? _numberError;

  @override
  void dispose() {
    _number.dispose();
    _holder.dispose();
    super.dispose();
  }

  /// So khớp tên không phân biệt hoa thường và dấu, vì server chuẩn hóa tên chủ
  /// tài khoản thành chữ hoa không dấu.
  static String _fold(String s) {
    const from =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const to =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    final b = StringBuffer();
    for (final r in s.toLowerCase().trim().runes) {
      final c = String.fromCharCode(r);
      final i = from.indexOf(c);
      b.write(i >= 0 ? to[i] : c);
    }
    return b.toString().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool get _holderDiffers {
    final profile = ref.read(profileControllerProvider).value?.fullName;
    return profile != null &&
        _holder.text.trim().isNotEmpty &&
        _fold(profile) != _fold(_holder.text);
  }

  Future<void> _save() async {
    if (_saving || !_key.currentState!.validate()) return;
    final bankCode = _bankCode;
    if (bankCode == null) return;
    setState(() {
      _saving = true;
      _numberError = null;
    });
    try {
      await ref
          .read(bankAccountsProvider.notifier)
          .add(
            bankCode: bankCode,
            accountNumber: _number.text.replaceAll(RegExp(r'\s'), ''),
            accountHolder: _holder.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } on ApiError catch (e) {
      if (!mounted) return;
      if (e.fieldErrors.containsKey('accountNumber')) {
        setState(() => _numberError = context.l10n.bankNumberInvalid);
      }
      AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final banks = ref.watch(banksProvider);
    String? required(String? s) =>
        (s == null || s.trim().isEmpty) ? l.addrRequired : null;

    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(l.bankAdd),
          const SizedBox(height: AppSpacing.sm),
          banks.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AppErrorView(
              error: error,
              onRetry: () => ref.invalidate(banksProvider),
            ),
            data: (items) => DropdownButtonFormField<String>(
              initialValue: _bankCode,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.bankPickBank),
              items: [
                for (final b in items)
                  DropdownMenuItem(value: b.code, child: Text(b.name)),
              ],
              validator: (v) => v == null ? l.addrRequired : null,
              onChanged: _saving ? null : (v) => setState(() => _bankCode = v),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l.bankNumber,
            controller: _number,
            keyboardType: TextInputType.number,
            enabled: !_saving,
            errorText: _numberError,
            validator: (s) =>
                RegExp(r'^\d{6,20}$')
                    .hasMatch((s ?? '').replaceAll(RegExp(r'\s'), ''))
                ? null
                : l.bankNumberInvalid,
            onChanged: (_) {
              if (_numberError != null) setState(() => _numberError = null);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l.bankHolder,
            controller: _holder,
            enabled: !_saving,
            validator: required,
            textCapitalization: TextCapitalization.characters,
            helperText: l.bankHolderNote,
            onChanged: (_) => setState(() {}),
          ),
          if (_holderDiffers)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: colors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l.bankHolderMismatch,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: l.bankSave, loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
