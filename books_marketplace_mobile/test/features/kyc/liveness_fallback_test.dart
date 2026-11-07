import 'dart:typed_data';

import 'package:books_marketplace_mobile/core/l10n/app_localizations.dart';
import 'package:books_marketplace_mobile/core/theme/app_theme.dart';
import 'package:books_marketplace_mobile/core/util/image_picking.dart';
import 'package:books_marketplace_mobile/features/kyc/presentation/liveness_capture_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<BuildContext> _context(WidgetTester tester) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  return ctx;
}

void main() {
  testWidgets('chụp ảnh thường: không khung liveness, không thử thách', (
    tester,
  ) async {
    final ctx = await _context(tester);
    final bytes = Uint8List.fromList([1, 2, 3]);
    final r = await captureSystemSelfie(ctx, () async => bytes);
    expect(r!.selfie, bytes);
    expect(r.frames, isEmpty);
    expect(r.challenges, isEmpty);
  });

  testWidgets('người dùng hủy camera: trả null', (tester) async {
    final ctx = await _context(tester);
    expect(await captureSystemSelfie(ctx, () async => null), isNull);
  });

  testWidgets('camera hệ thống lỗi: trả null, không ném', (tester) async {
    final ctx = await _context(tester);
    final r = await captureSystemSelfie(
      ctx,
      () async => throw const ImagePickException(ImagePickFailure.unavailable),
    );
    expect(r, isNull);
    await tester.pump();
  });
}
