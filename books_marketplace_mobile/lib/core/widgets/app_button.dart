import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

enum AppButtonVariant { primary, secondary, text, danger }

/// Nút chuẩn của ứng dụng. Cao 48, có trạng thái đang xử lý.
///
/// Khi [loading] nút bị khóa và hiện vòng quay thay nội dung, nhưng vẫn giữ
/// nguyên kích thước để bố cục không nhảy.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;

  /// `true`: chiếm hết chiều ngang.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null && !loading;
    final VoidCallback? handler = enabled ? onPressed : null;

    final foreground = switch (variant) {
      AppButtonVariant.primary => colors.onPrimary,
      AppButtonVariant.danger => colors.onPrimary,
      AppButtonVariant.secondary || AppButtonVariant.text => colors.primary,
    };

    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color:
                  variant == AppButtonVariant.primary ||
                      variant == AppButtonVariant.danger
                  ? colors.onPrimary
                  : colors.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: handler,
        child: child,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: handler,
        style: FilledButton.styleFrom(
          backgroundColor: colors.error,
          foregroundColor: foreground,
        ),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: handler,
        child: child,
      ),
      AppButtonVariant.text => TextButton(onPressed: handler, child: child),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
