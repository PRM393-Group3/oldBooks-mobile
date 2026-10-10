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
import '../data/auth_repository.dart';
import 'auth_header.dart';
import 'otp_field.dart';
import 'password_rules.dart';

/// Quên mật khẩu: xác thực bằng OTP rồi đặt mật khẩu mới (FR-AUTH-05).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  Map<String, String> _serverErrors = const {};

  @override
  void dispose() {
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
          .resetPassword(
            phone: _phone.text.trim(),
            otp: _otp.text.trim(),
            newPassword: _password.text,
          );
      if (!mounted) return;
      AppSnackbar.show(context, l.forgotDone, type: AppSnackbarType.success);
      context.go('/login');
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _serverErrors = e.localizedFieldErrors(l));
      AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = Validators(l);

    return AppPage(
      bottom: AppButton(
        label: l.forgotSubmit,
        loading: _loading,
        onPressed: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(title: l.forgotTitle, subtitle: l.forgotSubtitle),
            Text(
              l.forgotOtpNotice,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.phoneLabel,
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: v.phoneRequired,
              errorText: _serverErrors['phone'],
              enabled: !_loading,
              prefixIcon: Icons.phone_outlined,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            OtpField(
              controller: _otp,
              enabled: !_loading,
              errorText: _serverErrors['otp'],
              target: () => _phone.text.trim(),
              canSend: () => v.phoneRequired(_phone.text) == null,
              onSend: () async {
                final sent = await ref
                    .read(authControllerProvider.notifier)
                    .sendOtp(_phone.text.trim(), OtpPurpose.resetPassword);
                // OTP gửi tới email của tài khoản. Không có `sentTo` thì không
                // khẳng định đã gửi: số chưa đăng ký vẫn nhận 200 để không lộ
                // số nào có tài khoản.
                if (context.mounted) {
                  final sentTo = sent.sentTo;
                  AppSnackbar.show(
                    context,
                    sentTo != null
                        ? l.otpSentToEmail(sentTo)
                        : l.forgotOtpNotice,
                    type: AppSnackbarType.info,
                  );
                }
                return sent;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.newPasswordLabel,
              controller: _password,
              isPassword: true,
              textInputAction: TextInputAction.done,
              helperText: l.passwordHelperLetterDigit,
              validator: v.registerPassword,
              errorText: _serverErrors['newPassword'],
              enabled: !_loading,
              prefixIcon: Icons.lock_outline,
              onSubmitted: (_) => _submit(),
            ),
            PasswordRules(controller: _password),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: TextButton(
                onPressed: _loading ? null : () => context.go('/login'),
                child: Text(l.backToLogin, style: context.text.labelLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
