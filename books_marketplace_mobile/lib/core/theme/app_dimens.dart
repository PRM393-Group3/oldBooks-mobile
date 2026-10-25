import 'package:flutter/painting.dart';

/// Khoảng cách theo bội của 4. Dùng các hằng này, không viết số trực tiếp.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Lề ngang chuẩn của mọi màn hình.
  static const double screen = md;
  static const EdgeInsets screenPadding = EdgeInsets.all(screen);
}

/// Bo góc.
abstract final class AppRadius {
  static const double xs = 6; // bìa sách nhỏ (thẻ đấu giá, giỏ hàng)
  static const double sm = 10; // bìa trong lưới, chip nhỏ
  static const double md = 14; // nút, ô nhập, thẻ
  static const double lg = 18; // sheet, dialog, bảng giá đấu giá
  static const double full = 999; // badge, avatar, nút tròn

  static BorderRadius get xsAll => BorderRadius.circular(xs);
  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
}

/// Kích thước cố định dùng chung.
abstract final class AppSizes {
  /// Vùng chạm tối thiểu (WCAG, HIG, Material).
  static const double minTouchTarget = 48;
  static const double buttonHeight = 48;

  /// Nút CTA chính ở thanh cố định (Đặt giá, Mua ngay, Thanh toán).
  static const double ctaHeight = 52;

  /// Thanh điều hướng dưới.
  static const double navHeight = 64;
  static const double avatarSmall = 40;
  static const double avatarMedium = 72;
  static const double avatarLarge = 120;

  /// Chiều rộng tối đa của nội dung form trên màn hình rộng.
  static const double formMaxWidth = 480;
}
