// ignore_for_file: use_super_parameters
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../features/auth/application/auth_controller.dart';
import '../../features/profile/application/address_providers.dart';
import 'in_memory_listings.dart';
import '../../features/wallet/application/wallet_providers.dart';
import '../../features/wallet/data/wallet_repository.dart';
import '../../features/wallet/domain/wallet_models.dart';
import '../../features/profile/data/address_repository.dart';
import '../../features/profile/domain/address.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/auth_session.dart';
import '../../features/auth/domain/user_role.dart';
import '../../features/categories/application/category_providers.dart';
import '../../features/categories/data/category_repository.dart';
import '../../features/categories/domain/category.dart';
import '../../features/listings/application/listing_providers.dart';
import '../../features/notifications/application/notification_providers.dart';
import '../../features/notifications/data/notification_repository.dart';
import '../../features/notifications/domain/app_notification.dart';
import '../../features/profile/application/profile_controller.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/domain/profile.dart';
import '../config/config_providers.dart';
import '../config/config_repository.dart';
import '../config/public_config.dart';
import '../network/api_client.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_error.dart';
import '../network/paged_result.dart';
import '../storage/token_store.dart';

/// Token giả luôn "đã đăng nhập" để vào thẳng app khi xem trước giao diện.
class PreviewTokenStore extends TokenStore {
  String? _access = 'preview-access';
  String? _refresh = 'preview-refresh';

  @override
  String? get accessToken => _access;
  @override
  String? get refreshToken => _refresh;
  @override
  bool get hasSession => _refresh != null;

  @override
  Future<void> load() async {}

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

Profile _previewProfile() => Profile(
  id: 'u-preview',
  fullName: 'Nguyễn Minh Anh',
  phoneNumber: '+84912345482',
  role: UserRole.user,
  createdAt: DateTime.utc(2026, 9, 1),
);

/// Đăng nhập và đăng ký chấp nhận mọi thông tin.
class PreviewAuthRepository extends AuthRepository {
  PreviewAuthRepository(ApiClient api, TokenStore tokens)
    : _store = tokens,
      super(api, tokens);

  final TokenStore _store;

  Future<AuthSession> _ok() async {
    await _store.save(
      accessToken: 'preview-access',
      refreshToken: 'preview-refresh',
    );
    final exp = DateTime.now().add(const Duration(days: 30)).toIso8601String();
    return AuthSession.fromJson({
      'accessToken': 'preview-access',
      'accessTokenExpiresAt': exp,
      'refreshToken': 'preview-refresh',
      'refreshTokenExpiresAt': exp,
      'user': {
        'id': 'u-preview',
        'phone': '+84912345482',
        'fullName': 'Nguyễn Minh Anh',
        'role': UserRole.user.apiValue,
        'status': 'ACTIVE',
      },
    });
  }

  @override
  Future<int> sendOtp({
    required String phone,
    required OtpPurpose purpose,
  }) async => 300;

  @override
  Future<AuthSession> login({
    required String phone,
    required String password,
  }) => _ok();

  @override
  Future<AuthSession> register({
    required String phone,
    required String otp,
    required String password,
    required String fullName,
    required bool acceptTerms,
  }) => _ok();

  @override
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {}

  @override
  Future<void> logout({bool allDevices = false}) => _store.clear();
}

/// Sổ địa chỉ trong bộ nhớ, giữ các quy tắc mặc định của server: địa chỉ đầu
/// tiên luôn mặc định, đặt mặc định mới thì mặc định cũ tự bỏ cờ, xóa mặc định
/// thì địa chỉ mới nhất còn lại thành mặc định.
class InMemoryAddressRepository extends AddressRepository {
  InMemoryAddressRepository({List<Address>? seed})
    : _items = [...?seed],
      super(ApiClient(Dio()));

  /// Mặc định lên đầu, sau đó mới nhất trước.
  final List<Address> _items;
  int _seq = 0;

  List<Address> _sorted() {
    final list = [..._items.reversed];
    list.sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));
    return list;
  }

  void _setDefault(String id) {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isDefault: _items[i].id == id);
    }
  }

  @override
  Future<List<Address>> list() async => _sorted();

  @override
  Future<Address> create(Address a) async {
    final created = Address(
      id: 'a${_seq++}',
      recipient: a.recipient.trim(),
      phone: a.phone.trim(),
      province: a.province.trim(),
      district: a.district.trim(),
      ward: a.ward.trim(),
      detail: a.detail.trim(),
    );
    _items.add(created);
    if (_items.length == 1 || a.isDefault) _setDefault(created.id);
    return _items.last;
  }

  @override
  Future<Address> update(Address a) async {
    final i = _items.indexWhere((x) => x.id == a.id);
    if (i < 0) {
      throw const ApiError(status: 404, code: ApiErrorCode.addressNotFound);
    }
    _items[i] = a.copyWith(isDefault: _items[i].isDefault);
    if (a.isDefault) _setDefault(a.id);
    return _items[i];
  }

  @override
  Future<void> delete(String id) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i < 0) {
      throw const ApiError(status: 404, code: ApiErrorCode.addressNotFound);
    }
    final wasDefault = _items.removeAt(i).isDefault;
    if (wasDefault && _items.isNotEmpty) _setDefault(_items.last.id);
  }
}

