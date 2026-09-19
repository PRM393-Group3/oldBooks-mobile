/// Một trang kết quả. Doc chưa nêu rõ phần bao của phân trang nên đọc linh hoạt:
/// mảng trần, hoặc object có `items`/`data`/`results` cùng tổng số nếu có.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    this.totalCount,
  });

  factory PagedResult.fromJson(
    dynamic data,
    T Function(dynamic json) parse, {
    required int page,
    required int pageSize,
  }) {
    List<dynamic> raw = const [];
    int? total;
    if (data is List) {
      raw = data;
    } else if (data is Map) {
      final list = data['items'] ?? data['data'] ?? data['results'];
      if (list is List) raw = list;
      final t =
          data['totalCount'] ??
          data['total'] ??
          data['totalItems'] ??
          data['totalRecords'];
      if (t is num) total = t.toInt();
    }
    return PagedResult(
      items: raw.map(parse).toList(),
      page: page,
      pageSize: pageSize,
      totalCount: total,
    );
  }

  final List<T> items;
  final int page;
  final int pageSize;
  final int? totalCount;

  /// Còn trang sau không. Không biết tổng thì coi trang đầy là còn.
  bool get hasMore => totalCount != null
      ? page * pageSize < totalCount!
      : items.length >= pageSize;
}
