import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import 'app_button.dart';

/// Hộp thoại xác nhận. Trả `true` khi người dùng đồng ý.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final l = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        AppButton(
          label: l.cancel,
          variant: AppButtonVariant.text,
          expanded: false,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
        AppButton(
          label: confirmLabel,
          variant: destructive
              ? AppButtonVariant.danger
              : AppButtonVariant.primary,
          expanded: false,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}