/// Địa chỉ mẫu của chế độ xem trước và test.
const sampleAddress = Address(
  id: 'seed',
  recipient: 'Nguyễn Minh Anh',
  phone: '+84912345482',
  province: 'Hà Nội',
  district: 'Tây Hồ',
  ward: 'Quảng An',
  detail: '18 Ngõ 52 Tô Ngọc Vân',
  isDefault: true,
);

class PreviewProfileRepository extends ProfileRepository {
  PreviewProfileRepository(ApiClient api, TokenStore tokens)
    : super(api, Dio(), tokens);

  Profile _profile = _previewProfile();

  @override
  Future<Profile> getProfile() async => _profile;

  @override
  Future<Profile> updateProfile({required String fullName}) async =>
      _profile = Profile(
        id: _profile.id,
        fullName: fullName.trim(),
        phoneNumber: _profile.phoneNumber,
        avatarUrl: _profile.avatarUrl,
        role: _profile.role,
        createdAt: _profile.createdAt,
      );

  @override
  Future<Profile> changeAvatar({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async => _profile;

  @override
  Future<void> deleteAvatar() async {}

  @override
  Future<int> sendPhoneOtp({required String phone}) async => 300;

  @override
  Future<Profile> changePhone({
    required String phone,
    required String otp,
  }) async => _profile = Profile(
    id: _profile.id,
    fullName: _profile.fullName,
    phoneNumber: phone,
    avatarUrl: _profile.avatarUrl,
    role: _profile.role,
    createdAt: _profile.createdAt,
  );

  @override
  Future<void> deleteAccount({required String password}) async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}
}

class PreviewCategoryRepository extends CategoryRepository {
  PreviewCategoryRepository(ApiClient api) : super(api);

  @override
  Future<List<CategoryNode>> tree() async => [
    for (final n in previewCategoryNames) CategoryNode(id: 'cat-$n', name: n),
  ];
}

/// Thông báo backend để trống; thông báo đơn, ví, đấu giá đến từ kho mô phỏng.
class PreviewNotificationRepository extends NotificationRepository {
  PreviewNotificationRepository(ApiClient api) : super(api);

  @override
  Future<PagedResult<AppNotification>> list({
    bool unreadOnly = false,
    required int page,
    required int pageSize,
  }) async => PagedResult(items: const [], page: page, pageSize: pageSize);

  @override
  Future<int> unreadCount() async => 0;

  NotificationSettings _settings = const NotificationSettings();

  @override
  Future<int> markRead(List<String> ids) async => 0;

  @override
  Future<int> markAllRead() async => 0;

  @override
  Future<NotificationSettings> getSettings() async => _settings;

  @override
  Future<NotificationSettings> updateSettings({
    bool? marketing,
    bool? auctionWatch,
  }) async => _settings = _settings.copyWith(
    marketing: marketing,
    auctionWatch: auctionWatch,
  );
}

/// Ví trong bộ nhớ cho chế độ xem trước và test, theo đúng quy tắc của backend:
/// tiền bị giữ ngay khi tạo yêu cầu rút, `Idempotency-Key` phát lại cùng kết
/// quả, tối đa 3 tài khoản ngân hàng, số tiền nạp/rút có ngưỡng.
class InMemoryWalletRepository extends WalletRepository {
  InMemoryWalletRepository({
    int available = 0,
    this.autoPay = true,
    List<BankAccount>? bankAccounts,
    // ignore: prefer_initializing_formals
  }) : _available = available,
       _banks = [...?bankAccounts],
       super(ApiClient(Dio()));

  static const supportedBanks = [
    Bank(code: 'VCB', name: 'Vietcombank'),
    Bank(code: 'ACB', name: 'ACB'),
    Bank(code: 'TCB', name: 'Techcombank'),
  ];

  /// `true`: lần hỏi trạng thái đầu tiên báo `PAID` (giả lập cổng sandbox).
  final bool autoPay;
  int _available;
  int _held = 0;
  int _seq = 0;
  final List<BankAccount> _banks;
  final List<WalletTransaction> _ledger = [];
  final List<Topup> _topups = [];
  final List<Withdrawal> _withdrawals = [];
  final Map<String, Object> _replay = {};
  final List<String> calls = [];

