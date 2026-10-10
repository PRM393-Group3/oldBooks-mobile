import '../../../core/util/json_read.dart';

/// `GET /wallet`. Tiền là số nguyên đồng VND.
class Wallet {
  const Wallet({
    required this.available,
    required this.held,
    required this.total,
    this.updatedAt,
  });

  factory Wallet.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    final available = readInt(j, 'available') ?? 0;
    final held = readInt(j, 'held') ?? 0;
    return Wallet(
      available: available,
      held: held,
      total: readInt(j, 'total') ?? available + held,
      updatedAt: readDate(j, 'updatedAt'),
    );
  }

  /// Tiêu được, rút được.
  final int available;

  /// Đang bị khóa cho giao dịch chưa xong (chờ duyệt rút, đơn, cọc...).
  final int held;
  final int total;
  final DateTime? updatedAt;
}

/// Loại dòng sao kê. Mã lạ rơi vào [unknown], không crash.
enum LedgerType {
  topup('TOPUP'),
  withdraw('WITHDRAW'),
  hold('HOLD'),
  release('RELEASE'),
  capture('CAPTURE'),
  payout('PAYOUT'),
  fee('FEE'),
  refund('REFUND'),
  compensation('COMPENSATION'),
  unknown('');

  const LedgerType(this.api);
  final String api;

  static LedgerType fromApi(String? v) => values.firstWhere(
    (t) => t.api == v && t != unknown,
    orElse: () => unknown,
  );

  /// Bộ lọc hiển thị trong sao kê (các loại bút toán nội bộ không có).
  static const filters = [topup, hold, release, payout, refund, compensation];
}

/// Một dòng sao kê của số dư KHẢ DỤNG.
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.referenceType,
    this.referenceId,
    this.createdAt,
  });

  factory WalletTransaction.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return WalletTransaction(
      id: readInt(j, 'id') ?? 0,
      type: LedgerType.fromApi(readString(j, 'type')),
      amount: readInt(j, 'amount') ?? 0,
      balanceAfter: readInt(j, 'balanceAfter') ?? 0,
      referenceType: readString(j, 'referenceType'),
      referenceId: readString(j, 'referenceId'),
      createdAt: readDate(j, 'createdAt'),
    );
  }

  final int id;
  final LedgerType type;

  /// Có dấu: dương là tiền vào số dư khả dụng, âm là tiền ra.
  final int amount;
  final int balanceAfter;

  /// `TOPUP`, `WITHDRAWAL`, và các loại ở giai đoạn sau. An toàn với giá trị lạ.
  final String? referenceType;
  final String? referenceId;
  final DateTime? createdAt;
}

enum TopupStatus {
  pending('PENDING'),
  paid('PAID'),
  expired('EXPIRED'),
  failed('FAILED'),
  unknown('');

  const TopupStatus(this.api);
  final String api;

  static TopupStatus fromApi(String? v) => values.firstWhere(
    (t) => t.api == v && t != unknown,
    orElse: () => unknown,
  );
}

class Topup {
  const Topup({
    required this.id,
    required this.amount,
    required this.status,
    this.payUrl,
    this.expiresAt,
    this.createdAt,
    this.paidAt,
  });

  factory Topup.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return Topup(
      id: readString(j, 'id') ?? '',
      amount: readInt(j, 'amount') ?? 0,
      status: TopupStatus.fromApi(readString(j, 'status')),
      payUrl: readString(j, 'payUrl'),
      expiresAt: readDate(j, 'expiresAt'),
      createdAt: readDate(j, 'createdAt'),
      paidAt: readDate(j, 'paidAt'),
    );
  }

  final String id;
  final int amount;
  final TopupStatus status;
  final String? payUrl;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? paidAt;
}

enum WithdrawalStatus {
  requested('REQUESTED'),
  approved('APPROVED'),
  submitted('SUBMITTED'),
  paid('PAID'),
  rejected('REJECTED'),
  failed('FAILED'),
  unknown('');

