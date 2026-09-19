import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/storage/storage_providers.dart';
import 'core/storage/token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nạp trước để router biết ngay đã đăng nhập hay chưa, không cần màn chờ.
  final tokenStore = TokenStore();
  await tokenStore.load();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Riverpod 3 tự thử lại provider lỗi; tắt để lỗi mạng hiện ngay và
      // người dùng chủ động bấm "Thử lại", tránh lặp request ngầm.
      retry: (_, _) => null,
      overrides: [
        tokenStoreProvider.overrideWithValue(tokenStore),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
}
