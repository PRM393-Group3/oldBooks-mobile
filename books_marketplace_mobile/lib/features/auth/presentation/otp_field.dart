import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import 'countdown_text.dart';

/// Ô nhập OTP kèm nút "Gửi mã" có đếm ngược chờ gửi lại và đếm ngược hạn OTP.
///
/// [onSend] gọi API gửi OTP và trả về `expiresInSeconds` của server (không viết
/// cứng vì Super Admin chỉnh được); [validatePhone] cho biết số điện thoại đã hợp lệ
/// chưa (không hợp lệ thì không gửi).
class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.validatePhone,
    this.enabled = true,
    this.errorText,
    this.handleError,
    this.cooldown = const Duration(seconds: 60),
  });

  final TextEditingController controller;
  final Future<int> Function() onSend;
  final bool Function() validatePhone;
  final bool enabled;
  final String? errorText;

  /// Cho màn hình tự xử lý một số lỗi gửi OTP (trả `true` nếu đã xử lý, khi đó
  /// không hiện snackbar mặc định).
  final bool Function(ApiError error)? handleError;
  final Duration cooldown;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  Timer? _timer;
  int _left = 0;
  int _expiresLeft = 0;
  bool _sent = false;
  bool _sending = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        if (_left > 0) _left--;
        if (_expiresLeft > 0) _expiresLeft--;
      });
      if (_left <= 0 && _expiresLeft <= 0) t.cancel();
    });
  }

  Future<void> _send() async {
    if (_sending || _left > 0 || !widget.validatePhone()) return;
    setState(() => _sending = true);
    try {
      final expiresIn = await widget.onSend();
      if (!mounted) return;
      setState(() {
        _sent = true;
        _left = widget.cooldown.inSeconds;
        _expiresLeft = expiresIn;
      });
      _startTimer();
    } on ApiError catch (e) {
      if (!mounted) return;
      // Quá hạn mức OTP: khóa nút gửi theo đúng thời gian server yêu cầu.
      final wait = e.retryAfter;
      if (e.code == ApiErrorCode.rateLimited && wait != null) {
        setState(() => _left = wait.inSeconds);
        _startTimer();
      }
      if (widget.handleError?.call(e) != true) AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = Validators(l);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextField(
            label: l.otpLabel,
            controller: widget.controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.oneTimeCode],
            validator: v.otp,
            errorText: widget.errorText,
            helperText: _expiresLeft > 0
                ? l.otpExpiresIn(formatMmSs(_expiresLeft))
                : (_sent ? l.otpExpired : null),
            enabled: widget.enabled,
            maxLength: 6,
            prefixIcon: Icons.sms_outlined,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: OutlinedButton(
            onPressed: widget.enabled && !_sending && _left == 0 ? _send : null,
            child: Text(_left > 0 ? l.otpResendIn(_left) : l.otpSend),
          ),
        ),
      ],
    );
  }
}
