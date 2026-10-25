import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../data/app_update_service.dart';

/// Kiểm tra bản mới trên GitHub; nếu có thì cho tải và cài ngay trong app.
Future<void> showUpdateSheet(BuildContext context) {
  return showAppSheet<void>(context, builder: (_) => const _UpdateSheet());
}

class _UpdateSheet extends ConsumerStatefulWidget {
  const _UpdateSheet();

  @override
  ConsumerState<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends ConsumerState<_UpdateSheet> {
  late Future<UpdateCheck> _check;
  double? _progress;
  UpdateFailure? _failure;

  @override
  void initState() {
    super.initState();
    _check = ref.read(appUpdateServiceProvider).check();
  }

  Future<void> _install(UpdateCheck check) async {
    setState(() {
      _progress = 0;
      _failure = null;
    });
    try {
      await ref
          .read(appUpdateServiceProvider)
          .downloadAndInstall(
            check.release!,
            onProgress: (p) {
              if (mounted) setState(() => _progress = p);
            },
          );
      if (mounted) setState(() => _progress = null);
    } on UpdateException catch (e) {
      if (mounted) {
        setState(() {
          _progress = null;
          _failure = e.kind;
        });
      }
    }
  }

  void _retry() => setState(() {
    _failure = null;
    _check = ref.read(appUpdateServiceProvider).check();
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return FutureBuilder<UpdateCheck>(
      future: _check,
      builder: (context, snap) {
        final children = <Widget>[AppSheetTitle(l.updateTitle)];
        const gap = SizedBox(height: AppSpacing.md);
        if (snap.connectionState != ConnectionState.done) {
          children.addAll([
            gap,
            const Center(child: CircularProgressIndicator()),
            gap,
            Text(l.updateChecking, textAlign: TextAlign.center),
          ]);
        } else if (snap.hasError) {
          children.addAll([
            gap,
            Text(l.updateErrNetwork),
            gap,
            AppButton(label: l.retry, onPressed: _retry),
          ]);
        } else if (!Platform.isAndroid) {
          children.addAll([gap, Text(l.updateAndroidOnly)]);
        } else {
          final check = snap.requireData;
          if (!check.hasUpdate) {
            children.addAll([
              gap,
              Text(l.updateUpToDate(check.currentVersion)),
              gap,
              AppButton(
                label: l.close,
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]);
          } else {
            final r = check.release!;
            children.addAll([
              gap,
              Text(l.updateAvailable(r.version, check.currentVersion)),
              if (r.apkSize > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l.updateSize((r.apkSize / (1024 * 1024)).toStringAsFixed(1)),
                  style: context.text.bodySmall,
                ),
              ],
              if (_failure != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(switch (_failure!) {
                  UpdateFailure.network => l.updateErrNetwork,
                  UpdateFailure.checksum => l.updateErrChecksum,
                  UpdateFailure.install => l.updateErrInstall,
                }, style: TextStyle(color: context.colors.error)),
              ],
              gap,
              if (_progress != null) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l.updateDownloading((_progress! * 100).round()),
                  textAlign: TextAlign.center,
                ),
              ] else
                AppButton(
                  label: l.updateInstall,
                  icon: Icons.system_update,
                  onPressed: () => _install(check),
                ),
            ]);
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  }
}
