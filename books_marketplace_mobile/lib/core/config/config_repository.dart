import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import 'public_config.dart';

/// Tải và lưu cấu hình công khai. Dùng `ETag`: `304` thì giữ bản đã lưu, bản
/// cuối cùng cũng là dự phòng khi mất mạng.
class ConfigRepository {
  ConfigRepository(this._api, this._prefs);

  static const _bodyKey = 'public_config_body';
  static const _etagKey = 'public_config_etag';

  final ApiClient _api;
  final SharedPreferences _prefs;

  /// Bản đã lưu lần trước, hoặc `null` nếu chưa có / hỏng.
  PublicConfig? cached() {
    final raw = _prefs.getString(_bodyKey);
    if (raw == null) return null;
    try {
      return PublicConfig.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  /// Trả cấu hình hiện hành; `null` nghĩa là server báo không đổi (`304`).
  Future<PublicConfig?> fetch() async {
    final result = await _api.getConditional<PublicConfig>(
      '/config/public',
      etag: cached() == null ? null : _prefs.getString(_etagKey),
      parse: PublicConfig.fromJson,
    );
    if (result.notModified) return null;
    final config = result.data!;
    await _prefs.setString(_bodyKey, jsonEncode(config.toJson()));
    final etag = result.etag;
    if (etag != null) {
      await _prefs.setString(_etagKey, etag);
    } else {
      await _prefs.remove(_etagKey);
    }
    return config;
  }
}