  void _log(int amount, LedgerType type, String refType, String refId) {
    _ledger.insert(
      0,
      WalletTransaction(
        id: ++_seq,
        type: type,
        amount: amount,
        balanceAfter: _available,
        referenceType: refType,
        referenceId: refId,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<Wallet> wallet() async => Wallet(
    available: _available,
    held: _held,
    total: _available + _held,
    updatedAt: DateTime.now().toUtc(),
  );

  @override
  Future<PagedResult<WalletTransaction>> transactions({
    required int page,
    required int pageSize,
    LedgerType? type,
  }) async {
    final all = [
      for (final t in _ledger)
        if (type == null || t.type == type) t,
    ];
    final from = (page - 1) * pageSize;
    return PagedResult(
      items: all.skip(from).take(pageSize).toList(),
      page: page,
      pageSize: pageSize,
      totalCount: all.length,
    );
  }

  @override
  Future<List<PaymentMethod>> paymentMethods() async => const [
    PaymentMethod(
      provider: 'sandbox',
      displayName: 'Sandbox (chỉ dev)',
      isDefault: true,
    ),
  ];

  @override
  Future<Topup> createTopup({
    required int amount,
    required String idempotencyKey,
    String? provider,
  }) async {
    calls.add('topup:$amount:$idempotencyKey');
    final replay = _replay['t$idempotencyKey'];
    if (replay is Topup) return replay;
    if (amount < 10000 || amount > 50000000) {
      throw const ApiError(
        status: 400,
        code: ApiErrorCode.topupOutOfRange,
        fieldErrors: {'amount': 'out of range'},
      );
    }
    final t = Topup(
      id: 'tp${++_seq}',
      amount: amount,
      status: TopupStatus.pending,
      payUrl: 'https://pay.example/$_seq',
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 30)),
      createdAt: DateTime.now().toUtc(),
    );
    _topups.insert(0, t);
    _replay['t$idempotencyKey'] = t;
    return t;
  }

  Topup _settle(Topup t, TopupStatus status) {
    final done = Topup(
      id: t.id,
      amount: t.amount,
      status: status,
      payUrl: t.payUrl,
      expiresAt: t.expiresAt,
      createdAt: t.createdAt,
      paidAt: status == TopupStatus.paid ? DateTime.now().toUtc() : null,
    );
    _topups[_topups.indexWhere((x) => x.id == t.id)] = done;
    if (status == TopupStatus.paid) {
      _available += t.amount;
      _log(t.amount, LedgerType.topup, 'TOPUP', t.id);
    }
    return done;
  }

  @override
  Future<Topup> topup(String id) async {
    final t = _topups.firstWhere(
      (x) => x.id == id,
      orElse: () =>
          throw const ApiError(status: 404, code: ApiErrorCode.topupNotFound),
    );
    if (autoPay && t.status == TopupStatus.pending) {
      return _settle(t, TopupStatus.paid);
    }
    return t;
  }

  @override
  Future<void> devPayTopup(String id, {required bool success}) async {
    final t = _topups.firstWhere((x) => x.id == id);
    if (t.status == TopupStatus.pending) {
      _settle(t, success ? TopupStatus.paid : TopupStatus.failed);
    }
  }

  @override
  Future<PagedResult<Topup>> topups({
    required int page,
    required int pageSize,
  }) async => PagedResult(
    items: _topups.skip((page - 1) * pageSize).take(pageSize).toList(),
    page: page,
    pageSize: pageSize,
    totalCount: _topups.length,
  );

  @override
  Future<Withdrawal> createWithdrawal({
    required int amount,
    required String bankAccountId,
    required String idempotencyKey,
  }) async {
    calls.add('withdraw:$amount:$bankAccountId:$idempotencyKey');
    final replay = _replay['w$idempotencyKey'];
    if (replay is Withdrawal) return replay;
    final bank = _banks.firstWhere(
      (b) => b.id == bankAccountId,
      orElse: () => throw const ApiError(
        status: 404,
        code: ApiErrorCode.bankAccountNotFound,
      ),
    );
    if (amount < 50000) {
      throw const ApiError(
        status: 422,
        code: ApiErrorCode.withdrawBelowMinimum,
        fieldErrors: {'min_amount': '50000'},
      );
    }
    if (amount > _available) {
      throw ApiError(
        status: 422,
        code: ApiErrorCode.insufficientBalance,
        fieldErrors: {'required': '$amount', 'available': '$_available'},
      );
    }
    _available -= amount;
    _held += amount;
    final w = Withdrawal(
      id: 'wd${++_seq}',
      amount: amount,
      status: WithdrawalStatus.requested,
      bankName: bank.bankName,
      accountNumberMasked: bank.accountNumberMasked,
      accountHolder: bank.holder,
      createdAt: DateTime.now().toUtc(),
    );
    _withdrawals.insert(0, w);
    _log(-amount, LedgerType.hold, 'WITHDRAWAL', w.id);
    _replay['w$idempotencyKey'] = w;
    return w;
  }

  @override
  Future<PagedResult<Withdrawal>> withdrawals({
    required int page,
    required int pageSize,
  }) async => PagedResult(
    items: _withdrawals.skip((page - 1) * pageSize).take(pageSize).toList(),
    page: page,
    pageSize: pageSize,
    totalCount: _withdrawals.length,
  );

  @override
  Future<List<Bank>> banks() async => supportedBanks;

  @override
  Future<List<BankAccount>> bankAccounts() async => [..._banks];

  @override
  Future<BankAccount> addBankAccount({
    required String bankCode,
    required String accountNumber,
    required String accountHolder,
  }) async {
    if (_banks.length >= maxBankAccounts) {
      throw const ApiError(status: 422, code: ApiErrorCode.bankAccountLimit);
    }
    if (_banks.any(
      (b) =>
          b.bankCode == bankCode &&
          b.last4 == accountNumber.substring(accountNumber.length - 4),
    )) {
      throw const ApiError(
        status: 409,
        code: ApiErrorCode.bankAccountDuplicate,
      );
    }
    final bank = supportedBanks.firstWhere((b) => b.code == bankCode);
    final account = BankAccount(
      id: 'ba${++_seq}',
      bankCode: bankCode,
      bankName: bank.name,
      accountNumberMasked:
          '****${accountNumber.substring(accountNumber.length - 4)}',
      holder: accountHolder.toUpperCase(),
    );
    _banks.add(account);
    return account;
  }

  @override
  Future<void> deleteBankAccount(String id) async {
    final i = _banks.indexWhere((b) => b.id == id);
    if (i < 0) {
      throw const ApiError(status: 404, code: ApiErrorCode.bankAccountNotFound);
    }
    _banks.removeAt(i);
  }
}

/// Ví mẫu của chế độ xem trước: có sẵn số dư và một tài khoản ngân hàng.
InMemoryWalletRepository previewWalletRepository() => InMemoryWalletRepository(
  available: 1250000,
  bankAccounts: const [
    BankAccount(
      id: 'ba0',
      bankCode: 'VCB',
      bankName: 'Vietcombank',
      accountNumberMasked: '****4821',
      holder: 'NGUYEN MINH ANH',
    ),
  ],
);

/// Cấu hình công khai mẫu (giá trị mặc định hiện hành của backend).
const sampleConfig = PublicConfig({
  'fee.sale.rate': 0.05,
  'fee.auction.commissionRate': 0.1,
  'fee.auction.participation.rate': 0.02,
  'fee.auction.participation.min': 10000,
  'fee.auction.participation.max': 100000,
  'auction.deposit.rate': 0.1,
  'auction.step.minRate': 0.01,
  'auction.step.maxRate': 0.1,
  'auction.step.minAmount': 5000,
  'auction.buyNow.minMultiplier': 1.5,
  'listing.photos.min': 4,
  'shipping.sale.flatFee': 30000,
  'shipping.auction.flatFee': 30000,
  'wallet.topup.minAmount': 10000,
  'wallet.topup.maxAmount': 50000000,
  'wallet.withdraw.minAmount': 50000,
});

/// Cấu hình cố định, không gọi mạng.
class FixedConfigRepository extends ConfigRepository {
  FixedConfigRepository(SharedPreferences prefs, [PublicConfig? config])
    : _config = config ?? sampleConfig,
      super(ApiClient(Dio()), prefs);

