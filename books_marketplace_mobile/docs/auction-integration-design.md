# Thiết kế tích hợp đấu giá (mobile)

Ngày: 2026-10-10. Nguồn: tài liệu backend `com.oldBooks_Api/docs/integration/11-auctions.md`, `13-auctions-live-delivery.md`, `03-notifications.md`.

## 1. Tóm tắt

- **Làm gì**: nối thật toàn bộ luồng đấu giá với backend theo tài liệu 11 và 13:
  - tạo phiên (ảnh, mã nhập kho, hủy, phương án khi không đủ người, lệnh trả sách);
  - danh sách và chi tiết phiên, đăng ký và hủy đăng ký;
  - phiên realtime (SignalR), trả giá, mua ngay, lịch sử lượt;
  - "Phiên của tôi" với 4 tab: SELLER, BIDDER, LEADING, WINNER;
  - "Đơn đấu giá" (tab Mua/Bán, chi tiết theo `status` và `postExpiry.status`, đổi địa chỉ, phí ship, chọn lưu kho, chọn sau hết hạn, khiếu nại);
  - thông báo in-app `AUCTION_*` và `RETURN_*` có điều hướng.
- **Vì sao**: đấu giá hiện chạy hoàn toàn bằng simulator phía client (`features/sim`). Backend đã xong giai đoạn 6a, 6b và 6c.
- **Cho ai**: người bán, người chơi, người thắng.
- **Ràng buộc**:
  - Giữ pattern hiện có: Riverpod, `ApiClient`/`ApiError`, `newIdempotencyKey()` với `_key ??=`, enum có `fromApi` + `unknown`, `PagedNotifier`, l10n vi/en.
  - Realtime dùng `signalr_netcore`.
  - Gỡ hẳn `features/sim`; `UI_PREVIEW` dùng fake repository.
- **Ngoài phạm vi**: FCM/push hệ thống, chức năng admin, thay đổi backend.

## 2. Giả định

1. Màn phiên cập nhật dưới 1 giây sau sự kiện. Đồng hồ tick 1 giây theo offset server. Nút trả giá bị khóa khi đang gửi request; đây là cách debounce, không có request song song.
2. Mỗi lúc chỉ mở 1 phiên realtime. Hub kết nối khi có màn subscribe và đóng khi không còn màn nào.
3. `isLeading` không suy ra từ payload. Nhận `bid.placed`/`countdown.reset` có `amount` khác lượt mình vừa đặt thì đặt `false` ngay, rồi gọi lại `GET /auctions/{id}` (debounce 500ms) để xác nhận.
4. `INSUFFICIENT_BALANCE`: mở `showWalletTopupSheet(initialAmount: required - available)`. Người dùng tự bấm lại, trừ "Thanh toán phí ship": sau khi nạp xong, app tự gọi lại với cùng key.
5. `RATE_LIMITED`: khóa nút theo `retryAfter` (mặc định 1 giây).
6. Hub không dùng token. Không log PII. Idempotency-Key chỉ giữ trong state của sheet/panel, không lưu xuống đĩa.
7. Giới hạn bước nhảy và giá mua ngay lấy từ `GET /config/public` (`PublicConfig` đã có). Server vẫn là nơi kiểm tra cuối.
8. Làm trên nhánh `duymai`, chia commit theo từng bước ở mục 11.

## 3. Decision log

