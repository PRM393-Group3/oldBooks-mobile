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

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  bool _saving = false;
  Map<String, String> _serverErrors = const {};

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).requireValue;
    _fullName = TextEditingController(text: profile.fullName);
    _phone = TextEditingController(text: profile.phoneNumber ?? '');
    _email = TextEditingController(text: profile.email);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _clearError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors = {..._serverErrors}..remove(field));
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final l = context.l10n;
    setState(() {
      _saving = true;
      _serverErrors = const {};
    });
    try {
      final phone = _phone.text.trim();
      await ref
          .read(profileControllerProvider.notifier)
          .save(
            fullName: _fullName.text.trim(),
            phoneNumber: phone.isEmpty ? null : phone,
          );
      if (!mounted) return;
      AppSnackbar.success(context, l.profileUpdated);
      context.pop();
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _serverErrors = e.localizedFieldErrors(l));
      AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = Validators(l);

    return AppPage(
      title: l.editProfile,
      bottom: AppButton(label: l.save, loading: _saving, onPressed: _save),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: l.fullNameLabel,
              controller: _fullName,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              validator: v.fullName,
              errorText: _serverErrors['fullName'],
              enabled: !_saving,
              maxLength: Validators.fullNameMax,
              prefixIcon: Icons.person_outline,
              onChanged: (_) => _clearError('fullName'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.phoneLabel,
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: v.phoneOptional,
              errorText: _serverErrors['phoneNumber'],
              enabled: !_saving,
              maxLength: 20,
              prefixIcon: Icons.phone_outlined,
              onChanged: (_) => _clearError('phoneNumber'),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.emailLabel,
              controller: _email,
              enabled: false,
              helperText: l.emailReadOnlyHelper,
              prefixIcon: Icons.mail_outline,
            ),
          ],
        ),
      ),
    );
  }
}
