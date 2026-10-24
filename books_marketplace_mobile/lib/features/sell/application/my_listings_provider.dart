import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../../auth/application/auth_controller.dart';
import '../../listings/application/listing_providers.dart';
import '../../listings/domain/listing.dart';
import '../../listings/domain/listing_enums.dart';

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
