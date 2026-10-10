import '../../../core/util/json_read.dart';

/// Một nút trong cây danh mục (tối đa 3 cấp).
class CategoryNode {
  const CategoryNode({
    required this.id,
    required this.name,
    this.children = const [],
    this.isActive = true,
  });

  factory CategoryNode.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return CategoryNode(
      id: readString(j, 'id') ?? '',
      name: readString(j, 'name') ?? '',
      isActive: readBool(j, 'isActive') ?? true,
      children: readList(j, 'children').map(CategoryNode.fromJson).toList(),
    );
  }

  final String id;
  final String name;
  final bool isActive;
  final List<CategoryNode> children;

  /// Tìm nút theo id trong cả cây; `null` nếu không có.
  static CategoryNode? find(List<CategoryNode> tree, String? id) {
    if (id == null) return null;
    for (final n in tree) {
      if (n.id == id) return n;
      final inChild = find(n.children, id);
      if (inChild != null) return inChild;
    }
    return null;
  }
}
