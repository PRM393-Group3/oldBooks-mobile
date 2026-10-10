# Design system, Profile, Đăng bán và Kiểm định (v1)

Tài liệu này ghi lại quyết định thiết kế đã chốt trong quá trình brainstorming. Nguồn yêu cầu: `Book-Marketplace-SRS-v1.2.pdf`, tài liệu tích hợp Profile của backend, và tài liệu thiết kế "Luồng Đăng bán và Kiểm định".

## 1. Tóm tắt phạm vi

- **Xây (đợt 1):** design system nền (theme, token, component chuẩn), lớp mạng và xác thực, tính năng Profile (xem, sửa, avatar, đổi mật khẩu), cùng Login/Register/Logout tối thiểu.
- **Xây (đợt 2):** luồng Đăng bán và Kiểm định cho cả 3 vai trò — Seller (wizard 4 bước, Tin của tôi, sửa và nộp lại), Inspector (hàng đợi, nhận tin, duyệt/từ chối), Buyer (danh sách và chi tiết tin công khai) — cùng thông báo trong app và điều hướng đổi theo vai trò.
- **Người dùng:** Buyer, Seller, Inspector. Admin dùng cổng web; trên mobile chỉ thấy tab Hồ sơ.
- **Ngoài phạm vi:** đặt giá và đếm ngược đấu giá thật, giỏ hàng, thanh toán, tìm kiếm và bộ lọc nâng cao, checklist kiểm định từng tiêu chí, sửa tin đã duyệt, quét ISBN, đổi email, OTP, quên mật khẩu, sổ địa chỉ, eKYC, xóa tài khoản, dark mode hoàn chỉnh, Admin trên mobile.

## 2. Nhật ký quyết định

| # | Quyết định | Phương án đã cân nhắc | Lý do |
|---|---|---|---|
| 1 | Giao guideline kèm Flutter design system trong `lib/` | Chỉ tài liệu; guideline kèm mockup; tất cả | Nhóm cần code dùng được ngay, duyệt từng bước |
| 2 | Phong cách hiện đại, sạch. **Cập nhật:** nền pha tím, nút viên thuốc, bo góc lớn, bóng đổ mềm nhuốm tím, gradient tím sang hồng cho điểm nhấn, thanh điều hướng nổi | Vintage ấm; lai | Dễ đọc giá, đếm ngược, trạng thái; quen thuộc với người mua 18-45 |
| 3 | Màu chính tím lavender `#7657DC` (đổi từ xanh ngọc `#0F766E` theo yêu cầu). Phần "nhạt" nằm ở nền và khối tonal `#EDE7FF` | Xanh ngọc; xanh dương; cam đất; tím nhạt hơn `#8B5CF6` | Tím sáng nhất vẫn cho chữ trắng đạt AA (5.04:1). `#8B5CF6` chỉ đạt 4.23 nên bị loại |
| 4 | Light đầy đủ, dark chỉ chuẩn bị token | Chỉ light; light và dark | SRS không bắt buộc dark; token tách sẵn nên bật sau không sửa widget |
| 5 | Phủ Buyer, Seller, Inspector | Chỉ Buyer; cả 4 vai trò | Khớp SRS 8.1; nhiều component dùng chung xuyên vai trò |
| 6 | Font Arimo (tương thích số đo Helvetica), bundle trong `assets/fonts/` | Be Vietnam Pro; font hệ thống | Helvetica có bản quyền và không có trên Android; Arimo giống nhau trên hai nền tảng |
| 7 | i18n VI và EN, mặc định theo hệ thống, dự phòng VI | Chỉ VI | Quyết định của chủ dự án. **SRS mục 1.2 ghi đa ngôn ngữ ngoài phạm vi v1.0, SRS cần cập nhật** |
| 8 | Nền tảng trước, profile sau | Profile trước với theme tạm; chỉ lớp mạng | Profile là tính năng đầu tiên có form, ảnh, lỗi theo trường nên kiểm chứng luôn component |
| 9 | Riverpod, cấu trúc theo feature | Bloc; Provider | Trạng thái bất đồng bộ (profile, sau này đấu giá realtime) gọn hơn; TEC-02 yêu cầu một thư viện |
| 10 | Auth: Login, Register, Logout | Không Register; thêm OTP | Register là cách duy nhất tạo Buyer/Seller thật; OTP chờ backend |
| 11 | Material 3 cộng `ThemeExtension` cho token | Widget tự vẽ; ThemeData mặc định | Ít code nhất, có sẵn accessibility, thêm dark chỉ cần thêm bộ token |
| 12 | Phủ đủ 3 vai trò (Seller, Inspector, Buyer) cho luồng đăng bán/kiểm định | Chỉ Seller trước; chỉ Seller+Inspector | Vòng đời tin chỉ kiểm chứng trọn vẹn khi có cả ba đầu |
| 13 | Điều hướng: tab riêng theo vai trò, "+ Đăng bán" là nút nổi | 5 tab cố định có tab Đăng bán; 3 tab dùng chung, mọi thứ vào Trang chủ | Đăng tin là hành động thỉnh thoảng, không xứng một tab; nút nổi hợp thao tác một tay (NFR-USA-06) |
| 14 | Admin trên mobile chỉ thấy tab Hồ sơ kèm ghi chú "quản trị ở web" | Chặn đăng nhập hẳn; cho Admin dùng màn Inspector | Tốn ít code nhất, không có ngõ cụt, Admin vẫn đổi được mật khẩu |
| 15 | Bản nháp tạo lười: `POST /listings` chỉ chạy khi lưu bước 1 | Tạo ngay khi mở wizard; tạo ngay rồi tự xóa nếu rỗng | Backend chưa có job dọn nháp; mở rồi thoát ngay không để lại rác |
| 16 | Mỗi bước wizard lưu bằng PUT riêng, state luôn là `ListingDto` server trả về | Wizard giữ state cục bộ, gửi một lượt cuối | Khớp thiết kế nháp của backend; thoát giữa chừng vẫn tiếp tục đúng chỗ, không mất khi app bị kill |
| 17 | DTO doc chưa mô tả rõ (rules, phân trang, hàng đợi, thông báo) đọc phòng thủ, có giá trị mặc định | Coi doc là đặc tả đầy đủ, không phòng thủ | Doc tự nhận nhiều chỗ chưa chốt tên trường; cần đối chiếu Swagger khi backend chạy |

