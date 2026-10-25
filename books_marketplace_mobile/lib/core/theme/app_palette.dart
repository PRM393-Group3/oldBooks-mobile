import 'package:flutter/painting.dart';

/// Nguồn duy nhất của mọi giá trị màu thô (theme sáng).
///
/// Muốn đổi màu thương hiệu hoặc màu trạng thái: chỉ sửa file này và
/// [AppPaletteDark]. Mọi widget đọc màu qua [AppColors] (ngữ nghĩa), không bao
/// giờ dùng trực tiếp lớp này.
///
/// Giá trị lấy từ design system "Oldbook" v2 (Jade + Saffron + Ember). Tương
/// phản đã kiểm theo WCAG 2.1 AA (chữ >= 4.5:1, viền/icon >= 3:1).
abstract final class AppPalette {
  // ── Thương hiệu (Jade): mua bán, hành động chính, điều hướng ─────────────
  static const Color brand = Color(0xFF0B7A55);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color brandContainer = Color(0xFFD7F2E5);
  static const Color onBrandContainer = Color(0xFF075238);

  /// Trạng thái nhấn của nút brand; mảng tối trong logo.
  static const Color brandPressed = Color(0xFF075E42);

  // ── Điểm nhấn (Saffron): huy hiệu "Giá tốt", "Mới", nút + Bán ────────────
  /// Chỉ làm màu nền, không làm màu chữ trên nền sáng.
  static const Color accent = Color(0xFFFFB627);
  static const Color onAccent = Color(0xFF2B1D00);
  static const Color accentContainer = Color(0xFFFFF0CC);
  static const Color onAccentContainer = Color(0xFF6B4500);

  /// Prototype không dùng gradient: hai đầu trùng nhau để widget cũ vẫn dựng
  /// được mà không còn hiệu ứng chuyển màu.
  static const Color gradientStart = brand;
  static const Color gradientEnd = brand;
  static const Color heroStart = surface;
  static const Color heroEnd = surface;

  // ── Nền và bề mặt (giấy kem sáng) ────────────────────────────────────────
  static const Color background = Color(0xFFFBF8F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3EEE5);

  /// Khối tương phản cao: bảng giá đấu giá, snackbar.
  static const Color surfaceInverse = Color(0xFF1C1B18);
  static const Color onInverse = Color(0xFFFBF8F2);
  static const Color inverseMuted = Color(0xFFBDB6AA);
  static const Color inverseLeading = Color(0xFF7FE0AE);
  static const Color inverseUrgent = Color(0xFFFF9B7A);

  // ── Chữ ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1C1B18);
  static const Color textSecondary = Color(0xFF57524A);
  static const Color textMuted = Color(0xFF6E685E);

  // ── Viền ─────────────────────────────────────────────────────────────────
  /// Viền ô nhập và icon: bắt buộc >= 3:1 trên nền.
  static const Color border = Color(0xFF8C8578);

  /// Viền thẻ và đường kẻ trang trí, không mang thông tin.
  static const Color divider = Color(0xFFE8E2D7);

  /// Vòng focus 2px liền, >= 3:1 trên mọi bề mặt.
  static const Color focusRing = Color(0xFF2459C9);

  /// Lớp phủ sau sheet/dialog và trên ảnh toàn màn hình.
  static const Color scrim = Color(0x7A1C1B18);

  /// Thẻ phân tách bằng viền 1px, không bóng đổ.
  static const Color shadow = Color(0x00000000);

  // ── Trạng thái vô hiệu ───────────────────────────────────────────────────
  static const Color disabledBackground = Color(0xFFECE7DE);
  static const Color disabledForeground = Color(0xFF8A8376);

  // ── Ngữ nghĩa: mỗi loại gồm màu chính, nền nhạt và chữ trên nền nhạt ─────
  static const Color success = Color(0xFF1A7F45);
  static const Color successContainer = Color(0xFFDDF5E6);
  static const Color onSuccessContainer = Color(0xFF11592F);

