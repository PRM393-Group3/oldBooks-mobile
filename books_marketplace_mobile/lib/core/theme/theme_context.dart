import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'app_colors.dart';

/// Lối tắt để widget đọc màu, chữ và chuỗi i18n từ `BuildContext`.
extension AppContextX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
  AppLocalizations get l10n => AppLocalizations.of(this);
}
