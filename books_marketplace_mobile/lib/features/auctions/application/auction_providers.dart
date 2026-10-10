import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../../auth/application/auth_controller.dart';
import '../data/auction_hub.dart';
import '../data/auction_repository.dart';
import '../domain/auction.dart';

final auctionRepositoryProvider = Provider<AuctionRepository>(
  (ref) => AuctionRepository(
    ref.watch(apiClientProvider),
    ref.watch(blobUploaderProvider),
  ),
);

/// Một kết nối realtime cho cả app.
final auctionHubProvider = Provider<AuctionHub>((ref) {
  final hub = SignalRAuctionHub();
  ref.onDispose(hub.dispose);
  return hub;
});

/// Nhóm phiên ở tab Đấu giá.
enum AuctionTab {
  live,
  register,
  upcoming,
  ended;

  /// Trạng thái gửi lên `GET /auctions?status=`. Tab "Đang diễn ra" gộp hai
  /// trạng thái nên gọi hai lần.
  List<AuctionStatus> get statuses => switch (this) {
    live => const [AuctionStatus.live, AuctionStatus.buyNowCountdown],
    register => const [AuctionStatus.registrationOpen],
    upcoming => const [AuctionStatus.confirmed],
    ended => const [AuctionStatus.endedSold],
  };
}

class AuctionListNotifier extends PagedNotifier<AuctionSummary> {
  AuctionListNotifier(this.tab);
  final AuctionTab tab;

  @override
  Future<PagedResult<AuctionSummary>> fetchPage(int page) async {
    final repo = ref.read(auctionRepositoryProvider);
    final results = await Future.wait([
      for (final s in tab.statuses)
        repo.list(
          filter: (status: s, q: null),
          page: page,
          pageSize: PagedNotifier.pageSize,
        ),
    ]);
    if (results.length == 1) return results.single;
    final hasMore = results.any((r) => r.hasMore);
    return PagedResult(
      items: [for (final r in results) ...r.items],
      page: page,
      pageSize: PagedNotifier.pageSize,
      // Còn trang thì có ít nhất một nhóm trả đủ trang (danh sách gộp đủ dài);
      // hết thì báo tổng 0 để dừng tải thêm.
      totalCount: hasMore ? null : 0,
    );
  }
}

final auctionListProvider = AsyncNotifierProvider.autoDispose
    .family<AuctionListNotifier, PagedState<AuctionSummary>, AuctionTab>(
      AuctionListNotifier.new,
    );

/// Dải "Đang đấu giá" ở trang chủ: ảnh chụp, không realtime.
final liveAuctionStripProvider =
    FutureProvider.autoDispose<List<AuctionSummary>>((ref) async {
      final page = await ref
          .watch(auctionRepositoryProvider)
          .list(
            filter: (status: AuctionStatus.live, q: null),
            page: 1,
            pageSize: 5,
          );
      return page.items;
    });

class MyAuctionsNotifier extends PagedNotifier<AuctionSummary> {
  MyAuctionsNotifier(this.role);
  final AuctionRole role;

  @override
  Future<PagedResult<AuctionSummary>> fetchPage(int page) => ref
      .read(auctionRepositoryProvider)
      .mine(role: role, page: page, pageSize: PagedNotifier.pageSize);
}

final myAuctionsProvider = AsyncNotifierProvider.autoDispose
    .family<MyAuctionsNotifier, PagedState<AuctionSummary>, AuctionRole>(
      MyAuctionsNotifier.new,
    );

/// Số phiên đã tham gia, cho ô số liệu ở tab Tôi (từ `meta.totalItems`).
final myBidderAuctionCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final authed = ref.watch(
    authControllerProvider.select((s) => s == AuthStatus.authenticated),
  );
  if (!authed) return 0;
  final page = await ref
      .watch(auctionRepositoryProvider)
      .mine(role: AuctionRole.bidder, page: 1, pageSize: 1);
  return page.totalCount ?? page.items.length;
});

/// Lịch sử trả giá. Lượt mới từ realtime được chèn lên đầu qua [prepend].
class AuctionBidsNotifier extends PagedNotifier<Bid> {
  AuctionBidsNotifier(this.auctionId);
  final String auctionId;

  @override
  Future<PagedResult<Bid>> fetchPage(int page) => ref
      .read(auctionRepositoryProvider)
      .bids(auctionId, page: page, pageSize: PagedNotifier.pageSize);

  void prepend(Bid bid) {
    final current = state.value;
    if (current == null) return;
    if (current.items.any((b) => b.amount == bid.amount)) return;
    state = AsyncData(current.copyWith(items: [bid, ...current.items]));
  }
}

final auctionBidsProvider = AsyncNotifierProvider.autoDispose
    .family<AuctionBidsNotifier, PagedState<Bid>, String>(
      AuctionBidsNotifier.new,
    );

/// Làm mới danh sách sau khi đăng ký, trả giá, tạo hoặc hủy phiên.
void refreshAuctionLists(WidgetRef ref) {
  ref.invalidate(auctionListProvider);
  ref.invalidate(myAuctionsProvider);
  ref.invalidate(liveAuctionStripProvider);
  ref.invalidate(myBidderAuctionCountProvider);
}
