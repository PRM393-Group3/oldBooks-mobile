import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/config_providers.dart';
import '../domain/sell_rules.dart';

/// Quy tắc xem trước khi đăng bán, theo cấu hình công khai hiện hành.
final sellRulesProvider = Provider<SellRules>(
  (ref) => SellRules.fromConfig(ref.watch(publicConfigProvider)),
);
