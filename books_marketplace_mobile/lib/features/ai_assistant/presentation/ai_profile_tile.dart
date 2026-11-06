import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_section.dart';
import '../application/ai_providers.dart';

/// Hàng "Trợ lý AI" trên màn hồ sơ. Ẩn khi admin chưa bật Claude.
class AiProfileTile extends ConsumerWidget {
  const AiProfileTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final status = ref.watch(aiStatusProvider).value;
    if (status == null || !status.claudeAvailable) {
      return const SizedBox.shrink();
    }
    return AppSection(
      children: [
        AppMenuTile(
          icon: Icons.auto_awesome,
          title: l.aiMenuTitle,
          subtitle: l.aiMenuSubtitle,
          onTap: () => context.push('/me/ai'),
        ),
      ],
    );
  }
}
