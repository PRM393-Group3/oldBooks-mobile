# Dựng lại app theo prototype "Oldbook Mobile MVP"

Tài liệu ghi lại thiết kế đã chốt khi brainstorming. Nguồn: prototype tương tác (artifact claude.ai `GumThGvxzZ6mhc8zo4bevp`, dựng từ BE-SRS v1.1) và code Flutter hiện tại. Tài liệu này bổ sung cho `design-system.md`; khi hai bản mâu thuẫn, bản này thắng cho phần giao diện và điều hướng.

## 1. Tóm tắt hiểu biết

- **Xây gì:** dựng lại UI và cấu trúc app Flutter theo prototype. Năm tab: Trang chủ, Đấu giá, Bán, Ví, Tôi. Kèm chi tiết sách, giỏ hàng, thanh toán, đơn hàng, khiếu nại, đấu giá (đăng ký cọc, đặt giá, mua ngay đếm ngược), nạp ví VietQR giả, Tin của tôi, Thông báo.
- **Vì sao:** prototype đã chốt nghiệp vụ theo BE-SRS v1.1; cần bản Flutter chạy được.
- **Cho ai:** một loại người dùng, vừa mua vừa bán. Bỏ vai trò Inspector khỏi mobile.
- **Dữ liệu:** auth, profile, listings gọi backend thật. Giỏ, đơn, ví, đấu giá, khiếu nại, thông báo là mock, mỗi feature có repository interface để sau nối API.
- **Ngôn ngữ:** giữ VI và EN.
- **Giữ nguyên:** wizard đăng bán 4 bước (gọi backend), lớp `core/network`, `storage`, `l10n`, Riverpod, go_router.
- **Ngoài phạm vi:** kiểm định và Inspector trên mobile, OTP, sổ địa chỉ, cài đặt nâng cao, thanh toán thật, dark mode, golden test.

## 2. Giả định

1. Theme mới thay hẳn theme tím: nền `#F5F1E8`, thẻ `#FFFCF5`, xanh rêu `#2A6049`, đỏ gạch `#B8462A`. Font Newsreader, Be Vietnam Pro, JetBrains Mono bundle trong `assets/fonts/`; bỏ Arimo.
2. Mock giữ trong bộ nhớ, mất khi tắt app. Số dư mặc định 1.250.000 khả dụng và 345.000 đang giữ (theo prototype).
3. Phí ship giả định: 25.000 đ (bán thường), 30.000 đ (đấu giá).
4. Phí đăng ký đấu giá là 2% giá khởi điểm, tối thiểu 10.000, tối đa 100.000. Cọc là 10% giá khởi điểm.
5. Bước giá, chống bắn tỉa, đếm ngược mua ngay, cửa sổ khiếu nại: đọc lại số liệu trong script prototype khi làm lát tương ứng, không đoán.
6. Trường prototype có mà DTO listings chưa có (đánh giá người bán, số đã bán) sẽ ẩn, không bịa số.
7. Tin đăng vẫn qua bước duyệt; việc duyệt chuyển sang web/Admin.
8. Quy mô đồ án nhóm, không cần kiểm thử tải. Token lưu ở `flutter_secure_storage`; mock không giữ dữ liệu nhạy cảm.

## 3. Nhật ký quyết định

