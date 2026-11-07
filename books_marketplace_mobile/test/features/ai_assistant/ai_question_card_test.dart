import 'package:books_marketplace_mobile/core/l10n/app_localizations.dart';
import 'package:books_marketplace_mobile/core/theme/app_theme.dart';
import 'package:books_marketplace_mobile/features/ai_assistant/domain/ai_models.dart';
import 'package:books_marketplace_mobile/features/ai_assistant/presentation/ai_question_card.dart';
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
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

const _opts = [
  AiQuestionOption(value: 'NEW', label: 'Mới'),
  AiQuestionOption(value: 'GOOD', label: 'Tốt'),
];

void main() {
  testWidgets('một câu chọn một, không Khác: bấm là gửi ngay', (tester) async {
    List<AiAnswer>? got;
    String? shown;
    await tester.pumpWidget(
      _host(
        AiQuestionCard(
          pending: const AiPendingQuestion(
            questions: [
              AiQuestion(
                id: 'q1',
                kind: AiQuestionKind.singleChoice,
                prompt: 'Tình trạng?',
                options: _opts,
              ),
            ],
          ),
          onSubmit: (a, s) {
            got = a;
            shown = s;
          },
          onDismiss: () {},
        ),
      ),
    );
    expect(find.text('Gửi'), findsNothing);
    await tester.tap(find.text('Tốt'));
    await tester.pump();
    expect(got!.single.value, 'GOOD');
    expect(shown, 'Tốt');
  });

  testWidgets('nhiều chọn + Khác: nút Gửi chỉ bật khi đủ', (tester) async {
    List<AiAnswer>? got;
    await tester.pumpWidget(
      _host(
        AiQuestionCard(
          pending: const AiPendingQuestion(
            questions: [
              AiQuestion(
                id: 'm',
                kind: AiQuestionKind.multiChoice,
                prompt: 'Lỗi?',
                options: _opts,
                allowOther: true,
              ),
              AiQuestion(
                id: 'n',
                kind: AiQuestionKind.number,
                prompt: 'Giá?',
                unit: 'đ',
              ),
            ],
          ),
          onSubmit: (a, s) => got = a,
          onDismiss: () {},
        ),
      ),
    );
    FilledButton send() => tester.widget(find.byType(FilledButton));
    expect(send().onPressed, isNull);

    await tester.tap(find.text('Mới'));
    await tester.tap(find.text('Khác'));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-other-m')), 'rách bìa');
    await tester.pump();
    expect(send().onPressed, isNull, reason: 'chưa nhập giá');

    await tester.enterText(find.byKey(const Key('ai-number-n')), '1500000');
    await tester.pump();
    expect(send().onPressed, isNotNull);
    // Hiển thị có dấu nghìn.
    expect(find.text('1.500.000'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(got![0].values, ['NEW', 'rách bìa']);
    expect(got![1].value, '1500000');
  });

  testWidgets('Để mình tự gõ gọi onDismiss; vô hiệu khi đang gửi', (
    tester,
  ) async {
    var dismissed = 0;
    Widget build(bool enabled) => _host(
      AiQuestionCard(
        enabled: enabled,
        pending: const AiPendingQuestion(
          questions: [
            AiQuestion(id: 't', kind: AiQuestionKind.text, prompt: 'Tên?'),
          ],
        ),
        onSubmit: (_, _) {},
        onDismiss: () => dismissed++,
      ),
    );
    await tester.pumpWidget(build(true));
    await tester.tap(find.text('Để mình tự gõ'));
    expect(dismissed, 1);
    await tester.pumpWidget(build(false));
    await tester.tap(find.text('Để mình tự gõ'), warnIfMissed: false);
    expect(dismissed, 1);
  });
}
