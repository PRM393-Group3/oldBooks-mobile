import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../data/listing_repository.dart';
import '../domain/listing.dart';

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => ListingRepository(ref.watch(apiClientProvider)),
);

/// Tin công khai cho Buyer/Seller, lọc theo danh mục (`null` là tất cả).
class BrowseListingsNotifier extends PagedNotifier<Listing> {
  BrowseListingsNotifier(this.categoryId);
  final String? categoryId;

  @override
  Future<PagedResult<Listing>> fetchPage(int page) => ref
      .read(listingRepositoryProvider)
      .browse(
        categoryId: categoryId,
        page: page,
        pageSize: PagedNotifier.pageSize,
      );
}

final browseListingsProvider = AsyncNotifierProvider.autoDispose
    .family<BrowseListingsNotifier, PagedState<Listing>, String?>(
      BrowseListingsNotifier.new,
    );

final listingDetailProvider = FutureProvider.autoDispose
    .family<Listing, String>(
      (ref, id) => ref.watch(listingRepositoryProvider).get(id),
    );