## 3. Cách đổi giao diện nhanh

| Muốn đổi | Sửa ở |
|---|---|
| Màu thương hiệu, màu trạng thái | `lib/core/theme/app_palette.dart` (nguồn duy nhất của giá trị màu) |
| Gán màu thô cho vai trò ngữ nghĩa | `lib/core/theme/app_colors.dart` (`AppColors.light`) |
| Khoảng cách, bo góc, kích thước | `lib/core/theme/app_dimens.dart` |
| Cỡ chữ, font | `lib/core/theme/app_typography.dart`, mục `fonts` trong `pubspec.yaml` |
| Kiểu dáng widget Material | `lib/core/theme/app_theme.dart` |
| Thêm dark mode | Khai báo `AppColors.dark`, thêm `AppTheme.dark()`, đặt `darkTheme` trong `app.dart` |

Widget chỉ đọc màu qua `context.colors`, không dùng `AppPalette` hay mã màu trực tiếp.

## 4. Token

Tương phản đã kiểm theo WCAG 2.1 (chữ >= 4.5:1, viền và icon >= 3:1).

| Token | Giá trị | Tương phản trên trắng |
|---|---|---|
| `primary` (chữ trắng trên nền này: 5.04) | `#7657DC` | 5.04 |
| `primaryContainer` / `onPrimaryContainer` | `#EDE7FF` / `#2E1F7A` | 10.97 (chữ trên nền nhạt) |
| `background` / `surfaceMuted` | `#F7F5FF` / `#EFEBFF` | |
| `textPrimary` / `textSecondary` / `textMuted` | `#16132B` / `#4A4763` / `#6B6885` | 18.07 / 8.85 / 5.32 |
| `border` (viền ô nhập, icon) | `#77748F` | 4.49 |
| `success` / `warning` / `error` / `info` | `#0E7C57` / `#B45309` / `#C2183F` / `#2563EB` | 5.20 / 5.02 / 6.01 / 5.17 |
| `auction` (đếm ngược gấp) | `#C93B1E` | 5.09 |
| `gradientStart` → `gradientEnd` (điểm nhấn, không đặt chữ) | `#8B6CF0` → `#E879C9` | |
| `heroStart` → `heroEnd` (nền thẻ hero) | `#EDE7FF` → `#FCE7F6` | |
| `shadow` | `#7657DC` alpha 12% | |

`divider` (`#E7E2F7`) chỉ dùng làm đường kẻ trang trí, không dùng làm viền ô nhập.

Chữ: display 28/36, title 20/28, subtitle 16/24, body 16/24, bodySmall 14/20, label 14/20, caption 12/16. Spacing bội của 4 (4 đến 48). Bo góc: 12 (nhỏ), 16 (ô nhập), 24 (thẻ, sheet, dialog), nút và badge dạng viên thuốc. Bóng đổ mềm `softShadow` cho thẻ và thanh điều hướng nổi. Vùng chạm tối thiểu 48.

