// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Book Marketplace';

  @override
  String get retry => 'Thử lại';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get close => 'Đóng';

  @override
  String get loading => 'Đang tải';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get homePlaceholderTitle => 'Đang phát triển';

  @override
  String get homePlaceholderMessage =>
      'Màn hình trang chủ sẽ có ở phiên bản sau.';

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get loginSubtitle => 'Chào mừng bạn quay lại chợ sách cũ.';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get noAccountPrompt => 'Chưa có tài khoản?';

  @override
  String get registerLink => 'Đăng ký';

  @override
  String get registerTitle => 'Tạo tài khoản';

  @override
  String get registerSubtitle => 'Chỉ mất một phút để bắt đầu mua bán sách cũ.';

  @override
  String get registerButton => 'Đăng ký';

  @override
  String get haveAccountPrompt => 'Đã có tài khoản?';

  @override
  String get loginLink => 'Đăng nhập';

  @override
  String get roleLabel => 'Bạn muốn';

  @override
  String get roleOptionBuyer => 'Mua sách';

  @override
  String get roleOptionSeller => 'Bán sách';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logoutConfirmTitle => 'Đăng xuất?';

  @override
  String get logoutConfirmMessage =>
      'Bạn cần đăng nhập lại để tiếp tục sử dụng.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get fullNameLabel => 'Họ và tên';

  @override
  String get phoneLabel => 'Số điện thoại';

  @override
  String get showPassword => 'Hiện mật khẩu';

  @override
  String get hidePassword => 'Ẩn mật khẩu';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get editProfile => 'Sửa hồ sơ';

  @override
  String get changeAvatar => 'Đổi ảnh đại diện';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get languageVi => 'Tiếng Việt';

  @override
  String get languageEn => 'English';

  @override
  String get phoneNotSet => 'Chưa cập nhật';

  @override
  String get memberSince => 'Ngày tham gia';

  @override
  String get roleBuyer => 'Người mua';

  @override
  String get roleSeller => 'Người bán';

  @override
  String get roleInspector => 'Kiểm định viên';

  @override
  String get roleAdmin => 'Quản trị viên';

  @override
  String get roleUnknown => 'Người dùng';

  @override
  String get emailReadOnlyHelper =>
      'Email dùng để đăng nhập nên không thể thay đổi.';

  @override
  String get profileUpdated => 'Đã cập nhật hồ sơ';

  @override
  String get avatarPreviewLabel => 'Ảnh đại diện';

  @override
  String get avatarHint => 'JPG, PNG hoặc WebP, tối đa 5 MB.';

  @override
  String get chooseFromGallery => 'Chọn từ thư viện';

  @override
  String get takePhoto => 'Chụp ảnh';

  @override
  String get saveAvatar => 'Lưu ảnh';

  @override
  String get removeAvatar => 'Xóa ảnh đại diện';

  @override
  String get removeAvatarConfirmTitle => 'Xóa ảnh đại diện?';

  @override
  String get removeAvatarConfirmMessage =>
      'Ảnh của bạn sẽ được thay bằng chữ cái đầu tên.';

  @override
  String get avatarUpdated => 'Đã cập nhật ảnh đại diện';

  @override
  String get avatarRemoved => 'Đã xóa ảnh đại diện';

  @override
  String get currentPasswordLabel => 'Mật khẩu hiện tại';

  @override
  String get newPasswordLabel => 'Mật khẩu mới';

  @override
  String get confirmPasswordLabel => 'Nhập lại mật khẩu mới';

  @override
  String get passwordLengthHelper => 'Từ 8 đến 72 ký tự.';

  @override
  String get passwordRuleHelper =>
      'Từ 8 đến 72 ký tự và khác mật khẩu hiện tại.';

  @override
  String get passwordChangedOtherDevices =>
      'Các thiết bị khác sẽ được đăng xuất.';

  @override
  String get passwordChanged => 'Đã đổi mật khẩu';

  @override
  String changePasswordLocked(int seconds) {
    return 'Thử lại sau $seconds giây';
  }

  @override
  String get validationFullNameRequired => 'Vui lòng nhập họ và tên.';

  @override
  String get validationFullNameTooLong => 'Họ và tên tối đa 100 ký tự.';

  @override
  String get validationPhoneInvalid =>
      'Số điện thoại phải bắt đầu bằng 0 hoặc +84, theo sau là 9 hoặc 10 chữ số.';

  @override
  String get validationEmailRequired => 'Vui lòng nhập email.';

  @override
  String get validationEmailInvalid => 'Email chưa đúng định dạng.';

  @override
  String get validationPasswordRequired => 'Vui lòng nhập mật khẩu.';

  @override
  String get validationPasswordLength => 'Mật khẩu phải từ 8 đến 72 ký tự.';

  @override
  String get validationPasswordSame =>
      'Mật khẩu mới phải khác mật khẩu hiện tại.';

  @override
  String get validationPasswordMismatch => 'Mật khẩu nhập lại chưa khớp.';

  @override
  String get errorNetwork =>
      'Không có kết nối mạng. Hãy kiểm tra mạng rồi thử lại.';

  @override
  String get errorValidation =>
      'Thông tin chưa hợp lệ. Hãy kiểm tra lại các ô bên trên.';

  @override
  String get errorFieldInvalid => 'Giá trị chưa hợp lệ.';

  @override
  String get errorAvatarInvalid =>
      'Ảnh không hợp lệ hoặc vượt quá 5 MB. Hãy chọn ảnh khác.';

  @override
  String get errorAvatarUnsupported =>
      'Chỉ hỗ trợ ảnh JPG, PNG hoặc WebP. Hãy chọn ảnh khác.';

  @override
  String get errorAvatarTooLarge => 'Ảnh vượt quá 5 MB. Hãy chọn ảnh nhỏ hơn.';

  @override
  String get errorPickImage =>
      'Không mở được ảnh. Hãy kiểm tra quyền truy cập rồi thử lại.';

  @override
  String get errorUploadFailed => 'Tải ảnh lên thất bại. Hãy thử lại.';

  @override
  String get errorCurrentPasswordIncorrect => 'Mật khẩu hiện tại chưa đúng.';

  @override
  String get errorPasswordUnchanged => 'Mật khẩu mới phải khác mật khẩu cũ.';

  @override
  String get errorInvalidCredentials => 'Email hoặc mật khẩu chưa đúng.';

  @override
  String get errorSessionExpired =>
      'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.';

  @override
  String get errorUserNotFound => 'Tài khoản không còn tồn tại.';

  @override
  String get errorInternal =>
      'Hệ thống đang gặp sự cố. Hãy thử lại sau ít phút.';

  @override
  String get errorUnknown => 'Đã có lỗi xảy ra. Hãy thử lại.';

  @override
  String supportCode(String traceId) {
    return 'Mã hỗ trợ: $traceId';
  }

  @override
  String get navMyListings => 'Tin của tôi';

  @override
  String get navNotifications => 'Thông báo';

  @override
  String get navQueue => 'Hàng đợi';

  @override
  String get navClaimed => 'Đang giữ';

  @override
  String get sellAction => 'Đăng bán';

  @override
  String get adminWebNote => 'Chức năng quản trị nằm ở cổng web.';

  @override
  String get loadMoreFailed => 'Không tải thêm được. Chạm để thử lại.';

  @override
  String get optionalHint => 'Không bắt buộc';

  @override
  String get edit => 'Sửa';

  @override
  String get done => 'Xong';

  @override
  String get comingSoon => 'Mua hàng và đặt giá sẽ có ở phiên bản sau.';

  @override
  String get emptyBrowseTitle => 'Chưa có sách nào';

  @override
  String get emptyBrowseMessage => 'Sách đã kiểm định sẽ xuất hiện ở đây.';

  @override
  String get emptyMineTitle => 'Bạn chưa có tin nào';

  @override
  String get emptyMineMessage => 'Bấm Đăng bán để tạo tin đầu tiên.';

  @override
  String get emptyQueueTitle => 'Hàng đợi trống';

  @override
  String get emptyQueueMessage => 'Không có tin nào đang chờ kiểm định.';

  @override
  String get emptyClaimedTitle => 'Bạn chưa giữ tin nào';

  @override
  String get emptyClaimedMessage =>
      'Nhận tin từ hàng đợi để bắt đầu kiểm định.';

  @override
  String get emptyNotificationsTitle => 'Chưa có thông báo';

  @override
  String get emptyNotificationsMessage => 'Kết quả kiểm định sẽ hiện ở đây.';

  @override
  String get statusDraft => 'Nháp';

  @override
  String get statusPendingInspection => 'Chờ kiểm định';

  @override
  String get statusInInspection => 'Đang kiểm định';

  @override
  String get statusRejected => 'Bị từ chối';

  @override
  String get statusOnSale => 'Đang bán';

  @override
  String get statusAuctioning => 'Đang đấu giá';

  @override
  String get statusClosed => 'Đã đóng';

  @override
  String get statusUnknown => 'Không rõ';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get categoryAll => 'Tất cả danh mục';

  @override
  String get conditionLikeNew => 'Như mới';

  @override
  String get conditionLikeNewDesc =>
      'Gần như chưa qua sử dụng, không có dấu hiệu đã đọc.';

  @override
  String get conditionVeryGood => 'Rất tốt';

  @override
  String get conditionVeryGoodDesc =>
      'Rất ít dấu hiệu sử dụng, không rách, không ghi chú.';

  @override
  String get conditionGood => 'Tốt';

  @override
  String get conditionGoodDesc =>
      'Có dấu hiệu sử dụng nhẹ, nội dung nguyên vẹn.';

  @override
  String get conditionFair => 'Khá';

  @override
  String get conditionFairDesc =>
      'Có vết ố, gấp góc hoặc ghi chú nhưng đọc được đầy đủ.';

  @override
  String get conditionPoor => 'Cũ nhiều';

  @override
  String get conditionPoorDesc => 'Hư hỏng rõ rệt nhưng nội dung vẫn đầy đủ.';

  @override
  String get coverPaperback => 'Bìa mềm';

  @override
  String get coverHardcover => 'Bìa cứng';

  @override
  String get imageFrontCover => 'Bìa trước';

  @override
  String get imageBackCover => 'Bìa sau';

  @override
  String get imageSpine => 'Gáy sách';

  @override
  String get imageInnerPage => 'Trang trong';

  @override
  String get imageExtra => 'Ảnh thêm';

  @override
  String get saleFixedPrice => 'Giá cố định';

  @override
  String get saleAuction => 'Đấu giá';

  @override
  String get startOnApproval => 'Ngay khi được duyệt';

  @override
  String get startScheduled => 'Hẹn giờ';

  @override
  String get reasonBlurryPhotos => 'Ảnh không đủ hoặc không rõ';

  @override
  String get reasonDescriptionMismatch => 'Mô tả không khớp hiện trạng';

  @override
  String get reasonSuspectedPirated => 'Nghi ngờ sách in lậu';

  @override
  String get reasonProhibitedPublication => 'Xuất bản phẩm bị cấm lưu hành';

  @override
  String get reasonDamageBeyondThreshold =>
      'Sách hư hỏng vượt ngưỡng chấp nhận';

  @override
  String get reasonWrongCatalogInfo => 'Thông tin thư mục sai';

  @override
  String get reasonDuplicateListing => 'Trùng lặp tin đăng';

  @override
  String get notificationsTitle => 'Thông báo';

  @override
  String get markAllRead => 'Đọc tất cả';

  @override
  String get unreadOnly => 'Chưa đọc';

  @override
  String get notifListingApproved => 'Tin đăng của bạn đã được duyệt';

  @override
  String get notifListingRejected => 'Tin đăng của bạn bị từ chối';

  @override
  String get notifListingClosed => 'Tin đăng của bạn đã bị đóng';

  @override
  String get wizardTitleNew => 'Đăng bán sách';

  @override
  String get wizardTitleEdit => 'Sửa tin đăng';

  @override
  String get wizardStepBook => 'Thông tin sách';

  @override
  String get wizardStepPhotos => 'Ảnh';

  @override
  String get wizardStepSale => 'Cách bán';

  @override
  String get wizardStepReview => 'Xem lại';

  @override
  String wizardStepOf(int current, int total) {
    return 'Bước $current/$total';
  }

  @override
  String get next => 'Tiếp';

  @override
  String get back => 'Quay lại';

  @override
  String get submitForInspection => 'Nộp kiểm định';

  @override
  String get draftSavedHint => 'Bản nháp được lưu sau mỗi bước.';

  @override
  String get fieldTitle => 'Tên sách';

  @override
  String get fieldAuthor => 'Tác giả';

  @override
  String get fieldCategory => 'Danh mục';

  @override
  String get fieldPublisher => 'Nhà xuất bản';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldYear => 'Năm xuất bản';

  @override
  String get fieldLanguage => 'Ngôn ngữ (mã 2 chữ cái)';

  @override
  String get fieldLanguageHelper => 'Ví dụ: vi, en';

  @override
  String get fieldPages => 'Số trang';

  @override
  String get fieldCover => 'Loại bìa';

  @override
  String get fieldCondition => 'Tình trạng sách';

  @override
  String get fieldConditionHelper =>
      'Chọn mức gần đúng nhất. Kiểm định viên sẽ xác nhận.';

  @override
  String get fieldDescription => 'Mô tả';

  @override
  String fieldDescriptionHelper(int min, int count) {
    return 'Tối thiểu $min ký tự ($count/$min)';
  }

  @override
  String get fieldDefects => 'Ghi chú khuyết điểm';

  @override
  String get chooseCategory => 'Chọn danh mục';

  @override
  String get categoryPickerTitle => 'Chọn danh mục';

  @override
  String validationFieldRequired(String field) {
    return 'Vui lòng nhập $field.';
  }

  @override
  String get validationChooseCategory => 'Vui lòng chọn danh mục.';

  @override
  String get validationChooseCondition => 'Vui lòng chọn tình trạng sách.';

  @override
  String get validationIsbn => 'ISBN chưa hợp lệ (ISBN-10 hoặc ISBN-13).';

  @override
  String validationYearRange(int min, int max) {
    return 'Năm từ $min đến $max.';
  }

  @override
  String get validationPagesRange => 'Số trang từ 1 đến 10000.';

  @override
  String get validationLanguage => 'Nhập mã 2 chữ cái, ví dụ vi.';

  @override
  String validationDescriptionMin(int min) {
    return 'Mô tả tối thiểu $min ký tự.';
  }

  @override
  String validationTooLong(int max) {
    return 'Tối đa $max ký tự.';
  }

  @override
  String photosHint(int min, int max) {
    return 'Cần $min đến $max ảnh, đủ 4 góc: bìa trước, bìa sau, gáy và trang trong.';
  }

  @override
  String get photosRequired => 'Bắt buộc';

  @override
  String photosExtraTitle(int count, int max) {
    return 'Ảnh thêm ($count/$max)';
  }

  @override
  String get addPhoto => 'Thêm ảnh';

  @override
  String get photoUploading => 'Đang tải ảnh';

  @override
  String get photoFailed => 'Tải ảnh thất bại';

  @override
  String get photoRetry => 'Thử lại';

  @override
  String get removePhoto => 'Xóa ảnh';

  @override
  String get photosWaiting => 'Đang tải ảnh, vui lòng đợi.';

  @override
  String get photosMissing => 'Còn thiếu ảnh bắt buộc.';

  @override
  String photoSlotLabel(String angle) {
    return '$angle, ảnh bắt buộc';
  }

  @override
  String get photoSlotEmpty => 'Chưa có ảnh';

  @override
  String get saleMethodLabel => 'Cách bán';

  @override
  String get fieldPrice => 'Giá bán (₫)';

  @override
  String get fieldQuantity => 'Số lượng';

  @override
  String get fieldStartingPrice => 'Giá khởi điểm (₫)';

  @override
  String get fieldMinIncrement => 'Bước giá tối thiểu (₫)';

  @override
  String minIncrementHelper(String amount) {
    return 'Tối thiểu $amount';
  }

  @override
  String get fieldDuration => 'Thời lượng phiên';

  @override
  String durationDays(int days) {
    return '$days ngày';
  }

  @override
  String get fieldStartMode => 'Bắt đầu';

  @override
  String get fieldScheduledAt => 'Thời điểm bắt đầu';

  @override
  String get pickDateTime => 'Chọn ngày giờ';

  @override
  String validationPriceRange(String min, String max) {
    return 'Giá từ $min đến $max.';
  }

  @override
  String validationQuantityRange(int min, int max) {
    return 'Số lượng từ $min đến $max.';
  }

  @override
  String validationMinIncrement(String amount) {
    return 'Bước giá tối thiểu là $amount.';
  }

  @override
  String get validationScheduleRequired => 'Vui lòng chọn thời điểm bắt đầu.';

  @override
  String get validationScheduleFuture => 'Thời điểm bắt đầu phải ở tương lai.';

  @override
  String get changeMethodTitle => 'Đổi cách bán?';

  @override
  String get changeMethodMessage =>
      'Cấu hình của cách bán còn lại sẽ bị xóa khi bạn lưu.';

  @override
  String get reviewBookSection => 'Thông tin sách';

  @override
  String get reviewPhotosSection => 'Ảnh';

  @override
  String get reviewSaleSection => 'Cách bán';

  @override
  String get submitSuccessTitle => 'Đã nộp kiểm định';

  @override
  String submitSuccessMessage(int hours) {
    return 'Dự kiến xử lý trong $hours giờ. Bạn sẽ nhận thông báo khi có kết quả.';
  }

  @override
  String get incompleteTitle => 'Tin đăng còn thiếu';

  @override
  String get incompleteMessage => 'Hãy bổ sung các mục sau rồi nộp lại.';

  @override
  String get goToStep => 'Đến bước này';

  @override
  String get missingImages => 'Ảnh (đủ 4 góc)';

  @override
  String get missingSaleMethod => 'Cách bán';

  @override
  String get missingPrice => 'Giá bán';

  @override
  String get missingStartingPrice => 'Giá khởi điểm';

  @override
  String get missingCategory => 'Danh mục';

  @override
  String get myListingsTitle => 'Tin của tôi';

  @override
  String get continueDraft => 'Tiếp tục soạn';

  @override
  String get deleteListing => 'Xóa tin';

  @override
  String get deleteListingTitle => 'Xóa tin này?';

  @override
  String get deleteListingMessage => 'Tin sẽ được đóng và không thể khôi phục.';

  @override
  String get listingDeleted => 'Đã xóa tin';

  @override
  String get editAndResubmit => 'Sửa và nộp lại';

  @override
  String get closeListing => 'Đóng tin';

  @override
  String resubmitsLeft(int count) {
    return 'Còn $count lần nộp lại';
  }

  @override
  String get noResubmitsLeft => 'Đã hết lượt nộp lại';

  @override
  String estimatedProcessing(int hours) {
    return 'Dự kiến xử lý trong $hours giờ';
  }

  @override
  String get rejectedTitle => 'Tin bị từ chối';

  @override
  String get closedTitle => 'Tin đã bị đóng';

  @override
  String get reasonsLabel => 'Lý do';

  @override
  String get inspectorNote => 'Ghi chú của kiểm định viên';

  @override
  String get inspectionResult => 'Kết quả kiểm định';

  @override
  String get inspectionApproved => 'Đã duyệt';

  @override
  String get inspectionRejected => 'Bị từ chối';

  @override
  String inspectedOn(String date) {
    return 'Ngày kiểm định: $date';
  }

  @override
  String get sellerSection => 'Người bán';

  @override
  String get bookDetails => 'Thông tin sách';

  @override
  String get detailAuthor => 'Tác giả';

  @override
  String get detailPublisher => 'Nhà xuất bản';

  @override
  String get detailYear => 'Năm xuất bản';

  @override
  String get detailLanguage => 'Ngôn ngữ';

  @override
  String get detailPages => 'Số trang';

  @override
  String get detailCover => 'Loại bìa';

  @override
  String get detailCondition => 'Tình trạng';

  @override
  String get detailCategory => 'Danh mục';

  @override
  String get detailQuantity => 'Số lượng';

  @override
  String get auctionSection => 'Thông tin đấu giá';

  @override
  String get startingPriceLabel => 'Giá khởi điểm';

  @override
  String get minIncrementLabel => 'Bước giá tối thiểu';

  @override
  String get auctionStarts => 'Bắt đầu';

  @override
  String get auctionEnds => 'Kết thúc';

  @override
  String get auctionDuration => 'Thời lượng';

  @override
  String startingFrom(String price) {
    return 'Từ $price';
  }

  @override
  String listingPhotoLabel(String angle, String title) {
    return '$angle của sách $title';
  }

  @override
  String get description => 'Mô tả';

  @override
  String get defectNotesTitle => 'Khuyết điểm';

  @override
  String submissionOf(int n, int max) {
    return 'Lần nộp $n/$max';
  }

  @override
  String get queueTitle => 'Hàng đợi kiểm định';

  @override
  String get claimedTitle => 'Tin đang giữ';

  @override
  String get overdueTag => 'Quá hạn';

  @override
  String waitingHours(int hours) {
    return 'Chờ $hours giờ';
  }

  @override
  String get filterButton => 'Bộ lọc';

  @override
  String get filterTitle => 'Lọc hàng đợi';

  @override
  String get priceFrom => 'Giá từ (₫)';

  @override
  String get priceTo => 'Giá đến (₫)';

  @override
  String get applyFilter => 'Áp dụng';

  @override
  String get clearFilter => 'Xóa lọc';

  @override
  String get reviewTitle => 'Kiểm định';

  @override
  String claimExpiresIn(String time) {
    return 'Còn $time để quyết định';
  }

  @override
  String get claimExpired => 'Khóa đã hết hạn. Hãy nhận lại tin để tiếp tục.';

  @override
  String get reclaim => 'Nhận lại tin';

  @override
  String get release => 'Nhả tin';

  @override
  String get releaseTitle => 'Nhả tin này?';

  @override
  String get releaseMessage =>
      'Tin sẽ quay lại hàng đợi cho kiểm định viên khác.';

  @override
  String get approve => 'Duyệt';

  @override
  String get reject => 'Từ chối';

  @override
  String get approveTitle => 'Duyệt tin đăng';

  @override
  String get approveNoteLabel => 'Ghi chú (không bắt buộc)';

  @override
  String get rejectTitle => 'Từ chối tin đăng';

  @override
  String get rejectReasonsLabel => 'Lý do (chọn ít nhất 1)';

  @override
  String get rejectNoteLabel => 'Ghi chú cho người bán';

  @override
  String rejectNoteHelper(int min) {
    return 'Tối thiểu $min ký tự';
  }

  @override
  String get validationRejectReasons => 'Hãy chọn ít nhất một lý do.';

  @override
  String validationRejectNote(int min) {
    return 'Ghi chú tối thiểu $min ký tự.';
  }

  @override
  String get listingApproved => 'Đã duyệt tin';

  @override
  String get listingRejected => 'Đã từ chối tin';

  @override
  String get listingReleased => 'Đã nhả tin';

  @override
  String get sellerDeclared => 'Người bán khai báo';

  @override
  String get viewPhotos => 'Xem ảnh gốc';

  @override
  String get inspectionHistory => 'Lịch sử kiểm định';

  @override
  String get errorEmailTaken => 'Email này đã được sử dụng.';

  @override
  String get errorAccountDisabled =>
      'Tài khoản đã bị khóa. Hãy liên hệ quản trị viên.';

  @override
  String get errorListingIncomplete =>
      'Tin đăng còn thiếu thông tin. Hãy bổ sung rồi nộp lại.';

  @override
  String get errorListingImageInvalid =>
      'Có ảnh không hợp lệ. Hãy chọn lại ảnh đó.';

  @override
  String get errorListingNotFound => 'Không tìm thấy tin đăng này.';

  @override
  String get errorListingInvalidState =>
      'Trạng thái tin đã thay đổi. Đang tải lại tin.';

  @override
  String get errorSubmissionLimit => 'Tin đã hết lượt nộp lại.';

  @override
  String get errorConcurrentUpdate =>
      'Tin vừa được cập nhật ở nơi khác. Đang tải lại.';

  @override
  String get errorAlreadyClaimed => 'Kiểm định viên khác đang giữ tin này.';

  @override
  String get errorClaimRequired =>
      'Bạn không còn giữ tin này. Hãy nhận lại tin.';

  @override
  String get errorCategoryNotFound => 'Danh mục không còn tồn tại.';

  @override
  String get errorNotificationNotFound => 'Không tìm thấy thông báo này.';

  @override
  String errorPhotoTooLarge(int mb) {
    return 'Ảnh vượt quá $mb MB. Hãy chọn ảnh nhỏ hơn.';
  }

  @override
  String get errorPhotosUploadPending =>
      'Có ảnh chưa tải xong hoặc bị lỗi. Hãy thử lại ảnh đó.';
}
