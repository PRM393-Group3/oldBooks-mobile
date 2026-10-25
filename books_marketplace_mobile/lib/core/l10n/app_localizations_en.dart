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
      'Enter a Vietnamese mobile number (10 digits starting 03, 05, 07, 08 or 09, or +84).';

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
  String get errorInvalidCredentials =>
      'Phone number or password is incorrect.';

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
  String get navExplore => 'Explore';

  @override
  String get navAuctions => 'Auctions';

  @override
  String get navSell => 'Sell';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navMe => 'Me';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody => 'This feature is under construction.';

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
  String get filterButton => 'Filter';

  @override
  String get filterTitle => 'Filters';

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

  @override
  String get brandName => 'Oldbook';

  @override
  String cartButton(int count) {
    return 'Cart · $count';
  }

  @override
  String get cartTitle => 'Cart';

  @override
  String get searchHint => 'Title, author, ISBN';

  @override
  String get resultsNew => 'New listings';

  @override
  String get resultsSearch => 'Search results';

  @override
  String resultsCount(int count) {
    return '$count books';
  }

  @override
  String get noSearchResults =>
      'No matching books. Try removing accents or changing the category.';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get inCart => 'In cart';

  @override
  String get buyNow => 'Buy now';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get alreadyInCart => 'Already in your cart';

  @override
  String shipPlus(String price) {
    return '+ shipping $price';
  }

  @override
  String get escrowNote =>
      'Your payment is held in the Oldbook wallet until you confirm delivery. You have 3 days to file a complaint after delivery.';

  @override
  String get auctionListingNote => 'This book is sold by auction.';

  @override
  String toastOrderCancelled(String amount) {
    return 'Order cancelled, $amount refunded';
  }

  @override
  String get toastOrderCompleted => 'Order completed · thank you!';

  @override
  String get toastComplaintOpened => 'Complaint opened · funds are locked';

  @override
  String toastOfferAccepted(String amount) {
    return '$amount refunded to you';
  }

  @override
  String get toastNoBooks => 'No available books in your cart';

  @override
  String get toastSellerShipped => 'The seller entered a tracking code';

  @override
  String toastDeliveryFailed(int n) {
    return 'Delivery attempt $n failed';
  }

  @override
  String get toastMovedToStorage =>
      'Fifth delivery failed · the book moved to storage';

  @override
  String toastTopupOk(String amount) {
    return 'Top-up successful +$amount';
  }

  @override
  String toastWithdrawRequested(String amount) {
    return 'Withdrawal of $amount requested';
  }

  @override
  String toastRated(int n) {
    return 'Rated $n stars';
  }

  @override
  String toastRegistered(String amount) {
    return 'Registered · $amount held';
  }

  @override
  String toastUnregistered(String amount) {
    return 'Registration cancelled, $amount refunded';
  }

  @override
  String toastLeading(String amount) {
    return 'You are leading with $amount';
  }

  @override
  String get toastBuyNowStarted =>
      'Bought now · the 30-minute countdown has started';

  @override
  String toastOutbid(String title, String amount) {
    return 'You were outbid on \"$title\" · $amount';
  }

  @override
  String toastAuctionWon(String title, String amount) {
    return 'You won \"$title\" at $amount';
  }

  @override
  String get txnTopupVietQr => 'Top-up via VietQR';

  @override
  String txnHoldOrder(String arg) {
    return 'Hold for order $arg';
  }

  @override
  String txnHoldOrders(int n) {
    return 'Hold for $n orders';
  }

  @override
  String txnHoldAuctionRegistration(String arg) {
    return 'Registration for \"$arg\"';
  }

  @override
  String txnHoldBid(String arg) {
    return 'Bid on \"$arg\"';
  }

  @override
  String txnHoldBuyNow(String arg) {
    return 'Buy now \"$arg\"';
  }

  @override
  String txnHoldRedelivery(String arg) {
    return 'Redelivery fee $arg';
  }

  @override
  String txnReleaseOrderCancelled(String arg) {
    return 'Refund for cancelled order $arg';
  }

  @override
  String txnReleaseAuctionUnregistered(String arg) {
    return 'Registration cancelled \"$arg\"';
  }

  @override
  String txnReleaseAuctionDeposit(String arg) {
    return 'Deposit returned for \"$arg\"';
  }

  @override
  String txnPayoutSale(String arg) {
    return 'Sale proceeds for \"$arg\"';
  }

  @override
  String txnCaptureOrder(String arg) {
    return 'Payment for order $arg (from held funds)';
  }

  @override
  String txnRefundAgreement(String arg) {
    return 'Agreed refund for $arg';
  }

  @override
  String txnRefundVerdict(String arg) {
    return 'Refund by verdict for $arg';
  }

  @override
  String get txnWithdrawRequest =>
      'Withdrawal to Vietcombank · pending approval';

  @override
  String get txnTypeTopup => 'Top-up';

  @override
  String get txnTypeHold => 'Hold';

  @override
  String get txnTypeRelease => 'Release';

  @override
  String get txnTypePayout => 'Payout';

  @override
  String get txnTypeRefund => 'Refund';

  @override
  String get txnTypeCapture => 'Capture';

  @override
  String get txnTypeWithdraw => 'Withdrawal';

  @override
  String get orderStatusPaidAwaitingShipment => 'Awaiting shipment';

  @override
  String get orderStatusShipped => 'In transit';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderStatusRefunded => 'Refunded';

  @override
  String get orderStatusPartiallyRefunded => 'Partially refunded';

  @override
  String get orderStatusDisputed => 'Disputed';

  @override
  String get orderStatusReadyToShip => 'Ready to ship';

  @override
  String get orderStatusInDelivery => 'Out for delivery';

  @override
  String get orderStatusInStorage => 'In storage';

  @override
  String get orderStatusPickedUp => 'Picked up';

  @override
  String get orderKindSale => 'Fixed price';

  @override
  String get orderKindAuction => 'Auction';

  @override
  String get ordersTitle => 'My orders';

  @override
  String orderTitle(String arg) {
    return 'Order $arg';
  }

  @override
  String get ordersEmpty => 'You have no orders yet.';

  @override
  String noteShipBy(String date) {
    return 'Seller ships by $date';
  }

  @override
  String noteComplaintLeft(String time) {
    return '$time left to file a complaint';
  }

  @override
  String noteDeliveryAttempt(int n, String carrier) {
    return 'Attempt $n/5 · $carrier';
  }

  @override
  String noteStorage(int days) {
    return 'In storage $days days · 5,000 ₫/day deducted from deposit';
  }

  @override
  String get notePacking => 'The warehouse is packing';

  @override
  String get noteFundsLocked => 'Funds are locked';

  @override
  String get headPaidAwaitingShipment => 'Waiting for the seller to ship';

  @override
  String get headShipped => 'Your book is on its way';

  @override
  String get headDelivered => 'Did you receive the book?';

  @override
  String get headCompleted => 'Order completed';

  @override
  String get headDisputed => 'Complaint in progress';

  @override
  String get headCancelled => 'Order cancelled';

  @override
  String get headRefunded => 'Refunded';

  @override
  String get headPartiallyRefunded => 'Partially refunded';

  @override
  String get headReadyToShip => 'The warehouse is preparing your order';

  @override
  String get headInDelivery => 'Your auction book is being delivered';

  @override
  String get headInStorage => 'Your book is in storage';

  @override
  String get headPickedUp => 'Picked up at the warehouse';

  @override
  String detailNotePaid(String date) {
    return 'The seller must ship by $date. Past that the order is cancelled and fully refunded. You can cancel for free until the seller ships.';
  }

  @override
  String get detailNoteShipped =>
      'Tap \"I received the book\" when it arrives to start the 3-day inspection window.';

  @override
  String detailNoteDelivered(String time) {
    return 'You have $time to file a complaint. After that the order completes and the seller is paid.';
  }

  @override
  String get detailNoteCompleted => 'The seller has been paid after fees.';

  @override
  String get detailNoteDisputed =>
      'Funds stay locked until an agreement or a verdict.';

  @override
  String get detailNoteCancelled =>
      'All held funds were released to your wallet.';

  @override
  String get detailNoteRefunded => 'The refund is in your wallet.';

  @override
  String get detailNotePartiallyRefunded =>
      'The refunded part is in your wallet, the rest went to the seller.';

  @override
  String detailNoteReadyToShip(String amount) {
    return 'Shipping fee $amount is held. The warehouse photographs the package before delivery.';
  }

  @override
  String detailNoteInDelivery(int n) {
    return 'Attempt $n/5. After 5 failed attempts the book goes to storage (5,000 ₫/day, up to 30 days).';
  }

  @override
  String get detailNoteInStorage =>
      'Delivery failed 5 times. Storage fees are deducted from your deposit. Pick it up or ask for redelivery.';

  @override
  String get stepSaleOrdered => 'Ordered · funds held';

  @override
  String get stepSaleShipped => 'Seller shipped';

  @override
  String get stepDelivered => 'Delivered';

  @override
  String get stepSaleCompleted => 'Completed · seller paid';

  @override
  String get stepAuctionWon => 'Won the auction · warehouse notified';

  @override
  String get stepAuctionInDelivery => 'In delivery';

  @override
  String get stepAuctionReceived => 'Received';

  @override
  String get stepAuctionCompleted => 'Completed · deposit returned';

  @override
  String get stepCancelled => 'Cancelled · refunded to your wallet';

  @override
  String get stepNext => 'Next';

  @override
  String get moneyBookPrice => 'Book price';

  @override
  String get moneyWinPrice => 'Winning bid';

  @override
  String get moneyShipping => 'Shipping';

  @override
  String get moneyTotal => 'Total';

  @override
  String get moneyNoteAuction =>
      'The winning bid is held in escrow. Your deposit is returned when you receive the book.';

  @override
  String get moneyNoteSettled => 'Settled.';

  @override
  String get moneyNoteHeld => 'Held in your wallet until the order completes.';

  @override
  String get shipNoTracking => 'No tracking code yet';

  @override
  String get shipFromWarehouse => 'Shipped from the Oldbook warehouse';

  @override
  String get reviewSeller => 'Rate the seller';

  @override
  String get reviewNoteNew => 'Rate within 14 days of completion.';

  @override
  String get reviewNoteEdit => 'You can edit your rating once within 7 days.';

  @override
  String starLabel(int n) {
    return '$n stars';
  }

  @override
  String get actSimSellerShip => 'Simulate: seller ships';

  @override
  String actCancelOrder(String amount) {
    return 'Cancel order · refund $amount';
  }

  @override
  String get actReceived => 'I received the book';

  @override
  String get actSimWarehouseShip => 'Simulate: warehouse ships';

  @override
  String get actSimDeliverOk => 'Simulate: delivery succeeded';

  @override
  String get actSimDeliverFail => 'Simulate: delivery failed';

  @override
  String get actPickUp => 'Pick up at the warehouse';

  @override
  String actRedeliver(String amount) {
    return 'Redeliver · extra $amount';
  }

  @override
  String get actCompleteOrder => 'Satisfied, complete the order';

  @override
  String get actComplaint => 'File a complaint';

  @override
  String get actSimSellerOffer => 'Simulate: seller offers a 50% refund';

  @override
  String actAcceptOffer(String amount) {
    return 'Accept $amount refund';
  }

  @override
  String get actEscalate => 'Decline, escalate to Oldbook';

  @override
  String get actSimAdmin => 'Simulate: admin rules a full refund';

  @override
  String get actNone => 'Nothing to do right now.';

  @override
  String complaintCardTitle(String status) {
    return 'Complaint · $status';
  }

  @override
  String get complaintStatusOpen => 'Waiting for the seller';

  @override
  String get complaintStatusSellerResponded => 'Seller made an offer';

  @override
  String get complaintStatusEscalated => 'Oldbook is reviewing';

  @override
  String get complaintStatusAgreed => 'Agreed';

  @override
  String get complaintStatusResolved => 'Resolved';

  @override
  String get complaintTextOpenSale =>
      'The seller has 2 days to respond, otherwise Oldbook steps in.';

  @override
  String get complaintTextOpenAuction =>
      'Auction complaints go straight to Oldbook.';

  @override
  String complaintTextSellerResponded(String amount) {
    return 'The seller offered a $amount refund. Accept it or escalate to Oldbook.';
  }

  @override
  String get complaintTextEscalatedSale =>
      'An admin reviews both sides\' evidence and rules.';

  @override
  String get complaintTextEscalatedAuction =>
      'An admin reviews both sides\' evidence and the warehouse in/out photos, then rules.';

  @override
  String complaintTextAgreed(String amount) {
    return '$amount refunded by agreement.';
  }

  @override
  String get complaintTextResolved => 'Fully refunded by verdict.';

  @override
  String get complaintSheetTitle => 'File a complaint';

  @override
  String get complaintSheetNote =>
      'Funds stay locked until the complaint is resolved.';

  @override
  String get complaintReasonNotAsDescribed => 'Not as described';

  @override
  String get complaintReasonDamaged => 'Damaged';

  @override
  String get complaintReasonWrongItem => 'Wrong book';

  @override
  String get complaintReasonOther => 'Other';

  @override
  String get complaintDescribeHint => 'Describe the problem';

  @override
  String complaintAddEvidence(int n) {
    return '+ Add evidence photos ($n/10)';
  }

  @override
  String get complaintSubmit => 'Submit complaint';

  @override
  String get complaintNeedReasonAndPhoto =>
      'Choose a reason and add at least 1 photo';

  @override
  String get cartEmpty => 'Your cart is empty.';

  @override
  String cartSeller(String name) {
    return 'Seller: $name';
  }

  @override
  String get cartUnavailable => 'No longer available · sold';

  @override
  String get cartRemove => 'Remove';

  @override
  String get cartShipTo => 'Deliver to';

  @override
  String cartSubtotal(int n) {
    return 'Books ($n)';
  }

  @override
  String cartShippingFee(String amount) {
    return 'Shipping ($amount per order)';
  }

  @override
  String get cartBalance => 'Available wallet balance';

  @override
  String get cartNote =>
      'Each book becomes a separate order with its seller. You can cancel for free until the seller ships.';

  @override
  String get cartPayTotal => 'Total';

  @override
  String get cartPlaceOrder => 'Place order · pay with wallet';

  @override
  String get cartInsufficient => 'Not enough balance · top up';

  @override
  String get cartNoAvailable => 'No available books';

  @override
  String get insufficientTitle => 'Not enough balance';

  @override
  String insufficientBody(String need, String avail) {
    return 'You need $need more to continue. Available balance: $avail.';
  }

  @override
  String insufficientTopup(String amount) {
    return 'Top up $amount';
  }

  @override
  String get sheetClose => 'Close';

  @override
  String get sheetLater => 'Not now';

  @override
  String get orderPlacedTitle => 'Order placed';

  @override
  String orderPlacedBody(String amount, int n) {
    return '$amount was held from your wallet for $n orders. Sellers have 2 working days to ship, otherwise the order is cancelled and refunded.';
  }

  @override
  String get orderPlacedView => 'View orders';

  @override
  String get orderPlacedKeepShopping => 'Keep shopping';

  @override
  String get walletTitle => 'Oldbook wallet';

  @override
  String get walletAvailable => 'Available balance';

  @override
  String get walletHeld => 'Held';

  @override
  String get walletTotal => 'Total';

  @override
  String get walletTopup => 'Top up';

  @override
  String get walletWithdraw => 'Withdraw';

  @override
  String get walletNote =>
      'Held funds cover unfinished orders, auction deposits and your leading bids. Every payment goes through the wallet, never directly between users.';

  @override
  String get walletHistory => 'Transactions';

  @override
  String get walletNoTransactions => 'No transactions yet.';

  @override
  String get walletPayoutAccount => 'Payout account';

  @override
  String get topupSheetTitle => 'Top up your wallet';

  @override
  String get topupSheetNote =>
      'You will be taken to the payment gateway. The request expires if unpaid within the time limit.';

  @override
  String topupCreateCode(String amount) {
    return 'Create payment code · $amount';
  }

  @override
  String get topupScanTitle => 'Scan to pay';

  @override
  String get topupQrLabel => 'VietQR code';

  @override
  String get topupTransferContent =>
      'Reference: OLDBOOK NAP 7K2Q9 · expires in 30:00';

  @override
  String get topupConfirmNote =>
      'Your balance is credited only when the payment gateway confirms.';

  @override
  String get topupSimConfirm => 'Simulate: payment gateway confirms';

  @override
  String get withdrawSheetTitle => 'Withdraw';

  @override
  String get withdrawAmountHint => 'Amount (minimum 50,000 ₫)';

  @override
  String withdrawHintAvailable(String amount) {
    return 'Available: $amount';
  }

  @override
  String get withdrawHintMin => 'Minimum 50,000 ₫';

  @override
  String withdrawHintOver(String amount) {
    return 'Exceeds available balance ($amount)';
  }

  @override
  String withdrawHintHold(String amount) {
    return '$amount will be held pending approval';
  }

  @override
  String get withdrawNote =>
      'The amount is held now and transferred after Oldbook approves. The account holder name must match your profile name.';

  @override
  String get withdrawSubmit => 'Request withdrawal';

  @override
  String remainingDaysHours(int days, int hours) {
    return '${days}d ${hours}h';
  }

  @override
  String get agoNow => 'just now';

  @override
  String agoMinutes(int n) {
    return '$n min ago';
  }

  @override
  String agoHours(int n) {
    return '$n h ago';
  }

  @override
  String agoDays(int n) {
    return '$n d ago';
  }

  @override
  String get meMyOrders => 'My orders';

  @override
  String get meMyOrdersSub =>
      'Track deliveries, confirm receipt, file complaints';

  @override
  String get aucTitle => 'Auctions';

  @override
  String get aucSubtitle =>
      'Books are checked at the Oldbook warehouse before listing';

  @override
  String get aucTabLive => 'Live';

  @override
  String get aucTabRegister => 'Register';

  @override
  String get aucTabUpcoming => 'Upcoming';

  @override
  String get aucTabEnded => 'Ended';

  @override
  String get aucEmpty => 'No auctions in this state yet.';

  @override
  String get aucStatusLive => 'Live';

  @override
  String get aucStatusBuyNow => 'Buy-now countdown';

  @override
  String get aucStatusRegistration => 'Registration open';

  @override
  String get aucStatusConfirmed => 'Starting soon';

  @override
  String get aucStatusEnded => 'Ended';

  @override
  String get aucStatusNoBid => 'No bids';

  @override
  String get aucRegisteredTag => 'Registered';

  @override
  String aucParticipants(int n) {
    return '$n participants';
  }

  @override
  String aucParticipantsMin(int n, String min) {
    return '$n/$min minimum players';
  }

  @override
  String get aucPriceStarting => 'Starting price';

  @override
  String get aucPriceCurrent => 'Current price';

  @override
  String get aucPriceWinning => 'Winning price';

  @override
  String get aucTimerEndsIn => 'Ends in';

  @override
  String get aucTimerCountdown => 'Countdown';

  @override
  String get aucTimerRegCloses => 'Registration closes in';

  @override
  String get aucTimerStartsIn => 'Starts in';

  @override
  String get aucTimerEndedAt => 'Ended at';

  @override
  String get aucSubLive =>
      'A bid in the last 2 minutes extends the auction by 2 minutes.';

  @override
  String aucSubCountdown(String time) {
    return 'Someone bought now. Each higher bid resets 30 minutes · ends by $time at the latest.';
  }

  @override
  String aucSubRegistration(String time, String min) {
    return 'Starts $time · needs at least $min players.';
  }

  @override
  String aucSubConfirmed(String time) {
    return 'Enough players · starts $time.';
  }

  @override
  String get aucLeaderMe => 'You are leading';

  @override
  String aucLeaderOther(String name) {
    return 'Leading: $name';
  }

  @override
  String get aucNoBids => 'No bids yet';

  @override
  String get aucExtendedBanner =>
      'The auction was just extended by 2 minutes (anti-sniping)';

  @override
  String get aucStatStart => 'Starting price';

  @override
  String get aucStatStep => 'Bid step';

  @override
  String get aucStatBuyNow => 'Buy-now price';

  @override
  String get aucStatFeeDeposit => 'Entry fee · Deposit';

  @override
  String get aucNone => 'None';

  @override
  String get aucBidHistory => 'Bid history';

  @override
  String aucBidCount(int n) {
    return '$n bids';
  }

  @override
  String get aucBidYou => 'You';

  @override
  String get aucNoBidsYet =>
      'No bids yet. The first bid must be at least the starting price.';

  @override
  String aucSellerLine(String seller, String part) {
    return 'Seller: $seller · $part';
  }

  @override
  String get aucHoldLabel => 'Entry fee + deposit held';

  @override
  String get aucRegister => 'Register';

  @override
  String get aucRegisteredTitle => 'You are registered';

  @override
  String aucRegisteredSub(String amount) {
    return 'Holding $amount · you can cancel before it closes';
  }

  @override
  String get aucUnregister => 'Cancel registration';

  @override
  String get aucFilledTitle => 'The auction is full';

  @override
  String aucFilledSub(String amount) {
    return 'The entry fee was charged and the $amount deposit stays held. We will remind you 1 hour before it starts.';
  }

  @override
  String get aucWatchTitle => 'You are watching this auction';

  @override
  String get aucWatchSub =>
      'Registration closed 24 hours before the start. Only registered players can bid.';

  @override
  String get aucLeadingTitle => 'You are leading';

  @override
  String aucLeadingSub(String amount) {
    return '$amount is held in your wallet · released if you are outbid';
  }

  @override
  String aucMinimum(String amount) {
    return 'Minimum $amount';
  }

  @override
  String get aucBid => 'Place bid';

  @override
  String aucBuyNowButton(String amount) {
    return 'Buy now $amount';
  }

  @override
  String get aucEndedWon => 'You won this auction';

  @override
  String get aucEndedLost => 'You did not win this auction';

  @override
  String get aucEndedGeneric => 'The auction has ended';

  @override
  String aucEndedWonText(String amount) {
    return 'A delivery order was created in My orders. Your $amount deposit is returned when you receive the book.';
  }

  @override
  String aucEndedLostText(String amount) {
    return 'Your $amount deposit was released to your wallet.';
  }

  @override
  String aucEndedOtherText(String amount) {
    return 'Winning price $amount.';
  }

  @override
  String get aucNotFound => 'Auction not found.';

  @override
  String get aucErrEnded => 'The auction has ended, bidding is closed.';

  @override
  String get aucErrTooLow => 'Your bid is below the current minimum.';

  @override
  String get aucErrState => 'Not possible in the current state.';

  @override
  String get regSheetTitle => 'Register for the auction';

  @override
  String get regFee => 'Entry fee (2% of start, 10,000–100,000 ₫)';

  @override
  String get regDeposit => 'Deposit (10% of start)';

  @override
  String get regHold => 'Held from wallet';

  @override
  String get regBalance => 'Available balance';

  @override
  String get regNote1 =>
      '• The entry fee is charged only when 3 players join; otherwise it is fully refunded.';

  @override
  String get regNote2 =>
      '• The deposit is returned when the auction ends (losers) or when you receive the book (winner). A 5,000 ₫/day storage fee is deducted if you do not collect it.';

  @override
  String regNote3(String time) {
    return '• Cancel for free before $time.';
  }

  @override
  String regConfirm(String amount) {
    return 'Confirm · hold $amount';
  }

  @override
  String get regInsufficient => 'Not enough balance · top up';

  @override
  String buyNowTitle(String amount) {
    return 'Buy now for $amount?';
  }

  @override
  String buyNowNote1(String amount) {
    return '• $amount is held from your wallet and you become the leader.';
  }

  @override
  String get buyNowNote2 =>
      '• The auction switches to a 30-minute countdown. Each higher bid resets it to 30 minutes.';

  @override
  String get buyNowNote3 => '• The auction ends within 24 hours of buying now.';

  @override
  String get buyNowConfirm => 'Confirm buy now';

  @override
  String get myAuctionsTitle => 'My auctions';

  @override
  String get myAuctionsEmpty => 'You have not registered for any auction.';

  @override
  String myAucWon(String amount) {
    return 'Won · $amount';
  }

  @override
  String myAucLeading(String amount) {
    return 'Leading · $amount';
  }

  @override
  String get myAucLost => 'Did not win';

  @override
  String get myAucOutbid => 'Outbid';

  @override
  String get myAucRegistered => 'Registered';

  @override
  String get homeLiveAuctions => 'Live auctions';

  @override
  String get homeSeeAll => 'See all';

  @override
  String simNotifBuyNowTitle(String arg) {
    return 'Auction \"$arg\" is in the buy-now countdown';
  }

  @override
  String get simNotifBuyNowBody =>
      'Someone bought now. Bid higher to reset the 30-minute countdown.';

  @override
  String simNotifDeliveredTitle(String arg) {
    return 'Order $arg delivered';
  }

  @override
  String get simNotifDeliveredBody =>
      'You have 3 days to check the book and file a complaint if needed.';

  @override
  String simNotifFilledTitle(String arg) {
    return 'Auction \"$arg\" is full';
  }

  @override
  String simNotifFilledBody(String amount) {
    return 'It starts in a few hours. Your $amount deposit stays held.';
  }

  @override
  String get simNotifTopupTitle => 'Top-up successful';

  @override
  String simNotifTopupBody(String amount) {
    return '+$amount was added to your wallet.';
  }

  @override
  String get simNotifRegisteredTitle => 'Registration successful';

  @override
  String simNotifRegisteredBody(String arg, String amount) {
    return '\"$arg\" · $amount held';
  }

  @override
  String get simNotifOutbidTitle => 'You were outbid';

  @override
  String simNotifOutbidBody(String arg, String amount) {
    return '\"$arg\" · new price $amount. Your held funds were released.';
  }

  @override
  String simNotifWonTitle(String arg) {
    return 'You won \"$arg\"';
  }

  @override
  String simNotifWonBody(String amount) {
    return 'Winning price $amount. A delivery order was created in My orders.';
  }

  @override
  String get meStatOpenOrders => 'Open orders';

  @override
  String get meStatListings => 'Active listings';

  @override
  String get meStatAuctions => 'Auctions joined';

  @override
  String get meMyListings => 'My listings';

  @override
  String get meMyListingsSub => 'Review status, needs changes, sold';

  @override
  String get meMyAuctionsSub => 'Registered, leading, won';

  @override
  String meNotificationsSub(int n) {
    return '$n unread';
  }

  @override
  String get meNotificationsAllRead => 'All read';

  @override
  String get meDefaultAddress => 'Default address';

  @override
  String get sellTitle => 'Sell';

  @override
  String get sellModeFixed => 'Fixed price';

  @override
  String get sellModeAuction => 'Auction';

  @override
  String get sellAuctionNote =>
      'Auction books are sent to the Oldbook warehouse within 5 days to be checked and re-photographed. After approval, registration stays open for at least 3 days and needs at least 3 players.';

  @override
  String get sellPhotos => 'Book photos';

  @override
  String sellPhotoCount(int n) {
    return '$n/10 · at least 4';
  }

  @override
  String get sellPhotoAdd => '+ add';

  @override
  String get sellFieldTitle => 'Title';

  @override
  String get sellFieldTitleHint => 'e.g. The Little Prince';

  @override
  String get sellFieldAuthor => 'Author';

  @override
  String get sellFieldAuthorHint => 'e.g. Antoine de Saint-Exupéry';

  @override
  String get sellFieldCategory => 'Category';

  @override
  String get sellFieldCondition => 'Condition';

  @override
  String get sellFieldPrice => 'Price (₫)';

  @override
  String get sellFieldPriceHint => 'Minimum 1,000';

  @override
  String get sellFieldStart => 'Starting price';

  @override
  String get sellFieldStartHint => '≥ 10,000';

  @override
  String get sellFieldStep => 'Bid step';

  @override
  String get sellFieldBuyNow => 'Buy-now price';

  @override
  String get sellFieldBuyNowOptional => '(optional, ≥ 1.5 × starting price)';

  @override
  String get sellBuyNowHintEmpty => 'Leave empty to skip';

  @override
  String sellBuyNowHint(String amount) {
    return '≥ $amount';
  }

  @override
  String get sellStepHintEmpty => '1–10% of start';

  @override
  String get sellDuration => 'Auction length';

  @override
  String get sellDuration5m => '5 minutes';

  @override
  String get sellDuration15m => '15 minutes';

  @override
  String get sellDuration1h => '1 hour';

  @override
  String get sellDuration1d => '1 day';

  @override
  String get sellDuration3d => '3 days';

  @override
  String get sellDuration7d => '7 days';

  @override
  String sellEarliestStart(String time) {
    return 'Earliest start: $time (depends on system settings; too soon is rejected)';
  }

  @override
  String get sellFieldDesc => 'Description & defects (if any)';

  @override
  String get sellFieldDescHint =>
      'Publication year, publisher, notes, stained pages…';

  @override
  String get sellPreviewTitle => 'Estimate';

  @override
  String get sellPreviewPrice => 'Price';

  @override
  String get sellPreviewFee => 'Oldbook fee (5%)';

  @override
  String get sellPreviewReceive => 'You receive';

  @override
  String get sellPreviewShip => 'Shipping (paid by buyer)';

  @override
  String get sellPreviewPlayerFee => 'Player pays entry fee';

  @override
  String get sellPreviewPlayerDeposit => 'Player deposit';

  @override
  String get sellPreviewCommission => 'Oldbook commission (10% of winning bid)';

  @override
  String get sellPreviewReceiveAtStart =>
      'You receive if sold at the starting price';

  @override
  String get sellSubmitSale => 'Submit for review';

  @override
  String get sellSubmitAuction => 'Create auction & get warehouse code';

  @override
  String sellErrPhotos(int n) {
    return 'At least 4 photos needed (you have $n)';
  }

  @override
  String get sellKind => 'Listing type';

  @override
  String get sellKindSingle => 'Single book';

  @override
  String get sellKindSet => 'Book set';

  @override
  String get sellSetHint =>
      'The whole set is sold for one price. Add each volume with its own photos.';

  @override
  String get sellSetPhotos => 'Photos of the whole set';

  @override
  String get sellAddVolume => 'Add volume';

  @override
  String get sellVolumeNameHint => 'Volume title (optional)';

  @override
  String get sellVolumeRemove => 'Remove volume';

  @override
  String get sellErrSetPhotos => 'At least 1 photo of the whole set is needed';

  @override
  String get sellErrVolumePhotos => 'Every volume needs at least 1 photo';

  @override
  String sellSetPhotoCount(int n) {
    return '$n/10 · at least 1';
  }

  @override
  String sellVolumesTitle(int n) {
    return 'Volumes ($n)';
  }

  @override
  String sellVolumeLabel(int no) {
    return 'Volume $no';
  }

  @override
  String sellVolumePhotoCount(int n, int max) {
    return '$n/$max photos';
  }

  @override
  String sellErrVolumes(int min, int max) {
    return 'A set needs $min to $max volumes';
  }

  @override
  String setBadge(int n) {
    return 'Set of $n';
  }

  @override
  String detailVolumes(int n) {
    return 'Volumes in this set ($n)';
  }

  @override
  String get sellErrTitle => 'Enter the title';

  @override
  String get sellErrAuthor => 'Enter the author';

  @override
  String get sellErrPrice => 'Minimum price is 1,000 ₫';

  @override
  String get sellErrStart => 'Minimum starting price is 10,000 ₫';

  @override
  String sellErrStep(String lo, String hi) {
    return 'Bid step must be between $lo and $hi';
  }

  @override
  String sellErrBuyNow(String amount) {
    return 'Minimum buy-now price is $amount';
  }

  @override
  String get sellErrDesc => 'Enter a description';

  @override
  String get sellDoneSaleTitle => 'Submitted for review';

  @override
  String sellDoneSaleBody(String title) {
    return 'Oldbook will review \"$title\" within 24 hours and notify you.';
  }

  @override
  String get sellDoneAuctionTitle => 'Auction created';

  @override
  String get sellDoneAuctionBody =>
      'Send the book to the warehouse within 5 days with the code below. The auction is cancelled if late. You pay shipping to the warehouse.';

  @override
  String get sellDoneCode => 'Warehouse code';

  @override
  String get sellDoneWarehouse =>
      'Oldbook warehouse Hanoi · 25 Le Van Luong, Thanh Xuan, Hanoi';

  @override
  String get sellDoneView => 'View my listings';

  @override
  String get myListingsEmpty => 'You have no listings yet.';

  @override
  String get myListingStatusPublished => 'On sale';

  @override
  String get myListingStatusPending => 'Pending review';

  @override
  String get myListingStatusNeedsChanges => 'Needs changes';

  @override
  String get myListingStatusAwaitingInbound => 'Awaiting warehouse';

  @override
  String get myListingStatusSold => 'Sold';

  @override
  String myListingKindFixed(String price) {
    return 'Fixed price · $price';
  }

  @override
  String myListingKindAuction(String price) {
    return 'Auction · start $price';
  }

  @override
  String myListingNotePublished(int days, String views) {
    return 'Posted $days days ago · $views views';
  }

  @override
  String myListingNotePending(int hours) {
    return 'Submitted $hours h ago · reviewed within 24 hours';
  }

  @override
  String get myListingNotePendingNow =>
      'Just submitted · reviewed within 24 hours';

  @override
  String myListingNoteNeedsChanges(String reason) {
    return 'Admin: $reason';
  }

  @override
  String myListingNoteInbound(String date, String code) {
    return 'Send the book to the warehouse by $date · code $code';
  }

  @override
  String myListingNoteSold(String amount) {
    return 'Received $amount (after 5% fee, incl. shipping)';
  }

  @override
  String get sellCatLiterature => 'Literature';

  @override
  String get sellCatHistory => 'History';

  @override
  String get sellCatChildren => 'Children';

  @override
  String get sellCatScience => 'Science';

  @override
  String get sellCatForeign => 'Foreign language';

  @override
  String get validationPhoneRequired => 'Please enter your phone number.';

  @override
  String get validationOtpInvalid => 'The OTP has 6 digits.';

  @override
  String get validationPasswordLetterDigit =>
      'The password needs both letters and digits.';

  @override
  String get passwordHelperLetterDigit =>
      'At least 8 characters with letters and digits';

  @override
  String get otpLabel => 'OTP code';

  @override
  String get otpSend => 'Send code';

  @override
  String otpResendIn(int n) {
    return 'Resend in ${n}s';
  }

  @override
  String otpSentTo(String phone) {
    return 'OTP sent to $phone';
  }

  @override
  String get forgotLink => 'Forgot password?';

  @override
  String get forgotTitle => 'Forgot password';

  @override
  String get forgotSubtitle =>
      'Enter your phone number to get a code and set a new password.';

  @override
  String get forgotSubmit => 'Reset password';

  @override
  String get forgotDone => 'Password reset. Please sign in.';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get errOtpInvalid => 'The OTP is incorrect.';

  @override
  String get errOtpExpired => 'The OTP has expired. Request a new one.';

  @override
  String get errRateLimited => 'Too many attempts. Try again in a few minutes.';

  @override
  String get errAccountLocked => 'Your account is locked.';

  @override
  String get errInsufficientBalance => 'Your wallet balance is not enough.';

  @override
  String get errBidTooLow => 'Your bid is below the current minimum.';

  @override
  String get errAlreadyLeading => 'You are already leading this auction.';

  @override
  String get errAuctionEnded => 'The auction has ended.';

  @override
  String get errAuctionNotLive => 'The auction is not live yet.';

  @override
  String get errBuyNowUnavailable => 'Buy now is no longer available.';

  @override
  String get errNotRegistered => 'You have not registered for this auction.';

  @override
  String get errRegistrationClosed => 'Registration is closed.';

  @override
  String get errSellerCannotBid =>
      'Sellers cannot take part in their own auction.';

  @override
  String get errListingNotAvailable => 'This book is no longer available.';

  @override
  String get errComplaintWindowClosed => 'The complaint window has closed.';

  @override
  String get errWithdrawBelowMin => 'The withdrawal is below the minimum.';

  @override
  String get errForbidden => 'You are not allowed to do this.';

  @override
  String get errNotFound => 'Not found.';

  @override
  String get errInvalidState => 'Not possible in the current state.';

  @override
  String get errUpstream =>
      'A partner service is having trouble. Try again later.';

  @override
  String get addrTitle => 'Address book';

  @override
  String get addrSub => 'Delivery addresses, set a default';

  @override
  String get addrEmpty => 'You have no addresses yet.';

  @override
  String get addrAdd => 'Add address';

  @override
  String get addrEdit => 'Edit address';

  @override
  String get addrDefault => 'Default';

  @override
  String get addrSetDefault => 'Set as default';

  @override
  String get addrDelete => 'Delete';

  @override
  String get addrDeleteTitle => 'Delete this address?';

  @override
  String get addrRecipient => 'Recipient';

  @override
  String get addrPhone => 'Phone';

  @override
  String get addrProvince => 'Province/City';

  @override
  String get addrDistrict => 'District';

  @override
  String get addrWard => 'Ward';

  @override
  String get addrDetail => 'Street address';

  @override
  String get addrSave => 'Save address';

  @override
  String get addrRequired => 'Please fill this in.';

  @override
  String get addrNone => 'No delivery address yet';

  @override
  String get bankTitle => 'Bank accounts';

  @override
  String get bankSub => 'Receive withdrawals (up to 3)';

  @override
  String get bankEmpty => 'You have not saved a bank account.';

  @override
  String get bankAdd => 'Add account';

  @override
  String get bankName => 'Bank';

  @override
  String get bankNumber => 'Account number';

  @override
  String get bankHolder => 'Account holder';

  @override
  String get bankHolderNote => 'The holder name must match your profile name.';

  @override
  String get bankLimit => 'You can save up to 3 accounts.';

  @override
  String get bankSave => 'Save account';

  @override
  String get bankDeleteTitle => 'Remove this account?';

  @override
  String bankMasked(String last) {
    return '•••• $last';
  }

  @override
  String get roleUser => 'User';

  @override
  String get roleSuperAdmin => 'Super administrator';

  @override
  String get errPhoneTaken =>
      'This phone number already has an account. Sign in or reset your password.';

  @override
  String errAccountLockedTemp(int n) {
    return 'Sign-in is temporarily locked. Try again in $n minutes, or reset your password to unlock now.';
  }

  @override
  String errRateLimitedIn(int n) {
    return 'Too many attempts. Try again in $n seconds.';
  }

  @override
  String get termsLabel =>
      'I accept the Terms of Use and consent to personal data processing (Decree 13/2023).';

  @override
  String get validationTermsRequired =>
      'You need to accept the terms to continue.';

  @override
  String otpExpiresIn(String time) {
    return 'Code expires in $time';
  }

  @override
  String get otpExpired => 'The code has expired. Request a new one.';

  @override
  String get forgotOtpNotice =>
      'If the number is registered, the code will be sent to the account\'s email.';

  @override
  String get pwRuleLength => 'At least 8 characters';

  @override
  String get pwRuleLetter => 'Has a letter';

  @override
  String get pwRuleDigit => 'Has a digit';

  @override
  String loginLockedRetry(String time) {
    return 'Try again in $time';
  }

  @override
  String get errAddressNotFound => 'This address was not found.';

  @override
  String get errDeletionBlocked =>
      'Your account cannot be deleted yet because some things are unfinished.';

  @override
  String get errRoleNotAllowed =>
      'Administrator accounts cannot delete themselves.';

  @override
  String get phoneChangeLink => 'Change phone number';

  @override
  String get phoneReadOnlyHelper =>
      'Changing it needs an OTP sent to your account\'s email.';

  @override
  String get changePhoneTitle => 'Change phone number';

  @override
  String get changePhoneIntro =>
      'The OTP will be sent to your account\'s email. Use the new number the next time you sign in.';

  @override
  String get newPhoneLabel => 'New phone number';

  @override
  String get changePhoneSubmit => 'Confirm change';

  @override
  String get changePhoneDone => 'Phone number changed.';

  @override
  String get validationPhoneSame =>
      'The new number is the same as the current one.';

  @override
  String get errPhoneTakenOther => 'This number belongs to another account.';

  @override
  String get logoutAll => 'Sign out of all devices';

  @override
  String get logoutAllConfirmTitle => 'Sign out of all devices?';

  @override
  String get logoutAllConfirmMessage =>
      'You will need to sign in again on every device.';

  @override
  String get deleteAccountEntry => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountWarning =>
      'This cannot be undone. Your name and phone number are anonymised, addresses and devices are removed and every session is revoked. Transaction records are kept for reconciliation.';

  @override
  String get deleteAccountPasswordLabel => 'Enter your password to confirm';

  @override
  String get deleteAccountSubmit => 'Delete account permanently';

  @override
  String get deleteAccountConfirmTitle => 'Are you sure you want to delete?';

  @override
  String get deleteAccountConfirmMessage =>
      'Your account will be permanently deleted and cannot be restored.';

  @override
  String get deleteAccountBlockedHeader =>
      'Take care of the following, then try again:';

  @override
  String get notifSettingsTitle => 'Notification settings';

  @override
  String get notifSettingsMarketing => 'Promotions';

  @override
  String get notifSettingsMarketingSub => 'Push about offers and marketing.';

  @override
  String get notifSettingsAuction => 'Watched auctions';

  @override
  String get notifSettingsAuctionSub => 'Push about auctions you follow.';

  @override
  String get notifSettingsAlways =>
      'Transaction, security and money notifications (account lock, password change, wallet, orders, complaints) are always sent. In-app notifications are always saved, even with push off.';

  @override
  String walletTopupMin(String amount) {
    return 'Minimum top-up $amount';
  }

  @override
  String get walletLoadError => 'Could not load the wallet.';

  @override
  String get walletHistoryFilterAll => 'All';

  @override
  String get walletLedgerTopup => 'Top-up';

  @override
  String get walletLedgerWithdraw => 'Withdrawal';

  @override
  String get walletLedgerHold => 'Funds held';

  @override
  String get walletLedgerRelease => 'Held funds released';

  @override
  String get walletLedgerPayout => 'Sale proceeds';

  @override
  String get walletLedgerRefund => 'Refund';

  @override
  String get walletLedgerCompensation => 'Compensation from Oldbook';

  @override
  String get walletLedgerCapture => 'Funds charged';

  @override
  String get walletLedgerFee => 'Fee';

  @override
  String get walletLedgerOther => 'Transaction';

  @override
  String walletBalanceAfter(String amount) {
    return 'Balance after: $amount';
  }

  @override
  String walletHeldNote(String amount) {
    return 'On hold: $amount';
  }

  @override
  String get walletMoreHistory => 'Top-up / withdrawal history';

  @override
  String get walletLoadMore => 'Load more';

  @override
  String get topupAmountLabel => 'Top-up amount';

  @override
  String topupAmountRange(String min, String max) {
    return 'From $min to $max';
  }

  @override
  String topupAmountOut(String min, String max) {
    return 'Amount must be between $min and $max.';
  }

  @override
  String get topupCreate => 'Create top-up request';

  @override
  String get topupOpenPay => 'Open payment page';

  @override
  String get topupWaiting => 'Waiting for payment…';

  @override
  String topupWaitingNote(String time) {
    return 'Finish paying, then come back to the app. Pay before: $time.';
  }

  @override
  String get topupCheckAgain => 'Check again';

  @override
  String topupPaid(String amount) {
    return 'Top-up successful $amount';
  }

  @override
  String get topupExpired =>
      'The request expired. If you still pay, the money is credited; tap check again.';

  @override
  String get topupFailed =>
      'Payment failed. If you were charged, please contact support.';

  @override
  String get topupDevPay => 'Dev: simulate successful payment';

  @override
  String get topupCannotOpen => 'Could not open the payment page.';

  @override
  String get withdrawPickBank => 'Choose a receiving account';

  @override
  String get withdrawNoBank => 'You have no bank account yet.';

  @override
  String get withdrawAddBank => 'Add account';

  @override
  String withdrawMinHint(String amount) {
    return 'Minimum $amount';
  }

  @override
  String withdrawCreated(String amount) {
    return 'Withdrawal of $amount requested. The money is held for review.';
  }

  @override
  String withdrawNeedHave(String required, String available) {
    return 'Need $required, you have $available.';
  }

  @override
  String withdrawBelowMin(String amount) {
    return 'The minimum withdrawal is $amount.';
  }

  @override
  String get withdrawNoCancel =>
      'A withdrawal cannot be cancelled by you. Contact Oldbook for help.';

  @override
  String get historyTitle => 'Top-up / withdrawal history';

  @override
  String get historyTopups => 'Top-ups';

  @override
  String get historyWithdrawals => 'Withdrawals';

  @override
  String get historyEmpty => 'No transactions yet.';

  @override
  String get topupStatusPending => 'Awaiting payment';

  @override
  String get topupStatusPaid => 'Received';

  @override
  String get topupStatusExpired => 'Expired';

  @override
  String get topupStatusFailed => 'Failed';

  @override
  String get wdStatusRequested => 'Awaiting review';

  @override
  String get wdStatusApproved => 'Approved, awaiting transfer';

  @override
  String get wdStatusSubmitted => 'Sent to the bank';

  @override
  String get wdStatusPaid => 'Transferred';

  @override
  String get wdStatusRejected => 'Rejected, money returned to your wallet';

  @override
  String get wdStatusFailed => 'Transfer failed, money returned to your wallet';

  @override
  String get wdStatusUnknown => 'Processing';

  @override
  String wdReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String wdTimeline(String created) {
    return 'Created $created';
  }

  @override
  String get bankPickBank => 'Bank';

  @override
  String get bankHolderMismatch =>
      'The holder name differs from your profile name. An admin may reject the withdrawal if they do not match.';

  @override
  String get bankNumberInvalid => 'Account number has 6 to 20 digits.';

  @override
  String get errBankDuplicate => 'This account is already saved.';

  @override
  String get errBankLimit =>
      'You can save at most 3 accounts. Remove one first.';

  @override
  String get errBankNotFound => 'Bank account not found.';

  @override
  String get errTopupRange => 'Top-up amount is outside the allowed range.';

  @override
  String get errIdempotencyInProgress =>
      'The previous request is still being processed, please wait a moment.';

  @override
  String get statusReserved => 'Reserved';

  @override
  String get statusUnpublished => 'Unpublished';

  @override
  String get conditionBrandNew => 'New';

  @override
  String get conditionWorn => 'Worn';

  @override
  String filterButtonCount(int n) {
    return 'Filter ($n)';
  }

  @override
  String get filterCondition => 'Condition';

  @override
  String get filterPrice => 'Price range (₫)';

  @override
  String get filterMin => 'From';

  @override
  String get filterMax => 'To';

  @override
  String get filterSort => 'Sort by';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPriceAsc => 'Price: low to high';

  @override
  String get sortPriceDesc => 'Price: high to low';

  @override
  String get filterApply => 'Apply';

  @override
  String get filterReset => 'Reset';

  @override
  String get filterPriceInvalid =>
      'The minimum price cannot exceed the maximum.';

  @override
  String get detailReserved => 'Someone has already reserved this book.';

  @override
  String get detailSold => 'This book has been sold.';

  @override
  String detailOwnerStatus(String status) {
    return 'Your listing status: $status';
  }

  @override
  String detailReviewReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String sellerStats(int n) {
    return '$n completed orders';
  }

  @override
  String sellerRating(String rating) {
    return '$rating ★';
  }

  @override
  String listingPhotoN(int n, String title) {
    return 'Photo $n of $title';
  }

  @override
  String get sellProgressCreate => 'Creating the listing…';

  @override
  String sellProgressUpload(int done, int total) {
    return 'Uploading photos $done/$total…';
  }

  @override
  String get sellProgressSubmit => 'Submitting for review…';

  @override
  String get sellErrCategory => 'Choose a category.';

  @override
  String get sellErrIsbn => 'Invalid ISBN.';

  @override
  String get sellFieldPublisher => 'Publisher (optional)';

  @override
  String get sellFieldYear => 'Publication year (optional)';

  @override
  String get sellFieldIsbn => 'ISBN (optional)';

  @override
  String get sellFieldDefects => 'Defects, if any (optional)';

  @override
  String get sellEditTitle => 'Edit listing';

  @override
  String get sellEditSave => 'Save changes';

  @override
  String get sellEditSaveSubmit => 'Save and submit';

  @override
  String get sellEditWarnTitle => 'The listing will go back to review';

  @override
  String get sellEditWarnBody =>
      'Changing the title, author, category, condition, publisher, year, ISBN, defects or photos puts the listing back into review and hides it from search. Price and description changes apply immediately.';

  @override
  String get sellEditWarnConfirm => 'Save anyway';

  @override
  String get sellSaved => 'Changes saved.';

  @override
  String get photoMakeCover => 'Make cover photo';

  @override
  String sellPhotoLimit(int n) {
    return 'At most $n photos.';
  }

  @override
  String get mlTabPublished => 'On sale';

  @override
  String get mlTabPending => 'In review';

  @override
  String get mlTabChanges => 'Needs changes';

  @override
  String get mlTabDraft => 'Drafts';

  @override
  String get mlTabUnpublished => 'Unpublished';

  @override
  String get mlTabSold => 'Sold';

  @override
  String get mlTabRejected => 'Rejected';

  @override
  String get mlEdit => 'Edit';

  @override
  String get mlSubmit => 'Submit';

  @override
  String get mlResubmit => 'Resubmit';

  @override
  String get mlRepublish => 'Republish';

  @override
  String get mlUnpublish => 'Unpublish';

  @override
  String get mlUnpublishTitle => 'Unpublish this listing?';

  @override
  String get mlUnpublishBody =>
      'The listing disappears from search. Republishing needs a new review.';

  @override
  String get mlRejectedFinal =>
      'A rejected listing is final. Create a new one if you like.';

  @override
  String mlReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get mlPendingNote =>
      'In review, usually within 24 hours. It cannot be edited yet.';

  @override
  String get mlSubmitted => 'Submitted for review.';

  @override
  String get mlUnpublished => 'Listing unpublished.';

  @override
  String get mlSimHeader => 'Auctions (simulated)';

  @override
  String get mlReservedNote =>
      'Someone reserved it; it cannot be edited or unpublished.';

  @override
  String get errCategoryInactive =>
      'This category is hidden. Choose another one.';

  @override
  String get errListingConcurrent =>
      'The listing was changed elsewhere. It was reloaded, please try again.';

  @override
  String get errListingPhoto =>
      'A photo is invalid (not uploaded, over 10 MB or not an image). Pick it again.';

  @override
  String get errListingIncomplete =>
      'The listing is not ready to submit (missing photos or details).';

  @override
  String get errPaymentUnavailable =>
      'Top-up is temporarily unavailable. Try again later.';

  @override
  String get errOrderNotFound => 'Order not found.';

  @override
  String get errOwnListing => 'You cannot buy your own book.';

  @override
  String get errCartFull => 'Your cart is full (50 items).';

  @override
  String get errComplaintNotFound => 'Complaint not found.';

  @override
  String get errComplaintAttachment =>
      'An evidence file is invalid (wrong type, too large or already used). Pick it again.';

  @override
  String get topupNoGateway => 'Top-up is temporarily unavailable.';

  @override
  String get topupPickGateway => 'Choose a payment gateway';

  @override
  String get topupConfirming =>
      'Confirming the payment; your balance will update in a few minutes. You will be notified once it succeeds.';

  @override
  String get soStatusAwaiting => 'Awaiting shipment';

  @override
  String get soStatusShipped => 'In transit';

  @override
  String get soStatusDelivered => 'Delivered';

  @override
  String get soStatusCompleted => 'Completed';

  @override
  String get soStatusCancelledBuyer => 'Cancelled';

  @override
  String get soStatusCancelledTimeout => 'Cancelled (seller timeout)';

  @override
  String get soStatusDisputed => 'In dispute';

  @override
  String get soStatusRefunded => 'Refunded';

  @override
  String get soStatusPartial => 'Partially refunded';

  @override
  String get soTabBuy => 'Purchases';

  @override
  String get soTabSell => 'Sales';

  @override
  String get soEmpty => 'No orders yet.';

  @override
  String get soSimLink => 'Auction orders (simulated)';

  @override
  String soNoteShipBy(String time) {
    return 'Ship by $time';
  }

  @override
  String soNoteTracking(String carrier, String code) {
    return '$carrier · $code';
  }

  @override
  String soNoteComplaintBy(String time) {
    return 'Complain by $time';
  }

  @override
  String get soNoteLocked => 'Funds are locked while the complaint is handled';

  @override
  String get soDetailTitle => 'Order details';

  @override
  String get soPrice => 'Book price';

  @override
  String get soShipFee => 'Shipping';

  @override
  String get soTotal => 'Total paid';

  @override
  String get soPayout => 'You receive';

  @override
  String get soPayoutFee => 'Platform fee';

  @override
  String get soPayoutNet => 'Net amount';

  @override
  String get soSeller => 'Seller';

  @override
  String get soBuyer => 'Buyer';

  @override
  String get soAddress => 'Delivery address';

  @override
  String get soShipment => 'Shipment';

  @override
  String get soTimeline => 'Timeline';

  @override
  String soCountdownShip(String time) {
    return 'Ship deadline: $time left';
  }

  @override
  String soCountdownShipBuyer(String time) {
    return 'The seller must ship within $time.';
  }

  @override
  String soCountdownComplaint(String time) {
    return 'Complaint window: $time left. After it ends the order completes automatically.';
  }

  @override
  String get soOverdue => 'overdue';

  @override
  String get soCancel => 'Cancel order';

  @override
  String get soCancelTitle => 'Cancel this order?';

  @override
  String get soCancelBody =>
      'The money returns to your wallet and the book is listed again.';

  @override
  String get soReceived => 'Mark received';

  @override
  String get soReceivedTitle => 'Confirm you received it?';

  @override
  String get soReceivedBody =>
      'After confirming you have a window to complain if the book has a problem.';

  @override
  String get soComplete => 'Happy, complete';

  @override
  String get soCompleteTitle => 'Complete the order?';

  @override
  String get soCompleteBody =>
      'The seller is paid immediately and you can no longer complain.';

  @override
  String get soShip => 'Enter tracking';

  @override
  String get soShipCarrier => 'Carrier';

  @override
  String get soShipTracking => 'Tracking number';

  @override
  String get soShipSubmit => 'Confirm shipped';

  @override
  String get soShipInvalid =>
      'Carrier 2 to 50 characters, tracking number 3 to 50.';

  @override
  String get soComplain => 'Complain';

  @override
  String get soViewComplaint => 'View complaint';

  @override
  String get soCancelled => 'Order cancelled.';

  @override
  String get soReceivedDone => 'Receipt confirmed.';

  @override
  String get soCompleted => 'Order completed.';

  @override
  String get soShipped => 'Tracking saved.';

  @override
  String get ckUnavailable => 'No longer available';

  @override
  String get ckRemove => 'Remove';

  @override
  String get ckSubtotal => 'Books';

  @override
  String ckShipping(int count, String fee) {
    return 'Shipping ($count orders × $fee)';
  }

  @override
  String get ckTotal => 'Total';

  @override
  String get ckBalance => 'Wallet balance';

  @override
  String get ckAddress => 'Deliver to';

  @override
  String get ckPickAddress => 'Choose an address';

  @override
  String get ckNoAddress => 'You have no delivery address yet.';

  @override
  String get ckAddAddress => 'Add address';

  @override
  String get ckPlace => 'Place order · pay from wallet';

  @override
  String get ckPlaceEmpty => 'No books available';

  @override
  String get ckNeedAddress => 'Choose an address to order';

  @override
  String get ckInsufficient => 'Insufficient balance · top up';

  @override
  String get ckEmpty => 'Your cart is empty.';

  @override
  String get ckPlacedTitle => 'Order placed';

  @override
  String ckPlacedBody(String total, int count) {
    return '$total was held from your wallet for $count orders. Sellers have a deadline to ship; late orders are cancelled and refunded.';
  }

  @override
  String get ckViewOrders => 'View orders';

  @override
  String get ckKeepShopping => 'Keep shopping';

  @override
  String get ckSomeUnavailable =>
      'Some books were just taken or removed. They are marked in your cart; remove them and order again.';

  @override
  String get ckAdded => 'Added to cart';

  @override
  String get ckAlready => 'Already in your cart';

  @override
  String get cpListTitle => 'My complaints';

  @override
  String get cpTabBuy => 'Raised by me';

  @override
  String get cpTabSell => 'About my sales';

  @override
  String get cpEmpty => 'No complaints yet.';

  @override
  String get cpStatusOpen => 'Awaiting seller';

  @override
  String get cpStatusResponded => 'Awaiting buyer decision';

  @override
  String get cpStatusEscalated => 'With an administrator';

  @override
  String get cpStatusAgreed => 'Agreed';

  @override
  String get cpStatusResolved => 'Resolved';

  @override
  String get cpReasonNotAsDescribed => 'Not as described';

  @override
  String get cpReasonDamaged => 'Damaged';

  @override
  String get cpReasonWrongItem => 'Wrong item';

  @override
  String get cpReasonOther => 'Other';

  @override
  String get cpOpenTitle => 'Open a complaint';

  @override
  String get cpReasonLabel => 'Reason';

  @override
  String get cpDescLabel => 'Describe the problem';

  @override
  String get cpDescHint => 'At least 10 characters';

  @override
  String get cpDescInvalid => 'The description must be 10 to 2,000 characters.';

  @override
  String get cpEvidence => 'Evidence (photos or video)';

  @override
  String cpEvidenceCount(int n) {
    return '$n/10 · at least 1 needed';
  }

  @override
  String get cpEvidenceRequired => 'Add at least 1 photo or video.';

  @override
  String get cpAddEvidence => 'Add photo/video';

  @override
  String get cpPickPhoto => 'Choose photo';

  @override
  String get cpPickVideo => 'Choose video';

  @override
  String get cpEvidenceTooLarge =>
      'File too large (photos up to 10 MB, videos up to 50 MB).';

  @override
  String get cpEvidenceUnsupported =>
      'Unsupported format (photos JPEG/PNG/WebP, videos MP4/MOV/WebM).';

  @override
  String get cpSubmit => 'Submit complaint';

  @override
  String cpUploading(int done, int total) {
    return 'Uploading evidence $done/$total…';
  }

  @override
  String get cpOpened => 'Complaint submitted.';

  @override
  String get cpOpenNote =>
      'Opening a complaint locks the order\'s money until it is resolved.';

  @override
  String get cpOrder => 'Order';

  @override
  String get cpOpenOrder => 'View order';

  @override
  String cpSellerDeadline(String time) {
    return 'The seller must respond: $time left';
  }

  @override
  String cpBuyerDeadline(String time) {
    return 'You must decide: $time left';
  }

  @override
  String get cpDeadlineNote =>
      'After the deadline the complaint goes to an administrator automatically.';

  @override
  String get cpEscSellerTimeout =>
      'Escalated: the seller did not respond in time.';

  @override
  String get cpEscBuyerRejected => 'Escalated: the buyer disagreed.';

  @override
  String get cpEscBuyerTimeout =>
      'Escalated: the buyer did not decide in time.';

  @override
  String get cpEscAuction => 'Escalated (auction order).';

  @override
  String get cpResolution => 'Outcome';

  @override
  String get cpOutFull => 'Full refund (book and shipping)';

  @override
  String cpOutPartial(String amount) {
    return 'Partial refund: $amount';
  }

  @override
  String get cpOutRelease => 'No refund: money goes to the seller';

  @override
  String get cpReturnRequired =>
      'An administrator asks the buyer to send the book back. Returning happens outside the system; the parties can talk in messages.';

  @override
  String get cpByAdmin => 'Decided by an administrator';

  @override
  String get cpByAgreement => 'Agreed by both parties';

  @override
  String get cpAuthorBuyer => 'Buyer';

  @override
  String get cpAuthorSeller => 'Seller';

  @override
  String get cpAuthorAdmin => 'Administrator';

  @override
  String get cpAuthorSystem => 'System';

  @override
  String get cpEntryOpened => 'Complaint opened';

  @override
  String get cpEntrySellerResponse => 'Seller responded';

  @override
  String get cpEntryBuyerDecision => 'Buyer decided';

  @override
  String get cpEntryEscalated => 'Escalated to an administrator';

  @override
  String get cpEntryResolved => 'Resolved';

  @override
  String cpRefundAmount(String amount) {
    return 'Refund $amount';
  }

  @override
  String get cpRespond => 'Respond';

  @override
  String get cpRespondTitle => 'Respond to the complaint';

  @override
  String get cpActAccept => 'Agree to a full refund (book and shipping)';

  @override
  String get cpActPartial => 'Offer a partial refund';

  @override
  String get cpActReject => 'Reject';

  @override
  String get cpAmountLabel => 'Refund amount (of the book price)';

  @override
  String cpAmountInvalid(String max) {
    return 'Amount must be between 1 and $max.';
  }

  @override
  String get cpRejectReason =>
      'Reason for rejecting (add photo evidence if you can)';

  @override
  String get cpReasonInvalid => 'The reason needs at least 10 characters.';

  @override
  String get cpRespondSubmit => 'Send response';

  @override
  String get cpResponded => 'Response sent.';

  @override
  String get cpRespondNote => 'The buyer still has to confirm the result.';

  @override
  String get cpAccept => 'Agree';

  @override
  String get cpDisagree => 'Disagree, send to admin';

  @override
  String get cpAcceptTitle => 'Agree with the response?';

  @override
  String get cpAcceptFull =>
      'You get a full refund of the book price and shipping.';

  @override
  String cpAcceptPartial(String amount) {
    return 'You get $amount back. The rest goes to the seller.';
  }

  @override
  String get cpAcceptReject =>
      'The seller rejected. Agreeing means you WITHDRAW the complaint and the money goes to the seller.';

  @override
  String get cpDisagreeTitle => 'Send to an administrator?';

  @override
  String get cpDisagreeBody => 'An administrator will review and decide.';

  @override
  String get cpDecided => 'Decision recorded.';

  @override
  String get cpMessageHint => 'Type a message…';

  @override
  String get cpSend => 'Send';

  @override
  String get cpMessageClosed => 'The complaint is closed; messaging is off.';

  @override
  String get cpMessageNeed => 'Enter a message or attach a file.';

  @override
  String get cpOpenVideo => 'Open video';

  @override
  String get cpLockedNote =>
      'The order\'s money is locked until the complaint is resolved.';

  @override
  String otpSentToEmail(String email) {
    return 'Code sent to $email. Check your Spam/Promotions folder too.';
  }

  @override
  String get emailOtpHelper => 'The OTP will be sent to this email.';

  @override
  String get emailNotSet => 'No email';

  @override
  String get errEmailTakenLogin =>
      'This email belongs to another account. If it\'s yours, sign in.';

  @override
  String get errEmailRequired =>
      'This account has no email. Please contact support.';

  @override
  String get errOtpSendFailed => 'Couldn\'t send the code. Try again later.';

  @override
  String get aoTitle => 'Auction orders';

  @override
  String get aoDetailTitle => 'Auction order';

  @override
  String get aoTabBuyer => 'Won by me';

  @override
  String get aoTabSeller => 'Sold by me';

  @override
  String get aoFilterAction => 'Needs action';

  @override
  String get aoFilterShipping => 'Shipping';

  @override
  String get aoFilterFinished => 'Finished';

  @override
  String get aoEmpty => 'No auction orders yet.';

  @override
  String get aoEmptyBuyerHint => 'Win an auction and its order shows up here.';

  @override
  String aoWinningPrice(String amount) {
    return 'Winning price $amount';
  }

  @override
  String get aoStatusAwaitingFee => 'Awaiting shipping fee';

  @override
  String get aoStatusReadyToShip => 'Ready to ship';

  @override
  String get aoStatusInDelivery => 'In delivery';

  @override
  String get aoStatusInStorage => 'In storage';

  @override
  String get aoStatusDelivered => 'Delivered';

  @override
  String get aoStatusPickedUp => 'Picked up';

  @override
  String get aoStatusStorageExpired => 'Storage expired';

  @override
  String get aoStatusDisputed => 'Disputed';

  @override
  String get aoStatusCompleted => 'Completed';

  @override
  String get aoStatusRefunded => 'Refunded';

  @override
  String get aoStatusPartiallyRefunded => 'Partially refunded';

  @override
  String get aoPeAwaitingDecision => 'Waiting for your decision';

  @override
  String get aoPeExtended => 'Storage extended';

  @override
  String get aoPeAwaitingLiquidation => 'Book will be liquidated';

  @override
  String get aoPeLiquidated => 'Liquidated';

  @override
  String get aoPeReleased => 'Released to you';

  @override
  String get aoPeDecisionBody =>
      'The seller has been paid and the book is still yours. Extend, pick up or request redelivery before the deadline, otherwise it will be liquidated.';

  @override
  String aoDecisionLeft(String left) {
    return '$left left to decide';
  }

  @override
  String aoExtendButton(String fee, int n) {
    return 'Extend for $fee ($n left)';
  }

  @override
  String get aoExtendTitle => 'Extend storage';

  @override
  String aoExtendBody(String fee, int days) {
    return 'Prepay $fee to keep the book for $days more days.';
  }

  @override
  String aoExtendedUntil(String date) {
    return 'Extended until $date';
  }

  @override
  String get aoLiquidationBody =>
      'No decision was made in time. Admin will liquidate the book and credit the proceeds (minus fee) to your wallet.';

  @override
  String aoLiquidatedBody(String amount) {
    return '$amount was credited to your wallet (after the liquidation fee).';
  }

  @override
  String get aoAddressRequiredTitle => 'No delivery address';

  @override
  String get aoAddressRequiredBody =>
      'The warehouse can only ship once the order has an address. Pick one from your address book.';

  @override
  String aoFeeNeededTitle(String amount) {
    return '$amount shipping fee needed';
  }

  @override
  String aoFeeNeededBefore(String amount, String date) {
    return '$amount shipping fee needed by $date';
  }

  @override
  String get aoFeeNeededBody =>
      'After the deadline the book still ships and the fee is deducted from your deposit.';

  @override
  String aoTimeLeft(String left) {
    return '$left left';
  }

  @override
  String get aoPayFeeButton => 'Top up and pay shipping';

  @override
  String get aoPayFeeTitle => 'Pay shipping fee';

  @override
  String aoPayFeeBody(String amount) {
    return '$amount will be held from your wallet for the next delivery.';
  }

  @override
  String aoPayFeeConfirm(String amount) {
    return 'Hold $amount';
  }

  @override
  String get aoFeeHeld => 'Shipping fee held';

  @override
  String get aoFeeHeldBody => 'The warehouse will ship soon.';

  @override
  String get aoReadyTitle => 'Warehouse is preparing your book';

  @override
  String get aoReadyBody =>
      'You can change the address until the book leaves the warehouse.';

  @override
  String get aoInDeliveryTitle => 'Out for delivery';

  @override
  String aoInDeliveryBody(int count, int max) {
    return 'Attempt $count/$max. After too many failed attempts the book returns to storage.';
  }

  @override
  String get aoInStorageTitle => 'Book is in storage';

  @override
  String aoInStorageBody(int max, String perDay, String accrued) {
    return 'Delivery failed $max times so the book went back to storage. Storage fee $perDay/day, accrued $accrued (taken from your deposit).';
  }

  @override
  String aoStorageLeft(String left) {
    return '$left of storage left';
  }

  @override
  String get aoChosenPickup => 'You chose to pick up at the warehouse.';

  @override
  String get aoChosenRedeliver => 'You chose redelivery.';

  @override
  String get aoPickup => 'Pick up';

  @override
  String get aoRedeliver => 'Redeliver';

  @override
  String get aoPickupTitle => 'Pick up at warehouse';

  @override
  String get aoPickupBody =>
      'Collect the book at the Oldbook warehouse. Storage fees apply until pickup.';

  @override
  String get aoRedeliverTitle => 'Redeliver';

  @override
  String aoRedeliverBody(String amount) {
    return '$amount more shipping fee will be held for redelivery.';
  }

  @override
  String get aoChoiceSaved => 'Choice saved.';

  @override
  String get aoDeliveredTitle => 'Delivered';

  @override
  String get aoPickedUpTitle => 'Picked up';

  @override
  String get aoComplaintWindowBody =>
      'Check the book. Report any issue before the deadline; auction complaints go straight to Oldbook.';

  @override
  String aoComplaintLeft(String left) {
    return '$left left to complain';
  }

  @override
  String get aoComplain => 'Report a problem';

  @override
  String get aoDisputedTitle => 'Complaint in progress';

  @override
  String get aoDisputedBody =>
      'Oldbook is reviewing the evidence and will decide.';

  @override
  String get aoViewComplaint => 'View complaint';

  @override
  String aoFinishedAt(String date) {
    return 'Finished at $date';
  }

  @override
  String get aoUnsupportedStatus =>
      'Unsupported status, please update the app.';

  @override
  String get aoDeadlinePassed => 'Deadline passed';

  @override
  String get aoSellerInProgress =>
      'The Oldbook warehouse is handling delivery to the winner. You get paid when the order completes.';

  @override
  String get aoSellerFinished => 'This order is finished.';

  @override
  String get aoMoneyTitle => 'Money';

  @override
  String get aoMoneyFinal => 'Winning price';

  @override
  String get aoMoneyDeposit => 'Deposit held';

  @override
  String get aoMoneyShipping => 'Shipping fee per delivery';

  @override
  String get aoMoneyShippingUnpaid => 'Unpaid shipping (from deposit)';

  @override
  String get aoMoneyStorage => 'Storage fee (from deposit)';

  @override
  String get aoMoneyCommission => 'Commission';

  @override
  String get aoMoneyNet => 'You receive';

  @override
  String get aoMoneyNote =>
      'The deposit is returned when the order completes, minus unpaid shipping and storage fees.';

  @override
  String get aoNoAddressYet => 'No delivery address yet';

  @override
  String get aoChangeAddress => 'Change';

  @override
  String get aoNoAddress => 'You have no addresses yet, add one first.';

  @override
  String get aoAddressSaved => 'Delivery address updated.';

  @override
  String get aoNeedAddressFirst => 'Pick a delivery address first.';

  @override
  String get aoDeliveryTitle => 'Delivery';

  @override
  String aoAttempt(int round, int n) {
    return 'Round $round · attempt $n';
  }

  @override
  String get aoViewAuction => 'View auction';

  @override
  String get aucStatusAwaitingInbound => 'Awaiting warehouse';

  @override
  String get aucStatusPendingReview => 'Pending review';

  @override
  String get aucStatusNotEnough => 'Not enough bidders';

  @override
  String get aucStatusRejected => 'Rejected';

  @override
  String get aucStatusCancelled => 'Cancelled';

  @override
  String get aucStatusConverted => 'Converted to sale';

  @override
  String get aucStatusReturned => 'Returned';

  @override
  String get aucTimerInboundDeadline => 'Ship by';

  @override
  String get aucTimerFallbackDeadline => 'Decide by';

  @override
  String aucSubRegistrationOpen(String time) {
    return 'Auction starts $time.';
  }

  @override
  String get aucRegConfirmedTag => 'Confirmed';

  @override
  String get aucRegCancelledTag => 'Cancelled';

  @override
  String get aucRegRefundedTag => 'Refunded';

  @override
  String get aucRegCompletedTag => 'Participated';

  @override
  String get aucReturnAwaitingFee => 'Awaiting fee';

  @override
  String get aucReturnReady => 'Ready to dispatch';

  @override
  String get aucReturnDispatched => 'Dispatched';

  @override
  String aucNeedTopup(String amount) {
    return 'Your wallet is short by $amount.';
  }

  @override
  String aucErrTooLowMin(String amount) {
    return 'Bid is below the minimum of $amount.';
  }

  @override
  String bidConfirmTitle(String amount) {
    return 'Bid $amount?';
  }

  @override
  String bidConfirmHold(String amount) {
    return '$amount will be held in your wallet while you lead.';
  }

  @override
  String get bidConfirmOutbid =>
      'If you are outbid, the hold is released immediately.';

  @override
  String get aucWillHold => 'Will hold';

  @override
  String get fbTitle => 'Choose an option';

  @override
  String get fbReschedule => 'Reschedule';

  @override
  String fbRescheduleSub(int n) {
    return 'Reopen registration with a new start time · $n left';
  }

  @override
  String get fbConvert => 'Convert to fixed-price sale';

  @override
  String get fbConvertSub =>
      'Creates a listing at your price; the warehouse returns the book to you first';

  @override
  String get fbReturn => 'Get the book back';

  @override
  String get fbReturnSub =>
      'The warehouse returns the book at your shipping cost';

  @override
  String get fbPickStart => 'Pick a new start time';

  @override
  String get fbPrice => 'Sale price (VND)';

  @override
  String get fbPriceInvalid => 'Minimum 1,000 VND';

  @override
  String get fbReturnNote =>
      'The return shipping fee will be held from your wallet.';

  @override
  String get fbConfirm => 'Confirm';

  @override
  String get fbDone => 'Option saved.';

  @override
  String get aucCancel => 'Cancel auction';

  @override
  String get aucCancelConfirm =>
      'Cancel this auction? The book has not reached the warehouse, so there is no fee.';

  @override
  String get aucCancelConfirmInWarehouse =>
      'The book is in the warehouse: cancelling creates a return and you pay the shipping.';

  @override
  String get aucCancelledBySeller => 'You cancelled this auction.';

  @override
  String get aucCancelledTimeout =>
      'The warehouse did not receive the book in time, so the auction was cancelled.';

  @override
  String get aucPendingReviewTitle => 'Book received';

  @override
  String get aucPendingReviewBody =>
      'Admin is inspecting the book and reviewing the auction.';

  @override
  String get aucRejectedTitle => 'Auction rejected';

  @override
  String get aucSellerWaitingTitle => 'Waiting for the auction';

  @override
  String get aucNotEnoughTitle => 'Not enough participants';

  @override
  String get aucNoBidTitle => 'No bids were placed';

  @override
  String get aucFallbackBody =>
      'Reschedule, convert to a sale or get the book back. If you do nothing, the book is returned automatically.';

  @override
  String aucFallbackLeft(String left) {
    return '$left left to decide';
  }

  @override
  String get aucFallbackExpired => 'Decision deadline passed';

  @override
  String get aucSoldTitle => 'Auction sold';

  @override
  String aucSoldBody(String amount) {
    return 'Final price $amount. You get paid when the order completes.';
  }

  @override
  String get aucViewOrder => 'View order';

  @override
  String get aucConvertedTitle => 'Converted to a sale';

  @override
  String get aucConvertedBody =>
      'The warehouse returns the book to you first so you can ship it to the buyer.';

  @override
  String get aucViewListing => 'View listing';

  @override
  String get aucReturnedBody => 'The book is being returned to you.';

  @override
  String get aucSellerSection => 'Your auction';

  @override
  String get aucInboundHint =>
      'Write this code on the package and send it to the warehouse before the deadline, or the auction is cancelled.';

  @override
  String aucInboundLeft(String left) {
    return '$left left to ship the book';
  }

  @override
  String get aucInboundExpired => 'Shipping deadline passed';

  @override
  String get aucWarehouse => 'Warehouse address';

  @override
  String get aucCopyShipping => 'Copy shipping details';

  @override
  String get aucReturnTitle => 'Book return';

  @override
  String aucReturnFeeNeeded(String amount) {
    return 'Your wallet lacks the $amount return shipping fee. Top up and it will be held within an hour.';
  }

  @override
  String aucReturnFee(String amount) {
    return 'Return shipping fee $amount.';
  }

  @override
  String aucReturnTracking(String carrier, String tracking) {
    return '$carrier · $tracking';
  }

  @override
  String get aucClosing => 'Closing…';

  @override
  String get aucRealtimeOffline =>
      'Realtime disconnected, prices may lag. Pull to refresh.';

  @override
  String get aucBuyNowTag => 'Buy now';

  @override
  String aucOutbidToast(String amount) {
    return 'You were outbid ($amount). Your hold was released.';
  }

  @override
  String get aucEndedToast => 'The auction has ended.';

  @override
  String aucUnregisterConfirm(String amount) {
    return 'Cancel registration? $amount in fee and deposit returns to your wallet.';
  }

  @override
  String get aucRegistrationUnavailable =>
      'Registration is closed for this auction.';

  @override
  String get myAuctionsShort => 'Mine';

  @override
  String get myAucTabSeller => 'Selling';

  @override
  String get myAucTabBidder => 'Joined';

  @override
  String get myAucTabLeading => 'Leading';

  @override
  String get myAucTabWinner => 'Won';

  @override
  String get myAucCreate => 'Create an auction';

  @override
  String get myAucEmptySeller => 'You have not created any auctions.';

  @override
  String get myAucEmptyLeading => 'You are not leading any auction.';

  @override
  String get myAucEmptyWinner => 'You have not won any auction yet.';

  @override
  String get meAuctionOrdersSub => 'Shipping, delivery, storage';

  @override
  String get mlAuctionsLink => 'Your auctions';

  @override
  String get soAuctionOrdersLink => 'Auction orders';

  @override
  String get sellDoneViewAuction => 'View auction';

  @override
  String get sellStartAt => 'Desired start time';

  @override
  String sellStartTooSoon(String date) {
    return 'Start time too soon. Earliest: $date. Updated, please submit again.';
  }

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get loadMore => 'Load more';

  @override
  String get errAuctionNotFound => 'Auction not found.';

  @override
  String get errAuctionOwn => 'This is your own auction.';

  @override
  String get errAuctionAlreadyRegistered => 'You are already registered.';

  @override
  String get errAuctionRegistrationNotFound =>
      'You are not registered for this auction.';

  @override
  String get errAuctionStartTooSoon => 'Start time is too soon.';

  @override
  String get errAuctionRescheduleLimit => 'No reschedules left.';

  @override
  String get errAuctionPhotoInvalid => 'Invalid photo, please pick again.';

  @override
  String get errAuctionOrderNotFound => 'Auction order not found.';

  @override
  String get errAuctionOrderAddressRequired => 'Pick a delivery address first.';

  @override
  String get errAuctionOrderExtensionLimit => 'No extensions left.';

  @override
  String get ckRemoveSelected => 'Remove selected';

  @override
  String get ckAll => 'All';

  @override
  String get ckSelectToPay => 'Select books to check out';

  @override
  String ckPay(String amount) {
    return 'Pay $amount';
  }

  @override
  String ckSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get ckNoneSelected => 'Nothing selected';

  @override
  String get ckPayWith => 'Pay with';

  @override
  String get ckWallet => 'Oldbook wallet';

  @override
  String ckWalletAfter(String balance, String left) {
    return 'Balance $balance · $left left after paying';
  }

  @override
  String get ckChange => 'Change';

  @override
  String ckItemsCount(int count) {
    return '$count books';
  }

  @override
  String ckPlacedCount(int count) {
    return '$count orders placed';
  }

  @override
  String ckTrackOrders(int count) {
    return 'Track $count orders';
  }

  @override
  String get ckNotifyHint =>
      'You will be notified when each order ships, with its tracking code.';

  @override
  String get ckSeparateOrders =>
      'Each book creates its own order. Money is held in your wallet until you receive it.';

  @override
  String ckOrderLine(String code) {
    return 'ORDER #$code';
  }

  @override
  String ckAllOrNothing(int count) {
    return 'Creates $count separate orders. If one fails, none is charged.';
  }

  @override
  String get ckPayTitle => 'Checkout';

  @override
  String get sellStepMode => 'Format';

  @override
  String get sellStepBook => 'Book';

  @override
  String get sellStepPrice => 'Price';

  @override
  String get sellStepReview => 'Review';

  @override
  String get sellModeQuestion => 'How do you want to sell?';

  @override
  String get sellModeHint => 'Pick one. You can change it before submitting.';

  @override
  String get sellModeFixedDesc =>
      'Set a fixed price, buyers order right away. Good for common books.';

  @override
  String get sellModeAuctionDesc =>
      'Buyers bid against each other. Good for rare or old editions.';

  @override
  String get sellNext => 'Continue';

  @override
  String get sellBack => 'Back';

  @override
  String get sellEdit => 'Edit';

  @override
  String get sellReviewHeader => 'Buyers will see';

  @override
  String get sellDoneAnother => 'List another book';

  @override
  String get sellReviewPrice => 'Price';

  @override
  String get sellReviewDuration => 'Duration';

  @override
  String get sellReviewStartAt => 'Starts';
}