## 5. Component (`lib/core/widgets/`)

| Component | Vai trò |
|---|---|
| `AppButton` | primary, secondary, text, danger; trạng thái loading giữ nguyên kích thước |
| `AppTextField` | nhãn nổi, lỗi từ validator hoặc server, hiện/ẩn mật khẩu |
| `AppAvatar` | ảnh mạng, ảnh cục bộ hoặc chữ cái đầu; nút sửa |
| `AppTag` | nhãn viên thuốc theo tông (nền cho badge trạng thái tin đăng, đơn, đấu giá) |
| `AppPage` | khung màn hình: AppBar, cuộn, thanh hành động dính đáy, kéo để tải lại |
| `AppSection`, `AppInfoRow`, `AppMenuTile` | nhóm dòng trong thẻ |
| `AppSnackbar` | thông báo kèm biểu tượng; `apiError` map `error.code` sang chuỗi i18n |
| `AppLoadingView`, `AppEmptyView`, `AppErrorView` | trạng thái tải, trống, lỗi (lỗi hệ thống kèm mã hỗ trợ) |
| `AppBottomNav`, `showConfirmDialog` | điều hướng dưới (2 đến 5 mục, có badge số), hộp thoại xác nhận |
| `AppStepProgress` | thanh tiến trình wizard nhiều bước |
| `AppImageSlot` | ô ảnh: trống, đang tải, xong, lỗi kèm thử lại |
| `AppCountdown` | đếm ngược (khóa kiểm định 30 phút, sau này đấu giá) |
| `AppImageViewer` (`showImageViewer`) | xem ảnh toàn màn hình, vuốt, phóng to hai ngón |
| `AppPagedList` | danh sách tải theo lô 20, kéo để làm mới, lỗi tải thêm có nút thử lại |
| `AppKeyValueRow` (trong `app_section.dart`) | dòng nhãn/giá trị trong khối thông tin chi tiết |

Widget riêng cho tin đăng (`lib/features/listings/presentation/widgets/`): `ListingCard`, `ListingStatusTag`, `ListingGallery`, `InspectionBlock` (khối kết quả kiểm định, ngang hàng với giá theo FR-CAT-04), `ListingInfoBlock` (dùng chung giữa chi tiết tin và màn kiểm định).

## 6. Kiến trúc

```
lib/
  app/          app.dart, app_router.dart, app_shell.dart, nav_config.dart, role_home_redirect.dart
  core/         theme, l10n, network, storage, validation, widgets, config, paging, util
  features/
    auth/         login, register, logout
    profile/      xem, sửa, avatar, đổi mật khẩu; role_provider.dart (vai trò cho điều hướng)
    categories/    cây danh mục
    listings/      domain (Listing, enum, rules, input), data, application, presentation
                   (seller/wizard, seller/, browse/, widgets/)
    inspection/    hàng đợi, đang giữ, màn kiểm định, bảng từ chối
    notifications/ danh sách, badge chưa đọc
```

- `presentation` gọi provider Riverpod, provider gọi repository, repository dùng `ApiClient`.
- Hai Dio riêng: `apiDio` (có `AuthInterceptor`) và `plainDio` (không interceptor) dùng để refresh token và PUT thẳng lên Blob Storage không kèm `Authorization`. `BlobUploader` (`core/network/blob_uploader.dart`) gói luồng 2 bước này, dùng chung cho avatar và ảnh tin đăng.
- Tầng mạng báo mất phiên qua `SessionEvents`; `AuthController` lắng nghe và router tự chuyển về đăng nhập, nên `core/network` không phụ thuộc `features/auth`.
- Riverpod 3 tự thử lại provider lỗi; đã tắt (`ProviderScope(retry: ...)`) để lỗi mạng hiện ngay và người dùng chủ động bấm Thử lại.
- **Điều hướng theo vai trò:** `app/nav_config.dart` là bảng duy nhất ánh xạ `UserRole` sang danh sách tab; `AppShell` đọc vai trò từ `currentRoleProvider` (dựa trên `GET /profile`, không parse token). Thêm vai trò hoặc tab chỉ sửa một chỗ.
- **Wizard đăng bán:** `ListingDraft` (AsyncNotifier) không giữ bản sao dữ liệu — mỗi bước gọi repository (PUT) rồi gán `ListingDto` trả về làm state. `ImageDraft` (ChangeNotifier riêng, không qua Riverpod) quản lý 4 ô ảnh bắt buộc và ảnh thêm, tải tối đa 2 ảnh cùng lúc (`AsyncPool`), mỗi ảnh thử lại độc lập.
- **Kiểm định:** `ReviewController` tự `claim` khi mở màn hình; lỗi `INSPECTION_CLAIM_REQUIRED` chuyển UI sang trạng thái "hết khóa, nhận lại tin" **thay vì** hiện thêm snackbar nổi (từng che mất chính nút phục hồi — xem mục 8).
- **Mã lỗi mới** (`ApiErrorCode`): `emailTaken`, `accountDisabled`, `listingIncomplete`, `listingImageInvalid`, `listingNotFound`, `listingInvalidState`, `listingSubmissionLimit`, `listingConcurrentUpdate`, `listingAlreadyClaimed`, `claimRequired`, `categoryNotFound`, `notificationNotFound`. `ApiError.needsReload` gom 4 mã 409 cùng cần tải lại tin. Tài khoản bị khóa (`ACCOUNT_DISABLED`) làm `AuthInterceptor` đăng xuất ngay cả khi accessToken còn hạn.

