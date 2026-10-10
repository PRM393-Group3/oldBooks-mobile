import 'package:books_marketplace_mobile/core/l10n/app_localizations.dart';
import 'package:books_marketplace_mobile/core/theme/app_theme.dart';
import 'package:books_marketplace_mobile/core/widgets/app_avatar.dart';
import 'package:books_marketplace_mobile/core/widgets/app_button.dart';
import 'package:books_marketplace_mobile/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  locale: const Locale('vi'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('AppAvatar.initialsOf', () {
    test('lấy chữ đầu của từ đầu và từ cuối', () {
      expect(AppAvatar.initialsOf('Nguyen Van A'), 'NA');
      expect(AppAvatar.initialsOf('  trần   thị b '), 'TB');
      expect(AppAvatar.initialsOf('Duy'), 'D');
      expect(AppAvatar.initialsOf('  '), '?');
    });
  });

  testWidgets('AppButton: đang loading thì khóa và không nhận bấm', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(AppButton(label: 'Lưu', loading: true, onPressed: () => taps++)),
    );

    await tester.tap(find.byType(FilledButton));
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Lưu'), findsNothing);
  });

  testWidgets('AppButton: bình thường thì nhận bấm', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(AppButton(label: 'Lưu', onPressed: () => taps++)),
    );

    await tester.tap(find.text('Lưu'));
    expect(taps, 1);
  });

  testWidgets('AppTextField: nút hiện/ẩn mật khẩu', (tester) async {
    await tester.pumpWidget(
      _host(const AppTextField(label: 'Mật khẩu', isPassword: true)),
    );

    EditableText field() =>
        tester.widget<EditableText>(find.byType(EditableText));
    expect(field().obscureText, isTrue);

    await tester.tap(find.byTooltip('Hiện mật khẩu'));
    await tester.pump();
    expect(field().obscureText, isFalse);
    expect(find.byTooltip('Ẩn mật khẩu'), findsOneWidget);
  });

  testWidgets('bố cục không tràn khi chữ hệ thống phóng 130%', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: _host(
          const SizedBox(
            width: 320,
            child: Column(
              children: [
                AppTextField(
                  label: 'Họ và tên',
                  helperText: 'Tối đa 100 ký tự',
                ),
                AppButton(label: 'Lưu thay đổi', onPressed: null),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
