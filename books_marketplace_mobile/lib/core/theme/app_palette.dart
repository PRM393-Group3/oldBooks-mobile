import 'package:flutter/painting.dart';

/// Nguồn duy nhất của mọi giá trị màu thô.
///
/// Muốn đổi màu thương hiệu hoặc màu trạng thái: chỉ sửa file này. Mọi widget
/// đọc màu qua [AppColors] (ngữ nghĩa), không bao giờ dùng trực tiếp lớp này.
///
/// Tương phản đã kiểm theo WCAG 2.1 AA (chữ >= 4.5:1, viền/icon >= 3:1).
abstract final class AppPalette {
  // ── Thương hiệu (tím lavender) ───────────────────────────────────────────
  /// Tím sáng nhất vẫn đạt AA với chữ trắng (5.04:1). Sáng hơn nữa thì nút
  /// chính phải đổi sang chữ tối.
  static const Color brand = Color(0xFF7657DC);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color brandContainer = Color(0xFFEDE7FF);
  static const Color onBrandContainer = Color(0xFF2E1F7A);

  /// Cặp màu gradient cho điểm nhấn trang trí (biểu tượng, viền avatar).
  /// Không đặt chữ lên gradient.
  static const Color gradientStart = Color(0xFF8B6CF0);
  static const Color gradientEnd = Color(0xFFE879C9);

  /// Nền thẻ "hero": lavender nhạt chuyển sang hồng nhạt.
  static const Color heroStart = Color(0xFFEDE7FF);
  static const Color heroEnd = Color(0xFFFCE7F6);

  // ── Nền và bề mặt (trắng pha tím) ────────────────────────────────────────
  static const Color background = Color(0xFFF7F5FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFEBFF);

  // ── Chữ ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF16132B);
  static const Color textSecondary = Color(0xFF4A4763);
  static const Color textMuted = Color(0xFF6B6885);

  // ── Viền ─────────────────────────────────────────────────────────────────
  /// Viền ô nhập và icon: bắt buộc >= 3:1 trên nền.
  static const Color border = Color(0xFF77748F);

  /// Đường kẻ trang trí, không mang thông tin.
  static const Color divider = Color(0xFFE7E2F7);

  /// Bóng đổ mềm nhuốm tím (đã gồm độ trong suốt).
  static const Color shadow = Color(0x1F7657DC);

  // ── Trạng thái vô hiệu ───────────────────────────────────────────────────
  static const Color disabledBackground = Color(0xFFE7E2F7);
  static const Color disabledForeground = Color(0xFF9E9BB5);

  // ── Ngữ nghĩa: mỗi loại gồm màu chính, nền nhạt và chữ trên nền nhạt ─────
  static const Color success = Color(0xFF0E7C57);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccessContainer = Color(0xFF065F46);

  static const Color warning = Color(0xFFB45309);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF92400E);

  static const Color error = Color(0xFFC2183F);
  static const Color errorContainer = Color(0xFFFFE4E6);
  static const Color onErrorContainer = Color(0xFF9F1239);

  static const Color info = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfoContainer = Color(0xFF1E40AF);

  /// Đếm ngược đấu giá sắp kết thúc.
  static const Color auction = Color(0xFFC93B1E);
  static const Color auctionContainer = Color(0xFFFFEDD5);
  static const Color onAuctionContainer = Color(0xFF9A3412);
}
