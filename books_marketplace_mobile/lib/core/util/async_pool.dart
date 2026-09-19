import 'dart:async';
import 'dart:collection';

/// Giới hạn số tác vụ bất đồng bộ chạy cùng lúc (mặc định 2, để tải ảnh
/// không nghẽn mạng 4G).
class AsyncPool {
  AsyncPool([this.limit = 2]);

  final int limit;
  int _running = 0;
  final Queue<Completer<void>> _waiting = Queue();

  Future<T> run<T>(Future<T> Function() task) async {
    if (_running >= limit) {
      final c = Completer<void>();
      _waiting.add(c);
      await c.future;
    }
    _running++;
    try {
      return await task();
    } finally {
      _running--;
      if (_waiting.isNotEmpty) _waiting.removeFirst().complete();
    }
  }
}
