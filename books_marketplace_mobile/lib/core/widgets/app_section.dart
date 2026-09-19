import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Nhóm các dòng trong một thẻ bo góc, ngăn cách bằng đường kẻ.
class AppSection extends StatelessWidget {
  const AppSection({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              title!,
              style: context.text.labelMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        // Bóng ở DecoratedBox ngoài; Material bên trong (không tô nền bằng
        // DecoratedBox) để ListTile vẽ được hiệu ứng chạm.
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgAll,
            boxShadow: colors.softShadow,
          ),
          child: Material(
            color: colors.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.lgAll,
              side: BorderSide(color: colors.divider),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(indent: AppSpacing.md),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Dòng chỉ đọc: biểu tượng, nhãn nhỏ và giá trị.
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Làm mờ giá trị (ví dụ "Chưa cập nhật").
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          label,
          style: context.text.labelSmall?.copyWith(color: colors.textSecondary),
        ),
        subtitle: Text(
          value,
          style: context.text.bodyMedium?.copyWith(
            color: muted ? colors.textMuted : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Dòng bấm được để đi tới một chức năng.
class AppMenuTile extends StatelessWidget {
  const AppMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Hành động nguy hiểm (đăng xuất, xóa) hiện màu lỗi.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = destructive ? colors.error : colors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: destructive ? colors.error : null),
      title: Text(
        title,
        style: context.text.bodyMedium?.copyWith(color: color),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
      trailing: destructive
          ? null
          : Icon(Icons.chevron_right, color: colors.textMuted),
    );
  }
}

/// Dòng nhãn và giá trị nhỏ gọn, dùng trong khối thông tin chi tiết.
class AppKeyValueRow extends StatelessWidget {
  const AppKeyValueRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: context.text.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 6,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: context.text.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