| # | Quyết định | Phương án khác | Lý do |
|---|---|---|---|
| D1 | Phạm vi: toàn bộ luồng 11 + 13 | Chỉ 13; bỏ tạo phiên | Danh sách/đăng ký đang chạy sim. Chỉ làm 13 thì hai nguồn dữ liệu sẽ lệch nhau |
| D2 | Gỡ hẳn `features/sim` | Chỉ gỡ khỏi đấu giá; giữ sim cho preview | Chỉ còn một nguồn dữ liệu. Preview dùng fake repository như các module khác |
| D3 | Dùng `signalr_netcore` | Tự viết client trên `web_socket_channel`; polling | Có sẵn tự kết nối lại, ít code, đúng hướng dẫn backend |
| D4 | Thông báo chỉ in-app, có hàm điều hướng dùng chung | Thêm FCM; thêm local notification | Chưa có project Firebase. Sau này push gọi lại cùng hàm |
| D5 | Màn riêng `/me/auction-orders` (tab Mua/Bán) | Gộp vào `orders_screen`; chỉ vào từ phiên | DTO và vòng đời khác đơn thường; đáp ứng checklist 9.6 |
| D6 | Test mức đầy đủ: unit, controller, widget | Chỉ unit; tối thiểu | Logic realtime và tiền dễ sai, cần chặn hồi quy |
| D7 | State realtime: `AuctionLiveController` theo từng phiên + `AuctionHub` dùng chung có đếm subscriber | Repository trả về stream; `StatefulWidget` tự giữ kết nối | Khớp pattern Riverpod, test được bằng fake hub, autoDispose tự `Unsubscribe` |
| D8 | Tạo phiên ngay trong `sell_screen` (chế độ Đấu giá), không tách màn | Màn `create_auction_screen` riêng | Form đã có chế độ chuyển, ảnh và trường sách; chỉ thay nhánh submit |
| D9 | Thông báo `AUCTION_*` được xét trước nhánh `orderId`/`complaintId` cũ | Giữ thứ tự cũ | Tránh mở nhầm màn đơn thường |
| D10 | `live_auction_strip` ở Home không dùng realtime | Subscribe nhiều phiên | Mỗi lúc chỉ 1 phiên realtime; Home chỉ cần ảnh chụp |

## 4. Cấu trúc module

```
lib/features/auctions/
  domain/
    auction_enums.dart      AuctionStatus, RegistrationStatus, AuctionRole, BidKind,
                            FallbackChoice, ReturnOrderStatus
    auction.dart            AuctionSummary, Auction (owner, myRegistration, live),
                            AuctionLive, Bid, ReturnOrder
    auction_event.dart      AuctionLiveEvent (payload chung + name)
  data/
    auction_repository.dart list, get, bids, create, cancel, register, unregister,
                            placeBid, buyNow, fallback, myAuctions(role)
    auction_hub.dart        interface AuctionHub + SignalRAuctionHub
  application/
    auction_providers.dart  repository, hub, auctionListProvider, myAuctionsProvider(role)
    auction_live_controller.dart  AuctionLiveController + reduceLive()
    auction_publisher.dart  tải ảnh + POST /auctions
    server_clock.dart       ServerClock
  presentation/
    auctions_screen, auction_detail_screen, auction_card, live_auction_strip,
    bid_sheet, buy_now_dialog, register_sheet, fallback_sheet,
    inbound_code_card, return_order_card, seller_panels, countdown_text,
    my_auctions_screen

lib/features/auction_orders/
  domain/        auction_order.dart (AuctionOrderStatus, PostExpiryStatus, DeliveryResult,
                 CollectionChoice, OrderViewerRole, AuctionOrder, Delivery, Storage, PostExpiry)
  data/          auction_order_repository.dart
  application/   auction_order_providers.dart (list theo role, AuctionOrderController)
  presentation/  auction_orders_screen, auction_order_detail_screen, order_status_panels

lib/core/
  util/address_picker.dart              tách từ _pickAddress của cart_screen
  navigation/notification_router.dart   notificationTarget(n)
```

Mọi enum có `api` string, giá trị `unknown('')` và `fromApi` với `orElse: unknown`. JSON đọc bằng `json_read`.

**Routes**

| Route | Màn |
|---|---|
| `/auctions` | Danh sách (tab shell) |
| `/auctions/:id` | Chi tiết phiên |
| `/auctions/mine?tab=seller\|bidder\|leading\|winner` | Phiên của tôi |
| `/me/auction-orders?role=buyer\|seller` | Đơn đấu giá |
| `/me/auction-orders/:id` | Chi tiết đơn |

