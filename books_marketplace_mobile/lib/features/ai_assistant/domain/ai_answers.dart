import 'ai_models.dart';

/// Trạng thái nhập của MỘT câu hỏi trong thẻ (thuần, không phụ thuộc widget).
class AiAnswerDraft {
  const AiAnswerDraft({
    this.picked = const {},
    this.otherSelected = false,
    this.otherText = '',
    this.text = '',
  });

  /// Giá trị (`option.value`) các lựa chọn đã chọn.
  final Set<String> picked;

  /// Đã chọn "Khác" (chỉ khi câu hỏi `allowOther`).
  final bool otherSelected;
  final String otherText;

  /// Nội dung ô nhập của câu hỏi TEXT/NUMBER.
  final String text;

  AiAnswerDraft copyWith({
    Set<String>? picked,
    bool? otherSelected,
    String? otherText,
    String? text,
  }) => AiAnswerDraft(
    picked: picked ?? this.picked,
    otherSelected: otherSelected ?? this.otherSelected,
    otherText: otherText ?? this.otherText,
    text: text ?? this.text,
  );
}

/// Chuẩn hóa số nhập tay thành chuỗi số nguyên: bỏ dấu phân cách nghìn, khoảng
/// trắng, đơn vị. Trả null nếu không còn chữ số nào hoặc không phải số nguyên.
String? normalizeAiNumber(String raw) {
  final digits = raw.replaceAll(RegExp(r'[\s.,_₫đĐ]'), '');
  if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) return null;
  return BigInt.parse(digits).toString();
}

/// Thêm dấu chấm nghìn khi gõ số tiền (`1500000` -> `1.500.000`).
String formatAiNumberInput(String raw) {
  final n = normalizeAiNumber(raw);
  if (n == null) return '';
  final b = StringBuffer();
  for (var i = 0; i < n.length; i++) {
    if (i > 0 && (n.length - i) % 3 == 0) b.write('.');
    b.write(n[i]);
  }
  return b.toString();
}

/// Câu hỏi đã được trả lời đủ chưa.
bool isAiQuestionAnswered(AiQuestion q, AiAnswerDraft d) {
  switch (q.kind) {
    case AiQuestionKind.singleChoice:
      return d.otherSelected && q.allowOther
          ? d.otherText.trim().isNotEmpty
          : d.picked.isNotEmpty;
    case AiQuestionKind.multiChoice:
      final hasOther = q.allowOther && d.otherSelected;
      if (hasOther && d.otherText.trim().isEmpty) return false;
      return d.picked.isNotEmpty || hasOther;
    case AiQuestionKind.text:
      return d.text.trim().isNotEmpty;
    case AiQuestionKind.number:
      return normalizeAiNumber(d.text) != null;
  }
}

/// null nếu còn câu chưa trả lời; ngược lại danh sách đáp án gửi lên.
/// "Khác" gửi chính chữ người dùng nhập (không có mã riêng).
List<AiAnswer>? buildAiAnswers(
  List<AiQuestion> questions,
  Map<String, AiAnswerDraft> drafts,
) {
  final out = <AiAnswer>[];
  for (final q in questions) {
    final d = drafts[q.id] ?? const AiAnswerDraft();
    if (!isAiQuestionAnswered(q, d)) return null;
    switch (q.kind) {
      case AiQuestionKind.singleChoice:
        out.add(
          AiAnswer(
            questionId: q.id,
            value: q.allowOther && d.otherSelected
                ? d.otherText.trim()
                : d.picked.first,
          ),
        );
      case AiQuestionKind.multiChoice:
        // Giữ thứ tự theo danh sách lựa chọn của câu hỏi.
        out.add(
          AiAnswer(
            questionId: q.id,
            values: [
              for (final o in q.options)
                if (d.picked.contains(o.value)) o.value,
              if (q.allowOther && d.otherSelected) d.otherText.trim(),
            ],
          ),
        );
      case AiQuestionKind.text:
        out.add(AiAnswer(questionId: q.id, value: d.text.trim()));
      case AiQuestionKind.number:
        out.add(AiAnswer(questionId: q.id, value: normalizeAiNumber(d.text)));
    }
  }
  return out;
}

/// Tóm tắt dễ đọc cho bong bóng của người dùng: nhãn đã chọn, nhiều câu hỏi
/// thì mỗi câu một dòng.
String summarizeAiAnswers(
  List<AiQuestion> questions,
  List<AiAnswer> answers, {
  String Function(AiQuestion q, String value)? formatValue,
}) {
  final lines = <String>[];
  for (final a in answers) {
    final q = questions.where((q) => q.id == a.questionId).firstOrNull;
    if (q == null) continue;
    String label(String v) {
      final o = q.options.where((o) => o.value == v).firstOrNull;
      if (o != null) return o.label;
      return formatValue?.call(q, v) ?? v;
    }

    final vals = a.values ?? [if (a.value != null) a.value!];
    final text = vals.map(label).join(', ');
    lines.add(questions.length > 1 ? '${q.prompt}: $text' : text);
  }
  return lines.join('\n');
}
