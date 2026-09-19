import 'package:books_marketplace_mobile/app/app.dart';
import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/storage/storage_providers.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/categories/application/category_providers.dart';
import 'package:books_marketplace_mobile/features/inspection/application/inspection_providers.dart';
import 'package:books_marketplace_mobile/features/listings/application/listing_providers.dart';
import 'package:books_marketplace_mobile/features/notifications/application/notification_providers.dart';
import 'package:books_marketplace_mobile/features/profile/application/profile_controller.dart';
import 'package:books_marketplace_mobile/features/profile/data/profile_repository.dart';
import 'package:books_marketplace_mobile/features/profile/domain/profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    email: 'a@b.co',
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
      inspection = FakeInspectionRepository();

  final UserRole role;
  final MemoryTokenStore tokens;
  final FakeListingRepository listings;
  final FakeCategoryRepository categories;
  final FakeNotificationRepository notifications;
  final FakeInspectionRepository inspection;

  /// Bơm app đã đăng nhập với vai trò [role], ngôn ngữ tiếng Việt.
  Future<void> pump(WidgetTester tester, {bool settle = true}) async {
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

    SharedPreferences.setMockInitialValues({'app_locale': 'vi'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          tokenStoreProvider.overrideWithValue(tokens),
          sharedPreferencesProvider.overrideWithValue(prefs),
          profileRepositoryProvider.overrideWithValue(
            _FakeProfileRepository(tokens, role),
          ),
          listingRepositoryProvider.overrideWithValue(listings),
          categoryRepositoryProvider.overrideWithValue(categories),
          notificationRepositoryProvider.overrideWithValue(notifications),
          inspectionRepositoryProvider.overrideWithValue(inspection),
        ],
        child: const App(),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }
}

/// Bấm một tab của thanh điều hướng dưới theo nhãn.
Future<void> tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}
