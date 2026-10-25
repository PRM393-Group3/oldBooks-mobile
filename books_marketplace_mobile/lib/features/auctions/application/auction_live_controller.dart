import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/server_clock.dart';
import '../domain/auction.dart';
import '../domain/auction_event.dart';
import 'auction_providers.dart';

/// Trạng thái một phiên trên màn hình chi tiết: tải bằng REST rồi cập nhật bằng
/// sự kiện realtime.
///
/// - Lọc trùng theo `sequence`; payload là trạng thái đầy đủ nên gộp cả phiên.
/// - Không suy ra `isLeading` từ payload (tên đã che): có lượt mới không phải
///   của mình thì bỏ dẫn đầu ngay rồi tải lại để xác nhận.
/// - `auction.ended` và kết nối lại: tải lại để có `isWinner`, `auctionOrderId`.
class AuctionLiveController extends AsyncNotifier<Auction> {
  AuctionLiveController(this.auctionId);
  final String auctionId;

  /// Khoảng chờ gộp nhiều lần tải lại liên tiếp (nhiều lượt sát nhau).
  static const refreshDebounce = Duration(milliseconds: 500);

  int _lastSequence = 0;

  /// Số tiền lượt gần nhất của chính mình, để nhận ra sự kiện do mình gây ra.
  int? _myLastAmount;
  Timer? _refreshTimer;
  final _events = StreamController<AuctionLiveEvent>.broadcast();

  /// Sự kiện mới đã được áp dụng, cho hiệu ứng và toast trên màn hình.
  Stream<AuctionLiveEvent> get liveEvents => _events.stream;

  /// Số tiền lượt gần nhất của người dùng trên máy này.
  int? get myLastAmount => _myLastAmount;

  @override
  Future<Auction> build() async {
    final hub = ref.read(auctionHubProvider);
    final release = hub.acquire(auctionId);
    final eventSub = hub.events
        .where((e) => _sameId(e.auctionId))
        .listen(_onEvent);
    final reconnectSub = hub.reconnected.listen((_) => refresh());
    ref.onDispose(() {
      release();
      eventSub.cancel();
      reconnectSub.cancel();
      _refreshTimer?.cancel();
    });
    final a = await ref.read(auctionRepositoryProvider).get(auctionId);
    return _accept(a);
  }

  bool _sameId(String id) => id.toLowerCase() == auctionId.toLowerCase();

  /// Ghi nhận bản mới từ REST: đồng bộ đồng hồ và mốc sequence.
  Auction _accept(Auction a) {
    ServerClock.sync(a.serverTime);
    _lastSequence = a.live?.sequence ?? _lastSequence;
    return a;
  }

  void _onEvent(AuctionLiveEvent e) {
    final current = state.value;
    if (current == null || e.sequence <= _lastSequence) return;
    ServerClock.sync(e.serverTime);
    var next = reduceLive(current, e, lastSequence: _lastSequence);
    _lastSequence = e.sequence;

    if (e.isNewBid && e.amount != _myLastAmount && next.isLeading) {
      next = next.copyWith(live: next.live!.copyWith(isLeading: false));
      _scheduleRefresh();
    } else if (e.isNewBid && e.amount != _myLastAmount) {
      // Người xem chưa dẫn đầu: vẫn tải lại để biết có phải lượt của mình ở
      // máy khác không (server mới biết `isLeading`).
      if (current.isConfirmedBidder) _scheduleRefresh();
    }
    if (e.name == AuctionEventName.ended ||
        e.name == AuctionEventName.started) {
      _scheduleRefresh(immediate: true);
    }
    state = AsyncData(next);
    if (!_events.isClosed) _events.add(e);
  }

  void _scheduleRefresh({bool immediate = false}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(immediate ? Duration.zero : refreshDebounce, refresh);
  }

  /// Tải lại phiên ở nền, giữ dữ liệu cũ nếu lỗi.
  Future<void> refresh() async {
    try {
      final a = await ref.read(auctionRepositoryProvider).get(auctionId);
      state = AsyncData(_accept(a));
    } catch (_) {
      // Giữ nguyên màn hình; lần sự kiện hoặc kéo làm mới sau sẽ thử lại.
    }
  }

  Auction _applyOwnAction(Auction a, {int? amount}) {
    if (amount != null) _myLastAmount = amount;
    var next = _accept(a);
    final live = next.live;
    if (amount != null && live != null && !live.isLeading) {
      next = next.copyWith(live: live.copyWith(isLeading: true));
    }
    state = AsyncData(next);
    return next;
  }

  Future<Auction> placeBid(int amount, {required String idempotencyKey}) async {
    final a = await ref
        .read(auctionRepositoryProvider)
        .placeBid(auctionId, amount: amount, idempotencyKey: idempotencyKey);
    return _applyOwnAction(a, amount: amount);
  }

  Future<Auction> buyNow({required String idempotencyKey}) async {
    final price = state.value?.buyNowPrice;
    final a = await ref
        .read(auctionRepositoryProvider)
        .buyNow(auctionId, idempotencyKey: idempotencyKey);
    return _applyOwnAction(a, amount: price ?? a.currentPrice);
  }

  Future<Auction> register({required String idempotencyKey}) async {
    final a = await ref
        .read(auctionRepositoryProvider)
        .register(auctionId, idempotencyKey: idempotencyKey);
    return _applyOwnAction(a);
  }

  Future<Auction> unregister() async {
    final a = await ref.read(auctionRepositoryProvider).unregister(auctionId);
    return _applyOwnAction(a);
  }

  Future<Auction> cancel({String? reason}) async {
    final a = await ref
        .read(auctionRepositoryProvider)
        .cancel(auctionId, reason: reason);
    return _applyOwnAction(a);
  }

  Future<Auction> fallback(
    FallbackChoice choice, {
    DateTime? startAt,
    int? price,
  }) async {
    final a = await ref
        .read(auctionRepositoryProvider)
        .fallback(auctionId, choice: choice, startAt: startAt, price: price);
    return _applyOwnAction(a);
  }
}

final auctionLiveProvider = AsyncNotifierProvider.autoDispose
    .family<AuctionLiveController, Auction, String>(AuctionLiveController.new);
