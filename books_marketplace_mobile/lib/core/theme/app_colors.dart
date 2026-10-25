import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Màu ngữ nghĩa của ứng dụng, đăng ký như một [ThemeExtension].
///
/// Truy cập bằng `context.colors`. Có hai bộ: [AppColors.light] từ
/// [AppPalette] và [AppColors.dark] từ [AppPaletteDark].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primaryPressed,
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceInverse,
    required this.onInverse,
    required this.inverseMuted,
    required this.inverseLeading,
    required this.inverseUrgent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.focusRing,
    required this.scrim,
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
    required this.onAuction,
    required this.auctionContainer,
    required this.onAuctionContainer,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  /// Trạng thái nhấn của nút chính.
  final Color primaryPressed;

  /// Saffron: nền điểm nhấn (huy hiệu, nút + Bán). Không dùng làm màu chữ.
  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color onAccentContainer;
  final Color background;
  final Color surface;
  final Color surfaceMuted;

  /// Khối tương phản cao: bảng giá đấu giá, snackbar.
  final Color surfaceInverse;

  /// Chữ trên [surfaceInverse].
  final Color onInverse;

  /// Nhãn phụ trên [surfaceInverse].
  final Color inverseMuted;

  /// "Bạn đang dẫn đầu" trên [surfaceInverse].
  final Color inverseLeading;

  /// Đếm ngược gấp (< 2 phút) trên [surfaceInverse].
  final Color inverseUrgent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color divider;

  /// Vòng focus 2px.
  final Color focusRing;

  /// Lớp phủ sau sheet/dialog và trên ảnh toàn màn hình.
  final Color scrim;
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

  /// Ember: chỉ cho đấu giá đang chạy (LIVE, đếm ngược, nút Đặt giá).
  final Color auction;

  /// Chữ/icon trên nền [auction].
  final Color onAuction;
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

  /// Thẻ phân tách bằng viền 1px, không bóng đổ. Giữ getter để các widget gọi
  /// nó không phải sửa; trả về danh sách rỗng.
  List<BoxShadow> get softShadow => const [];

  /// Bóng của lớp nổi: snackbar, nút + Bán (`shadow-pop`).
  List<BoxShadow> get popShadow => [
    BoxShadow(
      color: scrim.withValues(alpha: 0.33),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Bóng của thanh CTA cố định đáy khi nội dung cuộn dưới nó (`shadow-bar`).
  List<BoxShadow> get barShadow => [
    BoxShadow(
      color: scrim.withValues(alpha: 0.17),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];

  static const AppColors light = AppColors(
    primary: AppPalette.brand,
    onPrimary: AppPalette.onBrand,
    primaryContainer: AppPalette.brandContainer,
    onPrimaryContainer: AppPalette.onBrandContainer,
    primaryPressed: AppPalette.brandPressed,
    accent: AppPalette.accent,
    onAccent: AppPalette.onAccent,
    accentContainer: AppPalette.accentContainer,
    onAccentContainer: AppPalette.onAccentContainer,
    background: AppPalette.background,
    surface: AppPalette.surface,
    surfaceMuted: AppPalette.surfaceMuted,
    surfaceInverse: AppPalette.surfaceInverse,
    onInverse: AppPalette.onInverse,
    inverseMuted: AppPalette.inverseMuted,
    inverseLeading: AppPalette.inverseLeading,
    inverseUrgent: AppPalette.inverseUrgent,
    textPrimary: AppPalette.textPrimary,
    textSecondary: AppPalette.textSecondary,
    textMuted: AppPalette.textMuted,
    border: AppPalette.border,
    divider: AppPalette.divider,
    focusRing: AppPalette.focusRing,
    scrim: AppPalette.scrim,
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
    onAuction: AppPalette.onAuction,
    auctionContainer: AppPalette.auctionContainer,
    onAuctionContainer: AppPalette.onAuctionContainer,
  );

  static const AppColors dark = AppColors(
    primary: AppPaletteDark.brand,
    onPrimary: AppPaletteDark.onBrand,
    primaryContainer: AppPaletteDark.brandContainer,
    onPrimaryContainer: AppPaletteDark.onBrandContainer,
    primaryPressed: AppPaletteDark.brandPressed,
    accent: AppPaletteDark.accent,
    onAccent: AppPaletteDark.onAccent,
    accentContainer: AppPaletteDark.accentContainer,
    onAccentContainer: AppPaletteDark.onAccentContainer,
    background: AppPaletteDark.background,
    surface: AppPaletteDark.surface,
    surfaceMuted: AppPaletteDark.surfaceMuted,
    surfaceInverse: AppPaletteDark.surfaceInverse,
    onInverse: AppPaletteDark.onInverse,
    inverseMuted: AppPaletteDark.inverseMuted,
    inverseLeading: AppPaletteDark.inverseLeading,
    inverseUrgent: AppPaletteDark.inverseUrgent,
    textPrimary: AppPaletteDark.textPrimary,
    textSecondary: AppPaletteDark.textSecondary,
    textMuted: AppPaletteDark.textMuted,
    border: AppPaletteDark.border,
    divider: AppPaletteDark.divider,
    focusRing: AppPaletteDark.focusRing,
    scrim: AppPaletteDark.scrim,
    gradientStart: AppPaletteDark.gradientStart,
    gradientEnd: AppPaletteDark.gradientEnd,
    heroStart: AppPaletteDark.heroStart,
    heroEnd: AppPaletteDark.heroEnd,
    shadow: AppPaletteDark.shadow,
    disabledBackground: AppPaletteDark.disabledBackground,
    disabledForeground: AppPaletteDark.disabledForeground,
    success: AppPaletteDark.success,
    successContainer: AppPaletteDark.successContainer,
    onSuccessContainer: AppPaletteDark.onSuccessContainer,
    warning: AppPaletteDark.warning,
    warningContainer: AppPaletteDark.warningContainer,
    onWarningContainer: AppPaletteDark.onWarningContainer,
    error: AppPaletteDark.error,
    errorContainer: AppPaletteDark.errorContainer,
    onErrorContainer: AppPaletteDark.onErrorContainer,
    info: AppPaletteDark.info,
    infoContainer: AppPaletteDark.infoContainer,
    onInfoContainer: AppPaletteDark.onInfoContainer,
    auction: AppPaletteDark.auction,
    onAuction: AppPaletteDark.onAuction,
    auctionContainer: AppPaletteDark.auctionContainer,
    onAuctionContainer: AppPaletteDark.onAuctionContainer,
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? primaryPressed,
    Color? accent,
    Color? onAccent,
    Color? accentContainer,
    Color? onAccentContainer,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceInverse,
    Color? onInverse,
    Color? inverseMuted,
    Color? inverseLeading,
    Color? inverseUrgent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? focusRing,
    Color? scrim,
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
    Color? onAuction,
    Color? auctionContainer,
    Color? onAuctionContainer,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentContainer: accentContainer ?? this.accentContainer,
      onAccentContainer: onAccentContainer ?? this.onAccentContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceInverse: surfaceInverse ?? this.surfaceInverse,
      onInverse: onInverse ?? this.onInverse,
      inverseMuted: inverseMuted ?? this.inverseMuted,
      inverseLeading: inverseLeading ?? this.inverseLeading,
      inverseUrgent: inverseUrgent ?? this.inverseUrgent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      focusRing: focusRing ?? this.focusRing,
      scrim: scrim ?? this.scrim,
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
      onAuction: onAuction ?? this.onAuction,
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
      primaryPressed: l(primaryPressed, other.primaryPressed),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentContainer: l(accentContainer, other.accentContainer),
      onAccentContainer: l(onAccentContainer, other.onAccentContainer),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceMuted: l(surfaceMuted, other.surfaceMuted),
      surfaceInverse: l(surfaceInverse, other.surfaceInverse),
      onInverse: l(onInverse, other.onInverse),
      inverseMuted: l(inverseMuted, other.inverseMuted),
      inverseLeading: l(inverseLeading, other.inverseLeading),
      inverseUrgent: l(inverseUrgent, other.inverseUrgent),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      border: l(border, other.border),
      divider: l(divider, other.divider),
      focusRing: l(focusRing, other.focusRing),
      scrim: l(scrim, other.scrim),
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
      onAuction: l(onAuction, other.onAuction),
      auctionContainer: l(auctionContainer, other.auctionContainer),
      onAuctionContainer: l(onAuctionContainer, other.onAuctionContainer),
    );
  }
}
