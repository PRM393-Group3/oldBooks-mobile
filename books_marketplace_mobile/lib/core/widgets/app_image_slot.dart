import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

enum AppImageSlotStatus { empty, uploading, done, failed }

/// Ô ảnh có nhãn: trống, đang tải, xong, hoặc lỗi kèm thử lại.
class AppImageSlot extends StatelessWidget {
  const AppImageSlot({
    super.key,
    required this.label,
    required this.status,
    required this.onTap,
    this.bytes,
    this.url,
    this.onRemove,
    this.onRetry,
    this.required = false,
  });

  final String label;
  final AppImageSlotStatus status;
  final Uint8List? bytes;
  final String? url;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onRetry;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;

    final Widget content;
    if (bytes != null) {
      content = Image.memory(bytes!, fit: BoxFit.cover);
    } else if (url != null) {
      content = Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Icon(Icons.broken_image_outlined, color: colors.textMuted),
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, color: colors.primary, size: 28),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            required ? l.photosRequired : l.addPhoto,
            style: context.text.labelSmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      );
    }

    final semantic = switch (status) {
      AppImageSlotStatus.empty => '$label, ${l.photoSlotEmpty}',
      AppImageSlotStatus.uploading => '$label, ${l.photoUploading}',
      AppImageSlotStatus.failed => '$label, ${l.photoFailed}',
      AppImageSlotStatus.done => label,
    };

    return Semantics(
      label: semantic,
      button: true,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Material(
          color: colors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgAll,
            side: BorderSide(
              color: status == AppImageSlotStatus.failed
                  ? colors.error
                  : colors.border,
              width: status == AppImageSlotStatus.empty ? 1 : 2,
            ),
          ),
          child: InkWell(
            onTap: status == AppImageSlotStatus.uploading ? null : onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                content,
                if (status == AppImageSlotStatus.uploading)
                  ColoredBox(
                    color: Colors.black38,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                if (status == AppImageSlotStatus.failed)
                  ColoredBox(
                    color: colors.errorContainer.withValues(alpha: 0.9),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: Text(l.photoRetry),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    color: Colors.black54,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (onRemove != null &&
                    status != AppImageSlotStatus.empty &&
                    status != AppImageSlotStatus.uploading)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton.filled(
                      tooltip: l.removePhoto,
                      onPressed: onRemove,
                      icon: const Icon(Icons.close, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
