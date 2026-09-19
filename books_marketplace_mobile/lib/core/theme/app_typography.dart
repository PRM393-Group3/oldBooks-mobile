import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Thang chữ. Font Arimo (tương thích số đo Helvetica) là font biến thiên nên
/// mỗi kiểu chữ khai báo cả `fontWeight` lẫn trục `wght`.
///
/// Đổi font: sửa [fontFamily] và mục `fonts` trong pubspec.yaml.
abstract final class AppTypography {
  static const String fontFamily = 'Arimo';

  static TextStyle _style(double size, double lineHeight, FontWeight weight) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
    );
  }

  /// Ánh xạ thang chữ của dự án vào các vai trò của Material.
  ///
  /// display 28/36 → headlineMedium · title 20/28 → titleLarge ·
  /// subtitle 16/24 → titleMedium · body 16/24 → bodyLarge, bodyMedium ·
  /// bodySmall 14/20 · label 14/20 → labelLarge, labelMedium · caption 12/16.
  static TextTheme textTheme(AppColors c) {
    return TextTheme(
      headlineMedium: _style(28, 36, FontWeight.w700),
      titleLarge: _style(20, 28, FontWeight.w700),
      titleMedium: _style(16, 24, FontWeight.w600),
      bodyLarge: _style(16, 24, FontWeight.w400),
      bodyMedium: _style(16, 24, FontWeight.w400),
      bodySmall: _style(14, 20, FontWeight.w400),
      labelLarge: _style(14, 20, FontWeight.w600),
      labelMedium: _style(14, 20, FontWeight.w600),
      labelSmall: _style(12, 16, FontWeight.w400),
    ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);
  }

  /// Kiểu chữ của nút (subtitle).
  static TextStyle get button => _style(16, 24, FontWeight.w600);
}
