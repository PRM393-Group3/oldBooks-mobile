import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/network/network_providers.dart';
import '../domain/app_release.dart';

/// Repo GitHub chứa bản phát hành APK (công khai).
const _releasesLatestUrl =
    'https://api.github.com/repos/PRM393-Group3/oldBooks-mobile/releases/latest';

/// Kết quả kiểm tra cập nhật.
class UpdateCheck {
  const UpdateCheck({required this.currentVersion, this.release});

  final String currentVersion;

  /// Có giá trị khi bản trên GitHub mới hơn bản đang cài.
  final AppRelease? release;

  bool get hasUpdate => release != null;
}

class UpdateException implements Exception {
  const UpdateException(this.kind);

  final UpdateFailure kind;
}

enum UpdateFailure { network, checksum, install }

/// Kiểm tra, tải và mở trình cài đặt APK từ GitHub Releases.
class AppUpdateService {
  AppUpdateService(this._dio);

  final Dio _dio;

  Future<UpdateCheck> check() async {
    final info = await PackageInfo.fromPlatform();
    final Response<dynamic> res;
    try {
      res = await _dio.get<dynamic>(
        _releasesLatestUrl,
        options: Options(headers: {'Accept': 'application/vnd.github+json'}),
      );
    } on DioException {
      throw const UpdateException(UpdateFailure.network);
    }
    final data = res.data;
    final release = data is Map<String, dynamic>
        ? AppRelease.fromGithubJson(data)
        : null;
    final newer =
        release != null && compareVersions(release.version, info.version) > 0;
    return UpdateCheck(
      currentVersion: info.version,
      release: newer ? release : null,
    );
  }

  /// Tải APK, kiểm `sha256` (nếu có) rồi mở trình cài đặt của hệ điều hành.
  Future<void> downloadAndInstall(
    AppRelease release, {
    required void Function(double progress) onProgress,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/oldbook-${release.version}.apk');
    try {
      await _dio.download(
        release.apkUrl,
        file.path,
        onReceiveProgress: (received, total) {
          final size = total > 0 ? total : release.apkSize;
          if (size > 0) onProgress((received / size).clamp(0, 1).toDouble());
        },
        options: Options(receiveTimeout: const Duration(minutes: 10)),
      );
      if (release.sha256Url != null) {
        final expected = await _expectedSha(release.sha256Url!);
        final actual = (await sha256.bind(file.openRead()).first).toString();
        if (expected != null && expected != actual) {
          await file.delete();
          throw const UpdateException(UpdateFailure.checksum);
        }
      }
    } on DioException {
      throw const UpdateException(UpdateFailure.network);
    }
    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );
    if (result.type != ResultType.done) {
      throw const UpdateException(UpdateFailure.install);
    }
  }

  /// File `.sha256` có dạng `<hash>  <tên file>`.
  Future<String?> _expectedSha(String url) async {
    final res = await _dio.get<String>(url);
    final text = res.data?.trim();
    if (text == null || text.isEmpty) return null;
    return text.split(RegExp(r'\s+')).first.toLowerCase();
  }
}

final appUpdateServiceProvider = Provider<AppUpdateService>(
  (ref) => AppUpdateService(ref.watch(plainDioProvider)),
);
