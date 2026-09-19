// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Book Marketplace';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Loading';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get homePlaceholderTitle => 'Coming soon';

  @override
  String get homePlaceholderMessage =>
      'The home screen will arrive in a later version.';

  @override
  String get loginTitle => 'Log in';

  @override
  String get loginSubtitle => 'Welcome back to the used-book marketplace.';

  @override
  String get loginButton => 'Log in';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get registerLink => 'Sign up';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle =>
      'It takes a minute to start buying and selling used books.';

  @override
  String get registerButton => 'Sign up';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get loginLink => 'Log in';

  @override
  String get roleLabel => 'I want to';

  @override
  String get roleOptionBuyer => 'Buy books';

  @override
  String get roleOptionSeller => 'Sell books';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmMessage =>
      'You will need to log in again to keep using the app.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changeAvatar => 'Change profile photo';

  @override
  String get changePassword => 'Change password';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageVi => 'Tiếng Việt';

  @override
  String get languageEn => 'English';

  @override
  String get phoneNotSet => 'Not set';

  @override
  String get memberSince => 'Member since';

  @override
  String get roleBuyer => 'Buyer';

  @override
  String get roleSeller => 'Seller';

  @override
  String get roleInspector => 'Inspector';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleUnknown => 'User';

  @override
  String get emailReadOnlyHelper =>
      'Your email is used to log in, so it can\'t be changed.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get avatarPreviewLabel => 'Profile photo';

  @override
  String get avatarHint => 'JPG, PNG or WebP, up to 5 MB.';

  @override
  String get chooseFromGallery => 'Choose from library';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get saveAvatar => 'Save photo';

  @override
  String get removeAvatar => 'Remove profile photo';

  @override
  String get removeAvatarConfirmTitle => 'Remove profile photo?';

  @override
  String get removeAvatarConfirmMessage =>
      'Your photo will be replaced by your initials.';

  @override
  String get avatarUpdated => 'Profile photo updated';

  @override
  String get avatarRemoved => 'Profile photo removed';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm new password';

  @override
  String get passwordLengthHelper => '8 to 72 characters.';

  @override
  String get passwordRuleHelper =>
      '8 to 72 characters and different from your current password.';

  @override
  String get passwordChangedOtherDevices => 'Other devices will be logged out.';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String changePasswordLocked(int seconds) {
    return 'Try again in $seconds s';
  }

  @override
  String get validationFullNameRequired => 'Please enter your full name.';

  @override
  String get validationFullNameTooLong =>
      'Full name can be at most 100 characters.';

  @override
  String get validationPhoneInvalid =>
      'Phone number must start with 0 or +84, followed by 9 or 10 digits.';

  @override
  String get validationEmailRequired => 'Please enter your email.';

  @override
  String get validationEmailInvalid => 'That email doesn\'t look right.';

  @override
  String get validationPasswordRequired => 'Please enter your password.';

  @override
  String get validationPasswordLength => 'Password must be 8 to 72 characters.';

  @override
  String get validationPasswordSame =>
      'New password must differ from the current one.';

  @override
  String get validationPasswordMismatch => 'The passwords don\'t match.';

  @override
  String get errorNetwork => 'No connection. Check your network and try again.';

  @override
  String get errorValidation =>
      'Some details aren\'t valid. Please review the fields above.';

  @override
  String get errorFieldInvalid => 'This value isn\'t valid.';

  @override
  String get errorAvatarInvalid =>
      'The photo is invalid or larger than 5 MB. Please choose another one.';

  @override
  String get errorAvatarUnsupported =>
      'Only JPG, PNG or WebP photos are supported. Please choose another one.';

  @override
  String get errorAvatarTooLarge =>
      'The photo is larger than 5 MB. Please choose a smaller one.';

  @override
  String get errorPickImage =>
      'Couldn\'t open the photo. Check app permissions and try again.';

  @override
  String get errorUploadFailed => 'Photo upload failed. Please try again.';

  @override
  String get errorCurrentPasswordIncorrect =>
      'The current password is incorrect.';

  @override
  String get errorPasswordUnchanged =>
      'New password must differ from the old one.';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String get errorUserNotFound => 'This account no longer exists.';

  @override
  String get errorInternal =>
      'Something went wrong on our side. Please try again in a few minutes.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String supportCode(String traceId) {
    return 'Support code: $traceId';
  }

  @override
  String get navMyListings => 'My listings';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navQueue => 'Queue';

  @override
  String get navClaimed => 'Claimed';

  @override
  String get sellAction => 'Sell';

  @override
  String get adminWebNote => 'Administration is available on the web portal.';

  @override
  String get loadMoreFailed => 'Couldn\'t load more. Tap to retry.';

  @override
  String get optionalHint => 'Optional';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get comingSoon => 'Buying and bidding will arrive in a later version.';

  @override
  String get emptyBrowseTitle => 'No books yet';

  @override
  String get emptyBrowseMessage => 'Inspected books will appear here.';

  @override
  String get emptyMineTitle => 'You have no listings yet';

  @override
  String get emptyMineMessage => 'Tap Sell to create your first listing.';

  @override
  String get emptyQueueTitle => 'The queue is empty';

  @override
  String get emptyQueueMessage => 'No listings are waiting for inspection.';

  @override
  String get emptyClaimedTitle => 'You aren\'t holding any listings';

  @override
  String get emptyClaimedMessage =>
      'Claim a listing from the queue to start inspecting.';

  @override
  String get emptyNotificationsTitle => 'No notifications yet';

  @override
  String get emptyNotificationsMessage =>
      'Inspection results will appear here.';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusPendingInspection => 'Pending inspection';

  @override
  String get statusInInspection => 'In inspection';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusOnSale => 'On sale';

  @override
  String get statusAuctioning => 'Auctioning';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get filterAll => 'All';

  @override
  String get categoryAll => 'All categories';

  @override
  String get conditionLikeNew => 'Like new';

  @override
  String get conditionLikeNewDesc => 'Almost unused, no sign of reading.';

  @override
  String get conditionVeryGood => 'Very good';

  @override
  String get conditionVeryGoodDesc => 'Very light wear, no tears or notes.';

  @override
  String get conditionGood => 'Good';

  @override
  String get conditionGoodDesc => 'Light wear, content intact.';

  @override
  String get conditionFair => 'Fair';

  @override
  String get conditionFairDesc =>
      'Stains, folded corners or notes, but fully readable.';

  @override
  String get conditionPoor => 'Heavily used';

  @override
  String get conditionPoorDesc => 'Clearly worn but content is complete.';

  @override
  String get coverPaperback => 'Paperback';

  @override
  String get coverHardcover => 'Hardcover';

  @override
  String get imageFrontCover => 'Front cover';

  @override
  String get imageBackCover => 'Back cover';

  @override
  String get imageSpine => 'Spine';

  @override
  String get imageInnerPage => 'Inner page';

  @override
  String get imageExtra => 'Extra photo';

  @override
  String get saleFixedPrice => 'Fixed price';

  @override
  String get saleAuction => 'Auction';

  @override
  String get startOnApproval => 'As soon as approved';

  @override
  String get startScheduled => 'Scheduled';

  @override
  String get reasonBlurryPhotos => 'Photos missing or blurry';

  @override
  String get reasonDescriptionMismatch => 'Description doesn\'t match the book';

  @override
  String get reasonSuspectedPirated => 'Suspected pirated copy';

  @override
  String get reasonProhibitedPublication => 'Prohibited publication';

  @override
  String get reasonDamageBeyondThreshold => 'Damage beyond the accepted level';

  @override
  String get reasonWrongCatalogInfo => 'Incorrect catalog information';

  @override
  String get reasonDuplicateListing => 'Duplicate listing';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get unreadOnly => 'Unread';

  @override
  String get notifListingApproved => 'Your listing was approved';

  @override
  String get notifListingRejected => 'Your listing was rejected';

  @override
  String get notifListingClosed => 'Your listing was closed';

  @override
  String get wizardTitleNew => 'Sell a book';

  @override
  String get wizardTitleEdit => 'Edit listing';

  @override
  String get wizardStepBook => 'Book info';

  @override
  String get wizardStepPhotos => 'Photos';

  @override
  String get wizardStepSale => 'Sale method';

  @override
  String get wizardStepReview => 'Review';

  @override
  String wizardStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get submitForInspection => 'Submit for inspection';

  @override
  String get draftSavedHint => 'Your draft is saved after each step.';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldAuthor => 'Author';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldPublisher => 'Publisher';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldYear => 'Publication year';

  @override
  String get fieldLanguage => 'Language (2-letter code)';

  @override
  String get fieldLanguageHelper => 'For example: vi, en';

  @override
  String get fieldPages => 'Pages';

  @override
  String get fieldCover => 'Cover type';

  @override
  String get fieldCondition => 'Book condition';

  @override
  String get fieldConditionHelper =>
      'Pick the closest level. An inspector will confirm it.';

  @override
  String get fieldDescription => 'Description';

  @override
  String fieldDescriptionHelper(int min, int count) {
    return 'At least $min characters ($count/$min)';
  }

  @override
  String get fieldDefects => 'Defect notes';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get categoryPickerTitle => 'Choose a category';

  @override
  String validationFieldRequired(String field) {
    return 'Please enter $field.';
  }

  @override
  String get validationChooseCategory => 'Please choose a category.';

  @override
  String get validationChooseCondition => 'Please choose the book condition.';

  @override
  String get validationIsbn => 'Invalid ISBN (ISBN-10 or ISBN-13).';

  @override
  String validationYearRange(int min, int max) {
    return 'Year must be between $min and $max.';
  }

  @override
  String get validationPagesRange => 'Pages must be between 1 and 10000.';

  @override
  String get validationLanguage => 'Enter a 2-letter code, for example vi.';

  @override
  String validationDescriptionMin(int min) {
    return 'Description needs at least $min characters.';
  }

  @override
  String validationTooLong(int max) {
    return 'At most $max characters.';
  }

  @override
  String photosHint(int min, int max) {
    return 'You need $min to $max photos covering 4 angles: front cover, back cover, spine and an inner page.';
  }

  @override
  String get photosRequired => 'Required';

  @override
  String photosExtraTitle(int count, int max) {
    return 'Extra photos ($count/$max)';
  }

  @override
  String get addPhoto => 'Add photo';

  @override
  String get photoUploading => 'Uploading photo';

  @override
  String get photoFailed => 'Photo upload failed';

  @override
  String get photoRetry => 'Retry';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get photosWaiting => 'Photos are still uploading, please wait.';

  @override
  String get photosMissing => 'Some required photos are missing.';

  @override
  String photoSlotLabel(String angle) {
    return '$angle, required photo';
  }

  @override
  String get photoSlotEmpty => 'No photo yet';

  @override
  String get saleMethodLabel => 'Sale method';

  @override
  String get fieldPrice => 'Price (₫)';

  @override
  String get fieldQuantity => 'Quantity';

  @override
  String get fieldStartingPrice => 'Starting price (₫)';

  @override
  String get fieldMinIncrement => 'Minimum bid increment (₫)';

  @override
  String minIncrementHelper(String amount) {
    return 'At least $amount';
  }

  @override
  String get fieldDuration => 'Auction length';

  @override
  String durationDays(int days) {
    return '$days days';
  }

  @override
  String get fieldStartMode => 'Start';

  @override
  String get fieldScheduledAt => 'Start time';

  @override
  String get pickDateTime => 'Pick date and time';

  @override
  String validationPriceRange(String min, String max) {
    return 'Price must be between $min and $max.';
  }

  @override
  String validationQuantityRange(int min, int max) {
    return 'Quantity must be between $min and $max.';
  }

  @override
  String validationMinIncrement(String amount) {
    return 'Minimum increment is $amount.';
  }

  @override
  String get validationScheduleRequired => 'Please pick a start time.';

  @override
  String get validationScheduleFuture =>
      'The start time must be in the future.';

  @override
  String get changeMethodTitle => 'Change sale method?';

  @override
  String get changeMethodMessage =>
      'The other method\'s settings are removed when you save.';

  @override
  String get reviewBookSection => 'Book info';

  @override
  String get reviewPhotosSection => 'Photos';

  @override
  String get reviewSaleSection => 'Sale method';

  @override
  String get submitSuccessTitle => 'Submitted for inspection';

  @override
  String submitSuccessMessage(int hours) {
    return 'Expected within $hours hours. You will be notified with the result.';
  }

  @override
  String get incompleteTitle => 'Listing is incomplete';

  @override
  String get incompleteMessage =>
      'Please complete the items below, then submit again.';

  @override
  String get goToStep => 'Go to this step';

  @override
  String get missingImages => 'Photos (all 4 angles)';

  @override
  String get missingSaleMethod => 'Sale method';

  @override
  String get missingPrice => 'Price';

  @override
  String get missingStartingPrice => 'Starting price';

  @override
  String get missingCategory => 'Category';

  @override
  String get myListingsTitle => 'My listings';

  @override
  String get continueDraft => 'Continue editing';

  @override
  String get deleteListing => 'Delete listing';

  @override
  String get deleteListingTitle => 'Delete this listing?';

  @override
  String get deleteListingMessage =>
      'The listing will be closed and can\'t be restored.';

  @override
  String get listingDeleted => 'Listing deleted';

  @override
  String get editAndResubmit => 'Edit and resubmit';

  @override
  String get closeListing => 'Close listing';

  @override
  String resubmitsLeft(int count) {
    return '$count resubmissions left';
  }

  @override
  String get noResubmitsLeft => 'No resubmissions left';

  @override
  String estimatedProcessing(int hours) {
    return 'Expected within $hours hours';
  }

  @override
  String get rejectedTitle => 'Listing rejected';

  @override
  String get closedTitle => 'Listing closed';

  @override
  String get reasonsLabel => 'Reasons';

  @override
  String get inspectorNote => 'Inspector\'s note';

  @override
  String get inspectionResult => 'Inspection result';

  @override
  String get inspectionApproved => 'Approved';

  @override
  String get inspectionRejected => 'Rejected';

  @override
  String inspectedOn(String date) {
    return 'Inspected on $date';
  }

  @override
  String get sellerSection => 'Seller';

  @override
  String get bookDetails => 'Book details';

  @override
  String get detailAuthor => 'Author';

  @override
  String get detailPublisher => 'Publisher';

  @override
  String get detailYear => 'Year';

  @override
  String get detailLanguage => 'Language';

  @override
  String get detailPages => 'Pages';

  @override
  String get detailCover => 'Cover';

  @override
  String get detailCondition => 'Condition';

  @override
  String get detailCategory => 'Category';

  @override
  String get detailQuantity => 'Quantity';

  @override
  String get auctionSection => 'Auction details';

  @override
  String get startingPriceLabel => 'Starting price';

  @override
  String get minIncrementLabel => 'Minimum increment';

  @override
  String get auctionStarts => 'Starts';

  @override
  String get auctionEnds => 'Ends';

  @override
  String get auctionDuration => 'Length';

  @override
  String startingFrom(String price) {
    return 'From $price';
  }

  @override
  String listingPhotoLabel(String angle, String title) {
    return '$angle of $title';
  }

  @override
  String get description => 'Description';

  @override
  String get defectNotesTitle => 'Defects';

  @override
  String submissionOf(int n, int max) {
    return 'Submission $n of $max';
  }

  @override
  String get queueTitle => 'Inspection queue';

  @override
  String get claimedTitle => 'Claimed listings';

  @override
  String get overdueTag => 'Overdue';

  @override
  String waitingHours(int hours) {
    return 'Waiting $hours h';
  }

  @override
  String get filterButton => 'Filters';

  @override
  String get filterTitle => 'Filter queue';

  @override
  String get priceFrom => 'Price from (₫)';

  @override
  String get priceTo => 'Price to (₫)';

  @override
  String get applyFilter => 'Apply';

  @override
  String get clearFilter => 'Clear filters';

  @override
  String get reviewTitle => 'Inspect';

  @override
  String claimExpiresIn(String time) {
    return '$time left to decide';
  }

  @override
  String get claimExpired =>
      'Your claim expired. Claim the listing again to continue.';

  @override
  String get reclaim => 'Claim again';

  @override
  String get release => 'Release';

  @override
  String get releaseTitle => 'Release this listing?';

  @override
  String get releaseMessage =>
      'It goes back to the queue for other inspectors.';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get approveTitle => 'Approve listing';

  @override
  String get approveNoteLabel => 'Note (optional)';

  @override
  String get rejectTitle => 'Reject listing';

  @override
  String get rejectReasonsLabel => 'Reasons (choose at least 1)';

  @override
  String get rejectNoteLabel => 'Note for the seller';

  @override
  String rejectNoteHelper(int min) {
    return 'At least $min characters';
  }

  @override
  String get validationRejectReasons => 'Choose at least one reason.';

  @override
  String validationRejectNote(int min) {
    return 'The note needs at least $min characters.';
  }

  @override
  String get listingApproved => 'Listing approved';

  @override
  String get listingRejected => 'Listing rejected';

  @override
  String get listingReleased => 'Listing released';

  @override
  String get sellerDeclared => 'Declared by the seller';

  @override
  String get viewPhotos => 'View original photos';

  @override
  String get inspectionHistory => 'Inspection history';

  @override
  String get errorEmailTaken => 'This email is already in use.';

  @override
  String get errorAccountDisabled =>
      'Your account is disabled. Please contact an administrator.';

  @override
  String get errorListingIncomplete =>
      'The listing is incomplete. Please complete it and submit again.';

  @override
  String get errorListingImageInvalid =>
      'One of the photos is invalid. Please choose it again.';

  @override
  String get errorListingNotFound => 'This listing can\'t be found.';

  @override
  String get errorListingInvalidState =>
      'The listing status changed. Reloading it.';

  @override
  String get errorSubmissionLimit => 'This listing has no resubmissions left.';

  @override
  String get errorConcurrentUpdate =>
      'The listing was just updated elsewhere. Reloading.';

  @override
  String get errorAlreadyClaimed =>
      'Another inspector is holding this listing.';

  @override
  String get errorClaimRequired =>
      'You no longer hold this listing. Claim it again.';

  @override
  String get errorCategoryNotFound => 'This category no longer exists.';

  @override
  String get errorNotificationNotFound => 'This notification can\'t be found.';

  @override
  String errorPhotoTooLarge(int mb) {
    return 'The photo is larger than $mb MB. Please choose a smaller one.';
  }

  @override
  String get errorPhotosUploadPending =>
      'Some photos are still uploading or failed. Retry them first.';
}
