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
import '../domain/user_role.dart';
import 'auth_header.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  UserRole _role = UserRole.buyer;
  bool _loading = false;
  Map<String, String> _serverErrors = const {};

  @override
  void dispose() {
    _fullName.dispose();
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
          .register(
            email: _email.text.trim(),
            password: _password.text,
            fullName: _fullName.text.trim(),
            role: _role,
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
                label: l.emailLabel,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
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
                autofillHints: const [AutofillHints.newPassword],
                helperText: l.passwordLengthHelper,
                validator: v.newPassword,
                errorText: _serverErrors['password'],
                enabled: !_loading,
                prefixIcon: Icons.lock_outline,
                onChanged: (_) => _clearError('password'),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l.roleLabel, style: context.text.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              SegmentedButton<UserRole>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: UserRole.buyer,
                    label: Text(l.roleOptionBuyer),
                    icon: const Icon(Icons.shopping_bag_outlined),
                  ),
                  ButtonSegment(
                    value: UserRole.seller,
                    label: Text(l.roleOptionSeller),
                    icon: const Icon(Icons.sell_outlined),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: _loading
                    ? null
                    : (selection) => setState(() => _role = selection.first),
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
