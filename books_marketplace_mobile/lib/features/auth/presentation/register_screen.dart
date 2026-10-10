import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/api_error_l10n.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/auth_controller.dart';
import '../data/auth_repository.dart';
import 'auth_header.dart';
import 'otp_field.dart';
import 'password_rules.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _acceptTerms = false;
  bool _termsError = false;
  Map<String, String> _serverErrors = const {};

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _otp.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    final formOk = _formKey.currentState!.validate();
    if (!_acceptTerms) setState(() => _termsError = true);
    if (!formOk || !_acceptTerms) return;
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
            acceptTerms: _acceptTerms,
            email: _email.text.trim(),
          );
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _serverErrors = _fieldErrors(e, l));
      AppSnackbar.apiError(context, e);
      // Có người vừa đăng ký số này trước: về đăng nhập.
      if (e.code == ApiErrorCode.phoneTaken) context.go('/login');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Email trùng báo ngay dưới ô email kèm gợi ý đăng nhập.
  Map<String, String> _fieldErrors(ApiError e, AppLocalizations l) => {
    ...e.localizedFieldErrors(l),
    if (e.code == ApiErrorCode.emailTaken) 'email': l.errEmailTakenLogin,
  };

  /// Luôn build lại để [OtpField] biết SĐT/email đã đổi so với lúc gửi mã.
  void _onChanged(String field) {
    setState(() {
      if (_serverErrors.containsKey(field)) {
        _serverErrors = {..._serverErrors}..remove(field);
      }
    });
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
                onChanged: (_) => _onChanged('phone'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.emailLabel,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                helperText: l.emailOtpHelper,
                validator: v.email,
                errorText: _serverErrors['email'],
                enabled: !_loading,
                maxLength: Validators.emailMax,
                prefixIcon: Icons.mail_outline,
                onChanged: (_) => _onChanged('email'),
              ),
              const SizedBox(height: AppSpacing.md),
              OtpField(
                controller: _otp,
                enabled: !_loading,
                errorText: _serverErrors['otp'],
                target: () =>
                    '${_phone.text.trim()}|${_email.text.trim().toLowerCase()}',
                canSend: () =>
                    v.phoneRequired(_phone.text) == null &&
                    v.email(_email.text) == null,
                handleError: (e) {
                  final errors = _fieldErrors(e, l);
                  if (!errors.containsKey('email') &&
                      !errors.containsKey('phone')) {
                    return false;
                  }
                  setState(() => _serverErrors = errors);
                  return true;
                },
                onSend: () async {
                  final sent = await ref
                      .read(authControllerProvider.notifier)
                      .sendOtp(
                        _phone.text.trim(),
                        OtpPurpose.register,
                        email: _email.text.trim(),
                      );
                  if (context.mounted) {
                    final sentTo = sent.sentTo;
                    AppSnackbar.show(
                      context,
                      sentTo != null
                          ? l.otpSentToEmail(sentTo)
                          : l.otpSentTo(_phone.text.trim()),
                      type: AppSnackbarType.success,
                    );
                  }
                  return sent;
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
              PasswordRules(controller: _password),
              const SizedBox(height: AppSpacing.md),
              _TermsCheckbox(
                value: _acceptTerms,
                showError: _termsError && !_acceptTerms,
                enabled: !_loading,
                onChanged: (v) => setState(() {
                  _acceptTerms = v;
                  _termsError = false;
                }),
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

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.value,
    required this.showError,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool showError;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: value,
          onChanged: enabled ? (v) => onChanged(v ?? false) : null,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l.termsLabel, style: context.text.bodySmall),
        ),
        if (showError)
          Text(
            l.validationTermsRequired,
            style: context.text.bodySmall?.copyWith(color: colors.error),
          ),
      ],
    );
  }
}
