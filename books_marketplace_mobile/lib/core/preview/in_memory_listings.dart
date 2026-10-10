import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../features/listings/data/listing_repository.dart';
import '../../features/listings/domain/listing.dart';
import '../../features/listings/domain/listing_enums.dart';
import '../../features/listings/domain/listing_query.dart';
import '../network/api_client.dart';
import '../network/api_error.dart';
import '../network/paged_result.dart';
import '../paging/cursor_notifier.dart';
import '../util/search.dart';

const previewCategoryNames = [
  'Văn học',
  'Lịch sử',
  'Thiếu nhi',
  'Khoa học',
  'Ngoại văn',
];

/// Id người bán của tin do chính người dùng tạo trong chế độ xem trước/test.
const previewMeId = 'me';

const _seed = [
  (
    'l1',
    'Nhà giả kim',
    'Paulo Coelho',
    'Văn học',
    BookCondition.good,
    45000,
    'Minh Thư',
    'NXB Hội Nhà Văn',
    2017,
    '9786045337563',
    'Gáy hơi cong nhẹ',
    'Bản dịch Lê Chu Cầu. Giấy còn trắng, không ghi chú, không mất trang.',
  ),
  (
    'l2',
    'Lược sử thời gian',
    'Stephen Hawking',
    'Khoa học',
    BookCondition.fair,
    62000,
    'Quang Huy',
    'NXB Trẻ',
    2015,
    '9786041074745',
    'Vài trang gạch chân bút chì',
    'Bản dịch Cao Chi, Phạm Văn Thiều. Bìa mềm, góc bìa sờn.',
  ),
  (
    'l3',
    'Hoàng tử bé (bìa cứng)',
    'Antoine de Saint-Exupéry',
    'Thiếu nhi',
    BookCondition.good,
    85000,
    'Thu Hà',
    'NXB Kim Đồng',
    2005,
    '',
    'Áo bìa rách nhỏ mép trên',
    'Bản bìa cứng in màu, minh họa gốc của tác giả.',
  ),
  (
    'l4',
    'Việt Nam sử lược',
    'Trần Trọng Kim',
    'Lịch sử',
    BookCondition.worn,
    120000,
    'Đức Anh',
    'NXB Văn hóa Thông tin',
    1999,
    '',
    'Ố vàng, bìa đã bọc lại',
    'Trọn bộ một cuốn, chữ rõ, không mất trang.',
  ),
  (
    'l5',
    'Norwegian Wood',
    'Haruki Murakami',
    'Ngoại văn',
    BookCondition.brandNew,
    150000,
    'Lan Chi',
    'Vintage',
    2003,
    '9780099448822',
    'Không',
    'Bản tiếng Anh, chưa đọc, còn seal.',
  ),
  (
    'l6',
    'Tôi thấy hoa vàng trên cỏ xanh',
    'Nguyễn Nhật Ánh',
    'Văn học',
    BookCondition.good,
    38000,
    'Minh Thư',
    'NXB Trẻ',
    2018,
    '9786041135637',
    'Không',
    'Bìa mềm, giấy tốt, không ghi chú.',
  ),
  (
    'l7',
    'Sapiens: Lược sử loài người',
    'Yuval Noah Harari',
    'Lịch sử',
    BookCondition.fair,
    95000,
    'Quang Huy',
    'NXB Tri Thức',
    2017,
    '9786047722350',
    'Bìa trầy nhẹ',
    'Bản dịch Nguyễn Thủy Chung.',
  ),
];

/// Tin đăng trong bộ nhớ, giữ các quy tắc của backend (`08-listings`): vòng đời
/// trạng thái, sửa tin đang bán, tối thiểu 4 ảnh, `PATCH` một phần, tìm kiếm
/// không dấu, phân trang cursor. Dùng cho chế độ xem trước và test.
class InMemoryListingRepository extends ListingRepository {
  InMemoryListingRepository({List<Listing>? seed, this.minPhotos = 4})
    : _items = [...?seed],
      super(ApiClient(Dio()));

