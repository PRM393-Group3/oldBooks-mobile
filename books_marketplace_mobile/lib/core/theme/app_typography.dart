import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Thang chữ. Be Vietnam Pro cho nội dung, Newsreader (serif) cho tiêu đề và
/// giá lớn, JetBrains Mono cho nhãn nhỏ viết hoa.
///
/// Đổi font: sửa các hằng `*Family` và mục `fonts` trong pubspec.yaml.
abstract final class AppTypography {
  static const String fontFamily = 'BeVietnamPro';
  static const String serifFamily = 'Newsreader';
  static const String monoFamily = 'JetBrainsMono';

  static TextStyle _style(double size, double lineHeight, FontWeight weight) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
    );
  }

  // Newsreader và JetBrains Mono là font biến thiên: khai báo cả trục `wght`.
  static TextStyle _serif(double size, double lineHeight, FontWeight weight) {
    return TextStyle(
      fontFamily: serifFamily,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
    );
  }

  /// Ánh xạ thang chữ của dự án vào các vai trò của Material.
  ///
  /// display 28/34 serif → headlineMedium · title 20/26 serif → titleLarge ·
  /// subtitle 16/24 → titleMedium · body 15/22 → bodyLarge, bodyMedium ·
  /// bodySmall 13/19 · label 14/20 → labelLarge, labelMedium · caption 12/16.
  static TextTheme textTheme(AppColors c) {
    return TextTheme(
      headlineMedium: _serif(28, 34, FontWeight.w600),
      titleLarge: _serif(20, 26, FontWeight.w600),
      titleMedium: _style(16, 24, FontWeight.w600),
      bodyLarge: _style(15, 22, FontWeight.w400),
      bodyMedium: _style(15, 22, FontWeight.w400),
      bodySmall: _style(13, 19, FontWeight.w400),
      labelLarge: _style(14, 20, FontWeight.w600),
      labelMedium: _style(14, 20, FontWeight.w600),
      labelSmall: _style(12, 16, FontWeight.w500),
    ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);
  }

  /// Kiểu chữ của nút.
  static TextStyle get button => _style(15, 22, FontWeight.w600);

  /// Giá và số tiền lớn (serif).
  static TextStyle price({double size = 22}) =>
      _serif(size, size * 1.2, FontWeight.w600);

  /// Nhãn nhỏ viết hoa (mono), dùng cho tiêu đề nhóm và mã tham chiếu.
  static TextStyle get overline => const TextStyle(
    fontFamily: monoFamily,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.9,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
  );
}
