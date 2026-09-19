import '../../../core/network/api_client.dart';
import '../../../core/network/paged_result.dart';
import '../../listings/domain/listing.dart';
import '../domain/inspection.dart';

class InspectionRepository {
  InspectionRepository(this._api);
  final ApiClient _api;

  Future<PagedResult<QueueItem>> queue({
    QueueFilter filter = const QueueFilter(),
    required int page,
    required int pageSize,
  }) => _api.get(
    '/inspections/queue',
    query: {
      'categoryId': ?filter.categoryId,
      'priceFrom': ?filter.priceFrom,
      'priceTo': ?filter.priceTo,
      'page': page,
      'pageSize': pageSize,
    },
    parse: (d) => PagedResult.fromJson(
      d,
      QueueItem.fromJson,
      page: page,
      pageSize: pageSize,
    ),
  );

  /// Tin đang giữ khóa, kèm `claimExpiresAt`.
  Future<List<QueueItem>> mine() => _api.get(
    '/inspections/mine',
    parse: (data) {
      final list = data is List
          ? data
          : (data is Map ? (data['items'] as List? ?? const []) : const []);
      return list.map(QueueItem.fromJson).toList();
    },
  );

  /// Nhận tin: trả `ListingDto` đầy đủ. Gọi lại khi đang giữ khóa vẫn 200 và
  /// không gia hạn.
  Future<Listing> claim(String listingId) =>
      _api.post('/inspections/$listingId/claim', parse: Listing.fromJson);

  Future<void> release(String listingId) =>
      _api.postNoContent('/inspections/$listingId/release');

  Future<InspectionSummary> approve(String listingId, {String? note}) =>
      _api.post(
        '/inspections/$listingId/approve',
        body: {if (note != null && note.trim().isNotEmpty) 'note': note.trim()},
        parse: InspectionSummary.fromJson,
      );

  Future<InspectionSummary> reject(
    String listingId, {
    required List<RejectReason> reasons,
    required String note,
  }) => _api.post(
    '/inspections/$listingId/reject',
    body: {
      'reasonCodes': [for (final r in reasons) r.api],
      'note': note.trim(),
    },
    parse: InspectionSummary.fromJson,
  );
}
