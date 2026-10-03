import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/util/format.dart';
import '../../domain/listing.dart';

/// Chuỗi giá cho thẻ và chi tiết (tin bán giá cố định).
String? listingPriceText(
  Listing listing,
  AppLocalizations l,
  String localeName,
) {
  final price = listing.displayPrice;
  if (price == null || price == 0) return null;
  final formatted = formatVnd(price, localeName);
  return formatted;
}