Bỏ route `/me/sim-orders`.

**Gói mới**: `signalr_netcore`.

## 5. Realtime và đồng hồ

### ServerClock
- `offset = serverTime - DateTime.now().toUtc()`, cập nhật mỗi khi có `serverTime` mới (GET, kết quả POST, sự kiện hub).
- `now() = DateTime.now().toUtc() + offset`.
- `remaining(to)` kẹp tại 0.

### Mốc đếm ngược

| Status | Mốc |
|---|---|
| `REGISTRATION_OPEN` | `registrationClosesAt` |
| `CONFIRMED` | `startAt` |
| `LIVE` | `live.endAt` |
| `BUY_NOW_COUNTDOWN` | `live.countdownEndAt`, có dòng phụ hiển thị `hardEndAt` |

- `CountdownText` có timer 1 giây riêng, chỉ widget này rebuild.
- Về 0 mà chưa nhận `auction.ended` thì hiện "Đang chốt…" và gọi lại GET một lần sau 3 giây.

### AuctionHub
- URL `{Env.apiBase}/hubs/auctions`, không token, bật `withAutomaticReconnect()`.
- Đăng ký 6 sự kiện: `auction.started`, `bid.placed`, `auction.extended`, `buynow.started`, `countdown.reset`, `auction.ended`. Mỗi sự kiện parse thành `AuctionLiveEvent` và phát qua broadcast stream.
- `acquire(auctionId)`:
  - tăng refcount; lần đầu thì `start()` (nếu chưa kết nối) và `invoke('Subscribe', auctionId)`;
  - trả về `release()`: khi refcount về 0 thì `invoke('Unsubscribe')`; khi không còn phiên nào thì `stop()` sau 5 giây.
- `onreconnected`: gọi lại `Subscribe` cho mọi id đang giữ, rồi phát `onReconnected`.
- Lỗi kết nối không chặn màn hình: vẫn hiển thị dữ liệu GET, kèm chip "Mất kết nối realtime".

### AuctionLiveController (`AsyncNotifier.family`, autoDispose)
1. **Build**: GET phiên, đặt offset, đặt `lastSequence = live?.sequence ?? 0`, gọi `hub.acquire`, `ref.onDispose(release)`.
2. **Mỗi sự kiện**: `state = reduceLive(state, event)`.
   - `bid.placed`/`countdown.reset` có `amount != _myLastAmount`: đặt `isLeading = false`, gọi lại GET (debounce 500ms).
   - `auction.ended`: gọi lại GET để lấy `isWinner`, `auctionOrderId`.
   - Phát `AuctionToast` theo tên sự kiện (flash giá, "Phiên được gia hạn", "Có người mua ngay").
3. **Reconnect**: gọi lại GET, đặt lại `lastSequence = live.sequence`.
4. **Action** `placeBid(amount, key)`, `buyNow(key)`: cập nhật state từ `AuctionDto` server trả về, đặt `isLeading = true`, lưu `_myLastAmount`.

### reduceLive(state, event) (hàm thuần)
- `event.sequence <= lastSequence`: trả về state cũ.
- Ngược lại: ghi đè `status`, `currentPrice`, `leader`, `bidCount`, `endAt`, `countdownEndAt`, `hardEndAt`, `buyNowAvailable`, `minNextBid`, `winner`, `finalPrice` và `lastSequence`.
- Không đổi `isLeading`, `isWinner`, `auctionOrderId`.

## 6. Trả giá, mua ngay, đăng ký

### Điều kiện hiển thị
- `isSeller = owner != null`.
- `canBid = loggedIn && myRegistration?.status == CONFIRMED && !isSeller && status ∈ {LIVE, BUY_NOW_COUNTDOWN} && !isLeading`.
- `canBuyNow = điều kiện của canBid trừ !isLeading && buyNowAvailable`.
- Đang dẫn đầu: badge "Bạn đang dẫn đầu". Người bán: "Phiên của bạn". Chưa đăng nhập: "Đăng nhập để tham gia".

