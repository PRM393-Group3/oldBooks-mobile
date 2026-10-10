import 'package:books_marketplace_mobile/core/preview/preview_auctions.dart';
import 'package:books_marketplace_mobile/features/auctions/application/auction_providers.dart';
import 'package:books_marketplace_mobile/features/auctions/data/auction_hub.dart';
import 'package:books_marketplace_mobile/app/app.dart';
import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/config/config_providers.dart';
import 'package:books_marketplace_mobile/features/wallet/application/wallet_providers.dart';
import 'package:books_marketplace_mobile/core/preview/preview_overrides.dart';
import 'package:books_marketplace_mobile/core/storage/storage_providers.dart';
import 'package:books_marketplace_mobile/features/profile/application/address_providers.dart';
import 'package:books_marketplace_mobile/features/auth/application/auth_controller.dart';
import 'package:books_marketplace_mobile/features/categories/application/category_providers.dart';
import 'package:books_marketplace_mobile/features/listings/application/listing_providers.dart';
import 'package:books_marketplace_mobile/features/notifications/application/notification_providers.dart';
import 'package:books_marketplace_mobile/features/auth/data/auth_repository.dart';
import 'package:books_marketplace_mobile/features/auth/domain/auth_session.dart';
import 'package:books_marketplace_mobile/features/auth/domain/otp_sent.dart';
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
  Future<OtpSent> sendOtp({
    required String phone,
    required OtpPurpose purpose,
    String? email,
  }) async => const OtpSent(expiresInSeconds: 300);

  @override
  Future<AuthSession> login({
    required String phone,
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
        fullName: 'Nguyen Van A',
        role: UserRole.buyer,
      ),
    );
  }

  @override
  Future<void> logout({bool allDevices = false}) => _tokens.clear();
}

