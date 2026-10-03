import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Một trang kết quả phân trang theo cursor (`meta.nextCursor`).
class CursorPage<T> {
  const CursorPage({
    required this.items,
    required this.hasNext,
    this.nextCursor,
  });

  factory CursorPage.fromJson(
    dynamic data,
    Map<dynamic, dynamic> meta,
    T Function(dynamic json) parse,
  ) => CursorPage(
    items: [for (final j in (data as List)) parse(j)],
    hasNext: meta['hasNext'] == true,
    nextCursor: meta['nextCursor'] as String?,
  );

  final List<T> items;
  final bool hasNext;
  final String? nextCursor;
}

/// Trạng thái danh sách cuộn vô hạn theo cursor.
class CursorState<T> {
  const CursorState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = true,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<T> items;
  final String? nextCursor;
  final bool hasMore;
  final bool loadingMore;
  final bool loadMoreFailed;

  CursorState<T> copyWith({
    List<T>? items,
    String? nextCursor,
    bool? hasMore,
    bool? loadingMore,
    bool? loadMoreFailed,
  }) => CursorState(
    items: items ?? this.items,
    nextCursor: nextCursor ?? this.nextCursor,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
  );
}

/// Notifier phân trang theo cursor. Cursor gắn với bộ lọc và kiểu sắp xếp: đổi
/// bộ lọc phải dựng notifier mới (family) để bắt đầu lại từ trang đầu. Cursor là
/// chuỗi mờ, không phân tích. Lớp con chỉ cài [fetch].
abstract class CursorNotifier<T> extends AsyncNotifier<CursorState<T>> {
  static const pageSize = 20;

  Future<CursorPage<T>> fetch(String? cursor);

  @override
  Future<CursorState<T>> build() async {
    final page = await fetch(null);
    return CursorState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasNext,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        current.loadingMore ||
        !current.hasMore ||
        current.nextCursor == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(loadingMore: true, loadMoreFailed: false),
    );
    try {
      final page = await fetch(current.nextCursor);
      state = AsyncData(
        CursorState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasNext,
        ),
      );
    } catch (_) {
      state = AsyncData(
        current.copyWith(loadingMore: false, loadMoreFailed: true),
      );
    }
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}
