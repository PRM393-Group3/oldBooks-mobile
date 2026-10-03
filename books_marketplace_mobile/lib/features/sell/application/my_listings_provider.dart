import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../../auth/application/auth_controller.dart';
import '../../listings/application/listing_providers.dart';
import '../../listings/domain/listing.dart';
import '../../listings/domain/listing_enums.dart';
import '../domain/my_listing.dart';
import '../domain/sell_rules.dart';
import '../../../core/util/clock.dart';

/// Tin của tôi (`GET /me/listings`), lọc theo trạng thái (`null` là tất cả).
class MyListingsNotifier extends PagedNotifier<Listing> {
  MyListingsNotifier(this.status);
  final ListingStatus? status;

  @override
  Future<PagedResult<Listing>> fetchPage(int page) => ref
      .read(listingRepositoryProvider)
      .mine(status: status, page: page, pageSize: PagedNotifier.pageSize);
}

final myListingsProvider = AsyncNotifierProvider.autoDispose
    .family<MyListingsNotifier, PagedState<Listing>, ListingStatus?>(
      MyListingsNotifier.new,
    );

/// Số tin đang bán, cho ô số liệu ở tab Tôi. Lấy từ `meta.totalItems` của trang
/// đầu nên không phải tải cả danh sách.
final publishedListingCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final authed = ref.watch(
    authControllerProvider.select((s) => s == AuthStatus.authenticated),
  );
  if (!authed) return 0;
  final page = await ref
      .watch(listingRepositoryProvider)
      .mine(status: ListingStatus.published, page: 1, pageSize: 1);
  return page.totalCount ?? page.items.length;
});

/// Làm mới mọi danh sách tin của tôi sau khi tạo/sửa/gửi duyệt/gỡ.
void refreshMyListings(WidgetRef ref) {
  ref.invalidate(myListingsProvider);
  ref.invalidate(publishedListingCountProvider);
}

/// Tin đấu giá do người dùng tạo, lưu trong bộ nhớ: đấu giá chưa có backend
/// (giai đoạn 6) nên vẫn mô phỏng. Bán giá cố định đi qua backend thật.
class SimAuctionListingsNotifier extends Notifier<List<MyListing>> {
  DateTime get _now => ref.read(clockProvider)();

  @override
  List<MyListing> build() => const [];

  /// Thêm tin vừa tạo và trả về mã nhập kho.
  String add(SellForm form, List<int>? cover, String Function() codeGenerator) {
    final now = _now;
    final code = codeGenerator();
    final item = MyListing(
      id: 'a${state.length + 1}-${now.microsecondsSinceEpoch}',
      title: form.title.trim(),
      status: MyListingStatus.awaitingInbound,
      isAuction: true,
      price: form.startingPrice,
      createdAt: now,
      inboundCode: code,
      inboundDeadline: now.add(const Duration(days: 5)),
      photoBytes: cover,
    );
    state = [item, ...state];
    return code;
  }
}

final simAuctionListingsProvider =
    NotifierProvider<SimAuctionListingsNotifier, List<MyListing>>(
      SimAuctionListingsNotifier.new,
    );
