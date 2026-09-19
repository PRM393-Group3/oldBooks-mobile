import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'token_store.dart';

/// Được ghi đè trong `main()` sau khi đã `load()` token từ secure storage.
final tokenStoreProvider = Provider<TokenStore>(
  (ref) => throw UnimplementedError('tokenStoreProvider chưa được override'),
);

/// Được ghi đè trong `main()` sau khi khởi tạo SharedPreferences.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider chưa được override'),
);
