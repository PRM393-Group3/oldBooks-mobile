import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Thanh chọn một trong vài mục: nền `surfaceMuted`, mục đang chọn là ô trắng.
class AppSegmented extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: AppRadius.mdAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == selected,
                  child: Material(
                    color: i == selected ? c.surface : Colors.transparent,
                    borderRadius: AppRadius.smAll,
                    child: InkWell(
                      onTap: () => onSelected(i),
                      borderRadius: AppRadius.smAll,
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            labels[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelMedium?.copyWith(
                              fontWeight: i == selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: i == selected
                                  ? c.textPrimary
                                  : c.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
