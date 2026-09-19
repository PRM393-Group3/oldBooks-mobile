import 'package:books_marketplace_mobile/app/app.dart';
import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/storage/storage_providers.dart';
import 'package:books_marketplace_mobile/features/auth/application/auth_controller.dart';
import 'package:books_marketplace_mobile/features/categories/application/category_providers.dart';
import 'package:books_marketplace_mobile/features/listings/application/listing_providers.dart';
import 'package:books_marketplace_mobile/features/notifications/application/notification_providers.dart';
import 'package:books_marketplace_mobile/features/auth/data/auth_repository.dart';
import 'package:books_marketplace_mobile/features/auth/domain/auth_session.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/profile/application/profile_controller.dart';
import 'package:books_marketplace_mobile/features/profile/data/profile_repository.dart';
import 'package:books_marketplace_mobile/features/profile/domain/profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository(MemoryTokenStore tokens)
    : _tokens = tokens,
      super(ApiClient(Dio()), tokens);

  final MemoryTokenStore _tokens;
  int logins = 0;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    logins++;
    if (password != 'Passw0rd!') {
      throw const ApiError(status: 401, code: ApiErrorCode.invalidCredentials);
    }
    await _tokens.save(accessToken: 'a', refreshToken: 'r');
    return AuthSession(
      accessToken: 'a',
      accessTokenExpiresAt: DateTime.now(),
      refreshToken: 'r',
      refreshTokenExpiresAt: DateTime.now(),
      user: const SessionUser(
        id: 'u1',
        email: 'a@b.co',
        fullName: 'Nguyen Van A',
        role: UserRole.buyer,
      ),
    );
  }

  @override
  Future<void> logout() => _tokens.clear();
}

class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository(MemoryTokenStore tokens)
    : super(ApiClient(Dio()), Dio(), tokens);

  Profile current = Profile(
    id: 'u1',
    email: 'a@b.co',
    fullName: 'Nguyen Van A',
    role: UserRole.seller,
    createdAt: DateTime.utc(2026, 9, 19),
  );

  @override
  Future<Profile> getProfile() async => current;

  @override
  Future<Profile> updateProfile({
    required String fullName,
    required String? phoneNumber,
  }) async {
    current = Profile(
      id: current.id,
      email: current.email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: current.role,
      createdAt: current.createdAt,
    );
    return current;
  }
}

Future<({MemoryTokenStore tokens, _FakeAuthRepository auth})> _pumpApp(
  WidgetTester tester, {
  bool loggedIn = false,
}) async {
  SharedPreferences.setMockInitialValues({'app_locale': 'vi'});
  final prefs = await SharedPreferences.getInstance();
  final tokens = MemoryTokenStore(
    access: loggedIn ? 'a' : null,
    refresh: loggedIn ? 'r' : null,
  );
  final auth = _FakeAuthRepository(tokens);

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        tokenStoreProvider.overrideWithValue(tokens),
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(
          _FakeProfileRepository(tokens),
        ),
        listingRepositoryProvider.overrideWithValue(FakeListingRepository()),
        categoryRepositoryProvider.overrideWithValue(FakeCategoryRepository()),
        notificationRepositoryProvider.overrideWithValue(
          FakeNotificationRepository(),
        ),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
  if (loggedIn) await _openProfileTab(tester);
  return (tokens: tokens, auth: auth);
}

/// Sau đăng nhập app vào Trang chủ theo vai trò; các test hồ sơ mở tab Hồ sơ.
Future<void> _openProfileTab(WidgetTester tester) async {
  await tester.tap(find.text('Hồ sơ').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('chưa đăng nhập: vào màn hình đăng nhập', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Chào mừng bạn quay lại chợ sách cũ.'), findsOneWidget);
    expect(find.text('Hồ sơ'), findsNothing);
  });

  testWidgets('gửi form rỗng: hiện lỗi từng ô, không gọi API', (tester) async {
    final app = await _pumpApp(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập email.'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu.'), findsOneWidget);
    expect(app.auth.logins, 0);
  });

  testWidgets('sai mật khẩu: báo lỗi bằng tiếng Việt, ở lại màn đăng nhập', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.co');
    await tester.enterText(find.byType(TextFormField).at(1), 'sai-mat-khau');
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.text('Email hoặc mật khẩu chưa đúng.'), findsOneWidget);
    expect(find.text('Chào mừng bạn quay lại chợ sách cũ.'), findsOneWidget);
  });

  testWidgets('đăng nhập đúng: sang tab Hồ sơ và thấy thông tin', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.co');
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd!');
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    await _openProfileTab(tester);

    expect(find.text('Nguyen Van A'), findsOneWidget);
    expect(find.text('Người bán'), findsOneWidget);
    expect(find.text('Chưa cập nhật'), findsOneWidget);
    expect(find.text('Sửa hồ sơ'), findsOneWidget);
  });

  testWidgets('đã có phiên: mở thẳng Hồ sơ, sửa họ tên và số điện thoại', (
    tester,
  ) async {
    await _pumpApp(tester, loggedIn: true);
    expect(find.text('Nguyen Van A'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Sửa hồ sơ'), 200);
    await tester.tap(find.text('Sửa hồ sơ'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Tran Thi B');
    await tester.enterText(find.byType(TextFormField).at(1), '12345');
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Số điện thoại phải bắt đầu bằng 0 hoặc +84, theo sau là 9 hoặc 10 chữ số.',
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).at(1), '0901234567');
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Đã cập nhật hồ sơ'), findsOneWidget);
    expect(find.text('Tran Thi B'), findsOneWidget);
    expect(find.text('0901234567'), findsOneWidget);
  });

  testWidgets('đổi mật khẩu: mật khẩu mới trùng mật khẩu cũ bị chặn ở client', (
    tester,
  ) async {
    await _pumpApp(tester, loggedIn: true);

    await tester.scrollUntilVisible(find.text('Đổi mật khẩu'), 200);
    await tester.tap(find.text('Đổi mật khẩu'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Passw0rd!');
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd!');
    await tester.enterText(find.byType(TextFormField).at(2), 'khac');
    await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
    await tester.pumpAndSettle();

    expect(
      find.text('Mật khẩu mới phải khác mật khẩu hiện tại.'),
      findsOneWidget,
    );
    expect(find.text('Mật khẩu nhập lại chưa khớp.'), findsOneWidget);
  });

  testWidgets('đăng xuất cần xác nhận rồi về màn hình đăng nhập', (
    tester,
  ) async {
    final app = await _pumpApp(tester, loggedIn: true);

    await tester.scrollUntilVisible(find.text('Đăng xuất'), 200);
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    expect(find.text('Đăng xuất?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Đăng xuất'));
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng bạn quay lại chợ sách cũ.'), findsOneWidget);
    expect(app.tokens.hasSession, isFalse);
  });

  testWidgets('đổi sang English ngay trong ứng dụng', (tester) async {
    await _pumpApp(tester, loggedIn: true);

    await tester.scrollUntilVisible(find.text('Ngôn ngữ'), 200);
    await tester.tap(find.text('Ngôn ngữ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Sửa hồ sơ'), findsNothing);
  });
}
