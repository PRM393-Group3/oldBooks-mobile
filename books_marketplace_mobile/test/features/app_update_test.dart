import 'package:books_marketplace_mobile/features/app_update/domain/app_release.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compareVersions so từng phần số, bỏ build và hậu tố', () {
    expect(compareVersions('1.2.0', '1.1.2') > 0, isTrue);
    expect(compareVersions('1.1.2', '1.2.0') < 0, isTrue);
    expect(compareVersions('1.10.0', '1.9.9') > 0, isTrue);
    expect(compareVersions('1.2', '1.2.0'), 0);
    expect(compareVersions('1.2.0+5', '1.2.0'), 0);
    expect(compareVersions('1.2.0-beta', '1.2.0'), 0);
  });

  group('AppRelease.fromGithubJson', () {
    Map<String, dynamic> json(List<Map<String, dynamic>> assets) => {
      'tag_name': 'v1.2.0',
      'body': 'notes',
      'assets': assets,
    };

    test('lấy APK, sha256 và bỏ tiền tố v', () {
      final r = AppRelease.fromGithubJson(
        json([
          {
            'name': 'oldbook-1.2.0.apk',
            'browser_download_url': 'https://x/a.apk',
            'size': 100,
          },
          {
            'name': 'oldbook-1.2.0.apk.sha256',
            'browser_download_url': 'https://x/a.apk.sha256',
            'size': 84,
          },
        ]),
      )!;
      expect(r.version, '1.2.0');
      expect(r.apkUrl, 'https://x/a.apk');
      expect(r.apkSize, 100);
      expect(r.sha256Url, 'https://x/a.apk.sha256');
      expect(r.notes, 'notes');
    });

    test('release không có APK thì trả null', () {
      expect(AppRelease.fromGithubJson(json([])), isNull);
      expect(AppRelease.fromGithubJson({'assets': []}), isNull);
    });
  });
}
