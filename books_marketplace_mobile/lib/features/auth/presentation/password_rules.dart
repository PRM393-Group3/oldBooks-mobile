import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/validation/validators.dart';

/// Danh sách yêu cầu mật khẩu, cập nhật theo từng ký tự gõ vào [controller].
class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final v = value.text;
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xxs,
            children: [
              _Rule(l.pwRuleLength, v.length >= Validators.passwordMin),
              _Rule(l.pwRuleLetter, RegExp(r'[A-Za-z]').hasMatch(v)),
              _Rule(l.pwRuleDigit, RegExp(r'\d').hasMatch(v)),
            ],
          ),
        );
      },
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule(this.label, this.ok);

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = ok ? colors.success : colors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(label, style: context.text.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
