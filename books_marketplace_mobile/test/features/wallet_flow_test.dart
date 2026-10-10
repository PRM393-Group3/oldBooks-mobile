import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/network/paged_result.dart';
import 'package:books_marketplace_mobile/core/preview/preview_overrides.dart';
import 'package:books_marketplace_mobile/core/util/idempotency.dart';
import 'package:books_marketplace_mobile/features/auth/domain/user_role.dart';
import 'package:books_marketplace_mobile/features/wallet/data/wallet_repository.dart';
import 'package:books_marketplace_mobile/features/wallet/domain/wallet_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/harness.dart';

const _vcb = BankAccount(
  id: 'ba0',
  bankCode: 'VCB',
  bankName: 'Vietcombank',
  accountNumberMasked: '****6789',
  holder: 'NGUYEN VAN TEST',
);

Future<Harness> _pump(
  WidgetTester tester, {
  int available = 1250000,
  List<BankAccount> banks = const [_vcb],
}) async {
  final h = Harness(UserRole.buyer)
    ..wallet = InMemoryWalletRepository(
      available: available,
      bankAccounts: banks,
    );
  await h.pump(tester);
  await tester.tap(find.text('Ví'));
  await tester.pumpAndSettle();
  return h;
}

void main() {
  group('mô hình', () {
    test('Wallet, giao dịch có dấu, type lạ không crash', () {
      final w = Wallet.fromJson({
        'available': 300000,
        'held': 200000,
        'total': 500000,
        'updatedAt': '2026-10-03T08:13:34.779Z',
      });
      expect((w.available, w.held, w.total), (300000, 200000, 500000));

      final t = WalletTransaction.fromJson({
        'id': 3,
        'type': 'HOLD',
        'amount': -200000,
        'balanceAfter': 300000,
        'referenceType': 'WITHDRAWAL',
        'referenceId': 'fbf0',
        'createdAt': '2026-10-03T08:13:34.779Z',
      });
      expect(t.type, LedgerType.hold);
      expect(t.amount, -200000);
      expect(
        WalletTransaction.fromJson({'type': 'NEW_KIND'}).type,
        LedgerType.unknown,
      );
    });

    test('trạng thái rút: cuối và đã hoàn tiền', () {
      expect(WithdrawalStatus.fromApi('PAID').isFinal, isTrue);
      expect(WithdrawalStatus.fromApi('REQUESTED').isFinal, isFalse);
      expect(WithdrawalStatus.fromApi('REJECTED').isRefunded, isTrue);
      expect(WithdrawalStatus.fromApi('FAILED').isRefunded, isTrue);
      expect(WithdrawalStatus.fromApi('PAID').isRefunded, isFalse);
      expect(WithdrawalStatus.fromApi('???'), WithdrawalStatus.unknown);
      expect(TopupStatus.fromApi('EXPIRED'), TopupStatus.expired);
    });

    test('tài khoản ngân hàng: chỉ có dạng che, lấy 4 số cuối', () {
      final b = BankAccount.fromJson({
        'id': '1',
        'bankCode': 'VCB',
        'bankName': 'Vietcombank',
        'accountNumberMasked': '****6789',
        'accountHolder': 'NGUYEN VAN TEST',
      });
      expect(b.last4, '6789');
      expect(b.holder, 'NGUYEN VAN TEST');
    });

    test('Idempotency-Key là UUID v4 và khác nhau mỗi lần', () {
      final a = newIdempotencyKey();
      expect(
        a,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(newIdempotencyKey(), isNot(a));
    });

    test('INSUFFICIENT_BALANCE: đọc số cần và số có từ details', () {
      final e = ApiError.fromBody(422, {
        'error': {
          'code': 'INSUFFICIENT_BALANCE',
          'details': [
            {'field': 'required', 'message': '200000'},
            {'field': 'available', 'message': '150000'},
          ],
        },
      });
      expect(e.detailAmount('required'), 200000);
      expect(e.detailAmount('available'), 150000);
      expect(e.detailAmount('min_amount'), isNull);
    });
  });

  group('WalletRepository (HTTP)', () {
    late List<RequestOptions> seen;
    late WalletRepository repo;

    void setup(ResponseBody Function(RequestOptions) h) {
      seen = [];
      final adapter = FakeAdapter((o) {
        seen.add(o);
        return h(o);
      });
      repo = WalletRepository(
        ApiClient(
          Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = adapter,
        ),
      );
    }

    test('nạp và rút gửi Idempotency-Key', () async {
      setup(
        (o) => jsonResponse(
          201,
          okBody(
            o.path == '/wallet/topups'
                ? {
                    'id': 't1',
                    'amount': 500000,
                    'status': 'PENDING',
                    'payUrl': 'https://p',
                  }
                : {'id': 'w1', 'amount': 200000, 'status': 'REQUESTED'},
          ),
        ),
      );

      final t = await repo.createTopup(amount: 500000, idempotencyKey: 'k-1');
      final w = await repo.createWithdrawal(
        amount: 200000,
        bankAccountId: 'ba0',
        idempotencyKey: 'k-2',
      );

      expect(seen[0].headers['Idempotency-Key'], 'k-1');
      expect(seen[0].data, {'amount': 500000});
      expect(t.status, TopupStatus.pending);
      expect(t.payUrl, 'https://p');
      expect(seen[1].headers['Idempotency-Key'], 'k-2');
      expect(seen[1].data, {'amount': 200000, 'bankAccountId': 'ba0'});
      expect(w.status, WithdrawalStatus.requested);
    });

    test('sao kê gửi type và phân trang', () async {
      setup((o) => jsonResponse(200, okBody(<dynamic>[])));
      await repo.transactions(page: 2, pageSize: 20, type: LedgerType.topup);
      expect(seen.single.queryParameters, {
        'page': 2,
        'pageSize': 20,
        'type': 'TOPUP',
      });
    });

    test('thêm tài khoản ngân hàng gửi số đầy đủ, trả dạng che', () async {
      setup(
        (o) => jsonResponse(
          201,
          okBody({
            'id': '9b79',
            'bankCode': 'VCB',
            'bankName': 'Vietcombank',
            'accountNumberMasked': '****6789',
            'accountHolder': 'NGUYEN VAN TEST',
          }),
        ),
      );
      final b = await repo.addBankAccount(
        bankCode: 'VCB',
        accountNumber: '0123456789',
        accountHolder: 'Nguyễn Văn Test',
      );
      expect(seen.single.data, {
        'bankCode': 'VCB',
        'accountNumber': '0123456789',
        'accountHolder': 'Nguyễn Văn Test',
      });
      expect(b.accountNumberMasked, '****6789');
    });
  });

  testWidgets('tab Ví: số dư thật, đang giữ, tổng và sao kê có dấu', (
    tester,
  ) async {
    final h = Harness(UserRole.buyer)
      ..wallet = InMemoryWalletRepository(
        available: 1250000,
        bankAccounts: const [_vcb],
      );
    await h.wallet.createWithdrawal(
      amount: 100000,
      bankAccountId: 'ba0',
      idempotencyKey: 'seed',
    );
    await h.pump(tester);
    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();

    expect(find.text('Ví Oldbook'), findsOneWidget);
    expect(find.text('1.150.000 ₫'), findsOneWidget, reason: 'khả dụng');
    expect(find.text('100.000 ₫'), findsOneWidget, reason: 'đang giữ');
    expect(find.text('1.250.000 ₫'), findsOneWidget, reason: 'tổng');
    expect(find.text('Giữ tiền'), findsWidgets);
    expect(find.text('−100.000 ₫'), findsOneWidget);
    expect(find.textContaining('Vietcombank'), findsOneWidget);
  });

  testWidgets('nạp tiền: ngoài khoảng bị chặn, hợp lệ thì chờ rồi cộng ví', (
    tester,
  ) async {
    final h = await _pump(tester, available: 0);

    await tester.tap(find.widgetWithText(FilledButton, 'Nạp tiền'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '5000');
    await tester.tap(find.text('Tạo yêu cầu nạp'));
    await tester.pumpAndSettle();
    expect(
      find.text('Số tiền phải từ 10.000 ₫ đến 50.000.000 ₫.'),
      findsOneWidget,
      reason: 'min/max lấy từ config công khai',
    );
    expect(h.wallet.calls, isEmpty);

    await tester.enterText(find.byType(TextField), '500000');
    await tester.tap(find.text('Tạo yêu cầu nạp'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Đang chờ thanh toán…'), findsOneWidget);
    expect(h.wallet.calls.single, startsWith('topup:500000:'));

    // Poll mỗi 3 giây; cổng sandbox báo PAID.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Nạp thành công 500.000 ₫'), findsOneWidget);

    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();
    expect(find.text('500.000 ₫'), findsWidgets);
    expect(find.text('Nạp tiền'), findsWidgets);
  });

  testWidgets('rút tiền: kiểm tra số tiền, chọn tài khoản, tiền bị giữ ngay', (
    tester,
  ) async {
    final h = await _pump(tester);

    await tester.tap(find.text('Rút tiền').first);
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(FilledButton, 'Gửi yêu cầu rút');
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    expect(find.textContaining('Vietcombank'), findsWidgets);

    await tester.enterText(find.byType(TextField), '10000');
    await tester.pump();
    expect(find.text('Số tiền rút tối thiểu là 50.000 ₫.'), findsOneWidget);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '2000000');
    await tester.pump();
    expect(find.textContaining('Vượt số dư khả dụng'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '200000');
    await tester.pump();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(h.wallet.calls.single, matches(RegExp(r'^withdraw:200000:ba0:.+')));
    expect(find.text('1.050.000 ₫'), findsOneWidget, reason: 'khả dụng giảm');
    expect(find.text('200.000 ₫'), findsOneWidget, reason: 'đang giữ tăng');
    expect(find.textContaining('Đã gửi yêu cầu rút 200.000 ₫'), findsOneWidget);
  });

  testWidgets('rút tiền khi chưa có tài khoản ngân hàng: không cho gửi', (
    tester,
  ) async {
    await _pump(tester, banks: const []);
    await tester.tap(find.text('Rút tiền').first);
    await tester.pumpAndSettle();

    expect(find.text('Bạn chưa có tài khoản ngân hàng.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '100000');
    await tester.pump();
    final submit = find.widgetWithText(FilledButton, 'Gửi yêu cầu rút');
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
  });

  testWidgets('lịch sử rút: hiện lý do bị từ chối', (tester) async {
    final h = Harness(UserRole.buyer)
      ..wallet = _WithReasons(available: 500000, bankAccounts: const [_vcb]);
    await h.pump(tester);
    await tester.tap(find.text('Ví'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lịch sử nạp / rút').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rút tiền').last);
    await tester.pumpAndSettle();

    expect(find.text('Bị từ chối, tiền đã trả về ví'), findsOneWidget);
    expect(find.text('Lý do: Tên chủ tài khoản không khớp'), findsOneWidget);
  });
}

class _WithReasons extends InMemoryWalletRepository {
  _WithReasons({super.available, super.bankAccounts});

  @override
  Future<PagedResult<Withdrawal>> withdrawals({
    required int page,
    required int pageSize,
  }) async => PagedResult(
    items: const [
      Withdrawal(
        id: 'w1',
        amount: 200000,
        status: WithdrawalStatus.rejected,
        bankName: 'Vietcombank',
        accountNumberMasked: '****6789',
        rejectReason: 'Tên chủ tài khoản không khớp',
      ),
    ],
    page: page,
    pageSize: pageSize,
    totalCount: 1,
  );
}
