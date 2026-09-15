# BookHub Flutter Application

Ứng dụng **BookHub - Verified Rare & Pre-Owned Book Marketplace** được viết bằng **Flutter & Dart** với kiến trúc Clean Architecture & Material 3.

## Tính năng đã hoàn thiện trong mã nguồn Flutter:
1. **Buyer Marketplace Home (`buyer_home_screen.dart`)**:
   - Thanh tìm kiếm từ khóa, ISBN, bộ lọc tình trạng sách.
   - Banner đấu giá Rare Book Auction Week đếm ngược thời gian.
   - Danh sách thẻ sách đấu giá trực tiếp (Live Auction) và kho sách đã kiểm định (Recommended).
   - Thêm giỏ hàng tức thời với huy hiệu số lượng.

2. **Live Auction Detail Console (`live_auction_detail_screen.dart`)**:
   - Ảnh bìa sách phóng to, con dấu kiểm định Grade 9.2 Fine/Mint.
   - Hệ thống đặt giá thầu trực tiếp với nút tăng nhanh (+$5, +$10, +$25) và nhập giá tùy ý.
   - Lịch sử đặt giá thầu thời gian thực (Audit Trail) và đồng hồ đếm ngược.

3. **Seller Hub & Listing Management (`seller_hub_screen.dart`)**:
   - Chỉ số doanh thu, kho sách đang bán, phiên đấu giá, kiện hàng chờ giao.
   - Bộ lọc trạng thái: All, Pending Inspection, Approved, Rejected, Sold.
   - Xem lý do từ chối kiểm định và gửi lại sách.

4. **Inspector Quality Audit Console (`inspector_audit_screen.dart`)**:
   - Thư viện 4 góc ảnh pháp y (Bìa trước, Gáy & keo PUR, Bìa sau, Trang Colophon/ISBN).
   - Bảng kiểm tra 6 tiêu chí điều kiện thực tế (Checklist).
   - Phê duyệt cấp chứng chỉ số neo vào Ledger Escrow hoặc từ chối có biên bản.

5. **Admin Portal & Governance (`admin_portal_screen.dart`)**:
   - Thống kê 6 chỉ số KPI toàn sàn.
   - Xử lý tranh chấp (Dispute Queue), đóng băng ký quỹ (Freeze Escrow), hoàn tiền người mua.
   - Nhật ký uy tín người dùng và luồng Colophon thời gian thực.

6. **New Book Listing Specification (`new_book_listing_screen.dart`)**:
   - 4 ô tải ảnh kiểm định bắt buộc.
   - Nhập ISBN-13, thông tin tác giả, nhà xuất bản, ghi chú khuyết tật.
   - Chọn hình thức bán: Đấu giá (Auction với giá sàn Reserve) hoặc Giá cố định (Fixed Price).

7. **Cart & SafeTrade Escrow Checkout (`cart_checkout_screen.dart`)**:
   - Danh sách sách trong giỏ, tăng giảm số lượng, mã giảm giá `BOOKHUB5`.
   - Lựa chọn phương thức vận chuyển: Tiêu chuẩn hoặc Hỏa tốc có bảo hiểm.
   - Thanh toán ký quỹ (Apple Pay, Thẻ ngân hàng, Ví Escrow).

8. **Order Tracking & Escrow Release (`order_tracking_screen.dart`)**:
   - Theo dõi tiến độ 5 mốc: Đặt hàng -> Kiểm định vật lý -> Bưu cục giao hàng -> Đang giao -> Đã giao.
   - Bản đồ lộ trình vận chuyển mô phỏng.
   - Nút người mua xác nhận nhận sách và giải ngân tiền ký quỹ (Release Escrow) cho người bán.

---

## Hướng dẫn chạy trên máy cục bộ (Local Run):

1. **Yêu cầu môi trường**:
   - Đã cài đặt Flutter SDK (>= 3.10.0) và Dart (>= 3.0.0).
   - VS Code (cài extension Flutter & Dart) hoặc Android Studio.

2. **Cách chạy**:
   ```bash
   cd flutter_app
   flutter pub get
   flutter run
   ```
   Hoặc chọn thiết bị Chrome/Android/iOS trong VS Code và nhấn **F5** để chạy.
