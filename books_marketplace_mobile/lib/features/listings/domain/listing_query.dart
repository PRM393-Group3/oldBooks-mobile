import 'listing_enums.dart';

enum ListingSort {
  newest('newest'),
  priceAsc('price_asc'),
  priceDesc('price_desc');

  const ListingSort(this.api);
  final String api;
}

/// Điều kiện tìm kiếm `GET /listings`. So sánh theo giá trị để dùng làm khóa
/// family: đổi bất kỳ điều kiện nào là một danh sách mới (cursor bắt đầu lại).
class ListingQuery {
  const ListingQuery({
    this.q = '',
    this.categoryId,
    this.condition,
    this.minPrice,
    this.maxPrice,
    this.sort = ListingSort.newest,
  });

  final String q;
  final String? categoryId;
  final BookCondition? condition;
  final int? minPrice;
  final int? maxPrice;
  final ListingSort sort;

  /// Số bộ lọc đang bật (không tính từ khóa và danh mục), cho nhãn nút lọc.
  int get activeFilters =>
      (condition != null ? 1 : 0) +
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (sort != ListingSort.newest ? 1 : 0);

  bool get isSearching => q.trim().isNotEmpty;

  ListingQuery copyWith({
    String? q,
    String? Function()? categoryId,
    BookCondition? Function()? condition,
    int? Function()? minPrice,
    int? Function()? maxPrice,
    ListingSort? sort,
  }) => ListingQuery(
    q: q ?? this.q,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    condition: condition != null ? condition() : this.condition,
    minPrice: minPrice != null ? minPrice() : this.minPrice,
    maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
    sort: sort ?? this.sort,
  );

  Map<String, dynamic> toQuery({String? cursor, required int pageSize}) => {
    if (q.trim().isNotEmpty) 'q': q.trim(),
    'categoryId': ?categoryId,
    if (condition != null) 'condition': condition!.api,
    'minPrice': ?minPrice,
    'maxPrice': ?maxPrice,
    if (sort != ListingSort.newest) 'sort': sort.api,
    'pageSize': pageSize,
    'cursor': ?cursor,
  };

  @override
  bool operator ==(Object other) =>
      other is ListingQuery &&
      other.q.trim() == q.trim() &&
      other.categoryId == categoryId &&
      other.condition == condition &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.sort == sort;

  @override
  int get hashCode =>
      Object.hash(q.trim(), categoryId, condition, minPrice, maxPrice, sort);
}

/// Dữ liệu tạo/sửa tin (`POST`/`PATCH /listings`). `null` ở PATCH là không đổi;
/// chuỗi rỗng ở trường tùy chọn là xóa giá trị.
class ListingDraftInput {
  const ListingDraftInput({
    this.title,
    this.author,
    this.categoryId,
    this.condition,
    this.price,
    this.description,
    this.publisher,
    this.publishYear,
    this.isbn,
    this.defectNotes,
    this.kind,
    this.volumes,
  });

  /// Chỉ gửi khi tạo; server không cho đổi loại sau khi tạo.
  final ListingKind? kind;

  /// Số tập và tên tập của bộ sách (thay toàn bộ danh sách); `null` là không gửi.
  final List<VolumeDraft>? volumes;
  final String? title;
  final String? author;
  final String? categoryId;
  final BookCondition? condition;
  final int? price;
  final String? description;
  final String? publisher;
  final int? publishYear;
  final String? isbn;
  final String? defectNotes;

  Map<String, dynamic> toJson() => {
    'title': ?title?.trim(),
    'author': ?author?.trim(),
    'categoryId': ?categoryId,
    if (condition != null) 'condition': condition!.api,
    'price': ?price,
    'description': ?description?.trim(),
    'publisher': ?publisher?.trim(),
    'publishYear': ?publishYear,
    'isbn': ?isbn?.trim(),
    'defectNotes': ?defectNotes?.trim(),
    if (kind != null) 'kind': kind!.api,
    if (volumes != null) 'volumes': [for (final v in volumes!) v.toJson()],
  };
}

/// Một tập khi tạo/sửa bộ sách.
class VolumeDraft {
  const VolumeDraft({required this.volumeNo, this.title});

  final int volumeNo;
  final String? title;

  Map<String, dynamic> toJson() => {
    'volumeNo': volumeNo,
    if (title != null && title!.trim().isNotEmpty) 'title': title!.trim(),
  };
}
