import 'package:flutter/material.dart';

import '../l10n/api_error_l10n.dart';
import '../network/api_error.dart';
import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import 'app_button.dart';

/// Trạng thái đang tải toàn màn hình.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: context.l10n.loading,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

/// Trạng thái trống hoặc chưa có nội dung.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: colors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                style: context.text.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lỗi toàn màn hình kèm nút thử lại. Lỗi hệ thống hiện thêm mã hỗ trợ.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final apiError = error is ApiError ? error as ApiError : null;

    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: colors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              apiError?.localized(l) ?? l.errorUnknown,
              style: context.text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (apiError?.supportCode(l) case final code?) ...[
              const SizedBox(height: AppSpacing.xs),
              SelectableText(
                code,
                style: context.text.labelSmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l.retry,
              icon: Icons.refresh,
              expanded: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