### BidSheet
- Ô nhập điền sẵn `minNextBid`, có các nút `+bidStep`, `+2×`, `+5×`. Kiểm tra cục bộ phải ≥ `minNextBid`. Realtime đẩy `minNextBid` lên thì tự nâng giá đang nhập.
- Ghi chú: "Sẽ tạm giữ X đ trong ví. Bị vượt giá sẽ hoàn ngay."
- Key: `_key ??= newIdempotencyKey()`. Đổi số tiền thì sinh key mới. Lỗi mạng (không có response) thì giữ key để retry.
- Nút loading trong lúc gửi request.

### Mua ngay
Dialog: giá mua ngay, số tiền bị giữ, chuyển sang đếm ngược 30 phút, người khác vẫn có thể trả cao hơn. Quy tắc key như trên.

### Đăng ký
`RegisterSheet` hiển thị phí tham gia + cọc = tổng bị giữ, cùng điều kiện hoàn (phí hoàn nếu không đủ người, cọc hoàn nếu không thắng). Hủy đăng ký (`DELETE`) có dialog xác nhận, chỉ hiện trước `registrationClosesAt`.

### Lịch sử lượt
`PagedNotifier` cho `/auctions/{id}/bids`. Có `bid.placed` mới thì thêm mục lên đầu từ payload, không tải lại toàn bộ.

### Map lỗi (`handleAuctionError`)

| Mã | Hành động |
|---|---|
| `BID_TOO_LOW` | `detailAmount('min_amount')` điền lại ô nhập, sheet giữ nguyên |
| `INSUFFICIENT_BALANCE` | Mở top-up với `required - available` |
| `ALREADY_LEADING` | Toast "Bạn đang dẫn đầu", gọi lại GET |
| `AUCTION_ENDED`, `INVALID_STATE`, `AUCTION_ALREADY_REGISTERED` | Đóng sheet, gọi lại GET |
| `BUY_NOW_UNAVAILABLE` | Gọi lại GET (nút tự ẩn) |
| `RATE_LIMITED` | Khóa nút theo `retryAfter ?? 1s` |
| `AUCTION_NOT_REGISTERED`, `AUCTION_NOT_LIVE`, `AUCTION_SELLER_CANNOT_BID`, `AUCTION_OWN`, `AUCTION_REGISTRATION_CLOSED`, `ACCOUNT_LOCKED`, `IDEMPOTENCY_CONFLICT` | Toast localized, gọi lại GET |

Bổ sung vào `ApiErrorCode` và `api_error_l10n` các mã còn thiếu: `AUCTION_OWN`, `AUCTION_ALREADY_REGISTERED`, `AUCTION_REGISTRATION_NOT_FOUND`, `AUCTION_START_TOO_SOON`, `AUCTION_RESCHEDULE_LIMIT`, `AUCTION_PHOTO_INVALID`, `AUCTION_NOT_FOUND`, `AUCTION_ORDER_NOT_FOUND`, `AUCTION_ORDER_ADDRESS_REQUIRED`, `AUCTION_ORDER_EXTENSION_LIMIT`, `ADDRESS_NOT_FOUND`, `RATE_LIMITED`.

## 7. Đơn đấu giá

### Danh sách
- Tab Mua/Bán, mỗi tab có `PagedNotifier` riêng.
- Chip lọc: Tất cả, Cần xử lý (`AWAITING_SHIPPING_FEE`, `IN_STORAGE`, `STORAGE_EXPIRED`), Đang giao, Hoàn tất.
- Thẻ đơn: ảnh, tên sách, `finalPrice`, badge status, chấm đỏ khi người mua cần làm gì đó.

### Chi tiết
`AuctionOrderController` (family theo id): GET khi mở, pull-to-refresh, cập nhật state từ DTO mà mọi action trả về.