  static const Color warning = Color(0xFFA35F00);
  static const Color warningContainer = Color(0xFFFFF0D1);
  static const Color onWarningContainer = Color(0xFF7A4600);

  static const Color error = Color(0xFFC2261B);
  static const Color errorContainer = Color(0xFFFDE2DF);
  static const Color onErrorContainer = Color(0xFF8F1810);

  static const Color info = Color(0xFF2459C9);
  static const Color infoContainer = Color(0xFFE0EAFF);
  static const Color onInfoContainer = Color(0xFF1A3F91);

  /// Ember: chỉ cho đấu giá đang chạy (LIVE, đếm ngược, nút Đặt giá).
  static const Color auction = Color(0xFFCC3418);
  static const Color onAuction = Color(0xFFFFFFFF);
  static const Color auctionContainer = Color(0xFFFFE3DA);
  static const Color onAuctionContainer = Color(0xFF9A2810);
}

/// Bảng màu theme tối, cùng tên khóa với [AppPalette].
abstract final class AppPaletteDark {
  static const Color brand = Color(0xFF4FD1A0);
  static const Color onBrand = Color(0xFF00281A);
  static const Color brandContainer = Color(0xFF0F3B2C);
  static const Color onBrandContainer = Color(0xFFA9EED2);
  static const Color brandPressed = Color(0xFF7FE0BB);

  static const Color accent = Color(0xFFFFC24D);
  static const Color onAccent = Color(0xFF2B1D00);
  static const Color accentContainer = Color(0xFF3D2C05);
  static const Color onAccentContainer = Color(0xFFFFD98A);

  static const Color gradientStart = brand;
  static const Color gradientEnd = brand;
  static const Color heroStart = surface;
  static const Color heroEnd = surface;

  static const Color background = Color(0xFF121311);
  static const Color surface = Color(0xFF1B1D1A);
  static const Color surfaceMuted = Color(0xFF262925);

  static const Color surfaceInverse = Color(0xFFF3EEE5);
  static const Color onInverse = Color(0xFF1C1B18);
  static const Color inverseMuted = Color(0xFF57524A);
  static const Color inverseLeading = Color(0xFF11592F);
  static const Color inverseUrgent = Color(0xFF9A2810);

  static const Color textPrimary = Color(0xFFF1EDE5);
  static const Color textSecondary = Color(0xFFC2BCB0);
  static const Color textMuted = Color(0xFFA39D91);

  static const Color border = Color(0xFF7D776C);
  static const Color divider = Color(0xFF34372F);
  static const Color focusRing = Color(0xFF8AB1FF);
  static const Color scrim = Color(0x99000000);
  static const Color shadow = Color(0x00000000);

  static const Color disabledBackground = Color(0xFF2A2D28);
  static const Color disabledForeground = Color(0xFF7A7468);

  static const Color success = Color(0xFF5DD58F);
  static const Color successContainer = Color(0xFF10331F);
  static const Color onSuccessContainer = Color(0xFFA6EEC2);

  static const Color warning = Color(0xFFF2B04B);
  static const Color warningContainer = Color(0xFF3A2806);
  static const Color onWarningContainer = Color(0xFFFFD89A);

  static const Color error = Color(0xFFFF8A80);
  static const Color errorContainer = Color(0xFF45110D);
  static const Color onErrorContainer = Color(0xFFFFB4AC);

  static const Color info = Color(0xFF8AB1FF);
  static const Color infoContainer = Color(0xFF142A57);
  static const Color onInfoContainer = Color(0xFFC3D6FF);

  static const Color auction = Color(0xFFFF7A57);
  static const Color onAuction = Color(0xFF2E0A00);
  static const Color auctionContainer = Color(0xFF47180B);
  static const Color onAuctionContainer = Color(0xFFFFB59E);
}
