import '../../listings/domain/listing.dart';

/// Một món trong giỏ: bản chụp những gì giỏ cần hiển thị, lấy từ tin đăng thật.
class CartItem {
  const CartItem({
    required this.listingId,
    required this.title,
    required this.price,
    this.author,
    this.coverUrl,
    this.sellerName,
  });

  /// Chỉ gọi với tin bán giá cố định (đã kiểm tra `fixedPrice != null`).
  factory CartItem.fromListing(Listing listing) => CartItem(
    listingId: listing.id,
    title: listing.title,
    author: listing.bookInfo.author,
    price: listing.fixedPrice?.price ?? 0,
    coverUrl: listing.coverImageUrl,
    sellerName: listing.seller?.name,
  );

  final String listingId;
  final String title;
  final String? author;
  final int price;
  final String? coverUrl;
  final String? sellerName;
}
