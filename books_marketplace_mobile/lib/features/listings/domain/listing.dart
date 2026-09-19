import '../../../core/util/json_read.dart';
import 'listing_enums.dart';

class PersonRef {
  const PersonRef({required this.id, required this.name});
  final String id;
  final String name;
}

class BookInfo {
  const BookInfo({
    this.title,
    this.author,
    this.publisher,
    this.isbn,
    this.publicationYear,
    this.language,
    this.pageCount,
    this.coverType,
    this.condition,
    this.description,
    this.defectNotes,
  });

  factory BookInfo.fromJson(Map<dynamic, dynamic> j) => BookInfo(
    title: readString(j, 'title'),
    author: readString(j, 'author'),
    publisher: readString(j, 'publisher'),
    isbn: readString(j, 'isbn'),
    publicationYear: readInt(j, 'publicationYear'),
    language: readString(j, 'language'),
    pageCount: readInt(j, 'pageCount'),
    coverType: CoverType.fromApi(readString(j, 'coverType')),
    condition: BookCondition.fromApi(readString(j, 'condition')),
    description: readString(j, 'description'),
    defectNotes: readString(j, 'defectNotes'),
  );

  final String? title;
  final String? author;
  final String? publisher;
  final String? isbn;
  final int? publicationYear;
  final String? language;
  final int? pageCount;
  final CoverType? coverType;
  final BookCondition? condition;
  final String? description;
  final String? defectNotes;
}

class FixedPriceConfig {
  const FixedPriceConfig({required this.price, required this.quantity});
  final int price;
  final int quantity;
}

class AuctionConfig {
  const AuctionConfig({
    required this.startingPrice,
    required this.minBidIncrement,
    required this.durationDays,
    required this.startMode,
    this.scheduledStartAt,
    this.startsAt,
    this.endsAt,
  });

  final int startingPrice;
  final int minBidIncrement;
  final int durationDays;
  final AuctionStartMode startMode;
  final DateTime? scheduledStartAt;
  final DateTime? startsAt;
  final DateTime? endsAt;
}

class ListingImage {
  const ListingImage({
    required this.url,
    required this.type,
    this.id,
    this.displayOrder = 0,
  });

  final String? id;
  final String url;
  final ImageType type;
  final int displayOrder;

  /// `ListingDto` không trả `blobName`, nên suy từ URL: phần sau `/public/`
  /// (dạng `{sellerId}/{guid}.{ext}`). Cần khi gửi lại toàn bộ danh sách ảnh.
  String? get blobName {
    final path = Uri.tryParse(url)?.path;
    if (path == null) return null;
    final at = path.indexOf('/public/');
    return at < 0 ? null : path.substring(at + '/public/'.length);
  }
}

/// Biên bản kiểm định gần nhất, hoặc một biên bản trong lịch sử.
class InspectionSummary {
  const InspectionSummary({
    required this.decision,
    required this.reasonCodes,
    required this.decidedAt,
    this.reportId,
    this.note,
    this.submissionNumber,
  });

  factory InspectionSummary.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return InspectionSummary(
      reportId: readString(j, 'reportId') ?? readString(j, 'id'),
      decision: readString(j, 'decision') ?? '',
      reasonCodes: readList(j, 'reasonCodes').whereType<String>().toList(),
      note: readString(j, 'note'),
      submissionNumber: readInt(j, 'submissionNumber'),
      decidedAt: readDate(j, 'decidedAt'),
    );
  }

  final String? reportId;
  final String decision;
  final List<String> reasonCodes;
  final String? note;
  final int? submissionNumber;
  final DateTime? decidedAt;

  /// Doc không nêu giá trị của `decision`; coi mọi chuỗi chứa "approv" là duyệt.
  bool get isApproved => decision.toLowerCase().contains('approv');
}

/// Tin đăng. Dùng chung cho `ListingDto` đầy đủ và các dòng danh sách rút gọn:
/// mọi trường ngoài `id`, `status` đều có thể thiếu.
class Listing {
  const Listing({
    required this.id,
    required this.status,
    this.saleMethod,
    this.seller,
    this.category,
    this.bookInfo = const BookInfo(),
    this.fixedPrice,
    this.auction,
    this.images = const [],
    this.coverUrl,
    this.submissionCount = 0,
    this.maxSubmissions = 4,
    this.submittedAt,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.latestInspection,
  });