**Panel theo status (phía người mua)**

| Status | Panel |
|---|---|
| `AWAITING_SHIPPING_FEE` | `address == null`: thẻ cảnh báo + "Chọn địa chỉ" (bắt buộc trước). `!shippingFeeHeld`: banner "Cần X đ trước <hạn>" + "Thanh toán phí ship". Đã giữ: "Đã giữ phí ship" |
| `READY_TO_SHIP` | "Kho đang chuẩn bị gửi", nút "Đổi địa chỉ" |
| `IN_DELIVERY` | Hãng, mã vận đơn (sao chép được), timeline `attempts` |
| `IN_STORAGE` | `feePerDay`, `feeAccrued` (trừ vào cọc), đếm tới `expiresAt`. Hai nút: Nhận tại kho / Giao lại (giữ thêm `shippingFee`, cần địa chỉ) |
| `DELIVERED`, `PICKED_UP` | Nút "Khiếu nại", hiện tới `complaintWindowEndsAt` |
| `STORAGE_EXPIRED` | Panel con theo `postExpiry.status` |
| `DISPUTED` | "Xem khiếu nại" → `/me/complaints/:complaintId` |
| `COMPLETED`, `REFUNDED`, `PARTIALLY_REFUNDED` | Tóm tắt, `completedAt` |
| `unknown` | "Trạng thái chưa hỗ trợ, hãy cập nhật ứng dụng" |

**Panel `postExpiry`**

| postExpiry.status | Panel |
|---|---|
| `AWAITING_DECISION` | Đếm tới `decisionDeadlineAt`. Gia hạn (`extensionFee`, còn `extensionMaxTimes - extensionCount` lần, ẩn khi hết lượt), Nhận tại kho, Giao lại |
| `EXTENDED` | "Đã gia hạn tới `extendedUntil`" |
| `AWAITING_LIQUIDATION` | "Sách sẽ được thanh lý" |
| `LIQUIDATED` | `liquidationAmount - liquidationFee` đã cộng vào ví |
| `RELEASED_TO_BUYER` | "Kho đã giao sách" (`releasedAt`) |

- **Thẻ tiền**: cọc, phí ship, `shippingFeeUnpaid` (nếu > 0), phí lưu kho.
- **Phía người bán**: không có địa chỉ, không có nút hành động; có thêm `commission` và số thực nhận.

### Hành động
- Mỗi nút có `_key ??= newIdempotencyKey()` riêng. Dialog xác nhận nêu rõ số tiền bị giữ hoặc trừ.
- Đổi địa chỉ: `pickAddress()` dùng chung → `PUT /auction-orders/{id}/address` (không cần key).
- "Thanh toán phí ship": gọi POST. Gặp `INSUFFICIENT_BALANCE` thì mở top-up với phần còn thiếu; nạp xong thì gọi lại POST với cùng key.

### Lỗi
- `AUCTION_ORDER_ADDRESS_REQUIRED`: mở picker.
- `AUCTION_ORDER_EXTENSION_LIMIT`: gọi lại GET.
- `INVALID_STATE`: toast, gọi lại GET.
- `AUCTION_ORDER_NOT_FOUND`: màn lỗi + nút quay lại.
- `ADDRESS_NOT_FOUND`: toast, mở picker.

### Khiếu nại
Dùng lại `open_complaint_screen` với `orderId = auctionOrder.id`. Nếu màn này đang phụ thuộc `SaleOrder` thì đổi sang nhận `orderId` + tiêu đề sách.

## 8. Phía người bán

### Tạo phiên trong `sell_screen` (chế độ Đấu giá)
- Dùng chung ảnh và các trường sách. Nhánh submit: tải ảnh lấy `blobName` → `AuctionPublisher.create()` (`POST /auctions`) → chuyển tới `/auctions/:id`.
- Trường riêng:
  - `startPrice` ≥ 10.000;
  - `bidStep` có helper "Từ X đến Y đ", tính từ `auction.step.minRate`, `.maxRate`, `.minAmount`;
  - `buyNowPrice` tùy chọn, ≥ `auction.buyNow.minMultiplier × startPrice`;
  - `durationMinutes` chọn qua chip: 1 giờ, 3 giờ, 12 giờ, 1 ngày, 3 ngày, 7 ngày;
  - `desiredStartAt` mặc định hiện tại + 9 ngày, picker chặn ngày sớm hơn.
