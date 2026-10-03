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
import '../../auth/presentation/otp_field.dart';
import '../application/profile_controller.dart';

/// Đổi số điện thoại: OTP gửi tới SỐ MỚI, rồi xác nhận bằng OTP đó.
class ChangePhoneScreen extends ConsumerStatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  ConsumerState<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends ConsumerState<ChangePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _otp = TextEditingController();

  bool _saving = false;
  Map<String, String> _serverErrors = const {};

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _clearError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors = {..._serverErrors}..remove(field));
    }
  }

  /// So sánh theo E.164 để `0987654321` và `+84987654321` là cùng một số.
  static String _e164(String? phone) {
    final p = (phone ?? '').trim();
    return p.startsWith('0') ? '+84${p.substring(1)}' : p;
  }

  String? _validatePhone(String? value, Validators v) {
    final base = v.phoneRequired(value);
    if (base != null) return base;
    final current = ref.read(profileControllerProvider).value?.phoneNumber;
    if (current != null && _e164(value) == _e164(current)) {
      return context.l10n.validationPhoneSame;
    }
    return null;
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final l = context.l10n;
    setState(() {
      _saving = true;
      _serverErrors = const {};
    });
    try {
      await ref
          .read(profileControllerProvider.notifier)
          .changePhone(phone: _phone.text.trim(), otp: _otp.text.trim());
      if (!mounted) return;
      AppSnackbar.success(context, l.changePhoneDone);
      context.pop();
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _serverErrors = e.code == ApiErrorCode.phoneTaken
            ? {'phone': l.errPhoneTakenOther}
            : e.localizedFieldErrors(l);
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

    return AppPage(
      title: l.changePhoneTitle,
      bottom: AppButton(
        label: l.changePhoneSubmit,
        loading: _saving,
        onPressed: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.changePhoneIntro,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.newPhoneLabel,
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: (s) => _validatePhone(s, v),
              errorText: _serverErrors['phone'],
              enabled: !_saving,
              prefixIcon: Icons.phone_outlined,
              onChanged: (_) => _clearError('phone'),
            ),
            const SizedBox(height: AppSpacing.md),
            OtpField(
              controller: _otp,
              enabled: !_saving,
              errorText: _serverErrors['otp'],
              validatePhone: () => _validatePhone(_phone.text, v) == null,
              handleError: (e) {
                if (e.code != ApiErrorCode.phoneTaken &&
                    !e.fieldErrors.containsKey('phone')) {
                  return false;
                }
                setState(
                  () => _serverErrors = {
                    'phone': e.code == ApiErrorCode.phoneTaken
                        ? l.errPhoneTakenOther
                        : l.errorFieldInvalid,
                  },
                );
                return true;
              },
              onSend: () async {
                final expiresIn = await ref
                    .read(profileControllerProvider.notifier)
                    .sendPhoneOtp(_phone.text.trim());
                if (context.mounted) {
                  AppSnackbar.show(
                    context,
                    l.otpSentTo(_phone.text.trim()),
                    type: AppSnackbarType.success,
                  );
                }
                return expiresIn;
              },
            ),
          ],
        ),
      ),
    );
  }
}
