import '../network/api_error.dart';
import 'app_localizations.dart';

/// Ánh xạ `error.code` sang chuỗi i18n. Không bao giờ hiển thị `error.message`.
extension ApiErrorL10n on ApiError {
  String localized(AppLocalizations l) {
    final wait = retryAfter;
    if (wait != null) {
      if (isTemporaryLock) {
        return l.errAccountLockedTemp((wait.inSeconds / 60).ceil());
      }
      if (code == ApiErrorCode.rateLimited) {
        return l.errRateLimitedIn(wait.inSeconds);
      }
    }
    return switch (code) {
      ApiErrorCode.validationFailed => l.errorValidation,
      ApiErrorCode.avatarInvalid => l.errorAvatarInvalid,
      ApiErrorCode.currentPasswordIncorrect => l.errorCurrentPasswordIncorrect,
      ApiErrorCode.passwordUnchanged => l.errorPasswordUnchanged,
      ApiErrorCode.unsupportedFile => l.errorAvatarUnsupported,
      ApiErrorCode.invalidRefreshToken ||
      ApiErrorCode.refreshTokenExpired ||
      ApiErrorCode.refreshTokenReused ||
      ApiErrorCode.unauthorized => l.errorSessionExpired,
      ApiErrorCode.phoneTaken => l.errPhoneTaken,
      ApiErrorCode.paymentGatewayUnavailable ||
      ApiErrorCode.paymentProviderUnknown => l.errPaymentUnavailable,
      ApiErrorCode.orderNotFound => l.errOrderNotFound,
      ApiErrorCode.orderOwnListing ||
      ApiErrorCode.cartOwnListing => l.errOwnListing,
      ApiErrorCode.cartFull => l.errCartFull,
      ApiErrorCode.complaintNotFound => l.errComplaintNotFound,
      ApiErrorCode.complaintAttachmentInvalid => l.errComplaintAttachment,
      ApiErrorCode.categoryInactive => l.errCategoryInactive,
      ApiErrorCode.listingPhotoInvalid => l.errListingPhoto,
      ApiErrorCode.listingIncomplete => l.errListingIncomplete,
      ApiErrorCode.listingConcurrentUpdate => l.errListingConcurrent,
      ApiErrorCode.idempotencyInProgress => l.errIdempotencyInProgress,
      ApiErrorCode.topupOutOfRange => l.errTopupRange,
      ApiErrorCode.topupNotFound ||
      ApiErrorCode.withdrawalNotFound => l.errNotFound,
      ApiErrorCode.bankAccountNotFound => l.errBankNotFound,
      ApiErrorCode.bankAccountLimit => l.errBankLimit,
      ApiErrorCode.bankAccountDuplicate => l.errBankDuplicate,
      ApiErrorCode.addressNotFound => l.errAddressNotFound,
      ApiErrorCode.deviceNotFound => l.errNotFound,
      ApiErrorCode.accountDeletionBlocked => l.errDeletionBlocked,
      ApiErrorCode.userRoleNotAllowed => l.errRoleNotAllowed,
      ApiErrorCode.invalidCredentials => l.errorInvalidCredentials,
      ApiErrorCode.userNotFound => l.errorUserNotFound,
      ApiErrorCode.internal => l.errorInternal,
      ApiErrorCode.emailTaken => l.errorEmailTaken,
      ApiErrorCode.accountDisabled => l.errorAccountDisabled,
      ApiErrorCode.listingImageInvalid => l.errorListingImageInvalid,
      ApiErrorCode.listingNotFound => l.errorListingNotFound,
      ApiErrorCode.listingInvalidState => l.errorListingInvalidState,
      ApiErrorCode.listingSubmissionLimit => l.errorSubmissionLimit,
      ApiErrorCode.listingAlreadyClaimed => l.errorAlreadyClaimed,
      ApiErrorCode.claimRequired => l.errorClaimRequired,
      ApiErrorCode.categoryNotFound => l.errorCategoryNotFound,
      ApiErrorCode.notificationNotFound => l.errorNotificationNotFound,
      ApiErrorCode.validationError => l.errorValidation,
      ApiErrorCode.unauthenticated => l.errorSessionExpired,
      ApiErrorCode.forbidden => l.errForbidden,
      ApiErrorCode.accountLocked => l.errAccountLocked,
      ApiErrorCode.notFound => l.errNotFound,
      ApiErrorCode.invalidState ||
      ApiErrorCode.idempotencyConflict => l.errInvalidState,
      ApiErrorCode.listingNotAvailable => l.errListingNotAvailable,
      ApiErrorCode.insufficientBalance => l.errInsufficientBalance,
      ApiErrorCode.otpInvalid => l.errOtpInvalid,
      ApiErrorCode.otpExpired => l.errOtpExpired,
      ApiErrorCode.auctionNotRegistered => l.errNotRegistered,
      ApiErrorCode.auctionRegistrationClosed => l.errRegistrationClosed,
      ApiErrorCode.auctionSellerCannotBid => l.errSellerCannotBid,
      ApiErrorCode.bidTooLow => l.errBidTooLow,
      ApiErrorCode.alreadyLeading => l.errAlreadyLeading,
      ApiErrorCode.auctionEnded => l.errAuctionEnded,
      ApiErrorCode.auctionNotLive => l.errAuctionNotLive,
      ApiErrorCode.buyNowUnavailable => l.errBuyNowUnavailable,
      ApiErrorCode.complaintWindowClosed => l.errComplaintWindowClosed,
      ApiErrorCode.withdrawBelowMinimum => l.errWithdrawBelowMin,
      ApiErrorCode.rateLimited => l.errRateLimited,
      ApiErrorCode.upstreamError ||
      ApiErrorCode.serviceUnavailable => l.errUpstream,
      ApiErrorCode.network => l.errorNetwork,
      ApiErrorCode.uploadFailed => l.errorUploadFailed,
      _ => message.isNotEmpty ? message : l.errorUnknown,
    };
  }

  /// Chỉ lỗi hệ thống mới kèm mã hỗ trợ để người dùng báo lại.
  String? supportCode(AppLocalizations l) =>
      code == ApiErrorCode.internal && traceId.isNotEmpty
      ? l.supportCode(traceId)
      : null;

  /// Thông điệp dưới từng ô nhập khi server trả `VALIDATION_FAILED`.
  Map<String, String> localizedFieldErrors(AppLocalizations l) => {
    for (final field in fieldErrors.keys) field: l.errorFieldInvalid,
  };
}
