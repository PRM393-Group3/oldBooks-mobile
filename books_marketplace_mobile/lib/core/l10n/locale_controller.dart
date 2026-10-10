import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_providers.dart';

/// Ngôn ngữ người dùng chọn. `null` nghĩa là theo hệ thống.
class LocaleController extends Notifier<Locale?> {
  static const _key = 'app_locale';
  static const supported = [Locale('vi'), Locale('en')];

  @override
  Locale? build() {
    final code = ref.read(sharedPreferencesProvider).getString(_key);
    return supported.where((l) => l.languageCode == code).firstOrNull;
  }

  Future<void> select(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
