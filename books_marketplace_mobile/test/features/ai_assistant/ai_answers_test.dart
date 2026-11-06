import 'package:books_marketplace_mobile/features/ai_assistant/domain/ai_answers.dart';
import 'package:books_marketplace_mobile/features/ai_assistant/domain/ai_models.dart';
import 'package:flutter_test/flutter_test.dart';

const _opts = [
  AiQuestionOption(value: 'NEW', label: 'Mới'),
  AiQuestionOption(value: 'GOOD', label: 'Tốt'),
  AiQuestionOption(value: 'FAIR', label: 'Khá'),
];

AiQuestion _q(
  String id,
  AiQuestionKind kind, {
  bool other = false,
  String? unit,
}) => AiQuestion(
  id: id,
  kind: kind,
  prompt: 'P$id',
  options:
      kind == AiQuestionKind.singleChoice || kind == AiQuestionKind.multiChoice
      ? _opts
      : const [],
  allowOther: other,
  unit: unit,
);

void main() {
  group('normalizeAiNumber / format', () {
    test('bỏ dấu nghìn và đơn vị', () {
      expect(normalizeAiNumber('1.500.000'), '1500000');
      expect(normalizeAiNumber('1,500 đ'), '1500');
      expect(normalizeAiNumber('abc'), isNull);
      expect(normalizeAiNumber(''), isNull);
      expect(formatAiNumberInput('1500000'), '1.500.000');
      expect(formatAiNumberInput('12'), '12');
    });
  });

  group('buildAiAnswers', () {
    test('một lựa chọn', () {
      final q = _q('a', AiQuestionKind.singleChoice);
      expect(buildAiAnswers([q], {}), isNull);
      final r = buildAiAnswers(
        [q],
        {
          'a': const AiAnswerDraft(picked: {'GOOD'}),
        },
      )!;
      expect(r.single.questionId, 'a');
      expect(r.single.value, 'GOOD');
    });

    test('Khác: gửi chữ người dùng, rỗng thì chưa đủ', () {
      final q = _q('a', AiQuestionKind.singleChoice, other: true);
      expect(
        buildAiAnswers(
          [q],
          {'a': const AiAnswerDraft(otherSelected: true, otherText: '  ')},
        ),
        isNull,
      );
      final r = buildAiAnswers(
        [q],
        {'a': const AiAnswerDraft(otherSelected: true, otherText: ' Hơi cũ ')},
      )!;
      expect(r.single.value, 'Hơi cũ');
    });

    test('nhiều lựa chọn giữ thứ tự và thêm Khác ở cuối', () {
      final q = _q('m', AiQuestionKind.multiChoice, other: true);
      expect(buildAiAnswers([q], {}), isNull);
      final r = buildAiAnswers(
        [q],
        {
          'm': const AiAnswerDraft(
            picked: {'FAIR', 'NEW'},
            otherSelected: true,
            otherText: 'x',
          ),
        },
      )!;
      expect(r.single.values, ['NEW', 'FAIR', 'x']);
      expect(r.single.value, isNull);
    });

    test('số gửi dạng chuỗi số nguyên', () {
      final q = _q('n', AiQuestionKind.number, unit: 'đ');
      expect(
        buildAiAnswers([q], {'n': const AiAnswerDraft(text: 'x')}),
        isNull,
      );
      final r = buildAiAnswers(
        [q],
        {'n': const AiAnswerDraft(text: '1.500.000')},
      )!;
      expect(r.single.value, '1500000');
    });

    test('văn bản được cắt khoảng trắng; thiếu một câu thì null', () {
      final t = _q('t', AiQuestionKind.text);
      final s = _q('s', AiQuestionKind.singleChoice);
      expect(
        buildAiAnswers([t, s], {'t': const AiAnswerDraft(text: ' hi ')}),
        isNull,
      );
      final r = buildAiAnswers(
        [t, s],
        {
          't': const AiAnswerDraft(text: ' hi '),
          's': const AiAnswerDraft(picked: {'NEW'}),
        },
      )!;
      expect(r.map((a) => a.value), ['hi', 'NEW']);
    });
  });

  group('summarizeAiAnswers', () {
    test('một câu: nhãn đã chọn', () {
      final q = _q('m', AiQuestionKind.multiChoice);
      final a = buildAiAnswers(
        [q],
        {
          'm': const AiAnswerDraft(picked: {'NEW', 'GOOD'}),
        },
      )!;
      expect(summarizeAiAnswers([q], a), 'Mới, Tốt');
    });

    test('nhiều câu: mỗi câu một dòng kèm câu hỏi, số định dạng', () {
      final s = _q('s', AiQuestionKind.singleChoice);
      final n = _q('n', AiQuestionKind.number, unit: 'đ');
      final a = buildAiAnswers(
        [s, n],
        {
          's': const AiAnswerDraft(picked: {'FAIR'}),
          'n': const AiAnswerDraft(text: '50000'),
        },
      )!;
      expect(
        summarizeAiAnswers(
          [s, n],
          a,
          formatValue: (q, v) => '${formatAiNumberInput(v)} ${q.unit}',
        ),
        'Ps: Khá\nPn: 50.000 đ',
      );
    });
  });
}