  factory Listing.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    // Dòng danh sách có thể phẳng (title ở gốc) thay vì lồng trong bookInfo.
    final info = BookInfo.fromJson(readMap(j, 'bookInfo') ?? j);

    PersonRef? person(String key) {
      final m = readMap(j, key);
      if (m == null) return null;
      return PersonRef(
        id: readString(m, 'id') ?? '',
        name: readString(m, 'fullName') ?? readString(m, 'name') ?? '',
      );
    }

    final fixed = readMap(j, 'fixedPrice');
    final flatPrice = readInt(j, 'price');
    final auc = readMap(j, 'auction');

    final images = readList(j, 'images')
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (m) => ListingImage(
            id: readString(m, 'id'),
            url: readString(m, 'url') ?? '',
            type:
                ImageType.fromApi(readString(m, 'type')) ?? ImageType.innerPage,
            displayOrder: readInt(m, 'displayOrder') ?? 0,
          ),
        )
        .toList();

    final latest = readMap(j, 'latestInspection');

    return Listing(
      id: readString(j, 'id') ?? '',
      status: ListingStatus.fromApi(readString(j, 'status')),
      saleMethod: SaleMethod.fromApi(readString(j, 'saleMethod')),
      seller: person('seller'),
      category: person('category'),
      bookInfo: info,
      fixedPrice: fixed != null
          ? FixedPriceConfig(
              price: readInt(fixed, 'price') ?? 0,
              quantity: readInt(fixed, 'quantity') ?? 1,
            )
          : (flatPrice != null
                ? FixedPriceConfig(
                    price: flatPrice,
                    quantity: readInt(j, 'quantity') ?? 1,
                  )
                : null),
      auction: auc != null
          ? AuctionConfig(
              startingPrice: readInt(auc, 'startingPrice') ?? 0,
              minBidIncrement: readInt(auc, 'minBidIncrement') ?? 0,
              durationDays: readInt(auc, 'durationDays') ?? 0,
              startMode:
                  AuctionStartMode.fromApi(readString(auc, 'startMode')) ??
                  AuctionStartMode.onApproval,
              scheduledStartAt: readDate(auc, 'scheduledStartAt'),
              startsAt: readDate(auc, 'startsAt'),
              endsAt: readDate(auc, 'endsAt'),
            )
          : null,
      images: images..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
      coverUrl:
          readString(j, 'coverImageUrl') ??
          readString(j, 'thumbnailUrl') ??
          readString(j, 'imageUrl'),
      submissionCount: readInt(j, 'submissionCount') ?? 0,
      maxSubmissions: readInt(j, 'maxSubmissions') ?? 4,
      submittedAt: readDate(j, 'submittedAt'),
      publishedAt: readDate(j, 'publishedAt'),
      createdAt: readDate(j, 'createdAt'),
      updatedAt: readDate(j, 'updatedAt'),
      latestInspection: latest == null
          ? null
          : InspectionSummary.fromJson(latest),
    );
  }

  final String id;
  final ListingStatus status;
  final SaleMethod? saleMethod;
  final PersonRef? seller;
  final PersonRef? category;
  final BookInfo bookInfo;
  final FixedPriceConfig? fixedPrice;
  final AuctionConfig? auction;
  final List<ListingImage> images;

  /// Ảnh bìa trong dòng danh sách rút gọn (không có `images`).
  final String? coverUrl;
  final int submissionCount;
  final int maxSubmissions;
  final DateTime? submittedAt;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final InspectionSummary? latestInspection;

  String get title => bookInfo.title ?? '';

  /// Số lần nộp lại còn lại (0 nếu hết).
  int get submissionsLeft {
    final left = maxSubmissions - submissionCount;
    return left < 0 ? 0 : left;
  }

  /// Ảnh bìa để hiện trên thẻ: ưu tiên bìa trước.
  String? get coverImageUrl {
    if (images.isNotEmpty) {
      final front = images.where((i) => i.type == ImageType.frontCover);
      return (front.isNotEmpty ? front.first : images.first).url;
    }
    return coverUrl;
  }

  /// Giá hiển thị trên thẻ: giá bán hoặc giá khởi điểm.
  int? get displayPrice => saleMethod == SaleMethod.auction
      ? auction?.startingPrice
      : fixedPrice?.price;
}
