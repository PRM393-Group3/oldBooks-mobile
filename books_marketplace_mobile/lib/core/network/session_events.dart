import 'dart:async';

/// Kênh thông báo "phiên đã mất" từ tầng mạng lên tầng xác thực.
///
/// Giúp `core/network` không phải phụ thuộc vào `features/auth`.
class SessionEvents {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get lost => _controller.stream;

  void notifyLost() => _controller.add(null);

  void dispose() => _controller.close();
}
