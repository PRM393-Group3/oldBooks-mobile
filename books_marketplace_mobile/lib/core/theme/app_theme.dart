import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Dựng [ThemeData] từ [AppColors]. Toàn bộ kiểu dáng của widget Material nằm
/// ở đây để các màn hình không phải tự chỉnh từng widget.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryContainer,
      onPrimaryContainer: c.onPrimaryContainer,
      secondary: c.primary,
      onSecondary: c.onPrimary,
      secondaryContainer: c.primaryContainer,
      onSecondaryContainer: c.onPrimaryContainer,
      error: c.error,
      onError: c.onPrimary,
      errorContainer: c.errorContainer,
      onErrorContainer: c.onErrorContainer,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerHighest: c.surfaceMuted,
      outline: c.border,
      outlineVariant: c.divider,
    );

    final textTheme = AppTypography.textTheme(c);

    OutlineInputBorder inputBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    // Nút dạng viên thuốc.
    const buttonShape = StadiumBorder();
    const buttonSize = Size(64, AppSizes.buttonHeight);
    const buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.lg);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: c.divider, space: 1, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(color: c.primary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.textMuted),
        helperStyle: textTheme.labelSmall?.copyWith(color: c.textSecondary),
        errorStyle: textTheme.bodySmall?.copyWith(color: c.error),
        errorMaxLines: 3,
        helperMaxLines: 3,
        border: inputBorder(c.border),
        enabledBorder: inputBorder(c.border),
        focusedBorder: inputBorder(c.primary, width: 2),
        errorBorder: inputBorder(c.error),
        focusedErrorBorder: inputBorder(c.error, width: 2),
        disabledBorder: inputBorder(c.divider),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: AppTypography.button,
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.disabledBackground,
          disabledForegroundColor: c.textMuted,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: AppTypography.button,
          foregroundColor: c.primary,
          side: BorderSide(color: c.primary),
          disabledForegroundColor: c.textMuted,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: AppTypography.button,
          foregroundColor: c.primary,
          disabledForegroundColor: c.textMuted,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: buttonSize,
          textStyle: AppTypography.button,
          foregroundColor: c.textSecondary,
          selectedForegroundColor: c.onPrimaryContainer,
          selectedBackgroundColor: c.primaryContainer,
          shape: const StadiumBorder(),
          side: BorderSide(color: c.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        // Nền do AppBottomNav vẽ (thanh nổi bo tròn).
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.primaryContainer,
        indicatorShape: const StadiumBorder(),
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? c.onPrimaryContainer : c.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? c.onPrimaryContainer : c.textSecondary,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.textPrimary,
        contentTextStyle: textTheme.bodySmall?.copyWith(color: c.surface),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: c.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: c.border),
        backgroundColor: c.surface,
        selectedColor: c.primaryContainer,
        labelStyle: textTheme.labelMedium?.copyWith(color: c.textPrimary),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: c.onPrimaryContainer,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        minTileHeight: AppSizes.minTouchTarget + 8,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    );
  }
}
