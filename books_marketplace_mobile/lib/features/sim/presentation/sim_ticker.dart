import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/sim_providers.dart';

/// Đẩy đồng hồ của kho mô phỏng mỗi giây khi màn hình thật sự hiển thị.
///
/// Tab nằm ngoài màn hình (IndexedStack) bị tắt `TickerMode`, nên timer dừng và
/// không tốn pin; khi quay lại, `tick()` bù mọi chuyển trạng thái đã đến hạn.
class SimTicker extends ConsumerStatefulWidget {
  const SimTicker({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SimTicker> createState() => _SimTickerState();
}

class _SimTickerState extends ConsumerState<SimTicker> {
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = TickerMode.valuesOf(context).enabled;
    if (enabled && _timer == null) {
      // Bù ngay các mốc đã qua rồi mới chạy theo nhịp giây.
      Future.microtask(() {
        if (mounted) ref.read(simProvider.notifier).tick();
      });
      _timer = Timer.periodic(ref.read(simTickIntervalProvider), (_) {
        if (mounted) ref.read(simProvider.notifier).tick();
      });
    } else if (!enabled && _timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
