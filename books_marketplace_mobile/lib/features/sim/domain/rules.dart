import 'dart:math' as math;

/// Quy tắc nghiệp vụ dùng chung cho dữ liệu mô phỏng. Hàm thuần, không phụ
/// thuộc đồng hồ hay ngẫu nhiên nên test được trực tiếp. Số liệu lấy từ
/// prototype "Oldbook Mobile MVP" (BE-SRS v1.1, mục 3).

/// Người bán phải gửi hàng trong 2 ngày làm việc, quá hạn đơn tự hủy.
const int sellerShipWorkDays = 2;

/// Cửa sổ khiếu nại sau khi giao.
const Duration complaintWindow = Duration(days: 3);

/// Phí lưu kho mỗi ngày, trừ vào cọc.
const int storageFeePerDay = 5000;

/// Số lần giao tối đa trước khi sách vào lưu kho.
const int maxDeliveryAttempts = 5;

/// Số dư tối thiểu cho một lần rút.
const int minWithdrawal = 50000;

/// Phí tham gia phiên: 2% giá khởi điểm, kẹp trong 10.000 đến 100.000 đ.
int auctionRegistrationFee(int startingPrice) =>
    math.min(100000, math.max(10000, startingPrice * 2 ~/ 100));

/// Cọc: 10% giá khởi điểm.
int auctionDeposit(int startingPrice) => startingPrice ~/ 10;

/// Tổng tạm giữ khi đăng ký phiên.
int auctionRegistrationHold(int startingPrice) =>
    auctionRegistrationFee(startingPrice) + auctionDeposit(startingPrice);

/// Cộng [n] ngày làm việc (bỏ thứ Bảy, Chủ nhật), giữ nguyên giờ.
DateTime addWorkDays(DateTime from, int n) {
  var d = from;
  var left = n;
  while (left > 0) {
    d = d.add(const Duration(days: 1));
    if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) left--;
  }
  return d;
}

DateTime sellerShipDeadline(DateTime placedAt) =>
    addWorkDays(placedAt, sellerShipWorkDays);

DateTime complaintDeadline(DateTime deliveredAt) =>
    deliveredAt.add(complaintWindow);

// ── Đấu giá ────────────────────────────────────────────────────────────────

/// Lượt trả giá trong khoảng này trước giờ kết thúc sẽ gia hạn phiên.
const Duration antiSnipingWindow = Duration(minutes: 2);

/// Phiên được gia hạn tới `now + antiSnipingWindow` (chống bắn tỉa).
const Duration antiSnipingExtension = Duration(minutes: 2);

/// Đếm ngược sau khi có người mua ngay; mỗi lượt cao hơn đặt lại về mốc này.
const Duration buyNowCountdown = Duration(minutes: 30);

/// Đếm ngược mua ngay kết thúc chậm nhất sau khoảng này kể từ lúc bấm.
const Duration buyNowHardLimit = Duration(hours: 24);

/// Phiên bắt đầu chạy dài tối đa bao lâu (giờ kết thúc dự kiến).
const Duration auctionRunDuration = Duration(minutes: 60);

/// Giờ kết thúc mới của phiên đang diễn ra sau một lượt trả giá lúc [now].
DateTime? extendedEnd(DateTime now, DateTime endsAt) =>
    endsAt.difference(now) < antiSnipingWindow
    ? now.add(antiSnipingExtension)
    : null;

/// Giờ kết thúc mới của đếm ngược mua ngay sau một lượt trả giá lúc [now].
DateTime resetBuyNowCountdown(DateTime now, DateTime hardEndsAt) {
  final reset = now.add(buyNowCountdown);
  return reset.isAfter(hardEndsAt) ? hardEndsAt : reset;
}

// ── Chu kỳ đơn ─────────────────────────────────────────────────────────────

/// Phí ship giả định (SRS để "theo cấu hình"): bán thường 25.000 đ, đấu giá
/// 30.000 đ. Đổi ở đây khi backend có cấu hình thật.
const int shippingFeeFixedPrice = 25000;
const int shippingFeeAuction = 30000;
