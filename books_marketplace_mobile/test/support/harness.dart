import 'package:books_marketplace_mobile/app/app.dart';
import 'package:books_marketplace_mobile/core/widgets/app_bottom_nav.dart';
import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/config/config_providers.dart';
import 'package:books_marketplace_mobile/features/wallet/application/wallet_providers.dart';
import 'package:books_marketplace_mobile/core/preview/preview_overrides.dart';
import 'package:books_marketplace_mobile/core/storage/storage_providers.dart';
import 'package:books_marketplace_mobile/features/profile/application/address_providers.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/categories/application/category_providers.dart';
import 'package:books_marketplace_mobile/features/listings/application/listing_providers.dart';
import 'package:books_marketplace_mobile/features/notifications/application/notification_providers.dart';
import 'package:books_marketplace_mobile/features/profile/application/profile_controller.dart';
import 'package:books_marketplace_mobile/core/preview/preview_auctions.dart';
import 'package:books_marketplace_mobile/features/auction_orders/application/auction_order_providers.dart';
import 'package:books_marketplace_mobile/features/auctions/application/auction_providers.dart';
import 'package:books_marketplace_mobile/features/auctions/data/auction_hub.dart';
import 'package:books_marketplace_mobile/features/profile/data/profile_repository.dart';
import 'package:books_marketplace_mobile/features/profile/domain/profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository(MemoryTokenStore tokens, this.role)
    : super(ApiClient(Dio()), Dio(), tokens);

  final UserRole role;

  @override
  Future<Profile> getProfile() async => Profile(
    id: 'u1',
    fullName: 'Nguyen Van A',
    role: role,
    createdAt: DateTime.utc(2026, 9, 19),
  );
}

/// Toàn bộ fake của app để test luồng theo vai trò mà không chạm mạng.
class Harness {
  Harness(this.role)
    : tokens = MemoryTokenStore(access: 'a', refresh: 'r'),
      listings = FakeListingRepository(),
      categories = FakeCategoryRepository(),
      notifications = FakeNotificationRepository(),
      auctions = InMemoryAuctionRepository(),
      auctionOrders = InMemoryAuctionOrderRepository(),
      hub = OfflineAuctionHub();

  final UserRole role;
  final MemoryTokenStore tokens;
  final FakeListingRepository listings;
  final FakeCategoryRepository categories;
  final FakeNotificationRepository notifications;

  /// Đấu giá trong bộ nhớ (dữ liệu mẫu của chế độ xem trước).
  final InMemoryAuctionRepository auctions;
  final InMemoryAuctionOrderRepository auctionOrders;

  /// Hub không kết nối; test phát sự kiện bằng `hub.emit`.
  final OfflineAuctionHub hub;

  /// Ví trong bộ nhớ; test đặt số dư/tài khoản trước khi [pump].
  InMemoryWalletRepository wallet = InMemoryWalletRepository();

  /// Bơm app đã đăng nhập với vai trò [role], ngôn ngữ tiếng Việt.
  Future<void> pump(
    WidgetTester tester, {
    bool settle = true,
    List<Override> overrides = const [],
  }) async {
    // Cửa sổ test mặc định (800x600, cỡ desktop) làm các trang cuộn dài hoặc
    // bottom sheet bị lệch tọa độ khi tap. Đặt cỡ gần điện thoại thật.
    final originalSize = tester.view.physicalSize;
    final originalRatio = tester.view.devicePixelRatio;
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.physicalSize = originalSize;
      tester.view.devicePixelRatio = originalRatio;
    });

    await loadAppFonts();
    SharedPreferences.setMockInitialValues({'app_locale': 'vi'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          tokenStoreProvider.overrideWithValue(tokens),
          sharedPreferencesProvider.overrideWithValue(prefs),
          walletRepositoryProvider.overrideWithValue(wallet),
          configRepositoryProvider.overrideWithValue(
            FixedConfigRepository(prefs),
          ),
          addressRepositoryProvider.overrideWithValue(
            InMemoryAddressRepository(seed: const [sampleAddress]),
          ),
          profileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository(tokens, role),
          ),
          listingRepositoryProvider.overrideWithValue(listings),
          categoryRepositoryProvider.overrideWithValue(categories),
          notificationRepositoryProvider.overrideWithValue(notifications),
          auctionRepositoryProvider.overrideWithValue(auctions),
          auctionOrderRepositoryProvider.overrideWithValue(auctionOrders),
          auctionHubProvider.overrideWithValue(hub),
          ...overrides,
        ],
        child: const App(),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }
}

/// Tab của thanh điều hướng dưới theo nhãn (không gồm nút "+" Bán).
Finder tabFinder(String label) =>
    find.descendant(of: find.byType(AppBottomNav), matching: find.text(label));

/// Bấm một tab của thanh điều hướng dưới theo nhãn.
Future<void> tapTab(WidgetTester tester, String label) async {
  await tester.tap(tabFinder(label));
  await tester.pumpAndSettle();
}

/// Bấm nút "+" Bán ở giữa thanh điều hướng.
Future<void> tapSellTab(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(AppBottomNav),
      matching: find.byIcon(Icons.add),
    ),
  );
  await tester.pumpAndSettle();
}

/// Container của app đang chạy trong [tester], để chuẩn bị hoặc kiểm tra
/// trạng thái ngoài giao diện.
ProviderContainer appContainer(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

var _fontsLoaded = false;

/// Nạp font thật của app. Mặc định `flutter test` dùng font Ahem (mỗi ký tự là
/// một ô vuông rộng 1em) nên bố cục và lỗi tràn chữ không phản ánh máy thật.
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final f in files) {
      loader.addFont(rootBundle.load('assets/fonts/$f'));
    }
    await loader.load();
  }

  await family('BeVietnamPro', [
    'BeVietnamPro-Regular.ttf',
    'BeVietnamPro-Medium.ttf',
    'BeVietnamPro-SemiBold.ttf',
    'BeVietnamPro-Bold.ttf',
  ]);
  await family('Newsreader', ['Newsreader.ttf']);
  await family('JetBrainsMono', ['JetBrainsMono.ttf']);
  _fontsLoaded = true;
}
