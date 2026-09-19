import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Avatar tròn: ảnh mạng, ảnh cục bộ hoặc chữ cái đầu tên khi chưa có ảnh.
///
/// Truyền [onTap] để avatar bấm được; [showEditBadge] thêm biểu tượng máy ảnh.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.localImage,
    this.size = AppSizes.avatarMedium,
    this.onTap,
    this.showEditBadge = false,
    this.semanticLabel,
  });

  final String name;
  final String? imageUrl;

  /// Ảnh vừa chọn, chưa tải lên; được ưu tiên hơn [imageUrl].
  final ImageProvider? localImage;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final String? semanticLabel;

  /// Chữ cái đầu của từ đầu và từ cuối, ví dụ "Nguyen Van A" → "NA".
  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.first;
    if (parts.length == 1) return first.toUpperCase();
    return (first + parts.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final fallback = Center(
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: colors.onPrimaryContainer,
        ),
      ),
    );

    final Widget content;
    if (localImage != null) {
      content = Image(
        image: localImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (imageUrl != null) {
      content = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback,
      );
    } else {
      content = fallback;
    }

    // Viền gradient thương hiệu quanh ảnh, cách ảnh một vòng trắng.
    final ring = size >= AppSizes.avatarLarge ? 4.0 : 3.0;
    final avatar = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ring),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: colors.brandGradient,
      ),
      child: Container(
        padding: EdgeInsets.all(ring - 1),
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Container(color: colors.primaryContainer, child: content),
        ),
      ),
    );

    final withBadge = showEditBadge
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 18,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ],
          )
        : avatar;

    return Semantics(
      label: semanticLabel ?? name,
      image: true,
      button: onTap != null,
      excludeSemantics: true,
      child: onTap == null
          ? withBadge
          : InkResponse(
              onTap: onTap,
              radius: size / 2 + AppSpacing.xs,
              child: withBadge,
            ),
    );
  }
}
