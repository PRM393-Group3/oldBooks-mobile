import 'dart:async';

import 'package:flutter/material.dart';

import '../util/format.dart';

/// Đếm ngược tới [until], cập nhật mỗi giây. Dùng cho khóa kiểm định 30 phút
/// và (sau này) phiên đấu giá.
class AppCountdown extends StatefulWidget {
  const AppCountdown({
    super.key,
    required this.until,
    required this.builder,
    this.onExpired,
  });

  final DateTime until;

  /// Dựng giao diện từ thời gian còn lại (>= 0).
  final Widget Function(BuildContext context, Duration remaining) builder;
  final VoidCallback? onExpired;

  @override
  State<AppCountdown> createState() => _AppCountdownState();
}

class _AppCountdownState extends State<AppCountdown> {
  Timer? _timer;
  late Duration _remaining;
  bool _expiredNotified = false;

  Duration _compute() {
    final d = widget.until.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  @override
  void initState() {
    super.initState();
    _remaining = _compute();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _notifyIfExpired();
  }

  @override
  void didUpdateWidget(AppCountdown old) {
    super.didUpdateWidget(old);
    if (old.until != widget.until) {
      _expiredNotified = false;
      _remaining = _compute();
    }
  }

  void _tick() {
    if (!mounted) return;
    setState(() => _remaining = _compute());
    _notifyIfExpired();
  }

  void _notifyIfExpired() {
    if (_remaining == Duration.zero && !_expiredNotified) {
      _expiredNotified = true;
      widget.onExpired?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _remaining);
}

/// Chữ `mm:ss` cho [AppCountdown].
String countdownLabel(Duration remaining) => formatCountdown(remaining);
