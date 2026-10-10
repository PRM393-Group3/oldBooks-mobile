import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/address_providers.dart';
import '../domain/address.dart';

/// Sổ địa chỉ giao hàng: thêm, sửa, xóa, đặt mặc định.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final state = ref.watch(addressesProvider);
    final notifier = ref.read(addressesProvider.notifier);

    return AppPage(
      title: l.addrTitle,
      scrollable: false,
      bottom: AppButton(
        label: l.addrAdd,
        icon: Icons.add,
        onPressed: () => showAddressSheet(context),
      ),
      child: state.when(
        skipLoadingOnReload: true,
        loading: () => const AppLoadingView(),
        error: (error, _) =>
            AppErrorView(error: error, onRetry: notifier.reload),
        data: (list) => list.isEmpty
            ? AppEmptyView(icon: Icons.location_on_outlined, title: l.addrEmpty)
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
                  final a = list[i];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${a.recipient} · ${a.phone}',
                                style: context.text.labelLarge,
                              ),
                            ),
                            if (a.isDefault)
                              AppTag(
                                label: l.addrDefault,
                                tone: AppTagTone.success,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          a.fullLine,
                          style: context.text.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  showAddressSheet(context, existing: a),
                              child: Text(l.addrEdit),
                            ),
                            if (!a.isDefault)
                              TextButton(
                                onPressed: () =>
                                    _run(context, () => notifier.setDefault(a)),
                                child: Text(l.addrSetDefault),
                              ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: colors.error,
                              ),
                              onPressed: () async {
                                final ok = await showConfirmDialog(
                                  context,
                                  title: l.addrDeleteTitle,
                                  message: a.fullLine,
                                  confirmLabel: l.addrDelete,
                                  destructive: true,
                                );
                                if (ok && context.mounted) {
                                  await _run(
                                    context,
                                    () => notifier.remove(a.id),
                                  );
                                }
                              },
                              child: Text(l.addrDelete),
                            ),
                          ],
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

/// Chạy một thao tác ghi, hiện lỗi API dưới dạng snackbar.
Future<void> _run(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } on ApiError catch (e) {
    if (context.mounted) AppSnackbar.apiError(context, e);
  }
}

/// Thêm hoặc sửa một địa chỉ.
Future<void> showAddressSheet(BuildContext context, {Address? existing}) {
  return showAppSheet<void>(
    context,
    builder: (sheet) => _AddressForm(existing: existing),
  );
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm({this.existing});

  final Address? existing;

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _key = GlobalKey<FormState>();
  late final _recipient = TextEditingController(
    text: widget.existing?.recipient,
  );
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _province = TextEditingController(text: widget.existing?.province);
  late final _district = TextEditingController(text: widget.existing?.district);
  late final _ward = TextEditingController(text: widget.existing?.ward);
  late final _detail = TextEditingController(text: widget.existing?.detail);

  @override
  void dispose() {
    for (final c in [
      _recipient,
      _phone,
      _province,
      _district,
      _ward,
      _detail,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _saving = false;
  bool _makeDefault = false;
  Map<String, String> _serverErrors = const {};

  /// Tên trường JSON của server → tên trường trong form.
  static const _fieldMap = {'recipientName': 'recipient'};

  Future<void> _save() async {
    if (_saving || !_key.currentState!.validate()) return;
    final l = context.l10n;
    final notifier = ref.read(addressesProvider.notifier);
    final base = widget.existing;
    final address = Address(
      id: base?.id ?? '',
      recipient: _recipient.text,
      phone: _phone.text,
      province: _province.text,
      district: _district.text,
      ward: _ward.text,
      detail: _detail.text,
      // Server không cho bỏ cờ mặc định của địa chỉ mặc định duy nhất, nên cứ
      // giữ cờ hiện tại; chỉ bật thêm khi người dùng chọn.
      isDefault: (base?.isDefault ?? false) || _makeDefault,
    );
    setState(() {
      _saving = true;
      _serverErrors = const {};
    });
    try {
      if (base == null) {
        await notifier.create(address);
      } else {
        await notifier.edit(address);
      }
      if (mounted) Navigator.of(context).pop();
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _serverErrors = {
          for (final k in e.fieldErrors.keys)
            _fieldMap[k] ?? k: l.errorFieldInvalid,
        };
      });
      AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = Validators(l);
    String? required(String? s) =>
        (s == null || s.trim().isEmpty) ? l.addrRequired : null;

    Widget gap() => const SizedBox(height: AppSpacing.sm);

    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(widget.existing == null ? l.addrAdd : l.addrEdit),
          gap(),
          AppTextField(
            label: l.addrRecipient,
            controller: _recipient,
            errorText: _serverErrors['recipient'],
            enabled: !_saving,
            validator: required,
            textCapitalization: TextCapitalization.words,
          ),
          gap(),
          AppTextField(
            label: l.addrPhone,
            controller: _phone,
            errorText: _serverErrors['phone'],
            enabled: !_saving,
            keyboardType: TextInputType.phone,
            validator: v.phoneRequired,
          ),
          gap(),
          AppTextField(
            label: l.addrProvince,
            controller: _province,
            errorText: _serverErrors['province'],
            enabled: !_saving,
            validator: required,
          ),
          gap(),
          AppTextField(
            label: l.addrDistrict,
            controller: _district,
            errorText: _serverErrors['district'],
            enabled: !_saving,
            validator: required,
          ),
          gap(),
          AppTextField(
            label: l.addrWard,
            controller: _ward,
            errorText: _serverErrors['ward'],
            enabled: !_saving,
            validator: required,
          ),
          gap(),
          AppTextField(
            label: l.addrDetail,
            controller: _detail,
            errorText: _serverErrors['detail'],
            enabled: !_saving,
            validator: required,
          ),
          if (!(widget.existing?.isDefault ?? false))
            CheckboxListTile(
              value: _makeDefault,
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _makeDefault = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(l.addrSetDefault, style: context.text.bodyMedium),
            ),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: l.addrSave, loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
