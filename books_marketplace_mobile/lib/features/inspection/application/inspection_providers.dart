import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../../listings/application/listing_providers.dart';
import '../data/inspection_repository.dart';
import '../domain/inspection.dart';

final inspectionRepositoryProvider = Provider<InspectionRepository>(
  (ref) => InspectionRepository(ref.watch(apiClientProvider)),
);

/// Bộ lọc đang chọn của hàng đợi.
class QueueFilterNotifier extends Notifier<QueueFilter> {
  @override
  QueueFilter build() => const QueueFilter();

  void set(QueueFilter filter) => state = filter;
}

final queueFilterProvider = NotifierProvider<QueueFilterNotifier, QueueFilter>(
  QueueFilterNotifier.new,
);

class InspectionQueueNotifier extends PagedNotifier<QueueItem> {
  InspectionQueueNotifier(this.filter);
  final QueueFilter filter;

  @override
  Future<PagedResult<QueueItem>> fetchPage(int page) => ref
      .read(inspectionRepositoryProvider)
      .queue(filter: filter, page: page, pageSize: PagedNotifier.pageSize);
}

final inspectionQueueProvider = AsyncNotifierProvider.autoDispose
    .family<InspectionQueueNotifier, PagedState<QueueItem>, QueueFilter>(
      InspectionQueueNotifier.new,
    );

/// Tin đang giữ khóa của tôi.
final myClaimsProvider = FutureProvider.autoDispose<List<QueueItem>>(
  (ref) => ref.watch(inspectionRepositoryProvider).mine(),
);

void invalidateInspectionViews(Ref ref, {String? listingId}) {
  ref.invalidate(inspectionQueueProvider);
  ref.invalidate(myClaimsProvider);
  if (listingId != null) ref.invalidate(listingDetailProvider(listingId));
}

/// Phiên kiểm định một tin: nhận khóa khi mở, giữ cho tới khi quyết định hoặc
/// nhả. Khóa hết hạn thì mọi quyết định bị `INSPECTION_CLAIM_REQUIRED` và phải
/// gọi [reclaim].
class ReviewController extends AsyncNotifier<ClaimedListing> {
  ReviewController(this.listingId);
  final String listingId;

  InspectionRepository get _repo => ref.read(inspectionRepositoryProvider);

  @override
  Future<ClaimedListing> build() => _claim();

  Future<ClaimedListing> _claim() async {
    final listing = await _repo.claim(listingId);
    // `claimExpiresAt` chỉ có ở /inspections/mine; nếu thiếu thì tính từ lúc
    // nhận theo giới hạn trong rules.
    DateTime? expires;
    try {
      final mine = await _repo.mine();
      expires = mine
          .where((m) => m.listing.id == listingId)
          .map((m) => m.claimExpiresAt)
          .whereType<DateTime>()
          .firstOrNull;
    } catch (_) {}
    if (expires == null) {
      final rules = await ref.read(listingRulesProvider.future);
      expires = DateTime.now().add(Duration(minutes: rules.claimMinutes));
    }
    return ClaimedListing(listing: listing, expiresAt: expires);
  }

  Future<void> reclaim() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_claim);
  }

  Future<void> approve({String? note}) async {
    await _repo.approve(listingId, note: note);
    invalidateInspectionViews(ref, listingId: listingId);
  }

  Future<void> reject({
    required List<RejectReason> reasons,
    required String note,
  }) async {
    await _repo.reject(listingId, reasons: reasons, note: note);
    invalidateInspectionViews(ref, listingId: listingId);
  }

  Future<void> release() async {
    await _repo.release(listingId);
    invalidateInspectionViews(ref, listingId: listingId);
  }
}

final reviewControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ReviewController, ClaimedListing, String>(ReviewController.new);
