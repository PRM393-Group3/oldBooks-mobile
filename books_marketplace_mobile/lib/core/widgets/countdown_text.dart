import 'dart:async';

import 'package:flutter/material.dart';

import '../util/format.dart';
import '../util/server_clock.dart';

/// Đếm ngược đến [target] (UTC), cập nhật mỗi giây. [builder] nhận chuỗi thời
/// gian còn lại đã định dạng và cờ [expired]. Dùng đồng hồ server (bù lệch từ
/// `serverTime`); server vẫn là nơi áp hạn.
class Countdown extends StatefulWidget {
  const Countdown({
    super.key,
    required this.target,
    required this.builder,
    required this.daysHours,
  });

  final DateTime target;
  final Widget Function(BuildContext context, String remaining, bool expired)
  builder;

  /// Dựng chuỗi theo ngôn ngữ khi còn từ một ngày trở lên.
  final String Function(int days, int hours) daysHours;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.target.toUtc().difference(ServerClock.now());
    return widget.builder(
      context,
      formatRemaining(left, daysHours: widget.daysHours),
      left.isNegative,
    );
  }
}
