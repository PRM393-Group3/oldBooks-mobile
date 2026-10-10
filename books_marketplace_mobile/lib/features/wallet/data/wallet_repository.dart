import '../../../core/network/api_client.dart';
import '../../../core/network/paged_result.dart';
import '../domain/wallet_models.dart';

/// Ví, nạp, rút và tài khoản ngân hàng (tài liệu `07-wallet`). Hai thao tác tạo
/// tiền ([createTopup], [createWithdrawal]) bắt buộc `Idempotency-Key`.
class WalletRepository {
  WalletRepository(this._api);

  final ApiClient _api;

  Future<Wallet> wallet() => _api.get('/wallet', parse: Wallet.fromJson);

  /// Sao kê số dư khả dụng, mới nhất trước.
  Future<PagedResult<WalletTransaction>> transactions({
    required int page,
    required int pageSize,
    LedgerType? type,
  }) => _api.get(
    '/wallet/transactions',
    query: {'page': page, 'pageSize': pageSize, 'type': ?type?.api},
    parse: (d) => PagedResult.fromJson(
      d,
      WalletTransaction.fromJson,
      page: page,
      pageSize: pageSize,
    ),
  );

  /// Mảng rỗng nghĩa là chưa nạp được (admin chưa bật cổng nào).
  Future<List<PaymentMethod>> paymentMethods() => _api.get(
    '/wallet/payment-methods',
    parse: (d) => [for (final j in d as List) PaymentMethod.fromJson(j)],
  );

  /// [provider] bỏ trống thì server dùng cổng mặc định.
  Future<Topup> createTopup({
    required int amount,
    required String idempotencyKey,
    String? provider,
  }) => _api.post(
    '/wallet/topups',
    body: {'amount': amount, 'provider': ?provider},
    headers: {'Idempotency-Key': idempotencyKey},
    parse: Topup.fromJson,
  );

  Future<Topup> topup(String id) =>
      _api.get('/wallet/topups/$id', parse: Topup.fromJson);

  Future<PagedResult<Topup>> topups({
    required int page,
    required int pageSize,
  }) => _api.get(
    '/wallet/topups',
    query: {'page': page, 'pageSize': pageSize},
    parse: (d) =>
        PagedResult.fromJson(d, Topup.fromJson, page: page, pageSize: pageSize),
  );

  /// Chỉ môi trường Development: mô phỏng cổng thanh toán báo kết quả.
  Future<void> devPayTopup(String id, {required bool success}) =>
      _api.post('/dev/payments/topups/$id/pay?success=$success', parse: (_) {});

  /// Tiền bị giữ ngay khi tạo yêu cầu.
  Future<Withdrawal> createWithdrawal({
    required int amount,
    required String bankAccountId,
    required String idempotencyKey,
  }) => _api.post(
    '/wallet/withdrawals',
    body: {'amount': amount, 'bankAccountId': bankAccountId},
    headers: {'Idempotency-Key': idempotencyKey},
    parse: Withdrawal.fromJson,
  );

  Future<Withdrawal> withdrawal(String id) =>
      _api.get('/wallet/withdrawals/$id', parse: Withdrawal.fromJson);

  Future<PagedResult<Withdrawal>> withdrawals({
    required int page,
    required int pageSize,
  }) => _api.get(
    '/wallet/withdrawals',
    query: {'page': page, 'pageSize': pageSize},
    parse: (d) => PagedResult.fromJson(
      d,
      Withdrawal.fromJson,
      page: page,
      pageSize: pageSize,
    ),
  );

  Future<List<Bank>> banks() => _api.get(
    '/wallet/banks',
    parse: (d) => [for (final j in d as List) Bank.fromJson(j)],
  );

  Future<List<BankAccount>> bankAccounts() => _api.get(
    '/me/bank-accounts',
    parse: (d) => [for (final j in d as List) BankAccount.fromJson(j)],
  );

  Future<BankAccount> addBankAccount({
    required String bankCode,
    required String accountNumber,
    required String accountHolder,
  }) => _api.post(
    '/me/bank-accounts',
    body: {
      'bankCode': bankCode,
      'accountNumber': accountNumber,
      'accountHolder': accountHolder,
    },
    parse: BankAccount.fromJson,
  );

  Future<void> deleteBankAccount(String id) =>
      _api.deleteNoContent('/me/bank-accounts/$id');
}
