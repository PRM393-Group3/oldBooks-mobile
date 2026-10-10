import '../../../core/network/api_client.dart';
import '../domain/category.dart';

class CategoryRepository {
  CategoryRepository(this._api);
  final ApiClient _api;

  /// Cây danh mục đang hoạt động (`children` lồng nhau).
  Future<List<CategoryNode>> tree() => _api.get(
    '/categories',
    parse: (data) {
      final list = data is List
          ? data
          : (data is Map ? (data['items'] as List? ?? const []) : const []);
      return list.map(CategoryNode.fromJson).toList();
    },
  );
}
