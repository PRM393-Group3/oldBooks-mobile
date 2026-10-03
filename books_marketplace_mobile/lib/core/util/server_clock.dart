/// Đồng hồ server. `serverTime` trong phản hồi đăng nhập/đăng ký/refresh cho
/// biết chênh lệch giữa đồng hồ máy và server; các đếm ngược hạn (gửi hàng,
/// khiếu nại, phản hồi) dùng đồng hồ này để không lệch khi máy sai giờ.
abstract final class ServerClock {
  static Duration _offset = Duration.zero;

  /// Chênh lệch server trừ máy, đã làm tròn đến giây.
  static Duration get offset => _offset;

  /// Ghi nhận `serverTime` (UTC) vừa nhận từ server.
  static void sync(DateTime? serverTime) {
    if (serverTime == null) return;
    _offset = serverTime.toUtc().difference(DateTime.now().toUtc());
  }

  /// Giờ hiện tại theo server (UTC).
  static DateTime now() => DateTime.now().toUtc().add(_offset);
}
