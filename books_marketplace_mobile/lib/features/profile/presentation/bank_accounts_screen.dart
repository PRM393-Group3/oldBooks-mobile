import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../application/address_providers.dart';
import '../application/profile_controller.dart';
import '../domain/address.dart';

/// Tài khoản ngân hàng nhận tiền rút (tối đa 3).
class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final list = ref.watch(bankAccountsProvider);
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
            onPressed: full ? null : () => showBankSheet(context),
          ),
        ],
      ),
      child: list.isEmpty
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
                              '${b.bank} ${l.bankMasked(b.last4)}',
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
                            message: '${b.bank} ${l.bankMasked(b.last4)}',
                            confirmLabel: l.addrDelete,
                            destructive: true,
                          );
                          if (ok) {
                            ref
                                .read(bankAccountsProvider.notifier)
                                .remove(b.id);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
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
  final _bank = TextEditingController();
  final _number = TextEditingController();
  late final _holder = TextEditingController(
    text: ref.read(profileControllerProvider).value?.fullName.toUpperCase(),
  );

  @override
  void dispose() {
    _bank.dispose();
    _number.dispose();
    _holder.dispose();
    super.dispose();
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final ok = ref
        .read(bankAccountsProvider.notifier)
        .add(
          BankAccount(
            id: 'b${DateTime.now().microsecondsSinceEpoch}',
            bank: _bank.text.trim(),
            number: _number.text.trim(),
            holder: _holder.text.trim().toUpperCase(),
          ),
        );
    if (!ok) {
      AppSnackbar.show(
        context,
        context.l10n.bankLimit,
        type: AppSnackbarType.error,
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String? required(String? s) =>
        (s == null || s.trim().isEmpty) ? l.addrRequired : null;
    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(l.bankAdd),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l.bankName,
            controller: _bank,
            validator: required,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l.bankNumber,
            controller: _number,
            keyboardType: TextInputType.number,
            validator: (s) => RegExp(r'^\d{6,20}$').hasMatch(s?.trim() ?? '')
                ? null
                : l.addrRequired,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l.bankHolder,
            controller: _holder,
            validator: required,
            textCapitalization: TextCapitalization.characters,
            helperText: l.bankHolderNote,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: l.bankSave, onPressed: _save),
        ],
      ),
    );
  }
}
