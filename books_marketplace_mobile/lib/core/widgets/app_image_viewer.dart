import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Xem ảnh toàn màn hình, vuốt để chuyển ảnh, hai ngón để phóng to
/// (FR-CAT-03, FR-INS-04).
Future<void> showImageViewer(
  BuildContext context, {
  required List<String> urls,
  required List<String> labels,
  int initialIndex = 0,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) =>
          _ImageViewer(urls: urls, labels: labels, initialIndex: initialIndex),
    ),
  );
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({
    required this.urls,
    required this.labels,
    required this.initialIndex,
  });

  final List<String> urls;
  final List<String> labels;
  final int initialIndex;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_index + 1}/${widget.urls.length} · ${widget.labels[_index]}',
          style: context.text.labelMedium?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          tooltip: context.l10n.close,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Center(
            child: Semantics(
              image: true,
              label: widget.labels[i],
              child: Image.network(
                widget.urls[i],
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.broken_image_outlined,
                  size: AppSizes.avatarLarge,
                  color: colors.textMuted,
                ),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
