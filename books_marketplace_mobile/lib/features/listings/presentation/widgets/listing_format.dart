import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/util/format.dart';
import '../../domain/listing.dart';
import '../../domain/listing_enums.dart';

/// Chuỗi giá cho thẻ và chi tiết: giá bán, hoặc "Từ {giá khởi điểm}" nếu đấu giá.
String? listingPriceText(
  Listing listing,
  AppLocalizations l,
  String localeName,
) {
  final price = listing.displayPrice;
  if (price == null || price == 0) return null;
  final formatted = formatVnd(price, localeName);
  return listing.saleMethod == SaleMethod.auction
      ? l.startingFrom(formatted)
      : formatted;
}
