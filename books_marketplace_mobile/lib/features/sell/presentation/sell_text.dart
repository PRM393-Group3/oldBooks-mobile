import '../../../core/l10n/app_localizations.dart';
import '../../../core/util/format.dart';
import '../domain/sell_rules.dart';

String sellConditionLabel(AppLocalizations l, SellCondition c) =>
    c.condition.label(l);

String sellErrorText(
  AppLocalizations l,
  String locale,
  SellError e,
  SellForm f, {
  SellRules rules = SellRules.defaults,
}) => switch (e) {
  SellError.photos => f.isSet ? l.sellErrSetPhotos : l.sellErrPhotos(f.photos),
  SellError.title => l.sellErrTitle,
  SellError.author => l.sellErrAuthor,
  SellError.price => l.sellErrPrice,
  SellError.startingPrice => l.sellErrStart,
  SellError.step => l.sellErrStep(
    formatVnd(rules.stepRange(f.startingPrice).lo, locale),
    formatVnd(rules.stepRange(f.startingPrice).hi, locale),
  ),
  SellError.buyNow => l.sellErrBuyNow(
    formatVnd(rules.minBuyNow(f.startingPrice), locale),
  ),
  SellError.description => l.sellErrDesc,
  SellError.category => l.sellErrCategory,
  SellError.isbn => l.sellErrIsbn,
  SellError.year => l.sellErrIsbn,
  SellError.volumes => l.sellErrVolumes(
    rules.setMinVolumes,
    rules.setMaxVolumes,
  ),
  SellError.volumePhotos => l.sellErrVolumePhotos,
};
