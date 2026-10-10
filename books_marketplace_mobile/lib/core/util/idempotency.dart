import 'dart:math';

import '../network/api_error.dart';

final _random = Random.secure();

/// Giữ `Idempotency-Key` cho MỘT thao tác của người dùng. Lấy [key] khi gửi;
/// gọi [settle] sau khi có kết quả: thành công hoặc server đã trả lỗi thì bỏ
/// key (lần bấm sau là thao tác mới), mất mạng thì giữ để thử lại cùng key.
class IdempotentAction {
  String? _key;

  String get key => _key ??= newIdempotencyKey();

  void settle([Object? error]) {
    final networkFailure = error is ApiError && error.status == 0;
    if (!networkFailure) _key = null;
  }

  /// Nội dung thao tác đã đổi (ví dụ số tiền trả giá): bắt buộc key mới.
  void reset() => _key = null;
}

/// UUID v4 làm `Idempotency-Key`. Sinh MỘT lần cho mỗi hành động của người dùng
/// (bấm "Nạp", "Rút") và giữ lại tới khi có kết quả cuối; gửi lại cùng key khi
/// mạng lỗi để server không thực hiện lần hai.
String newIdempotencyKey() {
  final b = List<int>.generate(16, (_) => _random.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String hex(int from, int to) => b
      .sublist(from, to)
      .map((e) => e.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
