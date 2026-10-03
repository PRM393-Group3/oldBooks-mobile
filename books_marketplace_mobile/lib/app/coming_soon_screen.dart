import 'package:flutter/material.dart';

import '../core/theme/theme_context.dart';
import '../core/widgets/app_page.dart';
import '../core/widgets/app_state_views.dart';

/// Chỗ giữ cho tab chưa có màn hình thật (Đấu giá, Ví); được thay dần theo
/// từng lát trong docs/redesign-oldbook-v2.md.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppPage(
      title: title,
      scrollable: false,
      child: AppEmptyView(
        icon: icon,
        title: l.comingSoonTitle,
        message: l.comingSoonBody,
      ),
    );
  }
}
