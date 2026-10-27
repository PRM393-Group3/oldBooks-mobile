import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../presentation/sell_text.dart';
import 'book_ai_service.dart';
import 'book_analysis.dart';
import 'device_compat.dart';

final bookAiServiceProvider = Provider<BookAiService>((ref) => BookAiService());

/// Mở trợ lý AI cho [photo]. Trả kết quả nếu người bán chọn "Áp dụng".
Future<BookAnalysis?> showBookAiSheet(BuildContext context, Uint8List photo) {
  return showAppSheet<BookAnalysis>(
    context,
    isDismissible: false,
    builder: (_) => _BookAiSheet(photo: photo),
  );
}

/// Lý do máy không chạy được AI trên máy, bằng chữ cho người dùng.
String deviceIssueText(AppLocalizations l, DeviceIssue issue, DeviceSpecs s) =>
    switch (issue) {
      DeviceIssue.notAndroid => l.aiIssueNotAndroid,
      DeviceIssue.androidTooOld => l.aiIssueAndroidOld(s.sdkInt, minAiSdk),
      DeviceIssue.noArm64 => l.aiIssueNoArm64,
      DeviceIssue.lowRam => l.aiIssueLowRam(
        (s.totalRamMb / 1024).toStringAsFixed(1),
        (minAiTotalRamMb / 1024).toStringAsFixed(1),
      ),
      DeviceIssue.lowFreeRam => l.aiIssueLowFreeRam(s.freeRamMb),
    };

enum _Phase {
  checking,
  incompatible,
  needDownload,
  downloading,
  analyzing,
  result,
  error,
}

class _BookAiSheet extends ConsumerStatefulWidget {
  const _BookAiSheet({required this.photo});

  final Uint8List photo;

  @override
  ConsumerState<_BookAiSheet> createState() => _BookAiSheetState();
}

class _BookAiSheetState extends ConsumerState<_BookAiSheet> {
  _Phase _phase = _Phase.checking;
  int _percent = 0;
  String _raw = '';
  BookAnalysis? _result;
  BookAiFailure? _failure;
  DeviceCheck? _device;

  BookAiService get _service => ref.read(bookAiServiceProvider);

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _fail(BookAiFailure f) {
    if (!mounted) return;
    setState(() {
      _failure = f;
      _phase = _Phase.error;
    });
  }

  Future<void> _start() async {
    setState(() => _phase = _Phase.checking);
    final device = await checkDeviceCompat();
    if (!mounted) return;
    if (!device.compatible) {
      setState(() {
        _device = device;
        _phase = _Phase.incompatible;
      });
      return;
    }
    final ready = await _service.isModelReady().catchError((_) => false);
    if (!mounted) return;
    if (ready) {
      await _analyze();
    } else {
      setState(() => _phase = _Phase.needDownload);
    }
  }

  Future<void> _downloadThenAnalyze() async {
    setState(() {
      _percent = 0;
      _phase = _Phase.downloading;
    });
    try {
      await _service.downloadModel((p) {
        if (mounted) setState(() => _percent = p.clamp(0, 100));
      });
    } on BookAiException catch (e) {
      return _fail(e.failure);
    }
    if (mounted) await _analyze();
  }

