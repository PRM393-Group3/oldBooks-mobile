import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../sell/ai/book_ai_service.dart';
import '../../sell/ai/book_ai_sheet.dart';
import '../../sell/ai/device_compat.dart';
import '../domain/cccd_analysis.dart';
import '../domain/kyc_rules.dart';

/// Mở trợ lý AI đọc mặt trước CCCD. Trả kết quả nếu người dùng chọn "Dùng
/// thông tin này". Ảnh chỉ xử lý trên máy, không gửi đi đâu.
Future<CccdFields?> showCccdAiSheet(BuildContext context, Uint8List photo) {
  return showAppSheet<CccdFields>(
    context,
    isDismissible: false,
    builder: (_) => _CccdAiSheet(photo: photo),
  );
}

enum _Phase {
  checking,
  incompatible,
  needDownload,
  downloading,
  analyzing,
  result,
  error,
}

class _CccdAiSheet extends ConsumerStatefulWidget {
  const _CccdAiSheet({required this.photo});

  final Uint8List photo;

  @override
  ConsumerState<_CccdAiSheet> createState() => _CccdAiSheetState();
}

class _CccdAiSheetState extends ConsumerState<_CccdAiSheet> {
  _Phase _phase = _Phase.checking;
  int _percent = 0;
  String _raw = '';
  CccdFields? _result;
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
      await for (final text in _service.analyzeStream(
        widget.photo,
        prompt: cccdPrompt,
        sensitive: true,
      )) {
        // Rời sheet thì thoát vòng lặp để hủy nghe và giải phóng model.
        if (!mounted) return;
        setState(() => _raw = text);
      }
      if (!mounted) return;
      if (_raw.trim().isEmpty) return _fail(BookAiFailure.empty);
      final result = parseCccd(_raw);
      if (result == null) return _fail(BookAiFailure.unreadable);
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
        _CccdRows(previewCccd(_raw)),
        if (_raw.isEmpty)
          Text(
            l.kycOcrAnalyzing,
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
        Text(l.kycOcrIncompatibleManual),
        if (_device!.issues.length == 1 &&
            _device!.issues.first == DeviceIssue.lowFreeRam) ...[
          gap,
          AppButton(label: l.aiRetry, onPressed: _start),
        ],
      ],
      _Phase.needDownload => [
        Text(l.kycOcrIntro),
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
        _CccdRows(_result!),
        const SizedBox(height: AppSpacing.xs),
        Text(l.kycOcrCheckNote, style: context.text.bodySmall),
        gap,
        AppButton(
          label: l.kycOcrApply,
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
          BookAiFailure.empty => l.kycOcrErrUnreadable,
          BookAiFailure.unreadable => l.kycOcrErrUnreadable,
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
        AppSheetTitle(l.kycOcrTitle),
        gap,
        ...body,
        if (!busy) ...[
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: l.kycOcrEnterManually,
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ],
    );
  }
}

/// Các trường đã đọc được, mỗi trường hiện dần khi có giá trị.
class _CccdRows extends StatelessWidget {
  const _CccdRows(this.fields);

  final CccdFields fields;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = <(String, String)>[
      if (fields.fullName != null) (l.kycFieldName, fields.fullName!),
      if (fields.idNumber != null) (l.kycFieldId, fields.idNumber!),
      if (fields.dateOfBirth != null)
        (l.kycFieldDob, formatVnDate(fields.dateOfBirth!)),
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
