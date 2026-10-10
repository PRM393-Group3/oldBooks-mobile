import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme_context.dart';

/// Ô nhập chuẩn: nhãn nổi, lỗi dưới ô, nút hiện/ẩn khi là mật khẩu.
///
/// [errorText] dành cho lỗi từ server (ví dụ `details[].field`). Lỗi từ
/// [validator] được ưu tiên hiển thị hơn [errorText].
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassword;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final IconData? prefixIcon;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;

    Widget? suffix;
    if (widget.isPassword) {
      suffix = IconButton(
        tooltip: _obscured ? l.showPassword : l.hidePassword,
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      );
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: widget.isPassword && _obscured,
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      maxLength: widget.maxLength,
      // Mặc định Flutter cắt bớt text ngay trong lúc IME đang ghép ký tự
      // (composing), làm gãy gõ tiếng Việt trên iOS (Telex/VNI) khi có
      // maxLength: mỗi ký tự có dấu bị chặn giữa chừng. Giá trị này đợi IME
      // ghép xong rồi mới cắt.
      maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.isPassword ? null : widget.minLines,
      autocorrect: !widget.isPassword,
      enableSuggestions: !widget.isPassword,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: context.text.bodyMedium?.copyWith(
        color: widget.enabled ? colors.textPrimary : colors.textMuted,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        counterText: '',
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, color: colors.textSecondary),
        suffixIcon: suffix,
        fillColor: widget.enabled ? colors.surface : colors.surfaceMuted,
      ),
    );
  }
}