  /// Tin công khai mẫu lấy từ prototype; không ảnh nên bìa vẽ theo tên sách.
  factory InMemoryListingRepository.preview() => InMemoryListingRepository(
    seed: [
      for (final s in _seed)
        Listing(
          id: s.$1,
          status: ListingStatus.published,
          seller: SellerInfo(id: 's-${s.$7}', name: s.$7),
          category: PersonRef(id: 'cat-${s.$4}', name: s.$4),
          bookInfo: BookInfo(
            title: s.$2,
            author: s.$3,
            condition: s.$5,
            publisher: s.$8,
            publicationYear: s.$9,
            isbn: s.$10.isEmpty ? null : s.$10,
            defectNotes: s.$11,
            description: s.$12,
          ),
          price: s.$6,
          publishedAt: DateTime.utc(
            2026,
            9,
            20,
          ).add(Duration(hours: _seed.indexOf(s))),
        ),
    ],
  );

  final int minPhotos;
  final List<Listing> _items;
  int _seq = 0;
  final calls = <String>[];

  /// Lỗi ném ra ở lần gọi kế tiếp của thao tác tên [op] (test lỗi).
  final Map<String, ApiError> failNext = {};

  List<Listing> get items => List.unmodifiable(_items);

  /// Thay toàn bộ dữ liệu (test dựng sẵn tình huống).
  void replaceAll(List<Listing> listings) {
    _items
      ..clear()
      ..addAll(listings);
  }

  /// Thêm hoặc thay một tin theo id.
  void upsert(Listing listing) {
    final i = _items.indexWhere((l) => l.id == listing.id);
    i < 0 ? _items.insert(0, listing) : _items[i] = listing;
  }

  void _maybeFail(String op) {
    final e = failNext.remove(op);
    if (e != null) throw e;
  }

  int _index(String id) {
    final i = _items.indexWhere((l) => l.id == id);
    if (i < 0) {
      throw const ApiError(status: 404, code: ApiErrorCode.listingNotFound);
    }
    return i;
  }

  Listing _mineOrThrow(String id) {
    final l = _items[_index(id)];
    if (l.seller?.id != previewMeId) {
      throw const ApiError(status: 404, code: ApiErrorCode.listingNotFound);
    }
    return l;
  }

  void _store(Listing l) => _items[_index(l.id)] = l;

  Listing _copy(
    Listing l, {
    ListingStatus? status,
    BookInfo? info,
    int? price,
    PersonRef? category,
    List<ListingPhoto>? photos,
    ListingReview? Function()? review,
    DateTime? publishedAt,
  }) => Listing(
    id: l.id,
    status: status ?? l.status,
    seller: l.seller,
    category: category ?? l.category,
    bookInfo: info ?? l.bookInfo,
    price: price ?? l.price,
    images: photos ?? l.images,
    coverUrl: l.coverUrl,
    submittedAt: l.submittedAt,
    publishedAt: publishedAt ?? l.publishedAt,
    createdAt: l.createdAt,
    updatedAt: DateTime.now().toUtc(),
    lastReview: review != null ? review() : l.lastReview,
  );

  // ── Tìm kiếm ────────────────────────────────────────────────────────────

