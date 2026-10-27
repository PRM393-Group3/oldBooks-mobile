/// Bản phát hành mới nhất trên GitHub Releases.
class AppRelease {
  const AppRelease({
    required this.version,
    required this.apkUrl,
    required this.apkSize,
    this.sha256Url,
    this.notes = '',
  });

  /// Số phiên bản đã bỏ tiền tố `v` (ví dụ `1.2.0`).
  final String version;
  final String apkUrl;
  final int apkSize;

  /// URL file `.sha256` đi kèm; không có thì bỏ qua bước kiểm tra toàn vẹn.
  final String? sha256Url;
  final String notes;

  /// Đọc JSON của `GET /repos/{owner}/{repo}/releases/latest`.
  /// Trả `null` khi release không có file APK.
  static AppRelease? fromGithubJson(Map<String, dynamic> json) {
    final tag = json['tag_name'];
    if (tag is! String || tag.isEmpty) return null;
    final assets = json['assets'];
    if (assets is! List) return null;
    Map<String, dynamic>? apk;
    String? sha;
    for (final a in assets) {
      if (a is! Map<String, dynamic>) continue;
      final name = a['name'];
      final url = a['browser_download_url'];
      if (name is! String || url is! String) continue;
      if (name.endsWith('.apk')) apk = a;
      if (name.endsWith('.apk.sha256')) sha = url;
    }
    if (apk == null) return null;
    final size = apk['size'];
    return AppRelease(
      version: tag.startsWith('v') ? tag.substring(1) : tag,
      apkUrl: apk['browser_download_url'] as String,
      apkSize: size is int ? size : 0,
      sha256Url: sha,
      notes: json['body'] is String ? json['body'] as String : '',
    );
  }
}

/// So sánh hai số phiên bản dạng `x.y.z` (bỏ phần `+build` và hậu tố sau `-`).
/// Trả số âm nếu [a] < [b], 0 nếu bằng, số dương nếu [a] > [b].
int compareVersions(String a, String b) {
  List<int> parse(String v) => v
      .split('+')
      .first
      .split('-')
      .first
      .split('.')
      .map((p) => int.tryParse(p) ?? 0)
      .toList();
  final pa = parse(a);
  final pb = parse(b);
  final n = pa.length > pb.length ? pa.length : pb.length;
  for (var i = 0; i < n; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x - y;
  }
  return 0;
}