class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository(MemoryTokenStore tokens)
    : super(ApiClient(Dio()), Dio(), tokens);

  Profile current = Profile(
    id: 'u1',
    fullName: 'Nguyen Van A',
    role: UserRole.seller,
    createdAt: DateTime.utc(2026, 9, 19),
  );

  @override
  Future<Profile> getProfile() async => current;

  @override
  Future<OtpSent> sendPhoneOtp({required String phone}) async =>
      const OtpSent(expiresInSeconds: 300);

  @override
  Future<Profile> changePhone({
    required String phone,
    required String otp,
  }) async => current = Profile(
    id: current.id,
    fullName: current.fullName,
    phoneNumber: phone,
    role: current.role,
    createdAt: current.createdAt,
  );

  @override
  Future<void> deleteAccount({required String password}) async {}

  @override
  Future<Profile> updateProfile({required String fullName}) async {
    current = Profile(
      id: current.id,
      fullName: fullName,
      phoneNumber: current.phoneNumber,
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
        walletRepositoryProvider.overrideWithValue(InMemoryWalletRepository()),
        configRepositoryProvider.overrideWithValue(
          FixedConfigRepository(prefs),
        ),
        addressRepositoryProvider.overrideWithValue(
          InMemoryAddressRepository(seed: const [sampleAddress]),
        ),
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(
          _FakeProfileRepository(tokens),
        ),
        listingRepositoryProvider.overrideWithValue(FakeListingRepository()),
        categoryRepositoryProvider.overrideWithValue(FakeCategoryRepository()),
        notificationRepositoryProvider.overrideWithValue(
          FakeNotificationRepository(),
        ),
        auctionRepositoryProvider.overrideWithValue(
          InMemoryAuctionRepository(),
        ),
        auctionHubProvider.overrideWithValue(OfflineAuctionHub()),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
  if (loggedIn) await _openProfileTab(tester);
  return (tokens: tokens, auth: auth);
}

/// Sau đăng nhập app vào Khám phá; các test hồ sơ mở tab Tôi.
Future<void> _openProfileTab(WidgetTester tester) async {
  await tester.tap(find.text('Tôi').last);
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

    expect(find.text('Vui lòng nhập số điện thoại.'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu.'), findsOneWidget);
    expect(app.auth.logins, 0);
  });

  testWidgets('sai mật khẩu: báo lỗi bằng tiếng Việt, ở lại màn đăng nhập', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.enterText(find.byType(TextFormField).at(0), '0912345678');
    await tester.enterText(find.byType(TextFormField).at(1), 'sai-mat-khau');
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.text('Số điện thoại hoặc mật khẩu chưa đúng.'), findsOneWidget);
    expect(find.text('Chào mừng bạn quay lại chợ sách cũ.'), findsOneWidget);
  });

  testWidgets('đăng nhập đúng: sang tab Hồ sơ và thấy thông tin', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.enterText(find.byType(TextFormField).at(0), '0912345678');
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd!');
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    await _openProfileTab(tester);

    expect(find.text('Nguyen Van A'), findsOneWidget);
    expect(find.text('Người bán'), findsOneWidget);
    expect(find.text('Chưa cập nhật'), findsWidgets);
    expect(find.text('Sửa hồ sơ'), findsOneWidget);
  });

  testWidgets(
    'đã có phiên: mở thẳng Hồ sơ, sửa họ tên (số điện thoại chỉ đọc)',
    (tester) async {
      await _pumpApp(tester, loggedIn: true);
      expect(find.text('Nguyen Van A'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Sửa hồ sơ'), 200);
      await tester.tap(find.text('Sửa hồ sơ'));
      await tester.pumpAndSettle();

      // Số điện thoại đổi bằng OTP ở màn riêng nên ô này bị khóa.
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).enabled,
        false,
      );
      expect(find.text('Đổi số điện thoại'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng nhập họ và tên.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Tran Thi B');
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Đã cập nhật hồ sơ'), findsOneWidget);
      expect(find.text('Tran Thi B'), findsOneWidget);
    },
  );

  testWidgets(
    'đổi số điện thoại: chặn số trùng, gửi OTP tới email rồi xác nhận',
    (tester) async {
      await _pumpApp(tester, loggedIn: true);
      await tester.scrollUntilVisible(find.text('Sửa hồ sơ'), 200);
      await tester.tap(find.text('Sửa hồ sơ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đổi số điện thoại'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), '0987654321');
      await tester.tap(find.text('Gửi mã'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Đã gửi mã OTP tới 0987654321'), findsOneWidget);
      expect(find.text('Mã hết hạn sau 05:00'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận đổi số'));
      await tester.pumpAndSettle();
      expect(find.text('Đã đổi số điện thoại.'), findsOneWidget);
    },
  );

  testWidgets('xóa tài khoản: cần mật khẩu và xác nhận hai bước', (
    tester,
  ) async {
    final app = await _pumpApp(tester, loggedIn: true);
    await tester.scrollUntilVisible(find.text('Xóa tài khoản'), 200);
    await tester.tap(find.text('Xóa tài khoản'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FilledButton, 'Xóa tài khoản vĩnh viễn'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập mật khẩu.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Passw0rd!');
    await tester.tap(
      find.widgetWithText(FilledButton, 'Xóa tài khoản vĩnh viễn'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bạn chắc chắn muốn xóa?'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Xóa tài khoản vĩnh viễn').last,
    );
    await tester.pumpAndSettle();

    expect(app.tokens.hasSession, isFalse);
    expect(find.text('Chào mừng bạn quay lại chợ sách cũ.'), findsOneWidget);
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

  testWidgets(
    'đăng ký bằng SĐT: cần số hợp lệ, OTP 6 số, mật khẩu có chữ và số',
    (tester) async {
      await _pumpApp(tester);
      await tester.tap(find.text('Đăng ký'));
      await tester.pumpAndSettle();
      expect(find.text('Mã OTP'), findsOneWidget);
      expect(find.text('Gửi mã'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Đăng ký'));
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng nhập họ và tên.'), findsOneWidget);
      expect(find.text('Vui lòng nhập số điện thoại.'), findsOneWidget);
      expect(find.text('Vui lòng nhập email.'), findsOneWidget);
      expect(find.text('Mã OTP gồm 6 chữ số.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Nguyen Van A');
      await tester.enterText(find.byType(TextFormField).at(1), '0912345678');
      await tester.enterText(find.byType(TextFormField).at(2), 'a@gmail.com');
      await tester.enterText(find.byType(TextFormField).at(3), '123456');
      await tester.enterText(find.byType(TextFormField).at(4), 'chiconchu');
      await tester.tap(find.widgetWithText(FilledButton, 'Đăng ký'));
      await tester.pumpAndSettle();
      expect(find.text('Mật khẩu cần có cả chữ và số.'), findsOneWidget);
    },
  );

  testWidgets('gửi mã OTP: cần SĐT hợp lệ, rồi đếm ngược gửi lại', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Quên mật khẩu?'));
    await tester.pumpAndSettle();
    expect(find.text('Quên mật khẩu'), findsOneWidget);

    await tester.tap(find.text('Gửi mã'));
    await tester.pump();
    expect(
      find.text('Gửi mã'),
      findsOneWidget,
      reason: 'chưa có SĐT thì không gửi',
    );

    await tester.enterText(find.byType(TextFormField).at(0), '0912345678');
    await tester.tap(find.text('Gửi mã'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Gửi lại sau 60s'), findsOneWidget);
    expect(
      find.text('Nếu số đã đăng ký, mã sẽ được gửi tới email của tài khoản.'),
      findsWidgets,
      reason: 'không lộ số nào đã có tài khoản',
    );
    expect(find.text('Mã hết hạn sau 05:00'), findsOneWidget);
  });

  testWidgets('đăng ký bắt buộc đồng ý điều khoản (acceptTerms)', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Nguyen Van A');
    await tester.enterText(find.byType(TextFormField).at(1), '0912345678');
    await tester.enterText(find.byType(TextFormField).at(2), 'a@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(3), '123456');
    await tester.enterText(find.byType(TextFormField).at(4), 'Passw0rd123');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Đăng ký'));
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng ký'));
    await tester.pumpAndSettle();

    expect(find.text('Bạn cần đồng ý điều khoản để tiếp tục.'), findsOneWidget);
  });

  testWidgets('đăng ký: gửi mã cần cả SĐT và email; sửa email phải gửi lại', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), '0912345678');
    await tester.tap(find.text('Gửi mã'));
    await tester.pump();
    expect(find.text('Gửi mã'), findsOneWidget, reason: 'chưa có email');

    await tester.enterText(find.byType(TextFormField).at(2), 'a@gmail.com');
    await tester.pump();
    await tester.tap(find.text('Gửi mã'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Gửi lại sau 60s'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'b@gmail.com');
    await tester.pump();
    expect(find.text('Gửi mã'), findsOneWidget);
    expect(find.text('Mã hết hạn sau 05:00'), findsNothing);
  });
}
