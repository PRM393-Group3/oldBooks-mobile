import 'package:books_marketplace_mobile/core/l10n/app_localizations.dart';
import 'package:books_marketplace_mobile/core/theme/app_theme.dart';
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

/// Mô phỏng IME gõ Telex: mỗi bước gửi cả từ đang ghép (composing), như
/// Gboard/Laban Key trên Android và bàn phím tiếng Việt của iOS.
Future<void> _telex(
  WidgetTester tester,
  String committed,
  List<String> steps,
) async {
  for (final word in steps) {
    final text = committed + word;
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
        composing: TextRange(start: committed.length, end: text.length),
      ),
    );
    await tester.pump();
  }
  final text = committed + steps.last;
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );
  await tester.pump();
}

/// Ô nhập có `onChanged` gọi `setState` như các form trong app (form đăng
/// bán, khiếu nại): dựng lại mỗi phím không được làm mất từ đang ghép.
class _RebuildingField extends StatefulWidget {
  const _RebuildingField({required this.controller, this.maxLength});

  final TextEditingController controller;
  final int? maxLength;

  @override
  State<_RebuildingField> createState() => _RebuildingFieldState();
}

class _RebuildingFieldState extends State<_RebuildingField> {
  int _changes = 0;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$_changes'),
      AppTextField(
        label: 'Tên sách',
        controller: widget.controller,
        maxLength: widget.maxLength,
        onChanged: (_) => setState(() => _changes++),
      ),
    ],
  );
}

void main() {
  final platforms = TargetPlatformVariant(const {
    TargetPlatform.android,
    TargetPlatform.iOS,
  });
  {
    group('gõ tiếng Việt', () {
      testWidgets('Telex qua từng bước ghép cho ra đúng chữ có dấu', (
        tester,
      ) async {
        final c = TextEditingController();
        await tester.pumpWidget(_host(_RebuildingField(controller: c)));
        await tester.tap(find.byType(TextField));
        await tester.pump();

        await _telex(tester, '', [
          'T',
          'Ti',
          'Tie',
          'Tiê',
          'Tiêns',
          'Tiến',
          'Tiếng',
        ]);
        await _telex(tester, 'Tiếng ', [
          'V',
          'Vi',
          'Vie',
          'Viê',
          'Viêj',
          'Việ',
          'Việt',
        ]);
        expect(c.text, 'Tiếng Việt');
        await _telex(tester, 'Tiếng Việt ', [
          'd',
          'dd',
          'đ',
          'đu',
          'đuw',
          'đư',
          'đươ',
          'đươc',
          'đươcj',
          'được',
        ]);
        expect(c.text, 'Tiếng Việt được');
        c.dispose();
      }, variant: platforms);

      testWidgets('sát maxLength: chuỗi ghép tạm dài hơn không làm mất dấu', (
        tester,
      ) async {
        final c = TextEditingController();
        await tester.pumpWidget(
          _host(_RebuildingField(controller: c, maxLength: 4)),
        );
        await tester.tap(find.byType(TextField));
        await tester.pump();

        // Bàn phím có thể gửi tạm "Viêtj" (5 ký tự) trước khi ghép thành "Việt".
        await _telex(tester, '', [
          'V',
          'Vi',
          'Vie',
          'Viê',
          'Viêt',
          'Viêtj',
          'Việt',
        ]);
        expect(c.text, 'Việt');
        c.dispose();
      }, variant: platforms);
    });
  }
}
