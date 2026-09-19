import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../paging/paged_notifier.dart';
import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';
import 'app_state_views.dart';

/// Danh sách tải theo lô: cuộn gần cuối thì tải thêm, kéo để làm mới, có trạng
/// thái đang tải, lỗi, trống và nút thử lại khi tải thêm thất bại.
class AppPagedList<T> extends StatelessWidget {
  const AppPagedList({
    super.key,
    required this.value,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    required this.empty,
    this.header,
    this.padding = AppSpacing.screenPadding,
    this.separator = const SizedBox(height: AppSpacing.sm),
  });

  final AsyncValue<PagedState<T>> value;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  /// Hiện khi danh sách rỗng.
  final Widget empty;

  /// Cuộn cùng danh sách, nằm trên các mục.
  final Widget? header;
  final EdgeInsetsGeometry padding;
  final Widget separator;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: true,
      loading: () => const AppLoadingView(),
      error: (e, _) => AppErrorView(error: e, onRetry: onRefresh),
      data: (state) => RefreshIndicator(
        onRefresh: onRefresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 300) onLoadMore();
            return false;
          },
          child: _list(context, state),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, PagedState<T> state) {
    final l = context.l10n;
    final count = state.items.length;
    final hasFooter = state.loadingMore || state.loadMoreFailed;
    final headerCount = header == null ? 0 : 1;
    final emptyCount = count == 0 ? 1 : 0;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount:
          headerCount + (count == 0 ? emptyCount : count) + (hasFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header!;
        final i = index - headerCount;
        if (count == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxl),
            child: empty,
          );
        }
        if (i >= count) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: state.loadMoreFailed
                  ? TextButton(
                      onPressed: onLoadMore,
                      child: Text(l.loadMoreFailed),
                    )
                  : const CircularProgressIndicator(),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : AppSpacing.sm),
          child: itemBuilder(context, state.items[i]),
        );
      },
    );
  }
}
