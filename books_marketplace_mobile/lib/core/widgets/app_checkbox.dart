import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Ô chọn bo 6, viền 2. [value] `null` là chọn một phần (dấu gạch ngang).
/// Vùng chạm 44x44; [onChanged] `null` làm ô mờ đi và không bấm được.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool? value;
  final VoidCallback? onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onChanged != null;
    final filled = value != false;
    final Color fill = !enabled
        ? c.disabledBackground
        : filled
        ? c.primary
        : c.surface;
    final Color border = !enabled
        ? c.disabledBackground
        : filled
        ? c.primary
        : c.border;

    return Semantics(
      checked: value == true,
      mixed: value == null,
      enabled: enabled,
      label: semanticLabel,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onChanged,
        radius: 24,
        child: SizedBox(
          width: AppSizes.minTouchTarget - 4,
          height: AppSizes.minTouchTarget - 4,
          child: Center(
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: AppRadius.xsAll,
                border: Border.all(color: border, width: 2),
              ),
              child: filled && enabled
                  ? Icon(
                      value == null ? Icons.remove : Icons.check,
                      size: 16,
                      color: c.onPrimary,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
