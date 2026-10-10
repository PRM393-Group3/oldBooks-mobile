import 'package:flutter/material.dart';

import '../../../core/l10n/api_error_l10n.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../wallet/presentation/topup_sheet.dart';

/// Lỗi cần tải lại phiên/đơn rồi cập nhật giao diện.
const _reloadCodes = {
  ApiErrorCode.auctionEnded,
  ApiErrorCode.invalidState,
  ApiErrorCode.auctionAlreadyRegistered,
  ApiErrorCode.buyNowUnavailable,
  ApiErrorCode.alreadyLeading,
  ApiErrorCode.auctionNotRegistered,
  ApiErrorCode.auctionNotLive,
  ApiErrorCode.auctionSellerCannotBid,
  ApiErrorCode.auctionOwn,
  ApiErrorCode.auctionRegistrationClosed,
  ApiErrorCode.auctionRegistrationNotFound,
  ApiErrorCode.auctionOrderExtensionLimit,
};

/// Phần còn thiếu trong ví của lỗi `INSUFFICIENT_BALANCE` (`required -
/// available`), hoặc `null` nếu server không gửi đủ.
int? missingAmount(ApiError e) {
  final required = e.detailAmount('required');
  final available = e.detailAmount('available');
  if (required == null || available == null) return null;
  final missing = required - available;
  return missing > 0 ? missing : null;
}

/// Xử lý lỗi của các thao tác đấu giá và đơn đấu giá theo `error.code`.
///
/// - `INSUFFICIENT_BALANCE`: mở nạp ví đúng phần thiếu; trả `true` nếu người
///   dùng đã đóng sheet nạp (để nơi gọi có thể thử lại).
/// - `BID_TOO_LOW`: đưa `details.min_amount` cho [onMinAmount].
/// - `RATE_LIMITED`: báo thời gian chờ cho [onRateLimited].
/// - Lỗi trạng thái: gọi [onReload].
Future<bool> handleAuctionError(
  BuildContext context,
  Object error, {
  VoidCallback? onReload,
  ValueChanged<int>? onMinAmount,
  ValueChanged<Duration>? onRateLimited,
}) async {
  if (error is! ApiError) {
    AppSnackbar.apiError(context, error);
    return false;
  }
  final l = context.l10n;
  final locale = Localizations.localeOf(context).toString();
  switch (error.code) {
    case ApiErrorCode.insufficientBalance:
      final missing = missingAmount(error);
      AppSnackbar.show(
        context,
        missing == null
            ? l.errInsufficientBalance
            : l.aucNeedTopup(formatVnd(missing, locale)),
        type: AppSnackbarType.error,
      );
      await showWalletTopupSheet(context, initialAmount: missing);
      return true;
    case ApiErrorCode.bidTooLow:
      final min = error.detailAmount('min_amount');
      if (min != null) onMinAmount?.call(min);
      AppSnackbar.show(
        context,
        min == null
            ? l.errBidTooLow
            : l.aucErrTooLowMin(formatVnd(min, locale)),
        type: AppSnackbarType.error,
      );
      return false;
    case ApiErrorCode.alreadyLeading:
      AppSnackbar.show(context, l.aucLeaderMe);
      onReload?.call();
      return false;
    case ApiErrorCode.rateLimited:
      onRateLimited?.call(error.retryAfter ?? const Duration(seconds: 1));
      AppSnackbar.show(
        context,
        error.localized(l),
        type: AppSnackbarType.error,
      );
      return false;
  }
  if (!context.mounted) return false;
  AppSnackbar.apiError(context, error);
  if (_reloadCodes.contains(error.code)) onReload?.call();
  return false;
}
