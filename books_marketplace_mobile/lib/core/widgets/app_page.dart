import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Khung màn hình chuẩn: AppBar tùy chọn, nội dung cuộn, thanh hành động dính đáy.
///
/// [bottom] nằm trong thân màn hình nên tự nâng lên khi bàn phím mở và luôn ở
/// nửa dưới màn hình (thao tác một tay). Nội dung được giới hạn bề rộng để
/// form không bị kéo giãn trên màn hình lớn.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    this.title,
    required this.child,
    this.bottom,
    this.actions,
    this.floatingActionButton,
    this.onRefresh,
    this.scrollable = true,
    this.padding = AppSpacing.screenPadding,
  });

  final String? title;
  final Widget child;

  /// Thanh hành động dính đáy, thường chứa nút chính.
  final Widget? bottom;
  final List<Widget>? actions;

  /// Nút nổi, nằm nửa dưới màn hình.
  final Widget? floatingActionButton;

  /// Có giá trị thì bọc [RefreshIndicator] (kéo để tải lại).
  final Future<void> Function()? onRefresh;
  final bool scrollable;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    Widget body = child;

    if (scrollable) {
      body = SingleChildScrollView(
        padding: padding,
        physics: onRefresh != null
            ? const AlwaysScrollableScrollPhysics()
            : null,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
            child: child,
          ),
        ),
      );
      if (onRefresh != null) {
        body = RefreshIndicator(onRefresh: onRefresh!, child: body);
      }
    }

    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: title == null && actions == null
          ? null
          : AppBar(
              title: title == null ? null : Text(title!),
              actions: actions,
            ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.formMaxWidth,
                    ),
                    child: bottom,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
