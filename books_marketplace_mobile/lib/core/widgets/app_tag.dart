import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

enum AppTagTone { neutral, brand, success, warning, error, info, auction }

/// Nhãn nhỏ dạng viên thuốc. Nền tảng cho badge trạng thái tin đăng, đơn hàng,
/// phiên đấu giá: mỗi trạng thái chỉ cần ánh xạ sang một [AppTagTone].
class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.tone = AppTagTone.neutral,
    this.icon,
  });

  final String label;
  final AppTagTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg) = switch (tone) {
      AppTagTone.neutral => (c.surfaceMuted, c.textSecondary),
      AppTagTone.brand => (c.primaryContainer, c.onPrimaryContainer),
      AppTagTone.success => (c.successContainer, c.onSuccessContainer),
      AppTagTone.warning => (c.warningContainer, c.onWarningContainer),
      AppTagTone.error => (c.errorContainer, c.onErrorContainer),
      AppTagTone.info => (c.infoContainer, c.onInfoContainer),
      AppTagTone.auction => (c.auctionContainer, c.onAuctionContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Flexible(
            child: Text(
              label,
              style: context.text.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
