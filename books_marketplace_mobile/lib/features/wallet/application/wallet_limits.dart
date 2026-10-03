import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/config_providers.dart';
import '../../../core/config/public_config.dart';

/// Giới hạn nạp/rút lấy từ `GET /config/public` để báo sớm ở client. Server vẫn
/// là nơi quyết định; thiếu khóa thì dùng mặc định của backend.
class WalletLimits {
  const WalletLimits({
    this.topupMin = 10000,
    this.topupMax = 50000000,
    this.withdrawMin = 50000,
  });

  factory WalletLimits.fromConfig(PublicConfig c) {
    const d = WalletLimits();
    return WalletLimits(
      topupMin: c.intOf(PublicConfig.topupMin) ?? d.topupMin,
      topupMax: c.intOf(PublicConfig.topupMax) ?? d.topupMax,
      withdrawMin: c.intOf(PublicConfig.withdrawMin) ?? d.withdrawMin,
    );
  }

  final int topupMin;
  final int topupMax;
  final int withdrawMin;
}

final walletLimitsProvider = Provider<WalletLimits>(
  (ref) => WalletLimits.fromConfig(ref.watch(publicConfigProvider)),
);