- Ghi chú về phí tham gia và cọc người chơi phải trả.
- `VALIDATION_ERROR` gắn vào đúng field. `AUCTION_START_TOO_SOON` thì đọc `details[0].message`, đặt lại giờ sớm nhất và báo cho người dùng.

### Chi tiết phiên khi có `owner`

| Status | Panel |
|---|---|
| `AWAITING_INBOUND` | `InboundCodeCard`: mã to, sao chép/chia sẻ, địa chỉ kho, đếm tới `inboundDeadlineAt`. Nút "Hủy phiên" |
| `PENDING_REVIEW` | "Kho đã nhận, chờ duyệt". Hủy kèm cảnh báo phí ship trả sách |
| `REJECTED`, `CANCELLED` | `reviewReason` / `cancelCause` |
| `REGISTRATION_OPEN`, `CONFIRMED` | `registeredCount`, đếm ngược |
| `NOT_ENOUGH_PARTICIPANTS`, `ENDED_NO_BID` | `FallbackSheet`: dời lịch (chỉ khi `rescheduleRemaining > 0`), chuyển bán thường (nhập giá), nhận lại sách. Đếm tới `fallbackDeadlineAt` |
| `ENDED_SOLD` | Giá chốt, nút "Xem đơn" |
| `CONVERTED_TO_SALE` | Link tới `convertedListingId` |
| `owner.return != null` | `ReturnOrderCard`: `AWAITING_FEE` có cảnh báo + nạp ví; `DISPATCHED` hiện hãng và mã vận đơn |

### Phiên của tôi
- 4 tab Đang bán / Đã tham gia / Đang dẫn đầu / Đã thắng, ứng với `role=SELLER|BIDDER|LEADING|WINNER`. Mỗi tab có `PagedNotifier` riêng, chỉ tải khi mở tab.
- Thẻ: `currentPrice ?? startPrice`, `endsAt`, status, `myRegistration`.
- "Tin của tôi" bỏ header sim, thêm link sang tab Đang bán.

## 9. Thông báo

- `NotificationType` thêm toàn bộ loại đấu giá và trả sách:
  - 6a: `AUCTION_INBOUND_RECEIVED`, `AUCTION_APPROVED`, `AUCTION_REJECTED`, `AUCTION_INBOUND_TIMEOUT`, `AUCTION_CONFIRMED`, `AUCTION_NOT_ENOUGH`, `AUCTION_REGISTRATION_REFUNDED`, `AUCTION_FALLBACK_TIMEOUT`, `RETURN_FEE_NEEDED`, `RETURN_READY`, `RETURN_DISPATCHED`;
  - 6b/6c: 20 loại ở mục 7 tài liệu 13.
- `AppNotification` đọc thêm `data.auctionId`, `data.auctionOrderId`.
- `notificationTarget(n)` là hàm thuần trả về `NotificationTarget?`:

