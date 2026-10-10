import '../../../core/util/json_read.dart';
import 'listing_enums.dart';

class PersonRef {
  const PersonRef({required this.id, required this.name});
  final String id;
  final String name;
}

/// Người bán trong `ListingDto`. `averageRating` là `null` và `completedOrders`
/// là 0 cho tới khi có module đơn hàng/đánh giá: ẩn khi `null`.
class SellerInfo {
  const SellerInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.averageRating,
    this.completedOrders = 0,
  });

  factory SellerInfo.fromJson(Map<dynamic, dynamic> j) => SellerInfo(
    id: readString(j, 'id') ?? '',
    name: readString(j, 'fullName') ?? readString(j, 'name') ?? '',
    avatarUrl: readString(j, 'avatarUrl'),
    averageRating: readDouble(j, 'averageRating'),
    completedOrders: readInt(j, 'completedOrders') ?? 0,
  );

  final String id;
  final String name;
  final String? avatarUrl;
  final double? averageRating;
  final int completedOrders;
}

class BookInfo {
  const BookInfo({
    this.title,
    this.author,
    this.publisher,
    this.isbn,
    this.publicationYear,
    this.condition,
    this.description,
    this.defectNotes,
  });

  final String? title;
  final String? author;
  final String? publisher;
  final String? isbn;
  final int? publicationYear;
  final BookCondition? condition;
  final String? description;
  final String? defectNotes;
}

class FixedPriceConfig {
  const FixedPriceConfig({required this.price, this.quantity = 1});
  final int price;

  /// Mỗi tin một cuốn.
  final int quantity;
}

/// Ảnh của tin (`ListingPhotoDto`). Server xử lý ảnh (xóa EXIF, thu nhỏ cạnh dài
/// 2048 px, sinh thumbnail 400 px) nên `url` khác `blobName` đã tải lên: luôn
/// dùng giá trị trả về.
class ListingPhoto {
  const ListingPhoto({
    required this.url,
    this.id,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.order = 0,
  });

  factory ListingPhoto.fromJson(Map<dynamic, dynamic> j) => ListingPhoto(
    id: readString(j, 'id'),
    url: readString(j, 'url') ?? '',
    thumbnailUrl: readString(j, 'thumbnailUrl'),
    width: readInt(j, 'width'),
    height: readInt(j, 'height'),
    order: readInt(j, 'order') ?? 0,
  );

  final String? id;
  final String url;
  final String? thumbnailUrl;
  final int? width;
  final int? height;
  final int order;

  /// `blobName` là phần sau `/public/` của `url` (dạng `<userId>/<tên-file>`).
  /// Cần khi gửi lại toàn bộ danh sách ảnh để giữ ảnh đã có.
  String? get blobName {
    final path = Uri.tryParse(url)?.path;
    if (path == null) return null;
    final at = path.indexOf('/public/');
    return at < 0 ? null : path.substring(at + '/public/'.length);
  }
}

/// Quyết định duyệt gần nhất. Chỉ chủ tin và admin thấy, người khác nhận `null`.
class ListingReview {
  const ListingReview({required this.decision, this.reason, this.createdAt});

  factory ListingReview.fromJson(Map<dynamic, dynamic> j) => ListingReview(
    decision: readString(j, 'decision') ?? '',
    reason: readString(j, 'reason'),
    createdAt: readDate(j, 'createdAt'),
  );

  /// `APPROVE`, `REQUEST_CHANGES` hoặc `REJECT`.
  final String decision;
  final String? reason;
  final DateTime? createdAt;
}

/// Tin đăng. Dùng cho cả `ListingDto` đầy đủ và `ListingSummaryDto` rút gọn:
/// mọi trường ngoài `id` và `status` đều có thể thiếu.
class Listing {
  const Listing({
    required this.id,
    required this.status,
    this.seller,
    this.category,
    this.bookInfo = const BookInfo(),
    this.price,
    this.images = const [],
    this.coverUrl,
    this.submittedAt,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.lastReview,
  });

  factory Listing.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;

    final cat = readMap(j, 'category');
    final categoryId = readString(j, 'categoryId');
    final sellerMap = readMap(j, 'seller');
    final review = readMap(j, 'lastReview');

    final photos = readList(
      j,
      'photos',
    ).whereType<Map<dynamic, dynamic>>().map(ListingPhoto.fromJson).toList();

    return Listing(
      id: readString(j, 'id') ?? '',
      status: ListingStatus.fromApi(readString(j, 'status')),
      seller: sellerMap == null ? null : SellerInfo.fromJson(sellerMap),
      category: cat != null
          ? PersonRef(
              id: readString(cat, 'id') ?? '',
              name: readString(cat, 'name') ?? '',
            )
          : (categoryId != null ? PersonRef(id: categoryId, name: '') : null),
      bookInfo: BookInfo(
        title: readString(j, 'title'),
        author: readString(j, 'author'),
        publisher: readString(j, 'publisher'),
        isbn: readString(j, 'isbn'),
        publicationYear: readInt(j, 'publishYear'),
        condition: BookCondition.fromApi(readString(j, 'condition')),
        description: readString(j, 'description'),
        defectNotes: readString(j, 'defectNotes'),
      ),
      price: readInt(j, 'price'),
      images: photos..sort((a, b) => a.order.compareTo(b.order)),
      coverUrl: readString(j, 'thumbnailUrl'),
      submittedAt: readDate(j, 'submittedAt'),
      publishedAt: readDate(j, 'publishedAt'),
      createdAt: readDate(j, 'createdAt'),
      updatedAt: readDate(j, 'updatedAt'),
      lastReview: review == null ? null : ListingReview.fromJson(review),
    );
  }

  final String id;
  final ListingStatus status;
  final SellerInfo? seller;

  /// Với dòng rút gọn chỉ có `id` (thiếu `name`).
  final PersonRef? category;
  final BookInfo bookInfo;
  final int? price;
  final List<ListingPhoto> images;

  /// `thumbnailUrl` của dòng rút gọn (không có `photos`); `null` nếu chưa có ảnh.
  final String? coverUrl;
  final DateTime? submittedAt;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ListingReview? lastReview;

  String get title => bookInfo.title ?? '';

  /// Tin bán giá cố định, mỗi tin một cuốn.
  FixedPriceConfig? get fixedPrice =>
      price == null ? null : FixedPriceConfig(price: price!);

  SaleMethod get saleMethod => SaleMethod.fixedPrice;

  int? get displayPrice => price;

  /// Ảnh bìa để hiện trên thẻ: ảnh đầu tiên (ảnh bìa), không thì thumbnail.
  String? get coverImageUrl => images.isNotEmpty
      ? (images.first.thumbnailUrl ?? images.first.url)
      : coverUrl;

  /// Lý do cần hiển thị cho chủ tin khi `NEEDS_CHANGES` hoặc `REJECTED`.
  String? get reviewReason =>
      status == ListingStatus.needsChanges || status == ListingStatus.rejected
      ? lastReview?.reason
      : null;
}
