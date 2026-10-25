import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import '../util/photo_picker.dart';
import 'app_sheet.dart';

/// Hỏi người dùng lấy ảnh từ máy ảnh hay thư viện (chọn được nhiều ảnh).
/// `null` nếu đóng sheet.
Future<PhotoSource?> showPhotoSourceSheet(
  BuildContext context, {
  bool multiple = true,
}) {
  return showAppSheet<PhotoSource>(
    context,
    builder: (sheetContext) {
      final l = sheetContext.l10n;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(l.photoSourceTitle),
          const SizedBox(height: AppSpacing.sm),
          _SourceTile(
            icon: Icons.photo_camera_outlined,
            title: l.photoSourceCamera,
            subtitle: l.photoSourceCameraHint,
            onTap: () => Navigator.of(sheetContext).pop(PhotoSource.camera),
          ),
          const SizedBox(height: AppSpacing.xs),
          _SourceTile(
            icon: Icons.photo_library_outlined,
            title: l.photoSourceGallery,
            subtitle: multiple
                ? l.photoSourceGalleryHint
                : l.photoSourceGalleryHintSingle,
            onTap: () => Navigator.of(sheetContext).pop(PhotoSource.gallery),
          ),
        ],
      );
    },
  );
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: colors.divider),
          ),
          child: Row(
            children: [
              Icon(icon, color: colors.primary, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(subtitle, style: context.text.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