| # | Quyết định | Phương án đã cân nhắc | Lý do |
|---|---|---|---|
| 1 | Dựng lại từ đầu theo prototype, bỏ phần prototype không có (kiểm định, Inspector) | Chỉ reskin; reskin cộng tính năng mới | Yêu cầu của chủ dự án |
| 2 | Mock trước, repository tách sẵn; auth, profile, listings giữ backend thật | Backend thật cho tất cả; toàn bộ mock | Backend chưa chắc có API giỏ, đơn, ví, đấu giá; tách repository để nối sau không sửa UI |
| 3 | Giữ VI và EN | Chỉ tiếng Việt | Giữ tính năng đã có, phù hợp quyết định #7 trong `design-system.md` |
| 4 | Một người dùng mua và bán, 5 tab cho tất cả | Giữ role Buyer/Seller; giữ cả Inspector | Khớp prototype, bỏ `nav_config` theo role |
| 5 | Giữ wizard 4 bước gọi backend, chỉ đổi style | Theo flow đơn giản của prototype | Backend đã có thiết kế nháp; không mất chức năng |
| 6 | Sách ở Trang chủ lấy từ backend thật, ẩn trường thiếu | Mock toàn bộ | Có dữ liệu thật để kiểm chứng; không bịa số |
| 7 | Hướng A: theme trước, rồi từng lát dọc | B: dựng song song rồi đổi; C: viết lại một lượt | App luôn chạy được, review từng lát, rủi ro thấp |
| 8 | Đổi token trong `app_palette`, giữ tên và API widget `core/widgets` | Viết lại widget | Màn cũ tự đổi giao diện, ít code |
| 9 | `StatefulShellRoute`, mỗi tab một stack; `/cart`, `/checkout`, `/notifications` đẩy lên trên shell | Một stack chung | Giữ trạng thái tab; đếm ngược vẫn chạy ngầm, nên timer chỉ chạy khi màn hình hiển thị |
| 10 | Quy tắc nghiệp vụ là hàm thuần có unit test; đồng hồ và `Random` được tiêm | Logic nằm trong widget | Kiểm thử xác định, không phụ thuộc giờ thật |
| 11 | `RivalSimulator` đặt giá ngẫu nhiên, chỉ chạy khi màn đấu giá mở, tắt được bằng cờ | Dữ liệu đấu giá tĩnh | Thấy được realtime, vượt giá, gia hạn như prototype |
| 12 | Không làm golden test, so thủ công với prototype khổ 402x860 | Golden test | YAGNI cho đồ án nhóm |

## 4. Thiết kế

### 4.1 Theme và token

- Màu: `background` `#F5F1E8`, `surface` `#FFFCF5`, `border` `#D9D1C0`, `divider` `#E3DCCD`, `textPrimary` `#1D1A15`, `textSecondary` `#5F594E`, `primary` `#2A6049` (nhấn `#1D4535`), `accent` `#B8462A`.
- Tông trạng thái (nền/chữ), dùng cho `AppTag`: đỏ `#F6E1D8`/`#A43D22`, xanh `#E1EDE5`/`#2A6049`, vàng `#F3E8CD`/`#86600F`, xám `#EBE6DB`/`#5F594E`, xanh dương `#E0E8EF`/`#2F5878`.
- Chữ: Newsreader cho tiêu đề và giá lớn, Be Vietnam Pro cho nội dung, JetBrains Mono cho nhãn nhỏ viết hoa.
- Hình khối: bo góc 10 đến 20, thẻ viền 1px thay bóng đổ nhuốm tím, bỏ gradient tím hồng, thanh tab cố định.
- Widget chỉ đọc `context.colors`. Kiểm tương phản WCAG từng cặp chữ/nền trước khi chốt; cặp nào dưới 4.5:1 thì chỉnh.

### 4.2 Shell và router

- Tab: Khám phá, Đấu giá, Bán, Ví, Tôi, hiện cho mọi người dùng đăng nhập. Theo prototype, Bán là nút tròn "+" ở giữa thanh dưới (không có nhãn chữ), thanh dưới cố định với viền trên 1px.
- `StatefulShellRoute`, mỗi nhánh một stack:
  - `home`: `/home`, `/home/book/:id`
  - `auctions`: `/auctions`, `/auctions/:id`, `/auctions/mine`
  - `sell`: `/sell`, `/sell/new` (wizard), `/sell/listing/:id`
  - `wallet`: `/wallet`, sheet nạp VietQR giả
  - `me`: `/me`, hồ sơ, đổi mật khẩu, ngôn ngữ, `/me/orders`, `/me/orders/:id`, khiếu nại
- Ngoài shell: `/login`, `/register`. Đẩy lên trên shell, ẩn thanh tab: `/cart`, `/checkout`, `/notifications`.
- Chưa đăng nhập hoặc mất phiên (`SessionEvents`) thì về `/login`. Bỏ `role_home_redirect.dart`.
- Nút Thông báo và Giỏ ở đầu Trang chủ có badge. Badge tab Đấu giá là số phiên theo dõi sắp kết thúc.

### 4.3 Dữ liệu mock và repository

Mỗi feature có `domain/` (model thuần Dart), `data/` (interface và bản `Mock...Repository`; listings, auth, profile có bản backend), `application/` (provider Riverpod). UI chỉ biết provider.

| Feature | Nguồn |
|---|---|
| auth, profile, listings | backend thật |
| cart, orders (kèm khiếu nại), wallet, auctions, notifications | mock |

