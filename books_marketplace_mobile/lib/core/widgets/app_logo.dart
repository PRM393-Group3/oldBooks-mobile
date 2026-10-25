import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import '../theme/theme_context.dart';

/// Logo Oldbook vẽ bằng code từ path của `assets/logo-oldbook/*.svg` (hai trang
/// sách và chấm saffron). Màu theo theme nên dùng được ở sáng và tối, không cần
/// ảnh raster hay `flutter_svg`.
///
/// [AppLogo.mark] chỉ có biểu tượng; [AppLogo.full] kèm chữ "Oldbook".
class AppLogo extends StatelessWidget {
  const AppLogo.mark({super.key, this.size = 32}) : _full = false;
  const AppLogo.full({super.key, this.size = 32}) : _full = true;

  /// Chiều cao hiển thị.
  final double size;
  final bool _full;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mark = CustomPaint(
      size: Size.square(size),
      painter: _MarkPainter(
        left: c.primary,
        right: c.primaryPressed,
        dot: c.accent,
      ),
    );
    return Semantics(
      image: true,
      label: 'Oldbook',
      excludeSemantics: true,
      child: _full
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                mark,
                SizedBox(width: size * 0.2),
                Text(
                  'Oldbook',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: size * 0.66,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: c.textPrimary,
                  ),
                ),
              ],
            )
          : mark,
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({
    required this.left,
    required this.right,
    required this.dot,
  });

  final Color left;
  final Color right;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    // Toạ độ gốc theo viewBox 32x32 của SVG.
    canvas.scale(size.width / 32, size.height / 32);
    final leftPage = Path()
      ..moveTo(4, 10)
      ..relativeCubicTo(4, -1.5, 8, -1, 12, 1.5)
      ..lineTo(16, 27)
      ..relativeCubicTo(-4, -2.5, -8, -3, -12, -1.5)
      ..close();
    final rightPage = Path()
      ..moveTo(28, 10)
      ..relativeCubicTo(-4, -1.5, -8, -1, -12, 1.5)
      ..lineTo(16, 27)
      ..relativeCubicTo(4, -2.5, 8, -3, 12, -1.5)
      ..close();
    canvas
      ..drawPath(leftPage, Paint()..color = left)
      ..drawPath(rightPage, Paint()..color = right)
      ..drawCircle(const Offset(16, 5.5), 3, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.left != left || old.right != right || old.dot != dot;
}
