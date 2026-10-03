import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Validator dùng chung cho các ô nhập. Quy tắc bám theo backend.
class Validators {
  const Validators(this.l);

  final AppLocalizations l;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^(\+84|0)\d{9,10}$');

  static const passwordMin = 8;
  static const passwordMax = 72;
  static const fullNameMax = 100;

  FormFieldValidator<String> get phoneRequired => (value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.validationPhoneRequired;
    if (!_phone.hasMatch(v)) return l.validationPhoneInvalid;
    return null;
  };

  static final _otp = RegExp(r'^\d{6}$');

  FormFieldValidator<String> get otp => (value) {
    if (!_otp.hasMatch(value?.trim() ?? '')) return l.validationOtpInvalid;
    return null;
  };

  FormFieldValidator<String> get email => (value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.validationEmailRequired;
    if (!_email.hasMatch(v)) return l.validationEmailInvalid;
    return null;
  };

  /// Mật khẩu đăng nhập: chỉ cần không rỗng.
  FormFieldValidator<String> get passwordRequired => (value) {
    if (value == null || value.isEmpty) return l.validationPasswordRequired;
    return null;
  };

  /// Mật khẩu mới: 8 đến 72 ký tự.
  FormFieldValidator<String> get newPassword => (value) {
    final v = value ?? '';
    if (v.isEmpty) return l.validationPasswordRequired;
    if (v.length < passwordMin || v.length > passwordMax) {
      return l.validationPasswordLength;
    }
    return null;
  };

  /// Mật khẩu đăng ký theo BE-SRS: 8 ký tự trở lên, có cả chữ và số.
  FormFieldValidator<String> get registerPassword => (value) {
    final base = newPassword(value);
    if (base != null) return base;
    final v = value!;
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return l.validationPasswordLetterDigit;
    }
    return null;
  };

  /// Mật khẩu mới phải hợp lệ và khác mật khẩu hiện tại.
  FormFieldValidator<String> newPasswordDifferentFrom(
    String Function() current,
  ) => (value) {
    final base = newPassword(value);
    if (base != null) return base;
    if (value == current()) return l.validationPasswordSame;
    return null;
  };

  FormFieldValidator<String> matches(String Function() other) => (value) {
    if (value != other()) return l.validationPasswordMismatch;
    return null;
  };

  FormFieldValidator<String> get fullName => (value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.validationFullNameRequired;
    if (v.length > fullNameMax) return l.validationFullNameTooLong;
    return null;
  };

  /// Số điện thoại không bắt buộc; rỗng nghĩa là xóa số.
  FormFieldValidator<String> get phoneOptional => (value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_phone.hasMatch(v)) return l.validationPhoneInvalid;
    return null;
  };
}
