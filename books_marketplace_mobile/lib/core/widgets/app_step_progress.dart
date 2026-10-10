import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Thanh tiến trình nhiều bước (wizard): các đoạn tô màu tới bước hiện tại.
class AppStepProgress extends StatelessWidget {
  const AppStepProgress({
    super.key,
    required this.current,
    required this.labels,
  });

  /// Bước hiện tại, tính từ 0.
  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l = context.l10n;
    return Semantics(
      label:
          '${l.wizardStepOf(current + 1, labels.length)}: ${labels[current]}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (var i = 0; i < labels.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.xxs),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= current
                            ? colors.primary
                            : colors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${l.wizardStepOf(current + 1, labels.length)} · ${labels[current]}',
              style: context.text.labelMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
