/// Kết quả `POST /auth/otp` và `POST /me/phone/otp`.
class OtpSent {
  const OtpSent({
    required this.expiresInSeconds,
    this.sentTo,
    this.resendAfterSeconds,
  });

  factory OtpSent.fromJson(dynamic json) {
    final j = json as Map;
    return OtpSent(
      expiresInSeconds: j['expiresInSeconds'] as int,
      sentTo: j['sentTo'] as String?,
      resendAfterSeconds: j['resendAfterSeconds'] as int?,
    );
  }

  /// Số giây OTP còn hiệu lực, lấy từ server vì Super Admin chỉnh được.
  final int expiresInSeconds;

  /// Email đích đã che, ví dụ `n*******a@gmail.com`; `null` nếu gửi SMS.
  final String? sentTo;

  /// Số giây phải chờ trước khi gửi lại, lấy từ server (`otp.resendCooldownSeconds`);
  /// `null` khi server cũ chưa trả, khi đó dùng thời gian chờ mặc định của ô OTP.
  final int? resendAfterSeconds;
}
