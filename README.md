# Oldbook – Chợ sách cũ (Android)

Ứng dụng mua bán, đấu giá sách cũ của nhóm PRM393 Group 3. Tài liệu này hướng dẫn
cài đặt bản phát hành Android (file APK) lên điện thoại hoặc máy ảo.

> Bản hiện tại: **v1.0.0**, kết nối server **staging**. Dữ liệu là dữ liệu thử,
> có thể bị xóa khi backend reset. Không nhập thông tin thật quan trọng.

Mã nguồn và hướng dẫn cho lập trình viên: [books_marketplace_mobile/README.md](books_marketplace_mobile/README.md).

## Mục lục

1. [Yêu cầu thiết bị](#1-yêu-cầu-thiết-bị)
2. [Tải file APK](#2-tải-file-apk)
3. [Kiểm tra file (tùy chọn)](#3-kiểm-tra-file-tùy-chọn)
4. [Cho phép cài ứng dụng ngoài Google Play](#4-cho-phép-cài-ứng-dụng-ngoài-google-play)
5. [Cài đặt](#5-cài-đặt)
6. [Lần đầu sử dụng](#6-lần-đầu-sử-dụng)
7. [Cập nhật lên bản mới](#7-cập-nhật-lên-bản-mới)
8. [Gỡ cài đặt](#8-gỡ-cài-đặt)
9. [Cài lên máy ảo Android hoặc qua máy tính (adb)](#9-cài-lên-máy-ảo-android-hoặc-qua-máy-tính-adb)
10. [Xử lý sự cố](#10-xử-lý-sự-cố)

## 1. Yêu cầu thiết bị

| Mục | Yêu cầu |
|---|---|
| Hệ điều hành | Android **7.0 (API 24)** trở lên |
| Kiến trúc CPU | arm64-v8a, armeabi-v7a hoặc x86_64 (gần như mọi điện thoại và máy ảo hiện nay) |
| Dung lượng trống | Khoảng **150 MB** (file APK ~60 MB, sau khi cài ~120 MB) |
| Mạng | Wi-Fi hoặc 4G/5G. Ứng dụng luôn cần Internet |
| Email | Một địa chỉ email nhận được thư, dùng để nhận mã OTP khi đăng ký |

Quyền ứng dụng sử dụng:

- **Internet**: gọi server. Được cấp tự động khi cài.
- **Ảnh**: chỉ khi bạn chọn ảnh đại diện, ảnh sách hoặc ảnh khiếu nại. Ứng dụng
  dùng trình chọn ảnh của hệ thống và chỉ đọc những ảnh bạn chọn. Không dùng
  camera, vị trí hay danh bạ.

## 2. Tải file APK

Bản phát hành nằm ở trang **Releases** của repo:

**https://github.com/PRM393-Group3/oldBooks-mobile/releases/latest**

1. Mở link trên, bằng trình duyệt trên điện thoại hoặc trên máy tính.
2. Ở mục **Assets**, tải file `oldbook-<phiên bản>.apk`, ví dụ `oldbook-1.0.0.apk`.
3. File `oldbook-<phiên bản>.apk.sha256` dùng để kiểm tra file (bước 3), không bắt buộc.

> Repo đang ở chế độ **private**: bạn phải đăng nhập GitHub bằng tài khoản đã được
> thêm vào tổ chức `PRM393-Group3` thì mới thấy trang Releases. Nếu không có
> quyền, nhờ thành viên nhóm gửi trực tiếp file APK (Zalo, Google Drive...).

Nếu tải trên máy tính, chép file APK sang điện thoại bằng cáp USB, Google Drive
hoặc Zalo, rồi làm tiếp từ bước 4 trên điện thoại.

## 3. Kiểm tra file (tùy chọn)

Bước này giúp chắc chắn file không bị hỏng hay bị thay đổi khi tải về. Chạy trên
máy tính, trong thư mục chứa cả hai file:

```bash
# macOS
shasum -a 256 -c oldbook-1.0.0.apk.sha256

# Linux
sha256sum -c oldbook-1.0.0.apk.sha256
```

```powershell
# Windows (PowerShell): so sánh kết quả với nội dung file .sha256
Get-FileHash .\oldbook-1.0.0.apk -Algorithm SHA256
```

Kết quả `oldbook-1.0.0.apk: OK`, hoặc hai chuỗi mã trùng nhau, là file đúng.

Mọi bản phát hành chính thức đều được ký bằng cùng một chứng chỉ. Dấu vân tay
SHA-256 của chứng chỉ bắt đầu bằng `3F:17:A3:BA:9C:08:1D:F0`. Có thể kiểm tra bằng
`apksigner verify --print-certs oldbook-1.0.0.apk` (có trong Android SDK build-tools).

## 4. Cho phép cài ứng dụng ngoài Google Play

Oldbook chưa có trên Google Play, nên Android sẽ chặn cài file APK cho tới khi
bạn cấp quyền **"Cài ứng dụng không xác định"** cho ứng dụng dùng để mở file:
trình duyệt (Chrome), trình quản lý tệp (Files/My Files) hoặc Zalo.

### Android 8.0 trở lên (đa số máy hiện nay)

Cách nhanh nhất: mở file APK (bước 5). Android sẽ hiện thông báo
*"Vì lý do bảo mật, điện thoại của bạn không được phép cài đặt ứng dụng không rõ
nguồn gốc từ nguồn này"*. Bấm **Cài đặt** (Settings), bật **Cho phép từ nguồn
này** (Allow from this source), rồi bấm quay lại.

Hoặc bật trước trong Cài đặt:

| Hãng | Đường dẫn |
|---|---|
| Android gốc (Pixel, Nokia, Motorola...) | Cài đặt → Ứng dụng → Quyền truy cập đặc biệt của ứng dụng → Cài đặt ứng dụng không xác định → chọn Chrome/Files → bật **Cho phép từ nguồn này** |
| Samsung (One UI) | Cài đặt → Ứng dụng → ⋮ → Quyền truy cập đặc biệt → Cài đặt ứng dụng không rõ → chọn ứng dụng → bật **Cho phép từ nguồn này** |
| Xiaomi / Redmi / POCO (MIUI, HyperOS) | Cài đặt → Ứng dụng → Quyền → Cài đặt ứng dụng không xác định → chọn ứng dụng → bật |
| OPPO / realme (ColorOS) | Cài đặt → Quyền riêng tư (hoặc Bảo mật) → Cài đặt ứng dụng không xác định → chọn ứng dụng → bật |
| vivo (Funtouch OS / OriginOS) | Cài đặt → Bảo mật → Cài đặt ứng dụng không xác định → chọn ứng dụng → bật |

Tên mục có thể khác đôi chút tùy phiên bản. Gõ "không xác định" hoặc "unknown"
vào ô tìm kiếm của Cài đặt để tìm nhanh.

### Android 7.x

Cài đặt → Bảo mật → bật **Nguồn không xác định** (Unknown sources) → OK.

> Sau khi cài xong Oldbook, bạn có thể tắt lại quyền này để an toàn hơn.

## 5. Cài đặt

1. Mở file `oldbook-1.0.0.apk`: bấm vào thông báo tải xong của trình duyệt, hoặc
   vào ứng dụng **Files / Quản lý tệp → Tải xuống (Downloads)**.
2. Màn hình hỏi *"Bạn có muốn cài đặt ứng dụng này không?"* → bấm **Cài đặt**.
3. Nếu **Google Play Protect** cảnh báo *"Ứng dụng chưa được xác minh"* hoặc
   *"Play Protect không nhận dạng được nhà phát triển"*: đây là cảnh báo bình
   thường cho ứng dụng không cài từ Google Play. Bấm **Thông tin chi tiết** (More
   details) → **Vẫn cài đặt** (Install anyway). Nếu được hỏi có gửi ứng dụng để
   quét không, chọn tùy ý.
4. Chờ vài giây đến khi thấy **Đã cài đặt ứng dụng** → bấm **Mở**.

Biểu tượng **Oldbook** sẽ xuất hiện trong danh sách ứng dụng.

## 6. Lần đầu sử dụng

### Đăng ký tài khoản

1. Mở Oldbook → **Đăng ký**.
2. Nhập **Họ và tên**, **Số điện thoại** (ví dụ `0912345678`) và **Email**.
3. Bấm **Gửi mã**. Ứng dụng hiện *"Mã đã gửi tới n\*\*\*\*\*\*\*a@gmail.com"*.
4. Mở hộp thư, tìm thư có tiêu đề **"Oldbook: mã OTP 123456"** gửi từ
   `DoNotReply@...azurecomm.net`. **Kiểm tra cả thư mục Spam/Quảng cáo.**
5. Nhập mã 6 số, mật khẩu (ít nhất 8 ký tự, có cả chữ và số), tick đồng ý điều
   khoản → **Đăng ký**.

Lưu ý:

- Mã OTP gửi qua **email**, không gửi qua SMS.
- Mã có hạn (thường 5 phút, hiện đếm ngược dưới ô nhập). Sau 60 giây mới được
  bấm **Gửi lại**, và gửi lại thì mã cũ hết hiệu lực.
- Nếu sửa số điện thoại hoặc email sau khi đã gửi mã, bạn phải gửi mã mới.
- Mỗi số điện thoại được gửi tối đa 5 mã mỗi giờ.

### Đăng nhập, quên mật khẩu

- **Đăng nhập** bằng số điện thoại + mật khẩu.
- **Quên mật khẩu?** → nhập số điện thoại → **Gửi mã**. Mã được gửi tới **email
  của tài khoản** → nhập mã và mật khẩu mới.

### Giới hạn của bản staging

- **Không có thông báo đẩy (push)**: xem thông báo trong tab thông báo của ứng dụng.
- **Nạp tiền ví** chỉ hoạt động khi backend đã cấu hình cổng thanh toán sandbox.
- **Dữ liệu có thể bị xóa** khi backend reset. Khi đó hãy đăng ký lại.

## 7. Cập nhật lên bản mới

1. Tải file APK mới từ trang [Releases](https://github.com/PRM393-Group3/oldBooks-mobile/releases/latest).
2. Mở file và bấm **Cập nhật** (Update). **Không cần gỡ bản cũ**, dữ liệu đăng
   nhập được giữ lại.

Ứng dụng không tự cập nhật. Theo dõi trang Releases hoặc thông báo của nhóm.

Nếu Android báo *"Ứng dụng chưa được cài đặt vì gói xung đột với gói hiện có"*:
bản đang có trên máy được ký bằng chứng chỉ khác, ví dụ bản build thử từ Android
Studio. Gỡ bản cũ (bước 8) rồi cài lại.

## 8. Gỡ cài đặt

- Nhấn giữ biểu tượng **Oldbook** → **Gỡ cài đặt** (Uninstall) → **OK**, hoặc
- Cài đặt → Ứng dụng → **Oldbook** → **Gỡ cài đặt**.

Gỡ ứng dụng sẽ xóa phiên đăng nhập trên máy. Tài khoản trên server vẫn còn. Muốn
xóa hẳn tài khoản, vào **Hồ sơ → Xóa tài khoản** trong ứng dụng trước khi gỡ.

## 9. Cài lên máy ảo Android hoặc qua máy tính (adb)

### Máy ảo (Android Studio Emulator)

1. Mở Android Studio → **Device Manager** → khởi động một máy ảo có API 24 trở lên.
2. **Kéo thả** file `oldbook-1.0.0.apk` vào cửa sổ máy ảo. APK được cài tự động.

### Qua cáp USB bằng adb

Cần [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools).

1. Trên điện thoại: Cài đặt → Thông tin điện thoại → bấm **Số hiệu bản tạo**
   (Build number) 7 lần để bật **Tùy chọn nhà phát triển**. Sau đó vào Tùy chọn
   nhà phát triển → bật **Gỡ lỗi USB** (USB debugging).
2. Cắm cáp, trên điện thoại chọn **Cho phép** gỡ lỗi USB cho máy tính này.
3. Trên máy tính:

```bash
adb devices                          # phải thấy thiết bị ở trạng thái "device"
adb install -r oldbook-1.0.0.apk     # -r: cài đè, giữ dữ liệu khi cập nhật
```

Gỡ bằng adb: `adb uninstall vn.oldbook.mobile`.

## 10. Xử lý sự cố

| Hiện tượng | Nguyên nhân thường gặp | Cách xử lý |
|---|---|---|
| Không thấy trang Releases (404) | Repo private, tài khoản chưa có quyền hoặc chưa đăng nhập | Đăng nhập GitHub đúng tài khoản, hoặc nhờ nhóm gửi file APK |
| "Không được phép cài đặt ứng dụng không rõ nguồn gốc" | Chưa cấp quyền cho ứng dụng mở file | Làm lại bước 4 cho đúng ứng dụng (Chrome, Files, Zalo...) |
| "Đã xảy ra lỗi khi phân tích cú pháp gói" (Parse error) | File tải chưa xong/bị hỏng, hoặc Android dưới 7.0 | Tải lại file và kiểm tra SHA-256 (bước 3). Kiểm tra phiên bản Android |
| "Ứng dụng chưa được cài đặt" / "gói xung đột" | Đã có bản Oldbook ký bằng chứng chỉ khác | Gỡ bản cũ rồi cài lại |
| Play Protect chặn cài đặt | Ứng dụng không đến từ Google Play | **Thông tin chi tiết → Vẫn cài đặt** |
| "Không có kết nối mạng..." / quay mãi không tải | Mất mạng, Wi-Fi chặn, hoặc server staging đang khởi động lại | Kiểm tra Internet, thử 4G, chờ 1–2 phút rồi thử lại. Mỗi thao tác có thể mất 0,3–1,5 giây |
| Không nhận được mail OTP | Thư vào Spam, gõ sai email, hạn mức gửi thư | Kiểm tra Spam/Quảng cáo. Đối chiếu email đã che trên màn hình. Chờ vài phút rồi **Gửi lại** |
| "Không gửi được mã, hãy thử lại sau" | Dịch vụ email tạm lỗi | Thử lại sau ít phút |
| "Gửi lại sau ...s" kéo dài / "Bạn thao tác quá nhanh..." | Đã gửi quá 5 mã/giờ cho số này | Chờ hết thời gian đếm ngược |
| "Email này đã thuộc tài khoản khác..." / "Email này đã được sử dụng." | Email đã dùng để đăng ký | Đăng nhập bằng tài khoản cũ hoặc dùng email khác |
| "Số điện thoại này đã có tài khoản..." | Số điện thoại đã có tài khoản trên staging | **Đăng nhập** hoặc **Quên mật khẩu?** |
| "Tài khoản chưa có email, hãy liên hệ hỗ trợ" | Tài khoản tạo trước khi bật OTP email | Liên hệ nhóm phát triển |
| Bị đăng xuất liên tục / "Phiên đăng nhập đã hết hạn" | Dữ liệu staging bị reset, hoặc token cũ | Đăng xuất, đăng nhập lại. Nếu vẫn lỗi thì đăng ký lại |

Khi báo lỗi cho nhóm, gửi kèm: phiên bản ứng dụng (ví dụ v1.0.0), hãng/model máy,
phiên bản Android, các bước dẫn tới lỗi, ảnh chụp màn hình, và **mã hỗ trợ** nếu
ứng dụng hiển thị.

---

PRM393 – Group 3. Bản phát hành: [Releases](https://github.com/PRM393-Group3/oldBooks-mobile/releases).