| Nhóm | Đích |
|---|---|
| `AUCTION_STARTED`, `AUCTION_OUTBID`, `AUCTION_BUY_NOW_STARTED`, `AUCTION_LOST`, `AUCTION_ENDED_NO_BID`, các loại 6a, `RETURN_*` | `/auctions/{auctionId}` |
| `AUCTION_WON`, `AUCTION_SOLD` | Push phiên, rồi push `/me/auction-orders/{auctionOrderId}` nếu có |
| `AUCTION_SHIPPING_FEE_NEEDED`, `AUCTION_SHIPPING_FEE_DEFERRED`, `AUCTION_ORDER_DISPATCHED`, `AUCTION_DELIVERY_FAILED`, `AUCTION_IN_STORAGE`, `AUCTION_ORDER_DELIVERED`, `AUCTION_ORDER_COMPLETED`, `AUCTION_STORAGE_EXPIRED`, `AUCTION_STORAGE_EXTENDED`, `AUCTION_AWAITING_LIQUIDATION`, `AUCTION_LIQUIDATED`, `AUCTION_RELEASED_TO_BUYER` | `/me/auction-orders/{auctionOrderId}`; thiếu id thì mở phiên |
| `AUCTION_LIQUIDATION_NEEDS_ADMIN` | `null`, đồng thời ẩn khỏi danh sách |
| Loại cũ | Logic hiện tại (wallet, complaintId, orderId, listingId) |

- Loại `AUCTION_*` / `RETURN_*` được xét trước nhánh `orderId`/`complaintId`.
- Badge unread chỉ lấy từ backend. Bỏ listener toast của sim trong `app_shell`.

## 10. Gỡ sim và preview

| Chỗ dùng | Thay bằng |
|---|---|
| Các màn đấu giá, `live_auction_strip` | Provider thật. Strip dùng `GET /auctions?status=LIVE&pageSize=5` |
| `sell_screen`, `my_listings_screen` | Mục 8 |
| `wallet_sheets.showTopupSheet` | Xóa, caller dùng `showWalletTopupSheet` |
| `orders_screen` link sim, `sim_orders_*`, `orders/domain/order.dart`, `orders/presentation/complaint_sheet.dart` | Link `/me/auction-orders`, xóa file sim |
| `notification_providers`, `notifications_screen`, `sim_notification.dart` | Mục 9 |
| `profile_screen`, `browse_screen` | Bỏ sim. Profile thêm "Đơn đấu giá", "Phiên của tôi" |
| `app_shell` toast, `sim_ticker`, `lib/features/sim/` | Xóa |
| l10n | Xóa key sim không còn dùng, thêm key mới (vi + en) |

`UI_PREVIEW`: thêm `FakeAuctionRepository` (phiên ở REGISTRATION_OPEN, LIVE, BUY_NOW_COUNTDOWN, ENDED_SOLD và một phiên người bán ở AWAITING_INBOUND), `FakeAuctionOrderRepository` (mỗi status chính một đơn) và `FakeAuctionHub` (không phát sự kiện).

## 11. Kiểm thử và thứ tự làm

### Test
- **Unit**:
  - parse DTO (đủ trường, null, enum lạ);
  - `reduceLive` (sequence trùng hoặc lùi, gộp đủ trường, giữ `isLeading`);
  - `ServerClock`;
  - `notificationTarget` (từng nhóm, thứ tự ưu tiên);
  - repository (path, query, body, header `Idempotency-Key`, map `ApiError`) qua `FakeAdapter`.
- **Controller** (với `FakeAuctionHub`):
  - sự kiện của người khác → `isLeading = false` rồi gọi lại GET;
  - `auction.ended` → gọi lại GET;
  - reconnect → gọi lại GET và đặt lại sequence;
  - dispose → release.
- **Widget**:
  - trả giá (điền sẵn `minNextBid`, `BID_TOO_LOW` điền lại, `INSUFFICIENT_BALANCE` mở top-up, retry giữ cùng key);
  - mua ngay, đăng ký;
  - panel đơn: `AWAITING_SHIPPING_FEE` có và không có địa chỉ, `IN_STORAGE`, `STORAGE_EXPIRED` + `AWAITING_DECISION` (ẩn nút gia hạn khi hết lượt);
  - "Phiên của tôi" 4 tab.
- Viết lại `auctions_flow_test`, xóa test sim.
- Tiêu chí xong: `flutter analyze` sạch, `flutter test` pass.

