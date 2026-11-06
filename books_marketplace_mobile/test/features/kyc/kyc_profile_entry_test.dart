import 'package:books_marketplace_mobile/core/l10n/app_localizations.dart';
import 'package:books_marketplace_mobile/core/widgets/verified_badge.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/kyc/application/kyc_providers.dart';
import 'package:books_marketplace_mobile/features/kyc/data/kyc_repository.dart';
import 'package:books_marketplace_mobile/features/kyc/domain/kyc_models.dart';
import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

class _FakeKycRepository extends KycRepository {
  _FakeKycRepository(this.state) : super(ApiClient(Dio()));

  final KycState state;

  @override
  Future<KycState> getState() async => state;
}

Future<void> _openProfile(WidgetTester tester, Harness h, KycState kyc) async {
  await h.pump(
    tester,
    overrides: [
      kycRepositoryProvider.overrideWithValue(_FakeKycRepository(kyc)),
    ],
  );
  await tapTab(tester, 'Tôi');
}

void main() {
  testWidgets('chưa xác minh: hiện hàng "Xác minh tài khoản" mời bắt đầu', (
    tester,
  ) async {
    final h = Harness(UserRole.buyer);
    await _openProfile(tester, h, const KycState(status: KycStatus.none));

    expect(find.text('Xác minh tài khoản'), findsOneWidget);
    expect(find.textContaining('Chưa xác minh'), findsOneWidget);
    expect(find.byType(VerifiedBadge), findsNothing);
  });

  testWidgets('đang chờ duyệt', (tester) async {
    final h = Harness(UserRole.buyer);
    await _openProfile(
      tester,
      h,
      const KycState(status: KycStatus.pendingReview, canSubmit: false),
    );
    expect(find.textContaining('Đang chờ duyệt'), findsOneWidget);
  });

  testWidgets('đã duyệt: dấu tích xanh cạnh tên và trạng thái Đã xác minh', (
    tester,
  ) async {
    final h = Harness(UserRole.buyer);
    await _openProfile(
      tester,
      h,
      const KycState(status: KycStatus.approved, isVerified: true),
    );
    expect(find.textContaining('Đã xác minh'), findsWidgets);
  });

  testWidgets('NameWithBadge: có dấu tích khi đã xác minh, không thì chỉ tên', (
    tester,
  ) async {
    final h = Harness(UserRole.buyer);
    await h.pump(tester);
    final ctx = tester.element(find.byType(Scaffold).first);
    await tester.pumpWidget(
      MaterialApp(
        theme: Theme.of(ctx),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: const Column(
          children: [
            NameWithBadge('An', verified: true),
            NameWithBadge('Bình', verified: false),
          ],
        ),
      ),
    );
    expect(find.byType(VerifiedBadge), findsOneWidget);
    expect(find.byTooltip('Đã xác minh danh tính'), findsOneWidget);
    expect(find.text('Bình'), findsOneWidget);
  });

  testWidgets('bấm vào hàng mở màn trạng thái, bị từ chối thì hiện lý do', (
    tester,
  ) async {
    final h = Harness(UserRole.buyer);
    await _openProfile(
      tester,
      h,
      KycState(
        status: KycStatus.rejected,
        latest: KycSubmission(
          id: 's1',
          status: KycStatus.rejected,
          fullName: 'NGUYEN VAN AN',
          idNumberMasked: '********8901',
          dateOfBirth: '1999-03-05',
          rejectReason: 'Ảnh CCCD bị mờ',
        ),
      ),
    );

    await tester.ensureVisible(find.text('Xác minh tài khoản'));
    await tester.tap(find.text('Xác minh tài khoản'));
    await tester.pumpAndSettle();

    expect(find.text('Lý do: Ảnh CCCD bị mờ'), findsOneWidget);
    expect(find.text('********8901'), findsOneWidget);
    expect(find.text('05/03/1999'), findsOneWidget);
    expect(find.text('Gửi lại hồ sơ'), findsOneWidget);
  });

  testWidgets('đang bị giới hạn gửi: không có nút gửi lại, có giờ thử lại', (
    tester,
  ) async {
    final h = Harness(UserRole.buyer);
    await _openProfile(
      tester,
      h,
      KycState(
        status: KycStatus.rejected,
        canSubmit: false,
        retryAfter: DateTime.utc(2030, 1, 1, 3),
      ),
    );
    await tester.ensureVisible(find.text('Xác minh tài khoản'));
    await tester.tap(find.text('Xác minh tài khoản'));
    await tester.pumpAndSettle();

    expect(find.text('Gửi lại hồ sơ'), findsNothing);
    expect(find.textContaining('Bạn có thể gửi lại sau'), findsOneWidget);
  });

  testWidgets('NONE: nút Bắt đầu mở luồng và phải tick đồng ý mới đi tiếp', (
    tester,
  ) async {
    final h = Harness(UserRole.buyer);
    await _openProfile(tester, h, const KycState(status: KycStatus.none));
    await tester.ensureVisible(find.text('Xác minh tài khoản'));
    await tester.tap(find.text('Xác minh tài khoản'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bắt đầu xác minh'));
    await tester.pumpAndSettle();
    expect(find.text('Xác minh danh tính'), findsOneWidget);

    FilledButton next() => tester.widget<FilledButton>(
      find.descendant(
        of: find.widgetWithText(Expanded, 'Tiếp'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(next().onPressed, isNull, reason: 'chưa đồng ý thì khóa');

    await tester.ensureVisible(find.textContaining('Tôi đồng ý cho Oldbook'));
    await tester.tap(find.textContaining('Tôi đồng ý cho Oldbook'));
    await tester.pumpAndSettle();
    expect(next().onPressed, isNotNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Tiếp'));
    await tester.pumpAndSettle();
    expect(find.text('Mặt trước CCCD'), findsOneWidget);
    expect(find.text('Mặt sau CCCD'), findsOneWidget);
  });
}
