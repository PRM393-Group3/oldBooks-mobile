import '../domain/sell_rules.dart';

/// Kết quả AI đánh giá ảnh sách: gợi ý tình trạng và mô tả ngắn cho người bán.
class BookAnalysis {
  const BookAnalysis({required this.condition, required this.description});

  final SellCondition condition;
  final String description;
}

/// Câu mô tả mặc định theo tình trạng, dùng khi model không trả được mô tả.
const _fallbackDescriptions = {
  SellCondition.isNew: 'Sách còn mới, bìa và các trang sạch đẹp.',
  SellCondition.good:
      'Sách còn tốt, bìa và ruột sạch, chỉ có dấu hiệu sử dụng nhẹ.',
  SellCondition.fair:
      'Sách đã qua sử dụng, có dấu hiệu cũ ở bìa hoặc các trang.',
  SellCondition.worn:
      'Sách cũ nhiều, có vết ố, nhàu hoặc hư hại rõ ở bìa và trang.',
};

/// Lời nhắc gửi model. Viết bằng tiếng Anh vì model nhỏ làm theo tốt hơn; yêu
/// cầu trả mô tả bằng tiếng Việt và đúng hai dòng để [parseBookAnalysis] đọc.
const bookAnalysisPrompt =
    'You are checking the physical condition of a used book from its photo. '
    'Rate it with exactly one code: NEW (like new, no visible wear), '
    'GOOD (light wear), FAIR (clear wear, stains or creases), '
    'WORN (heavy damage, torn or very yellowed). '
    'Answer with exactly two lines and nothing else:\n'
    'CONDITION: <NEW|GOOD|FAIR|WORN>\n'
    'DESCRIPTION: <one short sentence in Vietnamese about the cover, spine and '
    'pages you can see>';

final _conditionLine = RegExp(
  r'condition\W*(new|good|fair|worn)\b',
  caseSensitive: false,
);
final _descriptionLine = RegExp(
  r'description\s*[:：]\s*(.+)',
  caseSensitive: false,
  dotAll: true,
);
final _anyCode = RegExp(r'\b(new|good|fair|worn)\b', caseSensitive: false);

/// Từ khóa tiếng Việt theo mức hư hại, xét từ nặng đến nhẹ. Model nhỏ hay bỏ
/// qua định dạng và trả thẳng tiếng Việt. Dart không có `\b` cho chữ có dấu nên
/// dùng lookaround với `\p{L}`.
final _vietnameseCues = <(SellCondition, RegExp)>[
  (
    SellCondition.worn,
    _cue(['rách', 'hư hỏng', 'hỏng', 'nát', 'mục', 'bong', 'cũ nát', 'rất cũ']),
  ),
  (
    SellCondition.fair,
    _cue(['ố', 'vàng', 'nhàu', 'cong', 'xước', 'trầy', 'cũ', 'đã qua sử dụng']),
  ),
  (SellCondition.isNew, _cue(['như mới', 'còn mới', 'mới'])),
  (SellCondition.good, _cue(['tốt', 'đẹp', 'sạch', 'ổn'])),
];

RegExp _cue(List<String> words) => RegExp(
  '(?<![\\p{L}])(?:${words.join('|')})(?![\\p{L}])',
  unicode: true,
  caseSensitive: false,
);

String _clean(String s) => s
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll(RegExp('^["\'“]+|["\'”]+\$'), '')
    .trim();

/// Đọc câu trả lời của model. Trả `null` nếu không tìm được tình trạng nào,
/// kể cả từ khóa tiếng Việt; thiếu mô tả thì dùng câu mặc định theo tình trạng.
BookAnalysis? parseBookAnalysis(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;

  final code = (_conditionLine.firstMatch(text) ?? _anyCode.firstMatch(text))
      ?.group(1);

  SellCondition? condition;
  var description = _clean(_descriptionLine.firstMatch(text)?.group(1) ?? '');
  if (code != null) {
    condition = SellCondition.values.firstWhere(
      (c) => c.code == code.toUpperCase(),
    );
  } else {
    // Không có mã: đoán từ từ khóa tiếng Việt và dùng chính câu trả lời làm mô tả.
    for (final (c, cue) in _vietnameseCues) {
      if (cue.hasMatch(text)) {
        condition = c;
        break;
      }
    }
    if (condition == null) return null;
    if (description.isEmpty) description = _clean(text);
  }

  if (description.length < 8) description = _fallbackDescriptions[condition]!;
  if (description.length > 300) description = description.substring(0, 300);
  return BookAnalysis(condition: condition, description: description);
}
