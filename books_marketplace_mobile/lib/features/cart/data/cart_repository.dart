import '../domain/cart_item.dart';

/// Giỏ hàng. Hiện chỉ có bản mock trong bộ nhớ; khi backend có API giỏ thì
/// thêm một bản gọi mạng mà không phải sửa UI.
abstract class CartRepository {
  List<CartItem> get items;

  /// `false` nếu sách đã có trong giỏ (mỗi tin chỉ một cuốn).
  bool add(CartItem item);

  void remove(String listingId);

  void clear();
}

class MockCartRepository implements CartRepository {
  final List<CartItem> _items = [];

  @override
  List<CartItem> get items => List.unmodifiable(_items);

  @override
  bool add(CartItem item) {
    if (_items.any((i) => i.listingId == item.listingId)) return false;
    _items.add(item);
    return true;
  }

  @override
  void remove(String listingId) =>
      _items.removeWhere((i) => i.listingId == listingId);

  @override
  void clear() => _items.clear();
}