Quy tắc nghiệp vụ nằm trong hàm thuần ở `domain/rules`, có unit test: phí đăng ký đấu giá, cọc, phí ship, bước giá, chống bắn tỉa, đếm ngược mua ngay, cửa sổ khiếu nại. Đồng hồ đi qua `clockProvider`, `Random` được tiêm. Món trong giỏ là sách thật nhưng đơn là giả; ghi chú rõ trong tài liệu.

### 4.4 Lộ trình, kiểm thử, xử lý lỗi

Mỗi lát: code, test, `flutter analyze` sạch, chạy thử trên máy ảo, rồi commit riêng. Chủ dự án duyệt từng lát trước khi sang lát tiếp.

| # | Lát | Nội dung |
|---|---|---|
| 0 | Nền | Token màu, font, restyle `core/widgets`, shell 5 tab, router |
| 1 | Trang chủ và Chi tiết sách | Danh sách từ backend, tìm kiếm, lọc danh mục, thêm vào giỏ |
| 2 | Giỏ, Thanh toán, Đơn hàng | Mock, tạo đơn, chi tiết đơn, khiếu nại |
| 3 | Ví | Số dư, lịch sử, nạp VietQR giả |
| 4 | Đấu giá | Danh sách, chi tiết, đăng ký cọc, đặt giá, mua ngay, đối thủ ảo |
| 5 | Bán | Tin của tôi, restyle wizard 4 bước |
| 6 | Tôi và Thông báo | Restyle hồ sơ, ngôn ngữ, thông báo |
| 7 | Dọn dẹp | Xóa `features/inspection/`, `role_provider.dart`, `nav_config` theo role; cập nhật `design-system.md` và l10n |

Kiểm thử: unit test cho hàm quy tắc và notifier mock; widget test cho các luồng thêm giỏ, thanh toán, đặt giá, nạp ví. Phần nào không chạy thử được thì ghi rõ khi báo xong.

Lỗi: backend giữ `ApiError` theo `error.code` cùng các view tải, trống, lỗi có nút Thử lại. Mock trả lỗi nghiệp vụ có mã (số dư không đủ, phiên đã kết thúc, giá thấp hơn bước tối thiểu), hiển thị qua `AppSnackbar` theo chuỗi i18n. Đặt giá khi hết hạn hoặc bị vượt thì cập nhật UI theo trạng thái mới.

Trường hợp biên: món trong giỏ bị bán mất lúc thanh toán thì báo và bỏ khỏi giỏ; số dư thấp thì dẫn thẳng tới sheet nạp; font lớn và xoay màn hình không làm vỡ layout, vùng chạm tối thiểu 48.

## 5. Ghi chú triển khai (cập nhật theo từng lát)

**Lát 0 (nền):**
- Nút chính dùng `#24543F` (nút "+" và nút trong prototype), liên kết/trạng thái thành công dùng `#2A6049`. `border` (`#8A8271`) và `textMuted` (`#686155`) được chỉnh nhẹ so với prototype để đạt tương phản AA.
- Nhãn tab VI: Khám phá, Đấu giá, Ví, Tôi (theo prototype, không phải "Trang chủ").
- Tạm giữ đường dẫn wizard và chi tiết tin ở `/listings/...` (không phải `/sell/...`); chuyển ở lát 5. Hồ sơ đã chuyển sang `/me/...`.
- Nút Thông báo tạm đặt ở AppBar của Khám phá; lát 1 thay bằng đầu trang theo prototype.
- Đấu giá và Ví là màn hình "Sắp có" tới lát 3 và 4.
- `features/inspection/` không còn truy cập được từ router; test của nó đã xóa, mã nguồn xóa ở lát 7 cùng `role_provider.dart`.
- Chưa so sánh bằng mắt với prototype trên máy ảo vì backend không chạy ở môi trường này (không đăng nhập được); đã kiểm bằng `flutter analyze` và `flutter test`.

## 6. Rủi ro

- Khối lượng lớn (8 lát); giảm bằng commit riêng từng lát và duyệt từng bước.
- Đếm ngược và đối thủ ảo chạy liên tục có thể tốn pin; timer chỉ chạy khi màn hình hiển thị.
- DTO listings thiếu trường so với prototype; chấp nhận ẩn thay vì bịa.
- Số liệu bước giá, chống bắn tỉa, cửa sổ khiếu nại chưa đọc kỹ; đọc lại từ script prototype ở lát 2 và 4.
- Việc duyệt tin chuyển sang web/Admin; cần xác nhận web đã có chức năng này.