### Thứ tự commit
1. Domain, enum, repository, mã lỗi + test
2. Hub, `ServerClock`, `AuctionLiveController` + test (thử thật với staging)
3. Danh sách, chi tiết, đăng ký, trả giá, mua ngay
4. Người bán (sell, fallback, trả sách) + "Phiên của tôi"
5. Đơn đấu giá
6. Thông báo + `notification_router`
7. Gỡ sim, preview, dọn l10n
8. Cập nhật tài liệu

## 12. Rủi ro

- `signalr_netcore` chưa chạy thử với hub này. Thử thật trên staging ở bước 2. Nếu không tương thích, quay về D3 phương án tự viết client.
- Backend chưa có test HTTP/SignalR đầu cuối, có thể lệch tài liệu. Gặp lệch thì ghi lại và báo backend.
- Diff gỡ sim lớn, có thể va chạm với thành viên khác đang sửa các màn liên quan.

## 13. Ghi chú triển khai (lệch so với thiết kế)

| # | Thiết kế ban đầu | Đã làm | Lý do |
|---|---|---|---|
| I1 | `ServerClock` riêng cho mỗi phiên | Dùng lại `core/util/server_clock.dart` (offset dùng chung toàn app) và widget `Countdown` có sẵn | Offset là của thiết bị, không phụ thuộc phiên; tránh hai cơ chế đồng hồ |
| I2 | `BidSheet` riêng có ô nhập | Giữ bộ tăng/giảm trên màn chi tiết (mặc định `minNextBid`, thêm chip `+2×`, `+5×` bước nhảy), bấm "Trả giá" mở sheet xác nhận nêu số tiền tạm giữ | Giữ giao diện quen thuộc, vẫn đủ yêu cầu điền sẵn và xác nhận |
| I3 | Thiếu tiền khi nộp phí ship: thử lại cùng key | Thử lại một lần với key MỚI | Server có thể lưu kết quả lỗi theo key; dùng lại key sẽ nhận lại đúng lỗi cũ. Quy tắc chung: `IdempotentAction` giữ key khi mất mạng, bỏ key khi server đã trả lỗi hoặc thành công |
| I4 | Tab "Đang diễn ra" lọc một trạng thái | Gọi hai lần (`LIVE`, `BUY_NOW_COUNTDOWN`) rồi gộp trang | `GET /auctions?status=` chỉ nhận một trạng thái |
| I5 | — | `AuctionRole.bidder` cũng làm ô "Phiên tham gia" ở tab Tôi (`meta.totalItems`) | Thay số đếm từ simulator |
| I6 | — | Tạo phiên bắt buộc chọn thể loại; các trường NXB, năm, ISBN, ghi chú lỗi hiện cho cả hai chế độ | Backend bắt buộc `categoryId` cho `POST /auctions` |
| I7 | — | Sửa lỗi có sẵn ở `sell_screen`: nút giữ trạng thái bận trong khi sheet "Đã đăng" mở | Spinner chạy mãi làm treo `pumpAndSettle` (nguyên nhân một phần lỗi test cũ) |
| I8 | Viết lại test sim | Xóa `orders_wallet_flow_test.dart`, `sim_controller_test.dart`, `sim_rules_test.dart` | Kiểm tra hành vi simulator đã gỡ; các test giỏ/đơn trong đó đã fail sẵn trước thay đổi này |

### Trạng thái kiểm thử

- Mới: `auction_models_test`, `auction_repository_test`, `auction_live_controller_test`, `auctions_flow_test` (10 luồng widget), thêm test điều hướng thông báo đấu giá ở `navigation_shell_test`.
- `flutter analyze lib`: sạch.
- `flutter test`: còn 4 test fail, đều đã fail y hệt ở HEAD trước thay đổi (`browse_and_cart_test` không biên dịch, 2 test `sell_flow` về form bán thường, `preview_boot_test`).
- Realtime trên staging: `POST /hubs/auctions/negotiate` trả về WebSockets; chưa thử phiên thật vì staging chưa có phiên nào. Cần thử trên thiết bị khi có phiên `LIVE`.
