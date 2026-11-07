import 'package:books_marketplace_mobile/features/ai_assistant/domain/ai_fab_position.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const area = Size(400, 700);
  const safe = EdgeInsets.only(top: 40);

  test('kẹp vào vùng an toàn', () {
    final b = aiFabBounds(area, safe);
    expect(clampAiFab(const Offset(-50, -50), area, safe), b.topLeft);
    expect(clampAiFab(const Offset(9999, 9999), area, safe), b.bottomRight);
    expect(
      clampAiFab(const Offset(100, 200), area, safe),
      const Offset(100, 200),
    );
    // Không tràn qua mép phải/dưới.
    expect(b.right + aiFabSize + aiFabMargin, area.width);
    expect(b.bottom + aiFabSize + aiFabMargin, area.height);
    expect(b.top, 40 + aiFabMargin);
  });

  test('thả tay hít vào mép gần nhất, giữ độ cao', () {
    final b = aiFabBounds(area, safe);
    expect(snapAiFab(const Offset(60, 300), area, safe), Offset(b.left, 300));
    expect(snapAiFab(const Offset(300, 300), area, safe), Offset(b.right, 300));
    expect(snapAiFab(const Offset(300, 9999), area, safe).dy, b.bottom);
  });

  test('anchor khôi phục đúng sau khi đổi kích thước (xoay)', () {
    const portrait = Size(400, 700);
    const landscape = Size(700, 300);
    final b = aiFabBounds(portrait, safe);
    final anchor = aiFabAnchorFromOffset(b.bottomRight, portrait, safe);
    expect(anchor, AiFabAnchor.defaultAnchor);
    final o = aiFabOffsetFromAnchor(anchor, landscape, safe);
    expect(o, aiFabBounds(landscape, safe).bottomRight);
    // Vùng quá nhỏ vẫn không ném lỗi.
    final tiny = aiFabOffsetFromAnchor(anchor, const Size(20, 20), safe);
    expect(tiny.dx.isFinite && tiny.dy.isFinite, isTrue);
  });

  test('mặc định ở góc dưới phải', () {
    final o = aiFabOffsetFromAnchor(AiFabAnchor.defaultAnchor, area, safe);
    expect(o.dx, area.width - aiFabMargin - aiFabSize);
    expect(o.dy, area.height - aiFabMargin - aiFabSize);
  });

  test('shouldShowAiFab', () {
    for (final p in ['/home', '/auctions', '/sell', '/wallet', '/me']) {
      expect(shouldShowAiFab(p), isTrue, reason: p);
    }
    for (final p in [
      '/me/ai',
      '/me/ai/chat',
      '/me/ai/chat/new',
      '/me/ai/chat/abc',
      '/login',
      '/register',
      '/forgot-password',
      '/wallet/history',
    ]) {
      expect(shouldShowAiFab(p), isFalse, reason: p);
    }
    expect(shouldShowAiFab('/me/airline'), isTrue);
  });
}
