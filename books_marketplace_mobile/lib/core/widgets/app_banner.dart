import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import 'app_tag.dart';

/// Dải thông báo nền nhạt có icon. Màu theo [AppTagTone] để đồng bộ với tag.
class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
    required this.message,
    this.tone = AppTagTone.info,
    this.icon = Icons.info_outline,
    this.bold = false,
    this.liveRegion = false,
  });

  final String message;
  final AppTagTone tone;
  final IconData icon;

  /// `true`: chữ đậm (trạng thái quan trọng như "Bạn bị vượt giá").
  final bool bold;

  /// `true`: đọc ngay khi nội dung đổi (trạng thái đấu giá).
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg) = switch (tone) {
      AppTagTone.neutral => (c.surfaceMuted, c.textSecondary),
      AppTagTone.brand => (c.primaryContainer, c.onPrimaryContainer),
      AppTagTone.accent => (c.accentContainer, c.onAccentContainer),
      AppTagTone.success => (c.successContainer, c.onSuccessContainer),
      AppTagTone.warning => (c.warningContainer, c.onWarningContainer),
      AppTagTone.error => (c.errorContainer, c.onErrorContainer),
      AppTagTone.info => (c.infoContainer, c.onInfoContainer),
      AppTagTone.auction => (c.auctionContainer, c.onAuctionContainer),
    };
    return Semantics(
      liveRegion: liveRegion,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: bg, borderRadius: AppRadius.mdAll),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: context.text.bodySmall?.copyWith(
                    color: fg,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                    fontSize: bold ? 14 : 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
