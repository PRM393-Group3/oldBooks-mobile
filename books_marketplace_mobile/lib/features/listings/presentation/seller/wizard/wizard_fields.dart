import '../../../../../core/l10n/app_localizations.dart';

/// Chỉ số các bước của wizard.
abstract final class WizardStep {
  static const book = 0;
  static const photos = 1;
  static const sale = 2;
  static const review = 3;
}

String _last(String field) {
  final i = field.lastIndexOf('.');
  return (i < 0 ? field : field.substring(i + 1)).toLowerCase();
}

/// Bước chứa trường mà server báo lỗi (`details[].field`, ví dụ
/// `bookInfo.title`, `images`, `fixedPrice.price`).
int stepForField(String field) {
  final f = field.toLowerCase();
  if (f.startsWith('images')) return WizardStep.photos;
  if (f.startsWith('salemethod') ||
      f.startsWith('fixedprice') ||
      f.startsWith('auction')) {
    return WizardStep.sale;
  }
  return WizardStep.book;
}

/// Nhãn dễ hiểu cho trường thiếu; trường lạ thì trả nguyên tên.
String labelForField(AppLocalizations l, String field) {
  final f = field.toLowerCase();
  if (f.startsWith('images')) return l.missingImages;
  if (f.startsWith('salemethod')) return l.missingSaleMethod;
  if (f.startsWith('fixedprice')) return l.missingPrice;
  if (f.startsWith('auction')) return l.missingStartingPrice;
  return switch (_last(field)) {
    'title' => l.fieldTitle,
    'author' => l.fieldAuthor,
    'categoryid' || 'category' => l.missingCategory,
    'publicationyear' => l.fieldYear,
    'language' => l.fieldLanguage,
    'condition' => l.fieldCondition,
    'description' => l.fieldDescription,
    'isbn' => l.fieldIsbn,
    'pagecount' => l.fieldPages,
    'publisher' => l.fieldPublisher,
    _ => field,
  };
}

/// Khóa lỗi theo trường để hiện dưới ô nhập: `bookInfo.title` -> `title`.
Map<String, String> fieldKeys(Map<String, String> errors) => {
  for (final e in errors.entries) _last(e.key): e.value,
};