  Future<void> _analyze() async {
    setState(() {
      _raw = '';
      _phase = _Phase.analyzing;
    });
    try {
      await for (final text in _service.analyzeStream(widget.photo)) {
        // Rời sheet thì thoát vòng lặp để hủy nghe và giải phóng model.
        if (!mounted) return;
        setState(() => _raw = text);
      }
      if (!mounted) return;
      final result = _service.parseResult(_raw);
      setState(() {
        _result = result;
        _phase = _Phase.result;
      });
    } on BookAiException catch (e) {
      _fail(e.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    const gap = SizedBox(height: AppSpacing.md);
    final busy =
        _phase == _Phase.checking ||
        _phase == _Phase.downloading ||
        _phase == _Phase.analyzing;

    final body = switch (_phase) {
      _Phase.checking => [const Center(child: CircularProgressIndicator())],
      _Phase.analyzing => [
        const Center(child: PulsingAiIcon()),
        gap,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _raw.isEmpty ? l.aiReading : l.aiWriting,
            key: ValueKey(_raw.isEmpty),
            textAlign: TextAlign.center,
            style: context.text.titleSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const LinearProgressIndicator(),
        gap,
        _FieldRows(previewBookAnalysis(_raw)),
        if (_raw.isEmpty)
          Text(
            l.aiAnalyzing,
            textAlign: TextAlign.center,
            style: context.text.bodySmall,
          ),
      ],
      _Phase.incompatible => [
        Text(l.aiIncompatibleIntro),
        const SizedBox(height: AppSpacing.xs),
        for (final issue in _device!.issues)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Text(
              '• ${deviceIssueText(l, issue, _device!.specs)}',
              style: TextStyle(color: context.colors.error),
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Text(l.aiIncompatibleManual),
        if (_device!.issues.length == 1 &&
            _device!.issues.first == DeviceIssue.lowFreeRam) ...[
          gap,
          AppButton(label: l.aiRetry, onPressed: _start),
        ],
      ],
      _Phase.needDownload => [
        Text(l.aiSheetIntro),
        const SizedBox(height: AppSpacing.xs),
        Text(l.aiDownloadNote, style: context.text.bodySmall),
        gap,
        AppButton(
          label: l.aiDownloadButton,
          icon: Icons.download,
          onPressed: _downloadThenAnalyze,
        ),
      ],
      _Phase.downloading => [
        LinearProgressIndicator(value: _percent / 100),
        const SizedBox(height: AppSpacing.xs),
        Text(l.aiDownloading(_percent), textAlign: TextAlign.center),
      ],
      _Phase.result => [
        _FieldRows(
          BookAnalysisPreview(
            title: _result!.title,
            author: _result!.author,
            publisher: _result!.publisher,
            year: _result!.year,
            condition: _result!.condition,
            defects: _result!.defects,
            description: _result!.description,
          ),
        ),
        gap,
        AppButton(
          label: l.aiApply,
          icon: Icons.check,
          onPressed: () => Navigator.of(context).pop(_result),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: l.aiRetry,
          variant: AppButtonVariant.secondary,
          onPressed: _analyze,
        ),
      ],
      _Phase.error => [
        Text(switch (_failure!) {
          BookAiFailure.unsupported => l.aiErrUnsupported,
          BookAiFailure.download => l.aiErrDownload,
          BookAiFailure.model => l.aiErrModel,
          BookAiFailure.empty => l.aiErrEmpty,
          BookAiFailure.unreadable => l.aiErrUnreadable,
        }, style: TextStyle(color: context.colors.error)),
        gap,
        if (_failure != BookAiFailure.unsupported)
          AppButton(
            label: l.aiRetry,
            onPressed: _failure == BookAiFailure.download
                ? _downloadThenAnalyze
                : _analyze,
          ),
      ],
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(l.aiSheetTitle),
        gap,
        ...body,
        if (!busy) ...[
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: l.close,
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ],
    );
  }
}

/// Biểu tượng nhấp nháy để người dùng thấy máy đang làm việc khi chờ token đầu.
class PulsingAiIcon extends StatefulWidget {
  const PulsingAiIcon({super.key});

  @override
  State<PulsingAiIcon> createState() => _PulsingAiIconState();
}

class _PulsingAiIconState extends State<PulsingAiIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_controller),
      child: ScaleTransition(
        scale: Tween(begin: 0.9, end: 1.1).animate(_controller),
        child: Icon(
          Icons.auto_awesome,
          size: 40,
          color: context.colors.primary,
        ),
      ),
    );
  }
}

/// Các trường AI đã đọc được, mỗi trường hiện dần khi có giá trị.
class _FieldRows extends StatelessWidget {
  const _FieldRows(this.preview);

  final BookAnalysisPreview preview;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = <(String, String)>[
      if (preview.title != null) (l.aiFieldTitle, preview.title!),
      if (preview.author != null) (l.aiFieldAuthor, preview.author!),
      if (preview.publisher != null) (l.aiFieldPublisher, preview.publisher!),
      if (preview.year != null) (l.aiFieldYear, '${preview.year}'),
      if (preview.condition != null)
        (l.aiResultCondition, sellConditionLabel(l, preview.condition!)),
      if (preview.defects != null) (l.aiFieldDefects, preview.defects!),
      if (preview.description != null)
        (l.aiResultDescription, preview.description!),
    ];
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (label, value) in rows)
            TweenAnimationBuilder<double>(
              key: ValueKey(label),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (_, t, child) => Opacity(opacity: t, child: child),
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: context.text.labelLarge),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(value),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
