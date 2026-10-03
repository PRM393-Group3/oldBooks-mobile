import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_providers.dart';
import '../storage/storage_providers.dart';
import 'config_repository.dart';
import 'public_config.dart';

final configRepositoryProvider = Provider<ConfigRepository>(
  (ref) => ConfigRepository(
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);

/// Cấu hình công khai hiện hành. Hiện ngay bản đã lưu (nếu có) rồi làm mới nền;
/// lỗi mạng giữ bản cũ. Không có gì cả thì rỗng và UI dùng mặc định an toàn.
class PublicConfigNotifier extends Notifier<PublicConfig> {
  /// Cache của server là 60 giây, hỏi lại sớm hơn là vô ích.
  static const minRefreshGap = Duration(seconds: 60);

  DateTime? _lastFetch;
  bool _fetching = false;

  @override
  PublicConfig build() {
    final cached = ref.read(configRepositoryProvider).cached();
    Future.microtask(refresh);
    return cached ?? const PublicConfig();
  }

  /// Gọi khi khởi động và khi quay lại foreground. [force] bỏ qua khoảng chờ.
  Future<void> refresh({bool force = false}) async {
    final last = _lastFetch;
    if (_fetching ||
        (!force &&
            last != null &&
            DateTime.now().difference(last) < minRefreshGap)) {
      return;
    }
    _fetching = true;
    try {
      final fresh = await ref.read(configRepositoryProvider).fetch();
      _lastFetch = DateTime.now();
      if (fresh != null) state = fresh;
    } catch (_) {
      // Mất mạng hoặc server bảo trì: giữ bản đang có.
    } finally {
      _fetching = false;
    }
  }
}

final publicConfigProvider =
    NotifierProvider<PublicConfigNotifier, PublicConfig>(
      PublicConfigNotifier.new,
    );
