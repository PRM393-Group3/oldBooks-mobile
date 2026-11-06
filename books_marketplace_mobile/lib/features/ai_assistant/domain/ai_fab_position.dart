import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Kích thước nút nổi (dp).
const aiFabSize = 56.0;

/// Khoảng cách tối thiểu tới mép vùng khả dụng (dp).
const aiFabMargin = 12.0;

/// Vị trí lưu dạng tỉ lệ 0..1 trên miền di chuyển được, để khôi phục đúng khi
/// xoay màn hình hoặc đổi cỡ. [fx] 0 = mép trái, 1 = mép phải; [fy] 0 = trên.
class AiFabAnchor {
  const AiFabAnchor(this.fx, this.fy);

  /// Mặc định: góc dưới bên phải, ngay trên thanh điều hướng.
  static const defaultAnchor = AiFabAnchor(1, 1);

  final double fx;
  final double fy;

  @override
  bool operator ==(Object other) =>
      other is AiFabAnchor && other.fx == fx && other.fy == fy;

  @override
  int get hashCode => Object.hash(fx, fy);
}

/// Vùng cho phép góc trên-trái của nút: [area] là vùng chứa (phần thân màn hình,
/// đã trừ thanh điều hướng dưới), [safe] là vùng đệm an toàn (tai thỏ, thanh
/// trạng thái...). Nếu vùng quá nhỏ thì co về một điểm.
Rect aiFabBounds(Size area, EdgeInsets safe) {
  final left = safe.left + aiFabMargin;
  final top = safe.top + aiFabMargin;
  final right = math.max(
    left,
    area.width - safe.right - aiFabMargin - aiFabSize,
  );
  final bottom = math.max(
    top,
    area.height - safe.bottom - aiFabMargin - aiFabSize,
  );
  return Rect.fromLTRB(left, top, right, bottom);
}

/// Kẹp [o] (góc trên-trái) vào vùng cho phép.
Offset clampAiFab(Offset o, Size area, EdgeInsets safe) {
  final b = aiFabBounds(area, safe);
  return Offset(o.dx.clamp(b.left, b.right), o.dy.clamp(b.top, b.bottom));
}

/// Thả tay: hít vào mép ngang gần nhất (so tâm nút với giữa vùng), giữ nguyên
/// độ cao sau khi kẹp.
Offset snapAiFab(Offset o, Size area, EdgeInsets safe) {
  final b = aiFabBounds(area, safe);
  final center = o.dx + aiFabSize / 2;
  final x = center < (b.left + b.right + aiFabSize) / 2 ? b.left : b.right;
  return Offset(x, o.dy.clamp(b.top, b.bottom));
}

Offset aiFabOffsetFromAnchor(AiFabAnchor a, Size area, EdgeInsets safe) {
  final b = aiFabBounds(area, safe);
  return Offset(
    b.left + (b.right - b.left) * a.fx.clamp(0.0, 1.0),
    b.top + (b.bottom - b.top) * a.fy.clamp(0.0, 1.0),
  );
}

AiFabAnchor aiFabAnchorFromOffset(Offset o, Size area, EdgeInsets safe) {
  final b = aiFabBounds(area, safe);
  double frac(double v, double lo, double hi) =>
      hi <= lo ? 1 : ((v - lo) / (hi - lo)).clamp(0.0, 1.0);
  return AiFabAnchor(frac(o.dx, b.left, b.right), frac(o.dy, b.top, b.bottom));
}

/// Màn hình nào hiện nút nổi. [path] là đường dẫn hiện tại. Chat và màn mua gói
/// (`/me/ai...`), màn đăng nhập/đăng ký và ví lịch sử/nạp-rút (`/wallet/...`)
/// không hiện.
bool shouldShowAiFab(String path) {
  const hiddenPrefixes = [
    '/me/ai',
    '/login',
    '/register',
    '/forgot-password',
    '/wallet/',
  ];
  for (final p in hiddenPrefixes) {
    if (p.endsWith('/')) {
      if (path.startsWith(p)) return false;
    } else if (path == p || path.startsWith('$p/')) {
      return false;
    }
  }
  return true;
}
