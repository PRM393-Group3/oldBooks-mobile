import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/api_error_l10n.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/profile_controller.dart';

/// Xóa tài khoản: cảnh báo, nhập mật khẩu, xác nhận hai bước. Không hoàn tác.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  bool _busy = false;
  String? _passwordError;

  /// Lý do server chặn xóa (`details[].message`), hiện từng dòng.
  List<String> _blockedReasons = const [];

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.deleteAccountConfirmTitle,
      message: l.deleteAccountConfirmMessage,
      confirmLabel: l.deleteAccountSubmit,
      destructive: true,
    );
    if (!ok || !mounted) return;

    setState(() {
      _busy = true;
      _passwordError = null;
      _blockedReasons = const [];
    });
    try {
      // Thành công: token bị xóa, router tự đưa về màn đăng nhập.
      await ref
          .read(profileControllerProvider.notifier)
          .deleteAccount(password: _password.text);
    } on ApiError catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case ApiErrorCode.invalidCredentials:
          setState(() => _passwordError = e.localized(l));
        case ApiErrorCode.accountDeletionBlocked:
          setState(() => _blockedReasons = e.detailMessages);
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
    final v = Validators(l);

    return AppPage(
      title: l.deleteAccountTitle,
      bottom: AppButton(
        label: l.deleteAccountSubmit,
        loading: _busy,
        variant: AppButtonVariant.danger,
        onPressed: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colors.onErrorContainer,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l.deleteAccountWarning,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.deleteAccountPasswordLabel,
              controller: _password,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: v.passwordRequired,
              errorText: _passwordError,
              enabled: !_busy,
              prefixIcon: Icons.lock_outline,
              onChanged: (_) {
                if (_passwordError != null) {
                  setState(() => _passwordError = null);
                }
              },
              onSubmitted: (_) => _submit(),
            ),
            if (_blockedReasons.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l.deleteAccountBlockedHeader,
                style: context.text.labelLarge?.copyWith(color: colors.error),
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final reason in _blockedReasons)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, size: 18, color: colors.error),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(reason, style: context.text.bodyMedium),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