  const WithdrawalStatus(this.api);
  final String api;

  static WithdrawalStatus fromApi(String? v) => values.firstWhere(
    (t) => t.api == v && t != unknown,
    orElse: () => unknown,
  );

  /// Trạng thái cuối, không còn đổi.
  bool get isFinal => this == paid || this == rejected || this == failed;

  /// Tiền đã được trả về ví.
  bool get isRefunded => this == rejected || this == failed;
}

class Withdrawal {
  const Withdrawal({
    required this.id,
    required this.amount,
    required this.status,
    this.bankName = '',
    this.accountNumberMasked = '',
    this.accountHolder = '',
    this.rejectReason,
    this.failureReason,
    this.createdAt,
    this.reviewedAt,
    this.paidAt,
  });

  factory Withdrawal.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return Withdrawal(
      id: readString(j, 'id') ?? '',
      amount: readInt(j, 'amount') ?? 0,
      status: WithdrawalStatus.fromApi(readString(j, 'status')),
      bankName: readString(j, 'bankName') ?? '',
      accountNumberMasked: readString(j, 'accountNumberMasked') ?? '',
      accountHolder: readString(j, 'accountHolder') ?? '',
      rejectReason: readString(j, 'rejectReason'),
      failureReason: readString(j, 'failureReason'),
      createdAt: readDate(j, 'createdAt'),
      reviewedAt: readDate(j, 'reviewedAt'),
      paidAt: readDate(j, 'paidAt'),
    );
  }

  final String id;
  final int amount;
  final WithdrawalStatus status;
  final String bankName;
  final String accountNumberMasked;
  final String accountHolder;
  final String? rejectReason;
  final String? failureReason;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final DateTime? paidAt;
}

/// Ngân hàng hỗ trợ (`GET /wallet/banks`).
class Bank {
  const Bank({required this.code, required this.name});

  factory Bank.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return Bank(
      code: readString(j, 'code') ?? '',
      name: readString(j, 'name') ?? '',
    );
  }

  final String code;
  final String name;
}

/// Cổng thanh toán đang bật (`GET /wallet/payment-methods`). Đừng viết cứng danh
/// sách cổng ở client: admin bật/tắt được.
class PaymentMethod {
  const PaymentMethod({
    required this.provider,
    required this.displayName,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return PaymentMethod(
      provider: readString(j, 'provider') ?? '',
      displayName:
          readString(j, 'displayName') ?? readString(j, 'provider') ?? '',
      isDefault: readBool(j, 'isDefault') ?? false,
    );
  }

  /// Khóa gửi lên khi tạo yêu cầu nạp.
  final String provider;
  final String displayName;
  final bool isDefault;
}

/// Tối đa 3 tài khoản mỗi người.
const maxBankAccounts = 3;

/// `BankAccountDto`. Số tài khoản được mã hóa ở server, API chỉ trả dạng che
/// (`****6789`).
class BankAccount {
  const BankAccount({
    required this.id,
    required this.bankCode,
    required this.bankName,
    required this.accountNumberMasked,
    required this.holder,
  });

  factory BankAccount.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return BankAccount(
      id: readString(j, 'id') ?? '',
      bankCode: readString(j, 'bankCode') ?? '',
      bankName: readString(j, 'bankName') ?? '',
      accountNumberMasked: readString(j, 'accountNumberMasked') ?? '',
      holder: readString(j, 'accountHolder') ?? '',
    );
  }

  final String id;
  final String bankCode;
  final String bankName;
  final String accountNumberMasked;

  /// Server chuẩn hóa thành chữ hoa không dấu: hiển thị đúng giá trị này.
  final String holder;

  /// 4 chữ số cuối để hiển thị `**** 6789`.
  String get last4 => accountNumberMasked.replaceAll(RegExp(r'[^0-9]'), '');
}
