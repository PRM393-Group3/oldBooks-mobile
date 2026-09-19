import 'listing_enums.dart';

String? _nullIfBlank(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}

/// Body của `PUT /listings/{id}/book-info`. PUT thay thế toàn bộ: trường để
/// trống gửi `null` để xóa.
class BookInfoInput {
  const BookInfoInput({
    required this.title,
    required this.author,
    required this.categoryId,
    required this.condition,
    required this.description,
    this.publisher,
    this.isbn,
    this.publicationYear,
    this.language,
    this.pageCount,
    this.coverType,
    this.defectNotes,
  });

  final String title;
  final String author;
  final String categoryId;
  final String? publisher;
  final String? isbn;
  final int? publicationYear;
  final String? language;
  final int? pageCount;
  final CoverType? coverType;
  final BookCondition condition;
  final String description;
  final String? defectNotes;

  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'author': author.trim(),
    'categoryId': categoryId,
    'publisher': _nullIfBlank(publisher),
    'isbn': _nullIfBlank(isbn),
    'publicationYear': publicationYear,
    'language': _nullIfBlank(language)?.toLowerCase(),
    'pageCount': pageCount,
    'coverType': coverType?.api,
    'condition': condition.api,
    'description': description.trim(),
    'defectNotes': _nullIfBlank(defectNotes),
  };
}

/// Body của `PUT /listings/{id}/sale-method`.
sealed class SaleMethodInput {
  const SaleMethodInput();
  Map<String, dynamic> toJson();
}

class FixedPriceInput extends SaleMethodInput {
  const FixedPriceInput({required this.price, required this.quantity});
  final int price;
  final int quantity;

  @override
  Map<String, dynamic> toJson() => {
    'method': SaleMethod.fixedPrice.api,
    'fixedPrice': {'price': price, 'quantity': quantity},
  };
}

class AuctionInput extends SaleMethodInput {
  const AuctionInput({
    required this.startingPrice,
    required this.minBidIncrement,
    required this.durationDays,
    required this.startMode,
    this.scheduledStartAt,
  });

  final int startingPrice;
  final int minBidIncrement;
  final int durationDays;
  final AuctionStartMode startMode;

  /// Chỉ gửi khi [startMode] là `Scheduled`.
  final DateTime? scheduledStartAt;

  @override
  Map<String, dynamic> toJson() => {
    'method': SaleMethod.auction.api,
    'auction': {
      'startingPrice': startingPrice,
      'minBidIncrement': minBidIncrement,
      'durationDays': durationDays,
      'startMode': startMode.api,
      if (startMode == AuctionStartMode.scheduled)
        'scheduledStartAt': scheduledStartAt?.toUtc().toIso8601String(),
    },
  };
}

/// Kết quả của `POST /listings/{id}/submit`.
class SubmitResult {
  const SubmitResult({required this.estimatedProcessingHours});
  final int estimatedProcessingHours;
}
