/// Kết quả `POST /auth/otp` và `POST /me/phone/otp`.
class OtpSent {
  const OtpSent({required this.expiresInSeconds, this.sentTo});

  factory OtpSent.fromJson(dynamic json) {
    final j = json as Map;
    return OtpSent(
      expiresInSeconds: j['expiresInSeconds'] as int,
      sentTo: j['sentTo'] as String?,
    );
  }

  /// Số giây OTP còn hiệu lực, lấy từ server vì Super Admin chỉnh được.
  final int expiresInSeconds;

  /// Email đích đã che, ví dụ `n*******a@gmail.com`; `null` nếu gửi SMS.
  final String? sentTo;
}
