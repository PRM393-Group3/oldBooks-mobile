import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Màu ngữ nghĩa của ứng dụng, đăng ký như một [ThemeExtension].
///
/// Truy cập bằng `context.colors`. Để thêm dark mode: khai báo `AppColors.dark`
/// từ một bảng màu tối rồi truyền vào `AppTheme` — không phải sửa widget nào.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.gradientStart,
    required this.gradientEnd,
    required this.heroStart,
    required this.heroEnd,
    required this.shadow,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.error,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.auction,
    required this.auctionContainer,
    required this.onAuctionContainer,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color divider;
  final Color gradientStart;
  final Color gradientEnd;
  final Color heroStart;
  final Color heroEnd;
  final Color shadow;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color error;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color auction;
  final Color auctionContainer;
  final Color onAuctionContainer;

  /// Gradient thương hiệu cho điểm nhấn trang trí.
  LinearGradient get brandGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  /// Gradient nền thẻ hero.
  LinearGradient get heroGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [heroStart, heroEnd],
  );

  /// Bóng đổ mềm cho thẻ và thanh điều hướng nổi.
  List<BoxShadow> get softShadow => [
    BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 8)),
  ];

  static const AppColors light = AppColors(
    primary: AppPalette.brand,
    onPrimary: AppPalette.onBrand,
    primaryContainer: AppPalette.brandContainer,
    onPrimaryContainer: AppPalette.onBrandContainer,
    background: AppPalette.background,
    surface: AppPalette.surface,
    surfaceMuted: AppPalette.surfaceMuted,
    textPrimary: AppPalette.textPrimary,
    textSecondary: AppPalette.textSecondary,
    textMuted: AppPalette.textMuted,
    border: AppPalette.border,
    divider: AppPalette.divider,
    gradientStart: AppPalette.gradientStart,
    gradientEnd: AppPalette.gradientEnd,
    heroStart: AppPalette.heroStart,
    heroEnd: AppPalette.heroEnd,
    shadow: AppPalette.shadow,
    disabledBackground: AppPalette.disabledBackground,
    disabledForeground: AppPalette.disabledForeground,
    success: AppPalette.success,
    successContainer: AppPalette.successContainer,
    onSuccessContainer: AppPalette.onSuccessContainer,
    warning: AppPalette.warning,
    warningContainer: AppPalette.warningContainer,
    onWarningContainer: AppPalette.onWarningContainer,
    error: AppPalette.error,
    errorContainer: AppPalette.errorContainer,
    onErrorContainer: AppPalette.onErrorContainer,
    info: AppPalette.info,
    infoContainer: AppPalette.infoContainer,
    onInfoContainer: AppPalette.onInfoContainer,
    auction: AppPalette.auction,
    auctionContainer: AppPalette.auctionContainer,
    onAuctionContainer: AppPalette.onAuctionContainer,
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? gradientStart,
    Color? gradientEnd,
    Color? heroStart,
    Color? heroEnd,
    Color? shadow,
    Color? disabledBackground,
    Color? disabledForeground,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? error,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? info,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? auction,
    Color? auctionContainer,
    Color? onAuctionContainer,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      shadow: shadow ?? this.shadow,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledForeground: disabledForeground ?? this.disabledForeground,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      auction: auction ?? this.auction,
      auctionContainer: auctionContainer ?? this.auctionContainer,
      onAuctionContainer: onAuctionContainer ?? this.onAuctionContainer,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primaryContainer: l(primaryContainer, other.primaryContainer),
      onPrimaryContainer: l(onPrimaryContainer, other.onPrimaryContainer),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      border: l(border, other.border),
      divider: l(divider, other.divider),
      gradientStart: l(gradientStart, other.gradientStart),
      gradientEnd: l(gradientEnd, other.gradientEnd),
      heroStart: l(heroStart, other.heroStart),
      heroEnd: l(heroEnd, other.heroEnd),
      shadow: l(shadow, other.shadow),
      disabledBackground: l(disabledBackground, other.disabledBackground),
      disabledForeground: l(disabledForeground, other.disabledForeground),
      success: l(success, other.success),
      successContainer: l(successContainer, other.successContainer),
      onSuccessContainer: l(onSuccessContainer, other.onSuccessContainer),
      warning: l(warning, other.warning),
      warningContainer: l(warningContainer, other.warningContainer),
      onWarningContainer: l(onWarningContainer, other.onWarningContainer),
      error: l(error, other.error),
      errorContainer: l(errorContainer, other.errorContainer),
      onErrorContainer: l(onErrorContainer, other.onErrorContainer),
      info: l(info, other.info),
      infoContainer: l(infoContainer, other.infoContainer),
      onInfoContainer: l(onInfoContainer, other.onInfoContainer),
      auction: l(auction, other.auction),
      auctionContainer: l(auctionContainer, other.auctionContainer),
      onAuctionContainer: l(onAuctionContainer, other.onAuctionContainer),
    );
  }
}
