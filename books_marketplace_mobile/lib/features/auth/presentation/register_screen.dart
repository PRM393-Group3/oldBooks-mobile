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
import '../application/auth_controller.dart';
import 'auth_header.dart';
import 'otp_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  Map<String, String> _serverErrors = const {};

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _otp.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    final l = context.l10n;
    setState(() {
      _loading = true;
      _serverErrors = const {};
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            phone: _phone.text.trim(),
            otp: _otp.text.trim(),
            password: _password.text,
            fullName: _fullName.text.trim(),
          );
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _serverErrors = e.localizedFieldErrors(l));
      AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clearError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors = {..._serverErrors}..remove(field));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = Validators(l);

    return AppPage(
      bottom: AppButton(
        label: l.registerButton,
        loading: _loading,
        onPressed: _submit,
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(title: l.registerTitle, subtitle: l.registerSubtitle),
              AppTextField(
                label: l.fullNameLabel,
                controller: _fullName,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                validator: v.fullName,
                errorText: _serverErrors['fullName'],
                enabled: !_loading,
                maxLength: Validators.fullNameMax,
                prefixIcon: Icons.person_outline,
                onChanged: (_) => _clearError('fullName'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.phoneLabel,
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                validator: v.phoneRequired,
                errorText: _serverErrors['phone'],
                enabled: !_loading,
                prefixIcon: Icons.phone_outlined,
                onChanged: (_) => _clearError('phone'),
              ),
              const SizedBox(height: AppSpacing.md),
              OtpField(
                controller: _otp,
                enabled: !_loading,
                errorText: _serverErrors['otp'],
                validatePhone: () => v.phoneRequired(_phone.text) == null,
                onSend: () async {
                  await ref
                      .read(authControllerProvider.notifier)
                      .sendOtp(_phone.text.trim());
                  if (context.mounted) {
                    AppSnackbar.show(
                      context,
                      l.otpSentTo(_phone.text.trim()),
                      type: AppSnackbarType.success,
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.passwordLabel,
                controller: _password,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                helperText: l.passwordHelperLetterDigit,
                validator: v.registerPassword,
                errorText: _serverErrors['password'],
                enabled: !_loading,
                prefixIcon: Icons.lock_outline,
                onChanged: (_) => _clearError('password'),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l.haveAccountPrompt,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: _loading ? null : () => context.go('/login'),
                    child: Text(l.loginLink),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
