import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_logo.dart';

/// Đầu màn hình đăng nhập/đăng ký: biểu tượng thương hiệu, tiêu đề, phụ đề.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const AppLogo.full(size: 40),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          header: true,
          child: Text(title, style: context.text.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: context.text.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
