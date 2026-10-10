import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../../auth/application/auth_controller.dart';
import '../data/wallet_repository.dart';
import '../domain/wallet_models.dart';

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepository(ref.watch(apiClientProvider)),
);

bool _authed(Ref ref) => ref.watch(
  authControllerProvider.select((s) => s == AuthStatus.authenticated),
);

/// Số dư ví. Làm mới sau nạp/rút và khi người dùng kéo để tải lại.
class WalletNotifier extends AsyncNotifier<Wallet> {
  @override
  Future<Wallet> build() {
    if (!_authed(ref)) {
      return Future.value(const Wallet(available: 0, held: 0, total: 0));
    }
    return ref.read(walletRepositoryProvider).wallet();
  }

  /// Tải lại số dư mà không nháy màn hình về trạng thái loading.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(walletRepositoryProvider).wallet(),
    );
  }
}

final walletProvider = AsyncNotifierProvider<WalletNotifier, Wallet>(
  WalletNotifier.new,
);

class WalletTransactionsNotifier extends PagedNotifier<WalletTransaction> {
  WalletTransactionsNotifier(this.type);
  final LedgerType? type;

  @override
  Future<PagedResult<WalletTransaction>> fetchPage(int page) => ref
      .read(walletRepositoryProvider)
      .transactions(page: page, pageSize: PagedNotifier.pageSize, type: type);
}

/// Sao kê, lọc theo loại (`null` là tất cả).
final walletTransactionsProvider = AsyncNotifierProvider.autoDispose
    .family<
      WalletTransactionsNotifier,
      PagedState<WalletTransaction>,
      LedgerType?
    >(WalletTransactionsNotifier.new);

class TopupsNotifier extends PagedNotifier<Topup> {
  @override
  Future<PagedResult<Topup>> fetchPage(int page) => ref
      .read(walletRepositoryProvider)
      .topups(page: page, pageSize: PagedNotifier.pageSize);
}

final topupsProvider =
    AsyncNotifierProvider.autoDispose<TopupsNotifier, PagedState<Topup>>(
      TopupsNotifier.new,
    );

class WithdrawalsNotifier extends PagedNotifier<Withdrawal> {
  @override
  Future<PagedResult<Withdrawal>> fetchPage(int page) => ref
      .read(walletRepositoryProvider)
      .withdrawals(page: page, pageSize: PagedNotifier.pageSize);
}

final withdrawalsProvider =
    AsyncNotifierProvider.autoDispose<
      WithdrawalsNotifier,
      PagedState<Withdrawal>
    >(WithdrawalsNotifier.new);

/// Danh sách ngân hàng hỗ trợ cho ô chọn.
final banksProvider = FutureProvider.autoDispose<List<Bank>>(
  (ref) => ref.watch(walletRepositoryProvider).banks(),
);

/// Tài khoản ngân hàng nhận tiền, tối đa [maxBankAccounts].
class BankAccountsNotifier extends AsyncNotifier<List<BankAccount>> {
  WalletRepository get _repo => ref.read(walletRepositoryProvider);

  @override
  Future<List<BankAccount>> build() {
    if (!_authed(ref)) return Future.value(const []);
    return _repo.bankAccounts();
  }

  Future<void> add({
    required String bankCode,
    required String accountNumber,
    required String accountHolder,
  }) async {
    await _repo.addBankAccount(
      bankCode: bankCode,
      accountNumber: accountNumber,
      accountHolder: accountHolder,
    );
    state = AsyncData(await _repo.bankAccounts());
  }

  Future<void> remove(String id) async {
    await _repo.deleteBankAccount(id);
    state = AsyncData(await _repo.bankAccounts());
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final bankAccountsProvider =
    AsyncNotifierProvider<BankAccountsNotifier, List<BankAccount>>(
      BankAccountsNotifier.new,
    );

/// Cổng thanh toán đang bật. Gọi trước khi hiện màn nạp tiền.
final paymentMethodsProvider = FutureProvider.autoDispose<List<PaymentMethod>>(
  (ref) => ref.watch(walletRepositoryProvider).paymentMethods(),
);
