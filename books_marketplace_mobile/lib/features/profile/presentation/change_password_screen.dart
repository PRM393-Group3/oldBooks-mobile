import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/api_error_l10n.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/profile_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  /// Số lần sai mật khẩu hiện tại liên tiếp trước khi khóa tạm thời. Backend
  /// chưa giới hạn tần suất nên client tự hãm.
  static const _maxWrongAttempts = 3;
  static const _lockSeconds = 30;

  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  bool _saving = false;
  int _wrongAttempts = 0;
  int _lockRemaining = 0;
  Timer? _lockTimer;
  Map<String, String> _serverErrors = const {};

  @override
  void dispose() {
    _lockTimer?.cancel();
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _clearError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors = {..._serverErrors}..remove(field));
    }
  }

  void _startLock() {
    setState(() => _lockRemaining = _lockSeconds);
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _lockRemaining--);
      if (_lockRemaining <= 0) {
        timer.cancel();
        _wrongAttempts = 0;
      }
    });
  }

  Future<void> _submit() async {
    if (_saving || _lockRemaining > 0 || !_formKey.currentState!.validate()) {
      return;
    }
    final l = context.l10n;
    setState(() {
      _saving = true;
      _serverErrors = const {};
    });
    try {
      await ref
          .read(profileRepositoryProvider)
          .changePassword(
            currentPassword: _current.text,
            newPassword: _new.text,
          );
      if (!mounted) return;
      AppSnackbar.success(context, l.passwordChanged);
      context.pop();
    } on ApiError catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case ApiErrorCode.currentPasswordIncorrect:
          setState(() => _serverErrors = {'currentPassword': e.localized(l)});
          if (++_wrongAttempts >= _maxWrongAttempts) _startLock();
        case ApiErrorCode.passwordUnchanged:
          setState(() => _serverErrors = {'newPassword': e.localized(l)});
        default:
          setState(() => _serverErrors = e.localizedFieldErrors(l));
          AppSnackbar.apiError(context, e);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = Validators(l);
    final locked = _lockRemaining > 0;

    return AppPage(
      title: l.changePassword,
      bottom: AppButton(
        label: locked ? l.changePasswordLocked(_lockRemaining) : l.save,
        loading: _saving,
        onPressed: locked ? null : _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: l.currentPasswordLabel,
              controller: _current,
              isPassword: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.password],
              validator: v.passwordRequired,
              errorText: _serverErrors['currentPassword'],
              enabled: !_saving,
              prefixIcon: Icons.lock_outline,
              onChanged: (_) => _clearError('currentPassword'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.newPasswordLabel,
              controller: _new,
              isPassword: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              helperText: l.passwordRuleHelper,
              validator: v.newPasswordDifferentFrom(() => _current.text),
              errorText: _serverErrors['newPassword'],
              enabled: !_saving,
              prefixIcon: Icons.lock_reset,
              onChanged: (_) => _clearError('newPassword'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.confirmPasswordLabel,
              controller: _confirm,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: v.matches(() => _new.text),
              enabled: !_saving,
              prefixIcon: Icons.lock_reset,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l.passwordChangedOtherDevices,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
