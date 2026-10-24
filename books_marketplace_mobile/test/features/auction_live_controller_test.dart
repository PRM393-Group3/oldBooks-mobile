import 'package:books_marketplace_mobile/core/preview/preview_auctions.dart';
import 'package:books_marketplace_mobile/features/auctions/application/auction_live_controller.dart';
import 'package:books_marketplace_mobile/features/auctions/application/auction_providers.dart';
import 'package:books_marketplace_mobile/features/auctions/data/auction_hub.dart';
import 'package:books_marketplace_mobile/features/auctions/domain/auction.dart';
import 'package:books_marketplace_mobile/features/auctions/domain/auction_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kho đếm số lần GET để kiểm tra việc tải lại.
class _CountingRepo extends InMemoryAuctionRepository {
  _CountingRepo({super.seed});
  int gets = 0;

  @override
  Future<Auction> get(String id) {
    gets++;
    return super.get(id);
  }
}

AuctionLiveEvent _event(
  int sequence, {
  String name = AuctionEventName.bidPlaced,
  String status = 'LIVE',
  int amount = 700000,
}) => AuctionLiveEvent.fromJson(name, {
  'auctionId': 'A-LIVE',
  'sequence': sequence,
  'serverTime': DateTime.now().toUtc().toIso8601String(),
  'status': status,
  'currentPrice': amount,
  'leader': 'Tr***g',
  'bidCount': 7,
  'endAt': DateTime.now()
      .toUtc()
      .add(const Duration(hours: 1))
      .toIso8601String(),
  'buyNowAvailable': true,
  'minNextBid': amount + 20000,
  'amount': amount,
  'bidder': 'Tr***g',
});

void main() {
  late _CountingRepo repo;
  late OfflineAuctionHub hub;
  late ProviderContainer c;

  setUp(() {
    repo = _CountingRepo(
      seed: [
        sampleAuctionJson(
          id: 'a-live',
          title: 'X',
          status: 'LIVE',
          currentPrice: 640000,
          myRegistration: {'status': 'CONFIRMED'},
          buyNowAvailable: true,
          live: {'sequence': 6, 'isLeading': false, 'minNextBid': 660000},
        ),
      ],
    );
    hub = OfflineAuctionHub();
    c = ProviderContainer(
      overrides: [
        auctionRepositoryProvider.overrideWithValue(repo),
        auctionHubProvider.overrideWithValue(hub),
      ],
    );
    addTearDown(c.dispose);
  });

  Future<AuctionLiveController> open() async {
    c.listen(auctionLiveProvider('a-live'), (_, _) {});
    await c.read(auctionLiveProvider('a-live').future);
    return c.read(auctionLiveProvider('a-live').notifier);
  }

  Auction current() => c.read(auctionLiveProvider('a-live')).value!;

  test('mở phiên thì theo dõi hub, hủy khi không còn ai xem', () async {
    final sub = c.listen(auctionLiveProvider('a-live'), (_, _) {});
    await c.read(auctionLiveProvider('a-live').future);
    expect(hub.refs['a-live'], 1);
    sub.close();
    await Future<void>.delayed(Duration.zero);
    expect(hub.refs.containsKey('a-live'), isFalse);
  });

  test('sự kiện mới cập nhật giá; trùng sequence bị bỏ qua', () async {
    await open();
    hub.emit(_event(7, amount: 700000));
    await Future<void>.delayed(Duration.zero);
    expect(current().currentPrice, 700000);
    expect(current().minNextBid, 720000);

    hub.emit(_event(7, amount: 999999));
    hub.emit(_event(5, amount: 999999));
    await Future<void>.delayed(Duration.zero);
    expect(current().currentPrice, 700000);
  });

  test('id viết hoa/thường khác nhau vẫn nhận', () async {
    await open();
    hub.emit(_event(8));
    await Future<void>.delayed(Duration.zero);
    expect(current().live!.sequence, 8);
  });

  test(
    'trả giá thành công thì dẫn đầu; lượt người khác bỏ dẫn đầu và tải lại',
    () async {
      final ctl = await open();
      await ctl.placeBid(660000, idempotencyKey: 'k');
      expect(current().isLeading, isTrue);
      expect(repo.calls.last, 'bid a-live 660000 k');

      // Sự kiện của chính lượt mình (cùng số tiền): vẫn dẫn đầu.
      final seq = current().live!.sequence;
      hub.emit(_event(seq + 1, amount: 660000));
      await Future<void>.delayed(Duration.zero);
      expect(current().isLeading, isTrue);

      final before = repo.gets;
      hub.emit(_event(seq + 2, amount: 700000));
      await Future<void>.delayed(Duration.zero);
      expect(current().isLeading, isFalse);
      await Future<void>.delayed(
        AuctionLiveController.refreshDebounce +
            const Duration(milliseconds: 50),
      );
      expect(repo.gets, greaterThan(before));
    },
  );

  test('kết thúc phiên và kết nối lại đều tải lại từ REST', () async {
    await open();
    var before = repo.gets;
    hub.emit(_event(20, name: AuctionEventName.ended, status: 'ENDED_SOLD'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(repo.gets, greaterThan(before));

    before = repo.gets;
    hub.simulateReconnect();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(repo.gets, greaterThan(before));
    // Sau khi tải lại, mốc sequence lấy theo server: sự kiện cũ hơn vẫn bị bỏ.
    expect(current().live!.sequence, 6);
  });
}
