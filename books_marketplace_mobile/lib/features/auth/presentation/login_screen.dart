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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  Map<String, String> _serverErrors = const {};

  @override
  void dispose() {
    _email.dispose();
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
          .login(email: _email.text.trim(), password: _password.text);
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
        label: l.loginButton,
        loading: _loading,
        onPressed: _submit,
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(title: l.loginTitle, subtitle: l.loginSubtitle),
              AppTextField(
                label: l.emailLabel,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                validator: v.email,
                errorText: _serverErrors['email'],
                enabled: !_loading,
                prefixIcon: Icons.mail_outline,
                onChanged: (_) => _clearError('email'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.passwordLabel,
                controller: _password,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: v.passwordRequired,
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
                    l.noAccountPrompt,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: _loading ? null : () => context.go('/register'),
                    child: Text(l.registerLink),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors = {..._serverErrors}..remove(field));
    }
  }
}
