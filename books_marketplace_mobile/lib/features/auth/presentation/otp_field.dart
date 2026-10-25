import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/validation/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/otp_sent.dart';
import 'countdown_text.dart';

/// Ô nhập OTP kèm nút "Gửi mã" có đếm ngược chờ gửi lại và đếm ngược hạn OTP.
///
/// OTP gửi qua email nên không tự điền từ SMS. [onSend] gọi API gửi OTP và trả
/// về [OtpSent] của server (hạn mã không viết cứng vì Super Admin chỉnh được);
/// [canSend] cho biết thông tin cần để gửi đã hợp lệ chưa (không hợp lệ thì
/// không gửi). [target] trả về giá trị mã gắn với (ví dụ SĐT + email): đổi
/// sau khi đã gửi thì mã cũ không dùng được nữa, ô OTP về trạng thái chưa gửi.
/// Màn hình cha phải build lại khi giá trị đó đổi.
class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.canSend,
    this.target,
    this.enabled = true,
    this.errorText,
    this.handleError,
    this.cooldown = const Duration(seconds: 60),
  });

  final TextEditingController controller;
  final Future<OtpSent> Function() onSend;
  final bool Function() canSend;
  final ValueGetter<String>? target;
  final bool enabled;
  final String? errorText;

  /// Cho màn hình tự xử lý một số lỗi gửi OTP (trả `true` nếu đã xử lý, khi đó
  /// không hiện snackbar mặc định).
  final bool Function(ApiError error)? handleError;

  /// Thời gian chờ gửi lại khi server không trả `resendAfterSeconds`.
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
  String? _sentTo;
  String? _sentTarget;

  @override
  void didUpdateWidget(OtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sent && widget.target?.call() != _sentTarget) _reset();
  }

  /// Sửa thông tin sau khi gửi: phải gửi lại, nên cho bấm gửi ngay.
  void _reset() {
    _timer?.cancel();
    _sent = false;
    _left = 0;
    _expiresLeft = 0;
    _sentTo = null;
    _sentTarget = null;
    // Đang trong build của cha: xóa ô OTP sau khung hình để không gọi
    // setState của ô nhập giữa lúc build.
    final controller = widget.controller;
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.clear());
  }

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
    if (_sending || _left > 0 || !widget.canSend()) return;
    final target = widget.target?.call();
    setState(() => _sending = true);
    try {
      final sent = await widget.onSend();
      if (!mounted) return;
      setState(() {
        _sent = true;
        _sentTo = sent.sentTo;
        _sentTarget = target;
        _left = sent.resendAfterSeconds ?? widget.cooldown.inSeconds;
        _expiresLeft = sent.expiresInSeconds;
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
      if (widget.handleError?.call(e) == true) return;
      // Dịch vụ email lỗi: báo không gửi được, nút gửi vẫn bấm lại được.
      if (e.code == ApiErrorCode.upstreamError) {
        AppSnackbar.show(
          context,
          context.l10n.errOtpSendFailed,
          type: AppSnackbarType.error,
        );
      } else {
        AppSnackbar.apiError(context, e);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = Validators(l);
    final sentTo = _sentTo;
    final field = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextField(
            label: l.otpLabel,
            controller: widget.controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: v.otp,
            errorText: widget.errorText,
            helperText: _expiresLeft > 0
                ? l.otpExpiresIn(formatMmSs(_expiresLeft))
                : (_sent ? l.otpExpired : null),
            enabled: widget.enabled,
            maxLength: 6,
            prefixIcon: Icons.mark_email_unread_outlined,
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
    if (!_sent || sentTo == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        field,
        const SizedBox(height: AppSpacing.xxs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.mail_outline,
              size: 16,
              color: context.colors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Expanded(
              child: Text(
                l.otpSentToEmail(sentTo),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
