import '../domain/sell_rules.dart';

/// Kết quả AI đánh giá ảnh sách: thông tin đọc được trên bìa, gợi ý tình trạng
/// và mô tả ngắn cho người bán. Trường không đọc được thì `null`.
class BookAnalysis {
  const BookAnalysis({
    required this.condition,
    required this.description,
    this.title,
    this.author,
    this.publisher,
    this.year,
    this.defects,
  });

  final SellCondition condition;
  final String description;
  final String? title;
  final String? author;
  final String? publisher;
  final int? year;
  final String? defects;
}

/// Phần kết quả đã đọc được từ câu trả lời đang được model sinh dần. Trường
/// chưa xuất hiện hoặc chưa viết xong thì `null`.
class BookAnalysisPreview {
  const BookAnalysisPreview({
    this.title,
    this.author,
    this.publisher,
    this.year,
    this.condition,
    this.defects,
    this.description,
  });

  final String? title;
  final String? author;
  final String? publisher;
  final int? year;
  final SellCondition? condition;
  final String? defects;
  final String? description;

  bool get isEmpty =>
      title == null &&
      author == null &&
      publisher == null &&
      year == null &&
      condition == null &&
      defects == null &&
      description == null;
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
/// cầu từng trường một dòng, theo thứ tự này để [previewBookAnalysis] đọc được
/// khi model đang sinh dần. Mô tả đặt cuối vì có thể kéo dài nhiều dòng.
const bookAnalysisPrompt =
    'You are helping sell a used book from its photo. Read only what is '
    'clearly visible; never guess. Write UNKNOWN for anything you cannot read. '
    'Rate the physical condition with exactly one code: NEW (like new, no '
    'visible wear), GOOD (light wear), FAIR (clear wear, stains or creases), '
    'WORN (heavy damage, torn or very yellowed). '
    'Answer with exactly these lines and nothing else:\n'
    'TITLE: <book title as printed, or UNKNOWN>\n'
    'AUTHOR: <author as printed, or UNKNOWN>\n'
    'PUBLISHER: <publisher as printed, or UNKNOWN>\n'
    'YEAR: <4-digit publication year, or UNKNOWN>\n'
    'CONDITION: <NEW|GOOD|FAIR|WORN>\n'
    'DEFECTS: <short list in Vietnamese of visible damage, or NONE>\n'
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

/// Giá trị model hay điền khi không đọc được; coi như không có.
final _emptyValue = RegExp(
  r'^(unknown|none|n/?a|null|nil|-+|không rõ|không có|không biết)\.?$',
  caseSensitive: false,
);

/// Lấy giá trị một dòng `KEY: value`. Dòng chưa kết thúc bằng xuống dòng là
/// dòng model còn đang viết nên bị bỏ qua, trừ khi [last] (trường cuối cùng
/// hoặc câu trả lời đã xong).
String? _field(String text, String key, {required bool last}) {
  final m = RegExp(
    '^\\W*$key\\s*[:：]\\s*(.*?)(\\n|\$)',
    caseSensitive: false,
    multiLine: true,
  ).firstMatch(text);
  if (m == null) return null;
  if (m.group(2)!.isEmpty && !last) return null;
  final v = _clean(m.group(1)!);
  return v.isEmpty || _emptyValue.hasMatch(v) ? null : v;
}

int? _year(String? v) {
  final m = RegExp(r'\b(1[4-9]\d\d|20\d\d)\b').firstMatch(v ?? '');
  final y = m == null ? null : int.parse(m.group(1)!);
  return y != null && y <= DateTime.now().year + 1 ? y : null;
}

SellCondition? _conditionOf(String code) => SellCondition.values
    .where((c) => c.code == code.toUpperCase())
    .firstOrNull;

/// Đọc phần đã sinh ra của câu trả lời để hiện dần lên màn hình. [done] là
/// model đã sinh xong (cho phép đọc cả dòng cuối chưa xuống dòng).
BookAnalysisPreview previewBookAnalysis(String raw, {bool done = false}) {
  final code = _conditionLine.firstMatch(raw);
  final codeDone = code != null && (done || raw.length > code.end);
  final desc = _descriptionLine.firstMatch(raw)?.group(1);
  final cleaned = _clean(desc ?? '');
  return BookAnalysisPreview(
    title: _field(raw, 'title', last: done),
    author: _field(raw, 'author', last: done),
    publisher: _field(raw, 'publisher', last: done),
    year: _year(_field(raw, 'year', last: done)),
    condition: codeDone ? _conditionOf(code.group(1)!) : null,
    defects: _field(raw, 'defects', last: done),
    description: cleaned.isEmpty ? null : cleaned,
  );
}

/// Đọc câu trả lời của model. Trả `null` nếu không tìm được tình trạng nào,
/// kể cả từ khóa tiếng Việt; thiếu mô tả thì dùng câu mặc định theo tình trạng.
BookAnalysis? parseBookAnalysis(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final info = previewBookAnalysis(text, done: true);

  // Bỏ các dòng thông tin sách để tên sách (ví dụ "The New ...") không bị
  // nhận nhầm là mã tình trạng.
  final rest = text.replaceAll(
    RegExp(
      r'^\W*(title|author|publisher|year)\s*[:：].*$',
      caseSensitive: false,
      multiLine: true,
    ),
    '',
  );
  final code = (_conditionLine.firstMatch(text) ?? _anyCode.firstMatch(rest))
      ?.group(1);

  SellCondition? condition;
  var description = _clean(_descriptionLine.firstMatch(text)?.group(1) ?? '');
  if (code != null) {
    condition = _conditionOf(code);
  } else {
    // Không có mã: đoán từ từ khóa tiếng Việt và dùng chính câu trả lời làm mô tả.
    for (final (c, cue) in _vietnameseCues) {
      if (cue.hasMatch(rest)) {
        condition = c;
        break;
      }
    }
    if (condition == null) return null;
    if (description.isEmpty) description = _clean(rest);
  }
  if (condition == null) return null;

  if (description.length < 8) description = _fallbackDescriptions[condition]!;
  if (description.length > 300) description = description.substring(0, 300);
  return BookAnalysis(
    condition: condition,
    description: description,
    title: info.title,
    author: info.author,
    publisher: info.publisher,
    year: info.year,
    defects: info.defects,
  );
}
