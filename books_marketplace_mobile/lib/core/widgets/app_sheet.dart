import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Mở bottom sheet chuẩn: bo góc trên, tay kéo, tự nâng lên khi bàn phím mở và
/// cuộn được khi nội dung dài. [builder] trả về nội dung (không cần Padding).
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth + 40),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen + 4,
          0,
          AppSpacing.screen + 4,
          AppSpacing.lg,
        ),
        child: builder(sheetContext),
      ),
    ),
  );
}

/// Tiêu đề serif của sheet.
class AppSheetTitle extends StatelessWidget {
  const AppSheetTitle(this.text, {super.key, this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: center ? TextAlign.center : TextAlign.start,
    style: context.text.titleLarge?.copyWith(fontSize: 22),
  );
}
