import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../data/listing_repository.dart';
import '../domain/listing.dart';
import '../domain/listing_enums.dart';
import '../domain/listing_input.dart';
import '../domain/listing_rules.dart';

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => ListingRepository(ref.watch(apiClientProvider)),
);

/// Giới hạn nghiệp vụ; client không viết cứng mà lấy từ server.
final listingRulesProvider = FutureProvider<ListingRules>(
  (ref) => ref.watch(listingRepositoryProvider).rules(),
);

/// Tin của tôi, lọc theo trạng thái (`null` là tất cả).
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

final listingSummaryProvider =
    FutureProvider.autoDispose<Map<ListingStatus, int>>(
      (ref) => ref.watch(listingRepositoryProvider).mineSummary(),
    );

final listingDetailProvider = FutureProvider.autoDispose
    .family<Listing, String>(
      (ref, id) => ref.watch(listingRepositoryProvider).get(id),
    );

/// Làm mới mọi danh sách và chi tiết sau khi tin thay đổi.
void invalidateListingViews(Ref ref, {String? id}) {
  ref.invalidate(myListingsProvider);
  ref.invalidate(listingSummaryProvider);
  if (id != null) ref.invalidate(listingDetailProvider(id));
}

/// Bản nháp đang soạn trong wizard. Server là nguồn sự thật: mỗi bước lưu
/// bằng PUT rồi lấy `ListingDto` trả về làm state.
///
/// [id] `null` nghĩa là chưa có bản nháp; nó chỉ được tạo (lười) khi lưu bước
/// đầu, nên mở wizard rồi thoát không để lại nháp rỗng.
class ListingDraft extends AsyncNotifier<Listing?> {
  ListingDraft(this.id);
  final String? id;

  ListingRepository get _repo => ref.read(listingRepositoryProvider);

  @override
  Future<Listing?> build() async => id == null ? null : _repo.get(id!);

  Future<Listing> saveBookInfo(BookInfoInput input) async {
    var listing = state.value;
    if (listing == null) {
      listing = await _repo.create();
      // Giữ ngay để nếu PUT dưới lỗi thì lần thử lại không tạo nháp thứ hai.
      state = AsyncData(listing);
    }
    final saved = await _repo.saveBookInfo(listing.id, input);
    return _commit(saved);
  }

  Future<Listing> saveImages(
    List<({String blobName, ImageType type})> images,
  ) async => _commit(await _repo.saveImages(_requireId(), images));

  Future<Listing> saveSaleMethod(SaleMethodInput input) async =>
      _commit(await _repo.saveSaleMethod(_requireId(), input));

  Future<SubmitResult> submit() async {
    final r = await _repo.submit(_requireId());
    _commit(r.listing);
    return r.result;
  }

  /// Tải lại từ server (sau lỗi 409 hoặc khi mở lại).
  Future<void> reload() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(await _repo.get(current.id));
  }

  String _requireId() {
    final current = state.value;
    if (current == null) throw StateError('Chưa có bản nháp');
    return current.id;
  }

  Listing _commit(Listing listing) {
    state = AsyncData(listing);
    invalidateListingViews(ref, id: listing.id);
    return listing;
  }
}

final listingDraftProvider = AsyncNotifierProvider.autoDispose
    .family<ListingDraft, Listing?, String?>(ListingDraft.new);

/// Thao tác đơn lẻ trên tin từ màn hình chi tiết.
class ListingActions {
  ListingActions(this._ref);
  final Ref _ref;

  Future<void> delete(String id) async {
    await _ref.read(listingRepositoryProvider).delete(id);
    invalidateListingViews(_ref, id: id);
  }
}

final listingActionsProvider = Provider<ListingActions>(ListingActions.new);
