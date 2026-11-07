import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_providers.dart';
import '../../../core/theme/theme_context.dart';
import '../application/ai_providers.dart';
import '../domain/ai_fab_position.dart';

const _prefsKey = 'ai_fab_anchor';

AiFabAnchor? _readAnchor(SharedPreferences prefs) {
  try {
    final parts = prefs.getString(_prefsKey)?.split(',');
    if (parts == null || parts.length != 2) return null;
    final fx = double.tryParse(parts[0]);
    final fy = double.tryParse(parts[1]);
    if (fx == null || fy == null) return null;
    return AiFabAnchor(fx.clamp(0.0, 1.0), fy.clamp(0.0, 1.0));
  } catch (_) {
    return null;
  }
}

/// Nút nổi mở Trợ lý AI, đặt trong thân của [AppShell] (phía trên thanh điều
/// hướng). Kéo thả tự do, thả ra thì hít vào mép trái/phải gần nhất và nhớ vị
/// trí. [path] là đường dẫn hiện tại để ẩn ở các màn không phù hợp.
class AiFloatingButton extends ConsumerStatefulWidget {
  const AiFloatingButton({super.key, required this.path});

  final String path;

  @override
  ConsumerState<AiFloatingButton> createState() => _AiFloatingButtonState();
}

class _AiFloatingButtonState extends ConsumerState<AiFloatingButton> {
  AiFabAnchor _anchor = AiFabAnchor.defaultAnchor;
  Offset? _drag;

  @override
  void initState() {
    super.initState();
    try {
      _anchor = _readAnchor(ref.read(sharedPreferencesProvider)) ?? _anchor;
    } catch (_) {
      // Chưa có SharedPreferences (test): dùng vị trí mặc định.
    }
  }

  void _save(AiFabAnchor a) {
    try {
      ref
          .read(sharedPreferencesProvider)
          .setString(_prefsKey, '${a.fx},${a.fy}');
    } catch (_) {}
  }

  void _open() {
    final subscribed = ref.read(aiStatusProvider).value?.subscribed ?? false;
    context.push(subscribed ? '/me/ai/chat/new' : '/me/ai');
  }

  @override
  Widget build(BuildContext context) {
    final available = ref.watch(
      aiStatusProvider.select((s) => s.value?.claudeAvailable ?? false),
    );
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (!available || keyboardOpen || !shouldShowAiFab(widget.path)) {
      return const SizedBox.shrink();
    }
    final label = context.l10n.aiFabLabel;
    final safe = MediaQuery.paddingOf(context);

    return LayoutBuilder(
      builder: (context, c) {
        final area = c.biggest;
        final offset = _drag ?? aiFabOffsetFromAnchor(_anchor, area, safe);
        return Stack(
          children: [
            AnimatedPositioned(
              duration: _drag == null
                  ? const Duration(milliseconds: 180)
                  : Duration.zero,
              curve: Curves.easeOut,
              left: offset.dx,
              top: offset.dy,
              width: aiFabSize,
              height: aiFabSize,
              child: GestureDetector(
                onPanUpdate: (d) => setState(
                  () => _drag = clampAiFab(
                    (_drag ?? offset) + d.delta,
                    area,
                    safe,
                  ),
                ),
                onPanEnd: (_) {
                  final end = snapAiFab(_drag ?? offset, area, safe);
                  final a = aiFabAnchorFromOffset(end, area, safe);
                  setState(() {
                    _anchor = a;
                    _drag = null;
                  });
                  _save(a);
                },
                child: Semantics(
                  button: true,
                  label: label,
                  child: Tooltip(
                    message: label,
                    child: Material(
                      color: context.colors.primary,
                      elevation: 6,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _open,
                        child: Icon(
                          Icons.auto_awesome,
                          color: context.colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
