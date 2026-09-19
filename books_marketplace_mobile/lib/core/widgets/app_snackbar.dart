import 'package:flutter/material.dart';

import '../l10n/api_error_l10n.dart';
import '../network/api_error.dart';
import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

enum AppSnackbarType { info, success, error }

/// Thông báo nổi ngắn. Màu luôn đi kèm biểu tượng, không chỉ dựa vào màu.
abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackbarType type = AppSnackbarType.info,
    String? detail,
  }) {
    final colors = context.colors;
    final (IconData icon, Color background, Color foreground) = switch (type) {
      AppSnackbarType.success => (
        Icons.check_circle_outline,
        colors.successContainer,
        colors.onSuccessContainer,
      ),
      AppSnackbarType.error => (
        Icons.error_outline,
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      AppSnackbarType.info => (
        Icons.info_outline,
        colors.infoContainer,
        colors.onInfoContainer,
      ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          duration: const Duration(seconds: 4),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: context.text.bodySmall?.copyWith(
                        color: foreground,
                      ),
                    ),
                    if (detail != null)
                      SelectableText(
                        detail,
                        style: context.text.labelSmall?.copyWith(
                          color: foreground,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: AppSnackbarType.success);

  /// Hiện lỗi từ API. Mất phiên thì bỏ qua vì router sẽ đưa về đăng nhập.
  static void apiError(BuildContext context, Object error) {
    if (error is ApiError) {
      if (error.isSessionLost) return;
      final l = context.l10n;
      show(
        context,
        error.localized(l),
        type: AppSnackbarType.error,
        detail: error.supportCode(l),
      );
      return;
    }
    show(context, context.l10n.errorUnknown, type: AppSnackbarType.error);
  }
}