  @override
  Future<CursorPage<Listing>> search(
    ListingQuery query, {
    String? cursor,
    int pageSize = 20,
  }) async {
    calls.add('search:${query.q}|${query.categoryId}|${query.sort.api}');
    final terms = normalizeSearch(query.q)
        .split(' ')
        .where((t) => t.isNotEmpty)
        .toList();
    var list = [
      for (final l in _items)
        if (l.status == ListingStatus.published &&
            (query.categoryId == null || l.category?.id == query.categoryId) &&
            (query.condition == null ||
                l.bookInfo.condition == query.condition) &&
            (query.minPrice == null || (l.price ?? 0) >= query.minPrice!) &&
            (query.maxPrice == null || (l.price ?? 0) <= query.maxPrice!) &&
            terms.every(
              normalizeSearch(
                '${l.title} ${l.bookInfo.author ?? ''} ${l.bookInfo.isbn ?? ''}',
              ).contains,
            ))
          l,
    ];
    switch (query.sort) {
      case ListingSort.priceAsc:
        list.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
      case ListingSort.priceDesc:
        list.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
      case ListingSort.newest:
        list.sort(
          (a, b) => (b.publishedAt ?? DateTime(0)).compareTo(
            a.publishedAt ?? DateTime(0),
          ),
        );
    }
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + pageSize).clamp(0, list.length);
    return CursorPage(
      items: list.sublist(start.clamp(0, list.length), end),
      hasNext: end < list.length,
      nextCursor: end < list.length ? '$end' : null,
    );
  }

  @override
  Future<Listing> get(String id) async {
    calls.add('get:$id');
    _maybeFail('get');
    final l = _items[_index(id)];
    if (!l.status.isPublic && l.seller?.id != previewMeId) {
      throw const ApiError(status: 404, code: ApiErrorCode.listingNotFound);
    }
    return l;
  }

  // ── Tạo, sửa ────────────────────────────────────────────────────────────

  PersonRef? _category(String? id) => id == null
      ? null
      : PersonRef(id: id, name: id.startsWith('cat-') ? id.substring(4) : id);

  @override
  Future<Listing> create(ListingDraftInput input) async {
    calls.add('create');
    _maybeFail('create');
    final l = Listing(
      id: 'mine-${++_seq}',
      status: ListingStatus.draft,
      seller: const SellerInfo(id: previewMeId, name: 'Nguyễn Minh Anh'),
      category: _category(input.categoryId),
      bookInfo: BookInfo(
        title: input.title,
        author: input.author,
        condition: input.condition,
        description: input.description,
        publisher: input.publisher,
        publicationYear: input.publishYear,
        isbn: input.isbn,
        defectNotes: input.defectNotes,
      ),
      price: input.price,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    _items.insert(0, l);
    return l;
  }

  String? _clear(String? v) => v == null || v.isEmpty ? null : v;

  @override
  Future<Listing> update(String id, ListingDraftInput input) async {
    calls.add('update:$id');
    _maybeFail('update');
    final l = _mineOrThrow(id);
    if (!l.status.isEditable) {
      throw ApiError(
        status: 409,
        code: ApiErrorCode.invalidState,
        fieldErrors: {'current_status': l.status.api},
      );
    }
    final b = l.bookInfo;
    final info = BookInfo(
      title: input.title ?? b.title,
      author: input.author ?? b.author,
      condition: input.condition ?? b.condition,
      description: input.description ?? b.description,
      publisher: input.publisher != null
          ? _clear(input.publisher)
          : b.publisher,
      publicationYear: input.publishYear ?? b.publicationYear,
      isbn: input.isbn != null ? _clear(input.isbn) : b.isbn,
      defectNotes: input.defectNotes != null
          ? _clear(input.defectNotes)
          : b.defectNotes,
    );
    // Tin đang bán: chỉ đổi giá/mô tả thì giữ nguyên, đổi phần khác về chờ duyệt.
    var status = l.status;
    if (status == ListingStatus.published) {
      final mainChanged =
          info.title != b.title ||
          info.author != b.author ||
          info.condition != b.condition ||
          info.publisher != b.publisher ||
          info.publicationYear != b.publicationYear ||
          info.isbn != b.isbn ||
          info.defectNotes != b.defectNotes ||
          (input.categoryId != null && input.categoryId != l.category?.id);
      if (mainChanged) status = ListingStatus.pendingReview;
    }
    final updated = _copy(
      l,
      status: status,
      info: info,
      price: input.price,
      category: input.categoryId != null ? _category(input.categoryId) : null,
    );
    _store(updated);
    return updated;
  }

  // ── Ảnh ─────────────────────────────────────────────────────────────────

  @override
  Future<List<String>> uploadPhotos(String id, List<NewPhoto> photos) async {
    calls.add('upload:$id:${photos.length}');
    _maybeFail('upload');
    _mineOrThrow(id);
    return [for (final _ in photos) 'me/${++_seq}.jpg'];
  }

  @override
  Future<List<ListingPhoto>> setPhotos(
    String id,
    List<String> blobNames,
  ) async {
    calls.add('photos:$id:${blobNames.length}');
    _maybeFail('photos');
    final l = _mineOrThrow(id);
    if (!l.status.isEditable) {
      throw ApiError(
        status: 409,
        code: ApiErrorCode.invalidState,
        fieldErrors: {'current_status': l.status.api},
      );
    }
    final photos = [
      for (var i = 0; i < blobNames.length; i++)
        ListingPhoto(
          id: 'p$i-${blobNames[i]}',
          url: 'http://blob/public/${blobNames[i]}',
          thumbnailUrl: 'http://blob/public/${blobNames[i]}-thumb',
          order: i,
        ),
    ];
    var status = l.status;
    if (status == ListingStatus.published) status = ListingStatus.pendingReview;
    _store(_copy(l, status: status, photos: photos));
    return photos;
  }

  // ── Duyệt, gỡ ───────────────────────────────────────────────────────────

  @override
  Future<Listing> submit(String id) async {
    calls.add('submit:$id');
    _maybeFail('submit');
    final l = _mineOrThrow(id);
    if (!l.status.canSubmit) {
      throw ApiError(
        status: 409,
        code: ApiErrorCode.invalidState,
        fieldErrors: {'current_status': l.status.api},
      );
    }
    if (l.images.length < minPhotos) {
      throw ApiError(
        status: 422,
        code: ApiErrorCode.listingIncomplete,
        fieldErrors: {
          'photos':
              'Cần tối thiểu $minPhotos ảnh (hiện có ${l.images.length}).',
        },
      );
    }
    final updated = _copy(l, status: ListingStatus.pendingReview);
    _store(updated);
    return updated;
  }

  @override
  Future<Listing> unpublish(String id) async {
    calls.add('unpublish:$id');
    _maybeFail('unpublish');
    final l = _mineOrThrow(id);
    if (!l.status.canUnpublish) {
      throw ApiError(
        status: 409,
        code: ApiErrorCode.invalidState,
        fieldErrors: {'current_status': l.status.api},
      );
    }
    final updated = _copy(l, status: ListingStatus.unpublished);
    _store(updated);
    return updated;
  }

  /// Giả lập admin ra quyết định (test).
  void adminDecide(String id, String decision, {String? reason}) {
    final l = _items[_index(id)];
    final (status, publishedAt) = switch (decision) {
      'APPROVE' => (ListingStatus.published, DateTime.now().toUtc()),
      'REQUEST_CHANGES' => (ListingStatus.needsChanges, null),
      _ => (ListingStatus.rejected, null),
    };
    _store(
      _copy(
        l,
        status: status,
        publishedAt: publishedAt,
        review: () => ListingReview(decision: decision, reason: reason),
      ),
    );
  }

  @override
  Future<PagedResult<Listing>> mine({
    ListingStatus? status,
    required int page,
    required int pageSize,
  }) async {
    calls.add('mine:${status?.api}');
    final all =
        [
          for (final l in _items)
            if (l.seller?.id == previewMeId &&
                (status == null || l.status == status))
              l,
        ]..sort(
          (a, b) => (b.updatedAt ?? DateTime(0)).compareTo(
            a.updatedAt ?? DateTime(0),
          ),
        );
    final from = (page - 1) * pageSize;
    return PagedResult(
      items: all.skip(from).take(pageSize).toList(),
      page: page,
      pageSize: pageSize,
      totalCount: all.length,
    );
  }
}

/// Ảnh giả dùng khi cần byte hợp lệ trong test.
final tinyPhoto = NewPhoto(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'a.jpg',
  contentType: 'image/jpeg',
);
