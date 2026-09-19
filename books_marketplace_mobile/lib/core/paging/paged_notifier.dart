import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/paged_result.dart';

/// Trạng thái danh sách tải theo lô.
class PagedState<T> {
  const PagedState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final bool loadMoreFailed;

  PagedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    bool? loadMoreFailed,
  }) => PagedState(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
  );
}

/// Notifier danh sách phân trang dùng chung. Lớp con chỉ cài [fetchPage].
abstract class PagedNotifier<T> extends AsyncNotifier<PagedState<T>> {
  /// 20 mục mỗi lô theo FR-HOME-06.
  static const pageSize = 20;

  Future<PagedResult<T>> fetchPage(int page);

  @override
  Future<PagedState<T>> build() async {
    final result = await fetchPage(1);
    return PagedState(items: result.items, page: 1, hasMore: result.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(
      current.copyWith(loadingMore: true, loadMoreFailed: false),
    );
    try {
      final result = await fetchPage(current.page + 1);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...result.items],
          page: current.page + 1,
          hasMore: result.hasMore,
          loadingMore: false,
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
