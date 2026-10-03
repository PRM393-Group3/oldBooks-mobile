import 'package:flutter/painting.dart';

/// Nguồn duy nhất của mọi giá trị màu thô.
///
/// Muốn đổi màu thương hiệu hoặc màu trạng thái: chỉ sửa file này. Mọi widget
/// đọc màu qua [AppColors] (ngữ nghĩa), không bao giờ dùng trực tiếp lớp này.
///
/// Tương phản đã kiểm theo WCAG 2.1 AA (chữ >= 4.5:1, viền/icon >= 3:1).
/// Giá trị lấy từ prototype "Oldbook Mobile MVP" (xem docs/redesign-oldbook-v2.md);
/// riêng `border`, `textMuted` và chữ phụ được chỉnh nhẹ để đạt AA.
abstract final class AppPalette {
  // ── Thương hiệu (xanh rêu) ───────────────────────────────────────────────
  /// Xanh rêu đậm của nút chính (prototype `#24543F`), chữ kem trên nền này
  /// đạt AA.
  static const Color brand = Color(0xFF24543F);
  static const Color onBrand = Color(0xFFF5F1E8);
  static const Color brandContainer = Color(0xFFE1EDE5);
  static const Color onBrandContainer = Color(0xFF1D4535);

  /// Prototype không dùng gradient: hai đầu trùng nhau để widget cũ vẫn dựng
  /// được mà không còn hiệu ứng chuyển màu.
  static const Color gradientStart = Color(0xFF2A6049);
  static const Color gradientEnd = Color(0xFF2A6049);
  static const Color heroStart = Color(0xFFFFFCF5);
  static const Color heroEnd = Color(0xFFFFFCF5);

  // ── Nền và bề mặt (kem ấm) ───────────────────────────────────────────────
  static const Color background = Color(0xFFF5F1E8);
  static const Color surface = Color(0xFFFFFCF5);
  static const Color surfaceMuted = Color(0xFFEBE6DB);

  // ── Chữ ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1D1A15);
  static const Color textSecondary = Color(0xFF5F594E);
  static const Color textMuted = Color(0xFF686155);

  // ── Viền ─────────────────────────────────────────────────────────────────
  /// Viền ô nhập và icon: bắt buộc >= 3:1 trên nền.
  static const Color border = Color(0xFF8A8271);

  /// Viền thẻ và đường kẻ trang trí, không mang thông tin.
  static const Color divider = Color(0xFFE3DCCD);

  /// Prototype không dùng bóng đổ: thẻ phân tách bằng viền 1px.
  static const Color shadow = Color(0x00000000);

  // ── Trạng thái vô hiệu ───────────────────────────────────────────────────
  static const Color disabledBackground = Color(0xFFE3DCCD);
  static const Color disabledForeground = Color(0xFF9A927F);

  // ── Ngữ nghĩa: mỗi loại gồm màu chính, nền nhạt và chữ trên nền nhạt ─────
  // Cặp nền/chữ lấy từ bảng `TONES` của prototype.
  static const Color success = Color(0xFF2A6049);
  static const Color successContainer = Color(0xFFE1EDE5);
  static const Color onSuccessContainer = Color(0xFF2A6049);

  static const Color warning = Color(0xFF86600F);
  static const Color warningContainer = Color(0xFFF3E8CD);
  static const Color onWarningContainer = Color(0xFF86600F);

  static const Color error = Color(0xFFA43D22);
  static const Color errorContainer = Color(0xFFF6E1D8);
  static const Color onErrorContainer = Color(0xFFA43D22);

  static const Color info = Color(0xFF2F5878);
  static const Color infoContainer = Color(0xFFE0E8EF);
  static const Color onInfoContainer = Color(0xFF2F5878);

  /// Đỏ gạch: huy hiệu, đếm ngược đấu giá.
  static const Color auction = Color(0xFFB8462A);
  static const Color auctionContainer = Color(0xFFF6E1D8);
  static const Color onAuctionContainer = Color(0xFFA43D22);
}