## 7. Giả định và rủi ro

- Router `go_router`, http `dio`, chọn ảnh `image_picker` (thu nhỏ 1024px và nén 85% ngay khi chọn), lưu token `flutter_secure_storage`.
- Base URL theo nền tảng: iOS simulator `localhost`, Android emulator `10.0.2.2`, máy thật dùng `--dart-define=API_BASE_URL=http://<IP-LAN>:5148`.
- Lỗi hiển thị theo `error.code`, không bao giờ theo `error.message`. Chỉ lỗi 500 hiện thêm `traceId`.
- Backend chưa giới hạn tần suất đổi mật khẩu; client tự khóa 30 giây sau 3 lần sai mật khẩu hiện tại.
- Chuỗi tiếng Anh dài hơn tiếng Việt khoảng 20-30%: layout co giãn, không cố định độ rộng.
- Chưa kiểm tra trên thiết bị Android và chưa kiểm tra chọn ảnh thật từ thư viện/máy ảnh (simulator không có camera).
- **Hình dạng DTO chưa nêu rõ trong doc backend** (`ListingRules`, `ListingSummaryDto`, phân trang, `InspectionQueueItemDto`, thông báo) được suy từ mô tả, đọc phòng thủ (`core/util/json_read.dart`) với giá trị mặc định khớp doc. **Cần đối chiếu lại với Swagger khi backend chạy thật**, đặc biệt tên trường của `GET /listings/rules` và phần bao của phân trang.
- Ảnh thêm ngoài 4 góc bắt buộc tạm gán loại `InnerPage` (doc không có loại riêng cho ảnh thêm).
- `blobName` của ảnh cũ (khi mở lại tin) được suy từ URL (phần sau `/public/`), không lưu riêng — nếu backend đổi cấu trúc URL thì cần cập nhật `ListingImage.blobName`.

## 8. Lỗi thật do test bắt được (đợt đăng bán/kiểm định)

Cách làm: viết widget test lái đúng luồng người dùng trước, sửa code khi test lộ hành vi sai — không sửa test để né lỗi thật.

1. **Nút "Nộp kiểm định" quay vô hạn sau khi thành công.** `_submit()` bọc cả việc gọi API lẫn `showDialog` hộp thoại thành công trong cùng một khối `_run`, nên cờ `_saving` chỉ tắt sau khi người dùng đóng hộp thoại — nút vẫn hiện `CircularProgressIndicator` quay suốt lúc đó dù đã ẩn sau hộp thoại. Sửa: `_run` chỉ bọc đúng lời gọi mạng, `showDialog` chạy sau khi `_saving` đã tắt.
2. **`TextEditingController` dùng sau khi hủy.** Dialog "Duyệt tin đăng" tự tạo `TextEditingController()` ngay trong hàm rồi `dispose()` liền sau khi `showDialog` trả về — nhưng hộp thoại vẫn đang chạy hoạt ảnh đóng, khung hình kế tiếp dùng phải controller đã hủy và crash. Sửa: chuyển sang `_ApproveDialog` (StatefulWidget riêng), controller sống theo vòng đời `State`, chỉ dispose khi framework gỡ hẳn widget.
3. **Snackbar che mất nút phục hồi.** Khi gặp `INSPECTION_CLAIM_REQUIRED`, code vừa đổi UI sang banner cố định "Khóa đã hết hạn..." kèm nút "Nhận lại tin", vừa bắn thêm một `SnackBar` nổi cùng nội dung — snackbar nằm đúng vị trí nút trong 4 giây, chặn thao tác phục hồi chính. Sửa: bỏ snackbar cho riêng trường hợp này, banner cố định đã đủ.

## 9. Chạy thử

```
flutter run --dart-define=API_BASE_URL=http://localhost:5148   # backend thật
flutter test                                                    # 100 test
```