  final PublicConfig _config;

  @override
  PublicConfig? cached() => _config;

  @override
  Future<PublicConfig?> fetch() async => null;
}

/// Các provider thay bằng dữ liệu mẫu khi [Env.uiPreview] bật.
List<Override> previewOverrides(TokenStore tokens, SharedPreferences prefs) {
  final api = ApiClient(Dio());
  return [
    // tokenStoreProvider do main.dart đã override; không override lại ở đây.
    configRepositoryProvider.overrideWithValue(FixedConfigRepository(prefs)),
    walletRepositoryProvider.overrideWithValue(previewWalletRepository()),
    addressRepositoryProvider.overrideWithValue(
      InMemoryAddressRepository(seed: const [sampleAddress]),
    ),
    authRepositoryProvider.overrideWithValue(
      PreviewAuthRepository(api, tokens),
    ),
    profileRepositoryProvider.overrideWithValue(
      PreviewProfileRepository(api, tokens),
    ),
    listingRepositoryProvider.overrideWithValue(
      InMemoryListingRepository.preview(),
    ),
    categoryRepositoryProvider.overrideWithValue(
      PreviewCategoryRepository(api),
    ),
    notificationRepositoryProvider.overrideWithValue(
      PreviewNotificationRepository(api),
    ),
  ];
}
