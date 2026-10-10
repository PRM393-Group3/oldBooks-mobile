import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/paging/cursor_notifier.dart';
import '../data/listing_repository.dart';
import '../domain/listing.dart';
import '../domain/listing_query.dart';

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => ListingRepository(
    ref.watch(apiClientProvider),
    ref.watch(blobUploaderProvider),
  ),
);

/// Kết quả tìm kiếm/khám phá cho một bộ điều kiện.
class ListingSearchNotifier extends CursorNotifier<Listing> {
  ListingSearchNotifier(this.query);
  final ListingQuery query;

  @override
  Future<CursorPage<Listing>> fetch(String? cursor) => ref
      .read(listingRepositoryProvider)
      .search(query, cursor: cursor, pageSize: CursorNotifier.pageSize);
}

final listingSearchProvider = AsyncNotifierProvider.autoDispose
    .family<ListingSearchNotifier, CursorState<Listing>, ListingQuery>(
      ListingSearchNotifier.new,
    );

final listingDetailProvider = FutureProvider.autoDispose
    .family<Listing, String>(
      (ref, id) => ref.watch(listingRepositoryProvider).get(id),
    );
