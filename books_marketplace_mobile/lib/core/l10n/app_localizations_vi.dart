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
      'Nhập số di động Việt Nam hợp lệ (10 số, đầu số 03, 05, 07, 08, 09 hoặc +84).';

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
  String get errorInvalidCredentials =>
      'Số điện thoại hoặc mật khẩu chưa đúng.';

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
  String get navExplore => 'Khám phá';

  @override
  String get navAuctions => 'Đấu giá';

  @override
  String get navSell => 'Bán';

  @override
  String get navWallet => 'Ví';

  @override
  String get navMe => 'Tôi';

  @override
  String get comingSoonTitle => 'Sắp có';

  @override
  String get comingSoonBody => 'Tính năng này đang được xây dựng.';

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
  String get filterButton => 'Lọc';

  @override
  String get filterTitle => 'Bộ lọc';

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

  @override
  String get brandName => 'Oldbook';

  @override
  String cartButton(int count) {
    return 'Giỏ · $count';
  }

  @override
  String get cartTitle => 'Giỏ hàng';

  @override
  String get searchHint => 'Tên sách, tác giả, ISBN';

  @override
  String get resultsNew => 'Mới đăng';

  @override
  String get resultsSearch => 'Kết quả tìm kiếm';

  @override
  String resultsCount(int count) {
    return '$count cuốn';
  }

  @override
  String get noSearchResults =>
      'Không tìm thấy sách phù hợp. Thử bỏ dấu hoặc đổi thể loại.';

  @override
  String get addToCart => 'Thêm vào giỏ';

  @override
  String get inCart => 'Đã trong giỏ';

  @override
  String get buyNow => 'Mua ngay';

  @override
  String get addedToCart => 'Đã thêm vào giỏ';

  @override
  String get alreadyInCart => 'Sách đã có trong giỏ';

  @override
  String shipPlus(String price) {
    return '+ ship $price';
  }

  @override
  String get escrowNote =>
      'Tiền được giữ trong ví Oldbook đến khi bạn xác nhận nhận hàng. Có 3 ngày để khiếu nại sau khi giao.';

  @override
  String get auctionListingNote => 'Sách này bán theo hình thức đấu giá.';

  @override
  String toastOrderCancelled(String amount) {
    return 'Đã hủy đơn, hoàn $amount';
  }

  @override
  String get toastOrderCompleted => 'Đơn hoàn tất · cảm ơn bạn!';

  @override
  String get toastComplaintOpened => 'Đã mở khiếu nại · tiền bị khóa';

  @override
  String toastOfferAccepted(String amount) {
    return 'Đã nhận hoàn $amount';
  }

  @override
  String get toastNoBooks => 'Không có sách khả dụng trong giỏ';

  @override
  String get toastSellerShipped => 'Người bán đã nhập mã vận đơn';

  @override
  String toastDeliveryFailed(int n) {
    return 'Giao thất bại lần $n';
  }

  @override
  String get toastMovedToStorage => 'Giao thất bại lần 5 · sách vào lưu kho';

  @override
  String toastTopupOk(String amount) {
    return 'Nạp thành công +$amount';
  }

  @override
  String toastWithdrawRequested(String amount) {
    return 'Đã gửi yêu cầu rút $amount';
  }

  @override
  String toastRated(int n) {
    return 'Đã đánh giá $n sao';
  }

  @override
  String toastRegistered(String amount) {
    return 'Đã đăng ký · giữ $amount';
  }

  @override
  String toastUnregistered(String amount) {
    return 'Đã hủy đăng ký, hoàn $amount';
  }

  @override
  String toastLeading(String amount) {
    return 'Bạn đang dẫn đầu với $amount';
  }

  @override
  String get toastBuyNowStarted => 'Đã mua ngay · đếm ngược 30 phút bắt đầu';

  @override
  String toastOutbid(String title, String amount) {
    return 'Bạn đã bị vượt giá ở \"$title\" · $amount';
  }

  @override
  String toastAuctionWon(String title, String amount) {
    return 'Bạn đã thắng \"$title\" với giá $amount';
  }

  @override
  String get txnTopupVietQr => 'Nạp tiền qua VietQR';

  @override
  String txnHoldOrder(String arg) {
    return 'Giữ tiền đơn $arg';
  }

  @override
  String txnHoldOrders(int n) {
    return 'Giữ tiền $n đơn hàng';
  }

  @override
  String txnHoldAuctionRegistration(String arg) {
    return 'Đăng ký phiên \"$arg\"';
  }

  @override
  String txnHoldBid(String arg) {
    return 'Trả giá \"$arg\"';
  }

  @override
  String txnHoldBuyNow(String arg) {
    return 'Mua ngay \"$arg\"';
  }

  @override
  String txnHoldRedelivery(String arg) {
    return 'Phí giao lại $arg';
  }

  @override
  String txnReleaseOrderCancelled(String arg) {
    return 'Hoàn tiền hủy đơn $arg';
  }

  @override
  String txnReleaseAuctionUnregistered(String arg) {
    return 'Hủy đăng ký \"$arg\"';
  }

  @override
  String txnReleaseAuctionDeposit(String arg) {
    return 'Hoàn cọc phiên \"$arg\"';
  }

  @override
  String txnPayoutSale(String arg) {
    return 'Nhận tiền bán \"$arg\"';
  }

  @override
  String txnCaptureOrder(String arg) {
    return 'Thanh toán đơn $arg (từ tiền giữ)';
  }

  @override
  String txnRefundAgreement(String arg) {
    return 'Hoàn tiền thỏa thuận $arg';
  }

  @override
  String txnRefundVerdict(String arg) {
    return 'Hoàn tiền theo phán quyết $arg';
  }

  @override
  String get txnWithdrawRequest => 'Yêu cầu rút về Vietcombank · chờ duyệt';

  @override
  String get txnTypeTopup => 'Nạp tiền';

  @override
  String get txnTypeHold => 'Giữ tiền';

  @override
  String get txnTypeRelease => 'Nhả tiền';

  @override
  String get txnTypePayout => 'Nhận tiền';

  @override
  String get txnTypeRefund => 'Hoàn tiền';

  @override
  String get txnTypeCapture => 'Chốt thanh toán';

  @override
  String get txnTypeWithdraw => 'Rút tiền';

  @override
  String get orderStatusPaidAwaitingShipment => 'Chờ người bán gửi';

  @override
  String get orderStatusShipped => 'Đang vận chuyển';

  @override
  String get orderStatusDelivered => 'Đã giao';

  @override
  String get orderStatusCompleted => 'Hoàn tất';

  @override
  String get orderStatusCancelled => 'Đã hủy';

  @override
  String get orderStatusRefunded => 'Đã hoàn tiền';

  @override
  String get orderStatusPartiallyRefunded => 'Hoàn một phần';

  @override
  String get orderStatusDisputed => 'Đang khiếu nại';

  @override
  String get orderStatusReadyToShip => 'Chờ kho xuất';

  @override
  String get orderStatusInDelivery => 'Đang giao';

  @override
  String get orderStatusInStorage => 'Lưu kho';

  @override
  String get orderStatusPickedUp => 'Đã nhận tại kho';

  @override
  String get orderKindSale => 'Bán thường';

  @override
  String get orderKindAuction => 'Đấu giá';

  @override
  String get ordersTitle => 'Đơn mua';

  @override
  String orderTitle(String arg) {
    return 'Đơn $arg';
  }

  @override
  String get ordersEmpty => 'Bạn chưa có đơn mua nào.';

  @override
  String noteShipBy(String date) {
    return 'Người bán gửi trước $date';
  }

  @override
  String noteComplaintLeft(String time) {
    return 'Còn $time để khiếu nại';
  }

  @override
  String noteDeliveryAttempt(int n, String carrier) {
    return 'Lần giao $n/5 · $carrier';
  }

  @override
  String noteStorage(int days) {
    return 'Lưu kho $days ngày · 5.000 đ/ngày trừ vào cọc';
  }

  @override
  String get notePacking => 'Kho đang đóng gói';

  @override
  String get noteFundsLocked => 'Tiền đang bị khóa';

  @override
  String get headPaidAwaitingShipment => 'Chờ người bán gửi hàng';

  @override
  String get headShipped => 'Sách đang trên đường đến';

  @override
  String get headDelivered => 'Bạn đã nhận được sách?';

  @override
  String get headCompleted => 'Đơn đã hoàn tất';

  @override
  String get headDisputed => 'Khiếu nại đang được xử lý';

  @override
  String get headCancelled => 'Đơn đã hủy';

  @override
  String get headRefunded => 'Đã hoàn tiền';

  @override
  String get headPartiallyRefunded => 'Đã hoàn tiền một phần';

  @override
  String get headReadyToShip => 'Kho đang chuẩn bị giao';

  @override
  String get headInDelivery => 'Đang giao sách đấu giá';

  @override
  String get headInStorage => 'Sách đang được lưu kho';

  @override
  String get headPickedUp => 'Đã nhận tại kho';

  @override
  String detailNotePaid(String date) {
    return 'Người bán phải gửi trước $date. Quá hạn đơn tự hủy và hoàn 100%. Bạn có thể hủy miễn phí đến khi người bán gửi.';
  }

  @override
  String get detailNoteShipped =>
      'Bấm \"Đã nhận được hàng\" khi sách đến tay để bắt đầu 3 ngày kiểm tra.';

  @override
  String detailNoteDelivered(String time) {
    return 'Bạn còn $time để khiếu nại. Hết hạn, đơn tự hoàn tất và tiền chuyển cho người bán.';
  }

  @override
  String get detailNoteCompleted => 'Người bán đã nhận tiền sau khi trừ phí.';

  @override
  String get detailNoteDisputed =>
      'Tiền bị khóa đến khi có thỏa thuận hoặc phán quyết.';

  @override
  String get detailNoteCancelled => 'Toàn bộ tiền giữ đã được nhả về ví.';

  @override
  String get detailNoteRefunded => 'Tiền hoàn đã vào ví.';

  @override
  String get detailNotePartiallyRefunded =>
      'Phần hoàn đã vào ví, phần còn lại chuyển người bán.';

  @override
  String detailNoteReadyToShip(String amount) {
    return 'Phí ship $amount đã được giữ. Kho chụp ảnh đóng gói trước khi giao.';
  }

  @override
  String detailNoteInDelivery(int n) {
    return 'Lần giao $n/5. Sau 5 lần thất bại, sách vào lưu kho (5.000 đ/ngày, tối đa 30 ngày).';
  }

  @override
  String get detailNoteInStorage =>
      'Giao thất bại 5 lần. Phí lưu kho trừ vào cọc. Chọn nhận tại kho hoặc giao lại.';

  @override
  String get stepSaleOrdered => 'Đã đặt · tiền được giữ';

  @override
  String get stepSaleShipped => 'Người bán đã gửi';

  @override
  String get stepDelivered => 'Đã giao';

  @override
  String get stepSaleCompleted => 'Hoàn tất · tiền chuyển cho người bán';

  @override
  String get stepAuctionWon => 'Thắng phiên · kho nhận lệnh xuất';

  @override
  String get stepAuctionInDelivery => 'Đang giao';

  @override
  String get stepAuctionReceived => 'Đã nhận hàng';

  @override
  String get stepAuctionCompleted => 'Hoàn tất · hoàn cọc';

  @override
  String get stepCancelled => 'Đã hủy · tiền đã hoàn về ví';

  @override
  String get stepNext => 'Tiếp theo';

  @override
  String get moneyBookPrice => 'Tiền sách';

  @override
  String get moneyWinPrice => 'Giá thắng';

  @override
  String get moneyShipping => 'Phí ship';

  @override
  String get moneyTotal => 'Tổng';

  @override
  String get moneyNoteAuction =>
      'Giá thắng đã được chốt vào tài khoản trung gian. Cọc hoàn khi bạn nhận sách.';

  @override
  String get moneyNoteSettled => 'Đã quyết toán.';

  @override
  String get moneyNoteHeld => 'Đang giữ trong ví đến khi đơn hoàn tất.';

  @override
  String get shipNoTracking => 'Chưa có mã vận đơn';

  @override
  String get shipFromWarehouse => 'Giao từ kho Oldbook';

  @override
  String get reviewSeller => 'Đánh giá người bán';

  @override
  String get reviewNoteNew => 'Đánh giá trong 14 ngày sau khi hoàn tất.';

  @override
  String get reviewNoteEdit => 'Bạn có thể sửa đánh giá một lần trong 7 ngày.';

  @override
  String starLabel(int n) {
    return '$n sao';
  }

  @override
  String get actSimSellerShip => 'Mô phỏng: người bán gửi hàng';

  @override
  String actCancelOrder(String amount) {
    return 'Hủy đơn · hoàn $amount';
  }

  @override
  String get actReceived => 'Đã nhận được hàng';

  @override
  String get actSimWarehouseShip => 'Mô phỏng: kho xuất hàng';

  @override
  String get actSimDeliverOk => 'Mô phỏng: giao thành công';

  @override
  String get actSimDeliverFail => 'Mô phỏng: giao thất bại';

  @override
  String get actPickUp => 'Đến nhận tại kho';

  @override
  String actRedeliver(String amount) {
    return 'Giao lại · thêm $amount';
  }

  @override
  String get actCompleteOrder => 'Hài lòng, hoàn tất đơn';

  @override
  String get actComplaint => 'Khiếu nại';

  @override
  String get actSimSellerOffer => 'Mô phỏng: người bán đề xuất hoàn 50%';

  @override
  String actAcceptOffer(String amount) {
    return 'Chấp nhận hoàn $amount';
  }

  @override
  String get actEscalate => 'Từ chối, chuyển Oldbook phân xử';

  @override
  String get actSimAdmin => 'Mô phỏng: admin phán hoàn 100%';

  @override
  String get actNone => 'Không có thao tác nào cần làm.';

  @override
  String complaintCardTitle(String status) {
    return 'Khiếu nại · $status';
  }

  @override
  String get complaintStatusOpen => 'Chờ người bán phản hồi';

  @override
  String get complaintStatusSellerResponded => 'Người bán đã đề xuất';

  @override
  String get complaintStatusEscalated => 'Oldbook đang phân xử';

  @override
  String get complaintStatusAgreed => 'Đã thỏa thuận';

  @override
  String get complaintStatusResolved => 'Đã phán quyết';

  @override
  String get complaintTextOpenSale =>
      'Người bán có 2 ngày để phản hồi, quá hạn sẽ chuyển Oldbook phân xử.';

  @override
  String get complaintTextOpenAuction =>
      'Khiếu nại đấu giá được chuyển thẳng cho Oldbook.';

  @override
  String complaintTextSellerResponded(String amount) {
    return 'Người bán đề xuất hoàn $amount. Bạn đồng ý hoặc chuyển Oldbook phân xử.';
  }

  @override
  String get complaintTextEscalatedSale =>
      'Admin xem bằng chứng hai bên và ra phán quyết.';

  @override
  String get complaintTextEscalatedAuction =>
      'Admin xem bằng chứng hai bên, ảnh nhập/xuất kho và ra phán quyết.';

  @override
  String complaintTextAgreed(String amount) {
    return 'Đã hoàn $amount theo thỏa thuận.';
  }

  @override
  String get complaintTextResolved => 'Hoàn toàn bộ theo phán quyết.';

  @override
  String get complaintSheetTitle => 'Mở khiếu nại';

  @override
  String get complaintSheetNote =>
      'Tiền sẽ bị khóa đến khi khiếu nại được giải quyết.';

  @override
  String get complaintReasonNotAsDescribed => 'Không đúng mô tả';

  @override
  String get complaintReasonDamaged => 'Sách bị hư hỏng';

  @override
  String get complaintReasonWrongItem => 'Giao sai sách';

  @override
  String get complaintReasonOther => 'Lý do khác';

  @override
  String get complaintDescribeHint => 'Mô tả vấn đề';

  @override
  String complaintAddEvidence(int n) {
    return '+ Thêm ảnh bằng chứng ($n/10)';
  }

  @override
  String get complaintSubmit => 'Gửi khiếu nại';

  @override
  String get complaintNeedReasonAndPhoto => 'Chọn lý do và thêm ít nhất 1 ảnh';

  @override
  String get cartEmpty => 'Giỏ hàng trống.';

  @override
  String cartSeller(String name) {
    return 'Người bán: $name';
  }

  @override
  String get cartUnavailable => 'Không còn khả dụng · đã bán';

  @override
  String get cartRemove => 'Xóa';

  @override
  String get cartShipTo => 'Giao đến';

  @override
  String cartSubtotal(int n) {
    return 'Tiền sách ($n cuốn)';
  }

  @override
  String cartShippingFee(String amount) {
    return 'Phí ship (mỗi đơn $amount)';
  }

  @override
  String get cartBalance => 'Số dư ví khả dụng';

  @override
  String get cartNote =>
      'Mỗi cuốn tạo một đơn riêng với người bán. Bạn có thể hủy đơn miễn phí khi người bán chưa gửi hàng.';

  @override
  String get cartPayTotal => 'Tổng thanh toán';

  @override
  String get cartPlaceOrder => 'Đặt hàng · thanh toán bằng ví';

  @override
  String get cartInsufficient => 'Số dư không đủ · nạp thêm';

  @override
  String get cartNoAvailable => 'Không có sách khả dụng';

  @override
  String get insufficientTitle => 'Số dư không đủ';

  @override
  String insufficientBody(String need, String avail) {
    return 'Cần thêm $need để tiếp tục. Số dư khả dụng hiện tại: $avail.';
  }

  @override
  String insufficientTopup(String amount) {
    return 'Nạp $amount';
  }

  @override
  String get sheetClose => 'Đóng';

  @override
  String get sheetLater => 'Để sau';

  @override
  String get orderPlacedTitle => 'Đặt hàng thành công';

  @override
  String orderPlacedBody(String amount, int n) {
    return 'Đã giữ $amount từ ví cho $n đơn. Người bán có 2 ngày làm việc để gửi hàng, nếu không đơn tự hủy và hoàn tiền.';
  }

  @override
  String get orderPlacedView => 'Xem đơn hàng';

  @override
  String get orderPlacedKeepShopping => 'Tiếp tục mua';

  @override
  String get walletTitle => 'Ví Oldbook';

  @override
  String get walletAvailable => 'Số dư khả dụng';

  @override
  String get walletHeld => 'Đang giữ';

  @override
  String get walletTotal => 'Tổng';

  @override
  String get walletTopup => 'Nạp tiền';

  @override
  String get walletWithdraw => 'Rút tiền';

  @override
  String get walletNote =>
      'Tiền đang giữ dùng cho đơn hàng chưa hoàn tất, tiền cọc đấu giá và lượt trả giá đang dẫn đầu. Mọi giao dịch đi qua ví, không chuyển trực tiếp giữa người dùng.';

  @override
  String get walletHistory => 'Lịch sử giao dịch';

  @override
  String get walletNoTransactions => 'Chưa có giao dịch.';

  @override
  String get walletPayoutAccount => 'Tài khoản nhận tiền';

  @override
  String get topupSheetTitle => 'Nạp tiền vào ví';

  @override
  String get topupSheetNote =>
      'Bạn sẽ được chuyển tới trang thanh toán của cổng. Yêu cầu hết hạn nếu chưa thanh toán trong thời gian quy định.';

  @override
  String topupCreateCode(String amount) {
    return 'Tạo mã thanh toán · $amount';
  }

  @override
  String get topupScanTitle => 'Quét mã để thanh toán';

  @override
  String get topupQrLabel => 'mã VietQR';

  @override
  String get topupTransferContent =>
      'Nội dung: OLDBOOK NAP 7K2Q9 · hết hạn sau 30:00';

  @override
  String get topupConfirmNote =>
      'Số dư chỉ được cộng khi cổng thanh toán xác nhận.';

  @override
  String get topupSimConfirm => 'Mô phỏng: cổng thanh toán xác nhận';

  @override
  String get withdrawSheetTitle => 'Rút tiền';

  @override
  String get withdrawAmountHint => 'Số tiền (tối thiểu 50.000 đ)';

  @override
  String withdrawHintAvailable(String amount) {
    return 'Khả dụng: $amount';
  }

  @override
  String get withdrawHintMin => 'Tối thiểu 50.000 đ';

  @override
  String withdrawHintOver(String amount) {
    return 'Vượt số dư khả dụng ($amount)';
  }

  @override
  String withdrawHintHold(String amount) {
    return 'Sẽ giữ $amount chờ duyệt';
  }

  @override
  String get withdrawNote =>
      'Số tiền được giữ ngay và chuyển khoản sau khi Oldbook duyệt. Tên chủ tài khoản phải trùng họ tên hồ sơ.';

  @override
  String get withdrawSubmit => 'Gửi yêu cầu rút';

  @override
  String remainingDaysHours(int days, int hours) {
    return '$days ngày $hours giờ';
  }

  @override
  String get agoNow => 'vừa xong';

  @override
  String agoMinutes(int n) {
    return '$n phút trước';
  }

  @override
  String agoHours(int n) {
    return '$n giờ trước';
  }

  @override
  String agoDays(int n) {
    return '$n ngày trước';
  }

  @override
  String get meMyOrders => 'Đơn mua';

  @override
  String get meMyOrdersSub =>
      'Theo dõi giao hàng, xác nhận nhận hàng, khiếu nại';

  @override
  String get aucTitle => 'Đấu giá';

  @override
  String get aucSubtitle =>
      'Sách đã được kiểm tra tại kho Oldbook trước khi lên sàn';

  @override
  String get aucTabLive => 'Đang diễn ra';

  @override
  String get aucTabRegister => 'Đăng ký';

  @override
  String get aucTabUpcoming => 'Sắp tới';

  @override
  String get aucTabEnded => 'Đã xong';

  @override
  String get aucEmpty => 'Chưa có phiên nào ở trạng thái này.';

  @override
  String get aucStatusLive => 'Đang diễn ra';

  @override
  String get aucStatusBuyNow => 'Đếm ngược mua ngay';

  @override
  String get aucStatusRegistration => 'Đang mở đăng ký';

  @override
  String get aucStatusConfirmed => 'Sắp diễn ra';

  @override
  String get aucStatusEnded => 'Đã kết thúc';

  @override
  String get aucStatusNoBid => 'Không có lượt';

  @override
  String get aucRegisteredTag => 'Đã đăng ký';

  @override
  String aucParticipants(int n) {
    return '$n người tham gia';
  }

  @override
  String aucParticipantsMin(int n, String min) {
    return '$n/$min người tối thiểu';
  }

  @override
  String get aucPriceStarting => 'Giá khởi điểm';

  @override
  String get aucPriceCurrent => 'Giá hiện tại';

  @override
  String get aucPriceWinning => 'Giá thắng';

  @override
  String get aucTimerEndsIn => 'Kết thúc sau';

  @override
  String get aucTimerCountdown => 'Đếm ngược';

  @override
  String get aucTimerRegCloses => 'Đóng đăng ký sau';

  @override
  String get aucTimerStartsIn => 'Bắt đầu sau';

  @override
  String get aucTimerEndedAt => 'Kết thúc lúc';

  @override
  String get aucSubLive =>
      'Lượt trả giá trong 2 phút cuối sẽ gia hạn phiên thêm 2 phút.';

  @override
  String aucSubCountdown(String time) {
    return 'Đã có người mua ngay. Mỗi lượt cao hơn đặt lại 30 phút · kết thúc muộn nhất $time.';
  }

  @override
  String aucSubRegistration(String time, String min) {
    return 'Phiên bắt đầu $time · cần tối thiểu $min người.';
  }

  @override
  String aucSubConfirmed(String time) {
    return 'Đã đủ người · bắt đầu $time.';
  }

  @override
  String get aucLeaderMe => 'Bạn đang dẫn đầu';

  @override
  String aucLeaderOther(String name) {
    return 'Dẫn đầu: $name';
  }

  @override
  String get aucNoBids => 'Chưa có lượt trả giá';

  @override
  String get aucExtendedBanner =>
      'Phiên vừa được gia hạn thêm 2 phút (chống bắn tỉa)';

  @override
  String get aucStatStart => 'Giá khởi điểm';

  @override
  String get aucStatStep => 'Bước nhảy';

  @override
  String get aucStatBuyNow => 'Giá mua ngay';

  @override
  String get aucStatFeeDeposit => 'Phí tham gia · Cọc';

  @override
  String get aucNone => 'Không có';

  @override
  String get aucBidHistory => 'Lịch sử trả giá';

  @override
  String aucBidCount(int n) {
    return '$n lượt';
  }

  @override
  String get aucBidYou => 'Bạn';

  @override
  String get aucNoBidsYet =>
      'Chưa có lượt trả giá. Lượt đầu tiên phải từ giá khởi điểm.';

  @override
  String aucSellerLine(String seller, String part) {
    return 'Người bán: $seller · $part';
  }

  @override
  String get aucHoldLabel => 'Giữ phí tham gia + cọc';

  @override
  String get aucRegister => 'Đăng ký tham gia';

  @override
  String get aucRegisteredTitle => 'Bạn đã đăng ký';

  @override
  String aucRegisteredSub(String amount) {
    return 'Đang giữ $amount · hủy được trước khi đóng';
  }

  @override
  String get aucUnregister => 'Hủy đăng ký';

  @override
  String get aucFilledTitle => 'Phiên đã đủ người';

  @override
  String aucFilledSub(String amount) {
    return 'Phí tham gia đã thu, cọc $amount tiếp tục được giữ. Chúng tôi sẽ nhắc bạn 1 giờ trước khi bắt đầu.';
  }

  @override
  String get aucWatchTitle => 'Bạn đang theo dõi phiên này';

  @override
  String get aucWatchSub =>
      'Đăng ký đã đóng 24 giờ trước giờ bắt đầu. Chỉ người đã đăng ký mới được trả giá.';

  @override
  String get aucLeadingTitle => 'Bạn đang dẫn đầu';

  @override
  String aucLeadingSub(String amount) {
    return '$amount đang được giữ trong ví · sẽ nhả nếu bị vượt giá';
  }

  @override
  String aucMinimum(String amount) {
    return 'Tối thiểu $amount';
  }

  @override
  String get aucBid => 'Trả giá';

  @override
  String aucBuyNowButton(String amount) {
    return 'Mua ngay $amount';
  }

  @override
  String get aucEndedWon => 'Bạn đã thắng phiên này';

  @override
  String get aucEndedLost => 'Bạn không thắng phiên này';

  @override
  String get aucEndedGeneric => 'Phiên đã kết thúc';

  @override
  String aucEndedWonText(String amount) {
    return 'Đơn giao hàng đã được tạo trong Đơn mua. Cọc $amount hoàn khi bạn nhận sách.';
  }

  @override
  String aucEndedLostText(String amount) {
    return 'Cọc $amount đã được nhả về ví.';
  }

  @override
  String aucEndedOtherText(String amount) {
    return 'Giá thắng $amount.';
  }

  @override
  String get aucNotFound => 'Không tìm thấy phiên này.';

  @override
  String get aucErrEnded => 'Phiên đã kết thúc, không thể trả giá.';

  @override
  String get aucErrTooLow => 'Giá thấp hơn mức tối thiểu hiện tại.';

  @override
  String get aucErrState => 'Không thể thực hiện ở trạng thái hiện tại.';

  @override
  String get regSheetTitle => 'Đăng ký tham gia phiên';

  @override
  String get regFee => 'Phí tham gia (2% giá khởi điểm, 10.000–100.000 đ)';

  @override
  String get regDeposit => 'Tiền cọc (10% giá khởi điểm)';

  @override
  String get regHold => 'Tạm giữ từ ví';

  @override
  String get regBalance => 'Số dư khả dụng';

  @override
  String get regNote1 =>
      '• Phí tham gia chỉ thu khi phiên đủ 3 người; không đủ người sẽ hoàn toàn bộ.';

  @override
  String get regNote2 =>
      '• Cọc hoàn khi phiên kết thúc (người thua) hoặc khi bạn nhận hàng (người thắng). Phí lưu kho 5.000 đ/ngày trừ vào cọc nếu không nhận hàng.';

  @override
  String regNote3(String time) {
    return '• Hủy đăng ký miễn phí trước $time.';
  }

  @override
  String regConfirm(String amount) {
    return 'Xác nhận · giữ $amount';
  }

  @override
  String get regInsufficient => 'Số dư không đủ · nạp thêm';

  @override
  String buyNowTitle(String amount) {
    return 'Mua ngay với giá $amount?';
  }

  @override
  String buyNowNote1(String amount) {
    return '• $amount được giữ từ ví và bạn trở thành người dẫn đầu.';
  }

  @override
  String get buyNowNote2 =>
      '• Phiên chuyển sang đếm ngược 30 phút. Mỗi lượt trả giá cao hơn sẽ đặt lại 30 phút.';

  @override
  String get buyNowNote3 =>
      '• Phiên kết thúc chậm nhất 24 giờ sau khi bấm mua ngay.';

  @override
  String get buyNowConfirm => 'Xác nhận mua ngay';

  @override
  String get myAuctionsTitle => 'Phiên tôi tham gia';

  @override
  String get myAuctionsEmpty => 'Bạn chưa đăng ký phiên nào.';

  @override
  String myAucWon(String amount) {
    return 'Đã thắng · $amount';
  }

  @override
  String myAucLeading(String amount) {
    return 'Đang dẫn đầu · $amount';
  }

  @override
  String get myAucLost => 'Không thắng';

  @override
  String get myAucOutbid => 'Đã bị vượt giá';

  @override
  String get myAucRegistered => 'Đã đăng ký';

  @override
  String get homeLiveAuctions => 'Đang đấu giá';

  @override
  String get homeSeeAll => 'Xem tất cả';

  @override
  String simNotifBuyNowTitle(String arg) {
    return 'Phiên \"$arg\" đang đếm ngược mua ngay';
  }

  @override
  String get simNotifBuyNowBody =>
      'Có người bấm mua ngay. Trả giá cao hơn để đặt lại đếm ngược 30 phút.';

  @override
  String simNotifDeliveredTitle(String arg) {
    return 'Đơn $arg đã giao';
  }

  @override
  String get simNotifDeliveredBody =>
      'Bạn có 3 ngày để kiểm tra sách và khiếu nại nếu có vấn đề.';

  @override
  String simNotifFilledTitle(String arg) {
    return 'Phiên \"$arg\" đã đủ người';
  }

  @override
  String simNotifFilledBody(String amount) {
    return 'Phiên bắt đầu sau vài giờ. Cọc $amount tiếp tục được giữ.';
  }

  @override
  String get simNotifTopupTitle => 'Nạp tiền thành công';

  @override
  String simNotifTopupBody(String amount) {
    return '+$amount đã vào ví.';
  }

  @override
  String get simNotifRegisteredTitle => 'Đăng ký thành công';

  @override
  String simNotifRegisteredBody(String arg, String amount) {
    return '\"$arg\" · đã giữ $amount';
  }

  @override
  String get simNotifOutbidTitle => 'Bạn đã bị vượt giá';

  @override
  String simNotifOutbidBody(String arg, String amount) {
    return '\"$arg\" · giá mới $amount. Tiền giữ đã được nhả về ví.';
  }

  @override
  String simNotifWonTitle(String arg) {
    return 'Bạn đã thắng phiên \"$arg\"';
  }

  @override
  String simNotifWonBody(String amount) {
    return 'Giá thắng $amount. Đơn giao hàng đã được tạo trong Đơn mua.';
  }

  @override
  String get meStatOpenOrders => 'Đơn đang mua';

  @override
  String get meStatListings => 'Tin đang đăng';

  @override
  String get meStatAuctions => 'Phiên tham gia';

  @override
  String get meMyListings => 'Tin đăng của tôi';

  @override
  String get meMyListingsSub => 'Trạng thái duyệt, cần sửa, đã bán';

  @override
  String get meMyAuctionsSub => 'Đã đăng ký, đang dẫn đầu, đã thắng';

  @override
  String meNotificationsSub(int n) {
    return '$n chưa đọc';
  }

  @override
  String get meNotificationsAllRead => 'Đã đọc hết';

  @override
  String get meDefaultAddress => 'Địa chỉ mặc định';

  @override
  String get sellTitle => 'Đăng bán';

  @override
  String get sellModeFixed => 'Bán giá cố định';

  @override
  String get sellModeAuction => 'Đấu giá';

  @override
  String get sellAuctionNote =>
      'Sách đấu giá được gửi về kho Oldbook trong 5 ngày để kiểm tra và chụp ảnh lại. Sau khi duyệt, phiên mở đăng ký tối thiểu 3 ngày và cần ít nhất 3 người tham gia.';

  @override
  String get sellPhotos => 'Ảnh sách';

  @override
  String sellPhotoCount(int n) {
    return '$n/10 · tối thiểu 4';
  }

  @override
  String get sellPhotoAdd => '+ thêm';

  @override
  String get sellFieldTitle => 'Tên sách';

  @override
  String get sellFieldTitleHint => 'VD: Số đỏ';

  @override
  String get sellFieldAuthor => 'Tác giả';

  @override
  String get sellFieldAuthorHint => 'VD: Vũ Trọng Phụng';

  @override
  String get sellFieldCategory => 'Thể loại';

  @override
  String get sellFieldCondition => 'Tình trạng';

  @override
  String get sellFieldPrice => 'Giá bán (đ)';

  @override
  String get sellFieldPriceHint => 'Tối thiểu 1.000';

  @override
  String get sellFieldStart => 'Giá khởi điểm';

  @override
  String get sellFieldStartHint => '≥ 10.000';

  @override
  String get sellFieldStep => 'Bước nhảy';

  @override
  String get sellFieldBuyNow => 'Giá mua ngay';

  @override
  String get sellFieldBuyNowOptional => '(tùy chọn, ≥ 1,5 × giá khởi điểm)';

  @override
  String get sellBuyNowHintEmpty => 'Để trống nếu không dùng';

  @override
  String sellBuyNowHint(String amount) {
    return '≥ $amount';
  }

  @override
  String get sellStepHintEmpty => '1–10% giá KĐ';

  @override
  String get sellDuration => 'Thời lượng phiên';

  @override
  String get sellDuration5m => '5 phút';

  @override
  String get sellDuration15m => '15 phút';

  @override
  String get sellDuration1h => '1 giờ';

  @override
  String get sellDuration1d => '1 ngày';

  @override
  String get sellDuration3d => '3 ngày';

  @override
  String get sellDuration7d => '7 ngày';

  @override
  String sellEarliestStart(String time) {
    return 'Bắt đầu sớm nhất: $time (còn tùy cấu hình hệ thống; quá gần sẽ bị từ chối)';
  }

  @override
  String get sellFieldDesc => 'Mô tả & lỗi (nếu có)';

  @override
  String get sellFieldDescHint => 'Năm xuất bản, NXB, ghi chú, trang bị ố…';

  @override
  String get sellPreviewTitle => 'Dự tính';

  @override
  String get sellPreviewPrice => 'Giá bán';

  @override
  String get sellPreviewFee => 'Phí bán Oldbook (5%)';

  @override
  String get sellPreviewReceive => 'Bạn nhận';

  @override
  String get sellPreviewShip => 'Phí ship (người mua trả)';

  @override
  String get sellPreviewPlayerFee => 'Người chơi trả phí tham gia';

  @override
  String get sellPreviewPlayerDeposit => 'Người chơi đặt cọc';

  @override
  String get sellPreviewCommission => 'Hoa hồng Oldbook (10% giá thắng)';

  @override
  String get sellPreviewReceiveAtStart => 'Bạn nhận nếu bán ở giá khởi điểm';

  @override
  String get sellSubmitSale => 'Gửi duyệt';

  @override
  String get sellSubmitAuction => 'Tạo phiên & nhận mã gửi kho';

  @override
  String sellErrPhotos(int n) {
    return 'Cần ít nhất 4 ảnh (hiện có $n)';
  }

  @override
  String get sellKind => 'Loại tin';

  @override
  String get sellKindSingle => 'Sách lẻ';

  @override
  String get sellKindSet => 'Bộ sách';

  @override
  String get sellSetHint =>
      'Bán cả bộ một giá. Thêm từng tập kèm ảnh riêng của tập.';

  @override
  String get sellSetPhotos => 'Ảnh chung của cả bộ';

  @override
  String get sellAddVolume => 'Thêm tập';

  @override
  String get sellVolumeNameHint => 'Tên tập (tùy chọn)';

  @override
  String get sellVolumeRemove => 'Xóa tập';

  @override
  String get sellErrSetPhotos => 'Cần ít nhất 1 ảnh chung của cả bộ';

  @override
  String get sellErrVolumePhotos => 'Mỗi tập cần ít nhất 1 ảnh';

  @override
  String sellSetPhotoCount(int n) {
    return '$n/10 · tối thiểu 1';
  }

  @override
  String sellVolumesTitle(int n) {
    return 'Các tập ($n)';
  }

  @override
  String sellVolumeLabel(int no) {
    return 'Tập $no';
  }

  @override
  String sellVolumePhotoCount(int n, int max) {
    return '$n/$max ảnh';
  }

  @override
  String sellErrVolumes(int min, int max) {
    return 'Bộ sách cần từ $min đến $max tập';
  }

  @override
  String setBadge(int n) {
    return 'Bộ $n tập';
  }

  @override
  String detailVolumes(int n) {
    return 'Các tập trong bộ ($n)';
  }

  @override
  String get sellErrTitle => 'Nhập tên sách';

  @override
  String get sellErrAuthor => 'Nhập tác giả';

  @override
  String get sellErrPrice => 'Giá bán tối thiểu 1.000 đ';

  @override
  String get sellErrStart => 'Giá khởi điểm tối thiểu 10.000 đ';

  @override
  String sellErrStep(String lo, String hi) {
    return 'Bước nhảy phải từ $lo đến $hi';
  }

  @override
  String sellErrBuyNow(String amount) {
    return 'Giá mua ngay tối thiểu $amount';
  }

  @override
  String get sellErrDesc => 'Nhập mô tả';

  @override
  String get sellDoneSaleTitle => 'Đã gửi duyệt';

  @override
  String sellDoneSaleBody(String title) {
    return 'Oldbook sẽ duyệt \"$title\" trong 24 giờ và thông báo cho bạn.';
  }

  @override
  String get sellDoneAuctionTitle => 'Đã tạo phiên đấu giá';

  @override
  String get sellDoneAuctionBody =>
      'Gửi sách về kho trong 5 ngày kèm mã dưới đây. Quá hạn phiên tự hủy. Phí ship gửi kho do bạn trả.';

  @override
  String get sellDoneCode => 'Mã nhập kho';

  @override
  String get sellDoneWarehouse =>
      'Kho Oldbook HN · 25 Lê Văn Lương, Thanh Xuân, Hà Nội';

  @override
  String get sellDoneView => 'Xem tin đăng của tôi';

  @override
  String get myListingsEmpty => 'Bạn chưa có tin đăng nào.';

  @override
  String get myListingStatusPublished => 'Đang bán';

  @override
  String get myListingStatusPending => 'Chờ duyệt';

  @override
  String get myListingStatusNeedsChanges => 'Cần sửa';

  @override
  String get myListingStatusAwaitingInbound => 'Chờ gửi về kho';

  @override
  String get myListingStatusSold => 'Đã bán';

  @override
  String myListingKindFixed(String price) {
    return 'Bán thường · $price';
  }

  @override
  String myListingKindAuction(String price) {
    return 'Đấu giá · khởi điểm $price';
  }

  @override
  String myListingNotePublished(int days, String views) {
    return 'Đăng $days ngày trước · $views lượt xem';
  }

  @override
  String myListingNotePending(int hours) {
    return 'Gửi duyệt $hours giờ trước · duyệt trong 24 giờ';
  }

  @override
  String get myListingNotePendingNow => 'Vừa gửi duyệt · duyệt trong 24 giờ';

  @override
  String myListingNoteNeedsChanges(String reason) {
    return 'Admin: $reason';
  }

  @override
  String myListingNoteInbound(String date, String code) {
    return 'Gửi sách về kho trước $date · mã $code';
  }

  @override
  String myListingNoteSold(String amount) {
    return 'Đã nhận $amount (sau phí 5%, gồm ship)';
  }

  @override
  String get sellCatLiterature => 'Văn học';

  @override
  String get sellCatHistory => 'Lịch sử';

  @override
  String get sellCatChildren => 'Thiếu nhi';

  @override
  String get sellCatScience => 'Khoa học';

  @override
  String get sellCatForeign => 'Ngoại văn';

  @override
  String get validationPhoneRequired => 'Vui lòng nhập số điện thoại.';

  @override
  String get validationOtpInvalid => 'Mã OTP gồm 6 chữ số.';

  @override
  String get validationPasswordLetterDigit => 'Mật khẩu cần có cả chữ và số.';

  @override
  String get passwordHelperLetterDigit => 'Ít nhất 8 ký tự, gồm chữ và số';

  @override
  String get otpLabel => 'Mã OTP';

  @override
  String get otpSend => 'Gửi mã';

  @override
  String otpResendIn(int n) {
    return 'Gửi lại sau ${n}s';
  }

  @override
  String otpSentTo(String phone) {
    return 'Đã gửi mã OTP tới $phone';
  }

  @override
  String get forgotLink => 'Quên mật khẩu?';

  @override
  String get forgotTitle => 'Quên mật khẩu';

  @override
  String get forgotSubtitle =>
      'Nhập số điện thoại để nhận mã xác thực và đặt mật khẩu mới.';

  @override
  String get forgotSubmit => 'Đặt lại mật khẩu';

  @override
  String get forgotDone => 'Đã đặt lại mật khẩu. Hãy đăng nhập.';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get errOtpInvalid => 'Mã OTP chưa đúng.';

  @override
  String get errOtpExpired => 'Mã OTP đã hết hạn. Hãy gửi lại mã.';

  @override
  String get errRateLimited =>
      'Bạn thao tác quá nhanh. Hãy thử lại sau ít phút.';

  @override
  String get errAccountLocked => 'Tài khoản của bạn đang bị khóa.';

  @override
  String get errInsufficientBalance => 'Số dư ví không đủ.';

  @override
  String get errBidTooLow => 'Giá thấp hơn mức tối thiểu hiện tại.';

  @override
  String get errAlreadyLeading => 'Bạn đang dẫn đầu phiên này.';

  @override
  String get errAuctionEnded => 'Phiên đã kết thúc.';

  @override
  String get errAuctionNotLive => 'Phiên chưa diễn ra.';

  @override
  String get errBuyNowUnavailable => 'Không còn mua ngay được.';

  @override
  String get errNotRegistered => 'Bạn chưa đăng ký phiên này.';

  @override
  String get errRegistrationClosed => 'Đăng ký đã đóng.';

  @override
  String get errSellerCannotBid =>
      'Người bán không thể tham gia phiên của mình.';

  @override
  String get errListingNotAvailable => 'Sách này không còn bán.';

  @override
  String get errComplaintWindowClosed => 'Đã quá hạn khiếu nại.';

  @override
  String get errWithdrawBelowMin => 'Số tiền rút thấp hơn mức tối thiểu.';

  @override
  String get errForbidden => 'Bạn không có quyền thực hiện thao tác này.';

  @override
  String get errNotFound => 'Không tìm thấy nội dung này.';

  @override
  String get errInvalidState => 'Không thể thực hiện ở trạng thái hiện tại.';

  @override
  String get errUpstream => 'Dịch vụ đối tác đang gặp sự cố. Hãy thử lại sau.';

  @override
  String get addrTitle => 'Sổ địa chỉ';

  @override
  String get addrSub => 'Địa chỉ giao hàng, đặt mặc định';

  @override
  String get addrEmpty => 'Bạn chưa có địa chỉ nào.';

  @override
  String get addrAdd => 'Thêm địa chỉ';

  @override
  String get addrEdit => 'Sửa địa chỉ';

  @override
  String get addrDefault => 'Mặc định';

  @override
  String get addrSetDefault => 'Đặt làm mặc định';

  @override
  String get addrDelete => 'Xóa';

  @override
  String get addrDeleteTitle => 'Xóa địa chỉ này?';

  @override
  String get addrRecipient => 'Người nhận';

  @override
  String get addrPhone => 'Số điện thoại';

  @override
  String get addrProvince => 'Tỉnh/Thành phố';

  @override
  String get addrDistrict => 'Quận/Huyện';

  @override
  String get addrWard => 'Phường/Xã';

  @override
  String get addrDetail => 'Số nhà, tên đường';

  @override
  String get addrSave => 'Lưu địa chỉ';

  @override
  String get addrRequired => 'Vui lòng nhập thông tin này.';

  @override
  String get addrNone => 'Chưa có địa chỉ giao hàng';

  @override
  String get bankTitle => 'Tài khoản ngân hàng';

  @override
  String get bankSub => 'Nhận tiền khi rút từ ví (tối đa 3)';

  @override
  String get bankEmpty => 'Bạn chưa lưu tài khoản ngân hàng nào.';

  @override
  String get bankAdd => 'Thêm tài khoản';

  @override
  String get bankName => 'Ngân hàng';

  @override
  String get bankNumber => 'Số tài khoản';

  @override
  String get bankHolder => 'Tên chủ tài khoản';

  @override
  String get bankHolderNote =>
      'Tên chủ tài khoản phải trùng họ tên trong hồ sơ.';

  @override
  String get bankLimit => 'Chỉ lưu tối đa 3 tài khoản.';

  @override
  String get bankSave => 'Lưu tài khoản';

  @override
  String get bankDeleteTitle => 'Xóa tài khoản này?';

  @override
  String bankMasked(String last) {
    return '•••• $last';
  }

  @override
  String get roleUser => 'Người dùng';

  @override
  String get roleSuperAdmin => 'Quản trị cấp cao';

  @override
  String get errPhoneTaken =>
      'Số điện thoại này đã có tài khoản. Hãy đăng nhập hoặc đặt lại mật khẩu.';

  @override
  String errAccountLockedTemp(int n) {
    return 'Tạm khóa đăng nhập, thử lại sau $n phút. Bạn có thể đặt lại mật khẩu để mở khóa ngay.';
  }

  @override
  String errRateLimitedIn(int n) {
    return 'Bạn thao tác quá nhanh. Thử lại sau $n giây.';
  }

  @override
  String get termsLabel =>
      'Tôi đồng ý Điều khoản sử dụng và cho phép xử lý dữ liệu cá nhân theo Nghị định 13/2023.';

  @override
  String get validationTermsRequired =>
      'Bạn cần đồng ý điều khoản để tiếp tục.';

  @override
  String otpExpiresIn(String time) {
    return 'Mã hết hạn sau $time';
  }

  @override
  String get otpExpired => 'Mã đã hết hạn. Hãy gửi lại mã.';

  @override
  String get forgotOtpNotice =>
      'Nếu số đã đăng ký, mã sẽ được gửi tới email của tài khoản.';

  @override
  String get pwRuleLength => 'Ít nhất 8 ký tự';

  @override
  String get pwRuleLetter => 'Có chữ cái';

  @override
  String get pwRuleDigit => 'Có chữ số';

  @override
  String loginLockedRetry(String time) {
    return 'Thử lại sau $time';
  }

  @override
  String get errAddressNotFound => 'Không tìm thấy địa chỉ này.';

  @override
  String get errDeletionBlocked =>
      'Chưa thể xóa tài khoản vì còn việc chưa xong.';

  @override
  String get errRoleNotAllowed => 'Tài khoản quản trị không tự xóa được.';

  @override
  String get phoneChangeLink => 'Đổi số điện thoại';

  @override
  String get phoneReadOnlyHelper =>
      'Đổi số cần mã OTP gửi tới email của tài khoản.';

  @override
  String get changePhoneTitle => 'Đổi số điện thoại';

  @override
  String get changePhoneIntro =>
      'Mã OTP sẽ được gửi tới email của tài khoản. Lần đăng nhập sau dùng số mới.';

  @override
  String get newPhoneLabel => 'Số điện thoại mới';

  @override
  String get changePhoneSubmit => 'Xác nhận đổi số';

  @override
  String get changePhoneDone => 'Đã đổi số điện thoại.';

  @override
  String get validationPhoneSame => 'Số mới trùng số hiện tại.';

  @override
  String get errPhoneTakenOther => 'Số này đã thuộc tài khoản khác.';

  @override
  String get logoutAll => 'Đăng xuất mọi thiết bị';

  @override
  String get logoutAllConfirmTitle => 'Đăng xuất mọi thiết bị?';

  @override
  String get logoutAllConfirmMessage =>
      'Bạn sẽ phải đăng nhập lại trên tất cả thiết bị.';

  @override
  String get deleteAccountEntry => 'Xóa tài khoản';

  @override
  String get deleteAccountTitle => 'Xóa tài khoản';

  @override
  String get deleteAccountWarning =>
      'Hành động này không thể hoàn tác. Tên và số điện thoại của bạn sẽ bị ẩn danh, địa chỉ và thiết bị bị xóa, mọi phiên đăng nhập bị thu hồi. Dữ liệu giao dịch được giữ lại để đối soát.';

  @override
  String get deleteAccountPasswordLabel => 'Nhập mật khẩu để xác nhận';

  @override
  String get deleteAccountSubmit => 'Xóa tài khoản vĩnh viễn';

  @override
  String get deleteAccountConfirmTitle => 'Bạn chắc chắn muốn xóa?';

  @override
  String get deleteAccountConfirmMessage =>
      'Tài khoản sẽ bị xóa vĩnh viễn và không thể khôi phục.';

  @override
  String get deleteAccountBlockedHeader =>
      'Hãy xử lý các việc sau rồi thử lại:';

  @override
  String get notifSettingsTitle => 'Tùy chọn thông báo';

  @override
  String get notifSettingsMarketing => 'Tin khuyến mãi';

  @override
  String get notifSettingsMarketingSub => 'Nhận push về ưu đãi, tiếp thị.';

  @override
  String get notifSettingsAuction => 'Phiên đấu giá đang theo dõi';

  @override
  String get notifSettingsAuctionSub => 'Nhận push về các phiên bạn theo dõi.';

  @override
  String get notifSettingsAlways =>
      'Thông báo giao dịch, bảo mật và tiền (khóa tài khoản, đổi mật khẩu, ví, đơn, khiếu nại) luôn được gửi. Thông báo trong app luôn được lưu, kể cả khi tắt push.';

  @override
  String walletTopupMin(String amount) {
    return 'Nạp tối thiểu $amount';
  }

  @override
  String get walletLoadError => 'Không tải được ví.';

  @override
  String get walletHistoryFilterAll => 'Tất cả';

  @override
  String get walletLedgerTopup => 'Nạp tiền';

  @override
  String get walletLedgerWithdraw => 'Rút tiền';

  @override
  String get walletLedgerHold => 'Giữ tiền';

  @override
  String get walletLedgerRelease => 'Hoàn tiền giữ';

  @override
  String get walletLedgerPayout => 'Nhận tiền bán hàng';

  @override
  String get walletLedgerRefund => 'Hoàn tiền';

  @override
  String get walletLedgerCompensation => 'Bồi thường từ Oldbook';

  @override
  String get walletLedgerCapture => 'Chốt trừ tiền';

  @override
  String get walletLedgerFee => 'Phí';

  @override
  String get walletLedgerOther => 'Giao dịch';

  @override
  String walletBalanceAfter(String amount) {
    return 'Số dư sau: $amount';
  }

  @override
  String walletHeldNote(String amount) {
    return 'Đang giữ: $amount';
  }

  @override
  String get walletMoreHistory => 'Lịch sử nạp / rút';

  @override
  String get walletLoadMore => 'Xem thêm';

  @override
  String get topupAmountLabel => 'Số tiền nạp';

  @override
  String topupAmountRange(String min, String max) {
    return 'Từ $min đến $max';
  }

  @override
  String topupAmountOut(String min, String max) {
    return 'Số tiền phải từ $min đến $max.';
  }

  @override
  String get topupCreate => 'Tạo yêu cầu nạp';

  @override
  String get topupOpenPay => 'Mở trang thanh toán';

  @override
  String get topupWaiting => 'Đang chờ thanh toán…';

  @override
  String topupWaitingNote(String time) {
    return 'Hoàn tất thanh toán rồi quay lại app. Hạn thanh toán: $time.';
  }

  @override
  String get topupCheckAgain => 'Kiểm tra lại';

  @override
  String topupPaid(String amount) {
    return 'Nạp thành công $amount';
  }

  @override
  String get topupExpired =>
      'Yêu cầu đã quá hạn. Nếu bạn vẫn thanh toán, tiền vẫn được cộng; bấm kiểm tra lại.';

  @override
  String get topupFailed =>
      'Thanh toán không thành công. Nếu đã bị trừ tiền, hãy liên hệ hỗ trợ.';

  @override
  String get topupDevPay => 'Dev: giả lập thanh toán thành công';

  @override
  String get topupCannotOpen => 'Không mở được trang thanh toán.';

  @override
  String get withdrawPickBank => 'Chọn tài khoản nhận tiền';

  @override
  String get withdrawNoBank => 'Bạn chưa có tài khoản ngân hàng.';

  @override
  String get withdrawAddBank => 'Thêm tài khoản';

  @override
  String withdrawMinHint(String amount) {
    return 'Tối thiểu $amount';
  }

  @override
  String withdrawCreated(String amount) {
    return 'Đã gửi yêu cầu rút $amount. Tiền được giữ chờ duyệt.';
  }

  @override
  String withdrawNeedHave(String required, String available) {
    return 'Cần $required, hiện có $available.';
  }

  @override
  String withdrawBelowMin(String amount) {
    return 'Số tiền rút tối thiểu là $amount.';
  }

  @override
  String get withdrawNoCancel =>
      'Yêu cầu rút không tự hủy được. Cần hỗ trợ, hãy liên hệ Oldbook.';

  @override
  String get historyTitle => 'Lịch sử nạp / rút';

  @override
  String get historyTopups => 'Nạp tiền';

  @override
  String get historyWithdrawals => 'Rút tiền';

  @override
  String get historyEmpty => 'Chưa có giao dịch.';

  @override
  String get topupStatusPending => 'Chờ thanh toán';

  @override
  String get topupStatusPaid => 'Đã nhận tiền';

  @override
  String get topupStatusExpired => 'Quá hạn';

  @override
  String get topupStatusFailed => 'Thất bại';

  @override
  String get wdStatusRequested => 'Chờ duyệt';

  @override
  String get wdStatusApproved => 'Đã duyệt, chờ chuyển khoản';

  @override
  String get wdStatusSubmitted => 'Đã gửi lệnh tới ngân hàng';

  @override
  String get wdStatusPaid => 'Đã chuyển thành công';

  @override
  String get wdStatusRejected => 'Bị từ chối, tiền đã trả về ví';

  @override
  String get wdStatusFailed => 'Chuyển khoản thất bại, tiền đã trả về ví';

  @override
  String get wdStatusUnknown => 'Đang xử lý';

  @override
  String wdReason(String reason) {
    return 'Lý do: $reason';
  }

  @override
  String wdTimeline(String created) {
    return 'Tạo lúc $created';
  }

  @override
  String get bankPickBank => 'Ngân hàng';

  @override
  String get bankHolderMismatch =>
      'Tên chủ tài khoản khác họ tên hồ sơ. Admin có thể từ chối yêu cầu rút nếu hai tên không khớp.';

  @override
  String get bankNumberInvalid => 'Số tài khoản gồm 6 đến 20 chữ số.';

  @override
  String get errBankDuplicate => 'Tài khoản này đã được lưu.';

  @override
  String get errBankLimit =>
      'Bạn chỉ lưu được tối đa 3 tài khoản. Hãy xóa bớt.';

  @override
  String get errBankNotFound => 'Không tìm thấy tài khoản ngân hàng.';

  @override
  String get errTopupRange => 'Số tiền nạp ngoài khoảng cho phép.';

  @override
  String get errIdempotencyInProgress =>
      'Yêu cầu trước đang được xử lý, vui lòng đợi giây lát.';

  @override
  String get statusReserved => 'Đã có người đặt';

  @override
  String get statusUnpublished => 'Đã gỡ';

  @override
  String get conditionBrandNew => 'Mới';

  @override
  String get conditionWorn => 'Cũ';

  @override
  String filterButtonCount(int n) {
    return 'Lọc ($n)';
  }

  @override
  String get filterCondition => 'Tình trạng';

  @override
  String get filterPrice => 'Khoảng giá (₫)';

  @override
  String get filterMin => 'Từ';

  @override
  String get filterMax => 'Đến';

  @override
  String get filterSort => 'Sắp xếp';

  @override
  String get sortNewest => 'Mới nhất';

  @override
  String get sortPriceAsc => 'Giá tăng dần';

  @override
  String get sortPriceDesc => 'Giá giảm dần';

  @override
  String get filterApply => 'Áp dụng';

  @override
  String get filterReset => 'Đặt lại';

  @override
  String get filterPriceInvalid =>
      'Giá thấp nhất không được lớn hơn giá cao nhất.';

  @override
  String get detailReserved => 'Đã có người đặt mua cuốn này.';

  @override
  String get detailSold => 'Cuốn này đã bán.';

  @override
  String detailOwnerStatus(String status) {
    return 'Trạng thái tin của bạn: $status';
  }

  @override
  String detailReviewReason(String reason) {
    return 'Lý do: $reason';
  }

  @override
  String sellerStats(int n) {
    return '$n đơn hoàn tất';
  }

  @override
  String sellerRating(String rating) {
    return '$rating ★';
  }

  @override
  String listingPhotoN(int n, String title) {
    return 'Ảnh $n của sách $title';
  }

  @override
  String get sellProgressCreate => 'Đang tạo tin…';

  @override
  String sellProgressUpload(int done, int total) {
    return 'Đang tải ảnh $done/$total…';
  }

  @override
  String get sellProgressSubmit => 'Đang gửi duyệt…';

  @override
  String get sellErrCategory => 'Chọn thể loại.';

  @override
  String get sellErrIsbn => 'ISBN không hợp lệ.';

  @override
  String get sellFieldPublisher => 'Nhà xuất bản (tùy chọn)';

  @override
  String get sellFieldYear => 'Năm xuất bản (tùy chọn)';

  @override
  String get sellFieldIsbn => 'ISBN (tùy chọn)';

  @override
  String get sellFieldDefects => 'Mô tả lỗi, nếu có (tùy chọn)';

  @override
  String get sellEditTitle => 'Sửa tin đăng';

  @override
  String get sellEditSave => 'Lưu thay đổi';

  @override
  String get sellEditSaveSubmit => 'Lưu và gửi duyệt';

  @override
  String get sellEditWarnTitle => 'Tin sẽ quay về chờ duyệt';

  @override
  String get sellEditWarnBody =>
      'Sửa tên, tác giả, thể loại, tình trạng, nhà xuất bản, năm, ISBN, mô tả lỗi hoặc ảnh sẽ đưa tin về chờ duyệt và tạm ẩn khỏi tìm kiếm. Sửa giá và mô tả thì có hiệu lực ngay.';

  @override
  String get sellEditWarnConfirm => 'Vẫn lưu';

  @override
  String get sellSaved => 'Đã lưu thay đổi.';

  @override
  String get photoMakeCover => 'Đặt làm ảnh bìa';

  @override
  String sellPhotoLimit(int n) {
    return 'Tối đa $n ảnh.';
  }

  @override
  String get mlTabPublished => 'Đang bán';

  @override
  String get mlTabPending => 'Chờ duyệt';

  @override
  String get mlTabChanges => 'Cần sửa';

  @override
  String get mlTabDraft => 'Nháp';

  @override
  String get mlTabUnpublished => 'Đã gỡ';

  @override
  String get mlTabSold => 'Đã bán';

  @override
  String get mlTabRejected => 'Bị từ chối';

  @override
  String get mlEdit => 'Sửa';

  @override
  String get mlSubmit => 'Gửi duyệt';

  @override
  String get mlResubmit => 'Gửi duyệt lại';

  @override
  String get mlRepublish => 'Đăng lại';

  @override
  String get mlUnpublish => 'Gỡ tin';

  @override
  String get mlUnpublishTitle => 'Gỡ tin này?';

  @override
  String get mlUnpublishBody =>
      'Tin sẽ ẩn khỏi tìm kiếm. Muốn đăng lại phải qua duyệt lại.';

  @override
  String get mlRejectedFinal =>
      'Tin bị từ chối là kết thúc. Hãy tạo tin mới nếu muốn.';

  @override
  String mlReason(String reason) {
    return 'Lý do: $reason';
  }

  @override
  String get mlPendingNote =>
      'Đang chờ duyệt, thường trong 24 giờ. Chưa sửa được.';

  @override
  String get mlSubmitted => 'Đã gửi duyệt.';

  @override
  String get mlUnpublished => 'Đã gỡ tin.';

  @override
  String get mlSimHeader => 'Đấu giá (mô phỏng)';

  @override
  String get mlReservedNote => 'Đã có người đặt mua, chưa thể sửa hay gỡ.';

  @override
  String get errCategoryInactive =>
      'Thể loại này đã bị ẩn. Hãy chọn thể loại khác.';

  @override
  String get errListingConcurrent =>
      'Tin vừa bị thay đổi ở nơi khác. Đã tải lại, hãy thử lại.';

  @override
  String get errListingPhoto =>
      'Có ảnh không hợp lệ (chưa tải lên, quá 10 MB hoặc không phải ảnh). Hãy chọn lại.';

  @override
  String get errListingIncomplete =>
      'Tin chưa đủ điều kiện gửi duyệt (thiếu ảnh hoặc thông tin).';

  @override
  String get errPaymentUnavailable =>
      'Tạm thời chưa hỗ trợ nạp tiền. Hãy thử lại sau.';

  @override
  String get errOrderNotFound => 'Không tìm thấy đơn hàng này.';

  @override
  String get errOwnListing => 'Bạn không thể mua sách của chính mình.';

  @override
  String get errCartFull => 'Giỏ hàng đã đủ 50 sản phẩm.';

  @override
  String get errComplaintNotFound => 'Không tìm thấy khiếu nại này.';

  @override
  String get errComplaintAttachment =>
      'Có tệp bằng chứng không hợp lệ (sai loại, quá dung lượng hoặc đã dùng). Hãy chọn lại.';

  @override
  String get topupNoGateway => 'Tạm thời chưa hỗ trợ nạp tiền.';

  @override
  String get topupPickGateway => 'Chọn cổng thanh toán';

  @override
  String get topupConfirming =>
      'Đang xác nhận thanh toán, số dư sẽ cập nhật sau ít phút. Bạn sẽ nhận thông báo khi nạp thành công.';

  @override
  String get soStatusAwaiting => 'Chờ người bán gửi';

  @override
  String get soStatusShipped => 'Đang vận chuyển';

  @override
  String get soStatusDelivered => 'Đã giao';

  @override
  String get soStatusCompleted => 'Hoàn tất';

  @override
  String get soStatusCancelledBuyer => 'Đã hủy';

  @override
  String get soStatusCancelledTimeout => 'Hủy do quá hạn gửi';

  @override
  String get soStatusDisputed => 'Đang khiếu nại';

  @override
  String get soStatusRefunded => 'Đã hoàn tiền';

  @override
  String get soStatusPartial => 'Hoàn một phần';

  @override
  String get soTabBuy => 'Đơn mua';

  @override
  String get soTabSell => 'Đơn bán';

  @override
  String get soEmpty => 'Chưa có đơn nào.';

  @override
  String get soSimLink => 'Đơn đấu giá (mô phỏng)';

  @override
  String soNoteShipBy(String time) {
    return 'Gửi trước $time';
  }

  @override
  String soNoteTracking(String carrier, String code) {
    return '$carrier · $code';
  }

  @override
  String soNoteComplaintBy(String time) {
    return 'Khiếu nại trước $time';
  }

  @override
  String get soNoteLocked => 'Tiền đang bị khóa chờ xử lý khiếu nại';

  @override
  String get soDetailTitle => 'Chi tiết đơn';

  @override
  String get soPrice => 'Giá sách';

  @override
  String get soShipFee => 'Phí ship';

  @override
  String get soTotal => 'Tổng thanh toán';

  @override
  String get soPayout => 'Bạn nhận được';

  @override
  String get soPayoutFee => 'Phí nền tảng';

  @override
  String get soPayoutNet => 'Thực nhận';

  @override
  String get soSeller => 'Người bán';

  @override
  String get soBuyer => 'Người mua';

  @override
  String get soAddress => 'Địa chỉ nhận hàng';

  @override
  String get soShipment => 'Vận đơn';

  @override
  String get soTimeline => 'Diễn biến';

  @override
  String soCountdownShip(String time) {
    return 'Hạn gửi hàng: còn $time';
  }

  @override
  String soCountdownShipBuyer(String time) {
    return 'Người bán cần gửi hàng trong $time.';
  }

  @override
  String soCountdownComplaint(String time) {
    return 'Hạn khiếu nại: còn $time. Hết hạn này đơn sẽ tự hoàn tất.';
  }

  @override
  String get soOverdue => 'đã quá hạn';

  @override
  String get soCancel => 'Hủy đơn';

  @override
  String get soCancelTitle => 'Hủy đơn này?';

  @override
  String get soCancelBody => 'Tiền được hoàn về ví và sách được đăng bán lại.';

  @override
  String get soReceived => 'Đã nhận hàng';

  @override
  String get soReceivedTitle => 'Xác nhận đã nhận hàng?';

  @override
  String get soReceivedBody =>
      'Sau khi xác nhận, bạn có thời gian khiếu nại nếu sách có vấn đề.';

  @override
  String get soComplete => 'Hài lòng, hoàn tất';

  @override
  String get soCompleteTitle => 'Hoàn tất đơn?';

  @override
  String get soCompleteBody =>
      'Tiền chuyển cho người bán ngay và bạn không khiếu nại được nữa.';

  @override
  String get soShip => 'Nhập vận đơn';

  @override
  String get soShipCarrier => 'Hãng vận chuyển';

  @override
  String get soShipTracking => 'Mã vận đơn';

  @override
  String get soShipSubmit => 'Xác nhận đã gửi';

  @override
  String get soShipInvalid => 'Hãng 2 đến 50 ký tự, mã vận đơn 3 đến 50 ký tự.';

  @override
  String get soComplain => 'Khiếu nại';

  @override
  String get soViewComplaint => 'Xem khiếu nại';

  @override
  String get soCancelled => 'Đã hủy đơn.';

  @override
  String get soReceivedDone => 'Đã xác nhận nhận hàng.';

  @override
  String get soCompleted => 'Đã hoàn tất đơn.';

  @override
  String get soShipped => 'Đã nhập vận đơn.';

  @override
  String get ckUnavailable => 'Không còn bán';

  @override
  String get ckRemove => 'Xóa';

  @override
  String get ckSubtotal => 'Tiền sách';

  @override
  String ckShipping(int count, String fee) {
    return 'Phí ship ($count đơn × $fee)';
  }

  @override
  String get ckTotal => 'Tổng thanh toán';

  @override
  String get ckBalance => 'Số dư ví';

  @override
  String get ckAddress => 'Giao tới';

  @override
  String get ckPickAddress => 'Chọn địa chỉ';

  @override
  String get ckNoAddress => 'Bạn chưa có địa chỉ nhận hàng.';

  @override
  String get ckAddAddress => 'Thêm địa chỉ';

  @override
  String get ckPlace => 'Đặt hàng · thanh toán bằng ví';

  @override
  String get ckPlaceEmpty => 'Không có sách khả dụng';

  @override
  String get ckNeedAddress => 'Chọn địa chỉ để đặt hàng';

  @override
  String get ckInsufficient => 'Số dư không đủ · nạp thêm';

  @override
  String get ckEmpty => 'Giỏ hàng trống.';

  @override
  String get ckPlacedTitle => 'Đặt hàng thành công';

  @override
  String ckPlacedBody(String total, int count) {
    return 'Đã giữ $total từ ví cho $count đơn. Người bán có hạn gửi hàng, quá hạn đơn tự hủy và hoàn tiền.';
  }

  @override
  String get ckViewOrders => 'Xem đơn hàng';

  @override
  String get ckKeepShopping => 'Tiếp tục mua sắm';

  @override
  String get ckSomeUnavailable =>
      'Một số sách vừa bị người khác đặt hoặc gỡ. Đã đánh dấu trong giỏ, hãy bỏ chúng rồi đặt lại.';

  @override
  String get ckAdded => 'Đã thêm vào giỏ';

  @override
  String get ckAlready => 'Sách đã có trong giỏ';

  @override
  String get cpListTitle => 'Khiếu nại của tôi';

  @override
  String get cpTabBuy => 'Tôi khiếu nại';

  @override
  String get cpTabSell => 'Về đơn bán của tôi';

  @override
  String get cpEmpty => 'Chưa có khiếu nại nào.';

  @override
  String get cpStatusOpen => 'Chờ người bán phản hồi';

  @override
  String get cpStatusResponded => 'Chờ người mua quyết định';

  @override
  String get cpStatusEscalated => 'Chờ quản trị viên';

  @override
  String get cpStatusAgreed => 'Đã thỏa thuận';

  @override
  String get cpStatusResolved => 'Đã giải quyết';

  @override
  String get cpReasonNotAsDescribed => 'Không đúng mô tả';

  @override
  String get cpReasonDamaged => 'Hư hỏng';

  @override
  String get cpReasonWrongItem => 'Sai sách';

  @override
  String get cpReasonOther => 'Lý do khác';

  @override
  String get cpOpenTitle => 'Mở khiếu nại';

  @override
  String get cpReasonLabel => 'Lý do';

  @override
  String get cpDescLabel => 'Mô tả vấn đề';

  @override
  String get cpDescHint => 'Ít nhất 10 ký tự';

  @override
  String get cpDescInvalid => 'Mô tả từ 10 đến 2.000 ký tự.';

  @override
  String get cpEvidence => 'Bằng chứng (ảnh hoặc video)';

  @override
  String cpEvidenceCount(int n) {
    return '$n/10 · cần ít nhất 1';
  }

  @override
  String get cpEvidenceRequired => 'Cần ít nhất 1 ảnh hoặc video.';

  @override
  String get cpAddEvidence => 'Thêm ảnh/video';

  @override
  String get cpPickPhoto => 'Chọn ảnh';

  @override
  String get cpPickVideo => 'Chọn video';

  @override
  String get cpEvidenceTooLarge =>
      'Tệp quá lớn (ảnh tối đa 10 MB, video tối đa 50 MB).';

  @override
  String get cpEvidenceUnsupported =>
      'Định dạng không hỗ trợ (ảnh JPEG/PNG/WebP, video MP4/MOV/WebM).';

  @override
  String get cpSubmit => 'Gửi khiếu nại';

  @override
  String cpUploading(int done, int total) {
    return 'Đang tải bằng chứng $done/$total…';
  }

  @override
  String get cpOpened => 'Đã gửi khiếu nại.';

  @override
  String get cpOpenNote =>
      'Gửi khiếu nại sẽ khóa tiền của đơn cho tới khi được giải quyết.';

  @override
  String get cpOrder => 'Đơn hàng';

  @override
  String get cpOpenOrder => 'Xem đơn';

  @override
  String cpSellerDeadline(String time) {
    return 'Người bán cần phản hồi: còn $time';
  }

  @override
  String cpBuyerDeadline(String time) {
    return 'Bạn cần quyết định: còn $time';
  }

  @override
  String get cpDeadlineNote =>
      'Quá hạn, khiếu nại tự chuyển cho quản trị viên.';

  @override
  String get cpEscSellerTimeout =>
      'Chuyển admin vì người bán không phản hồi kịp.';

  @override
  String get cpEscBuyerRejected => 'Chuyển admin vì người mua không đồng ý.';

  @override
  String get cpEscBuyerTimeout =>
      'Chuyển admin vì người mua không quyết định kịp.';

  @override
  String get cpEscAuction => 'Chuyển admin (đơn đấu giá).';

  @override
  String get cpResolution => 'Kết quả';

  @override
  String get cpOutFull => 'Hoàn toàn bộ (giá sách và phí ship)';

  @override
  String cpOutPartial(String amount) {
    return 'Hoàn một phần: $amount';
  }

  @override
  String get cpOutRelease => 'Không hoàn: tiền chuyển cho người bán';

  @override
  String get cpReturnRequired =>
      'Quản trị viên yêu cầu người mua gửi trả sách. Việc gửi trả thực hiện ngoài hệ thống; hai bên trao đổi qua tin nhắn nếu cần.';

  @override
  String get cpByAdmin => 'Quản trị viên phán quyết';

  @override
  String get cpByAgreement => 'Hai bên thỏa thuận';

  @override
  String get cpAuthorBuyer => 'Người mua';

  @override
  String get cpAuthorSeller => 'Người bán';

  @override
  String get cpAuthorAdmin => 'Quản trị viên';

  @override
  String get cpAuthorSystem => 'Hệ thống';

  @override
  String get cpEntryOpened => 'Mở khiếu nại';

  @override
  String get cpEntrySellerResponse => 'Người bán phản hồi';

  @override
  String get cpEntryBuyerDecision => 'Người mua quyết định';

  @override
  String get cpEntryEscalated => 'Chuyển cho quản trị viên';

  @override
  String get cpEntryResolved => 'Đã giải quyết';

  @override
  String cpRefundAmount(String amount) {
    return 'Hoàn $amount';
  }

  @override
  String get cpRespond => 'Phản hồi';

  @override
  String get cpRespondTitle => 'Phản hồi khiếu nại';

  @override
  String get cpActAccept => 'Đồng ý hoàn toàn bộ (giá sách và phí ship)';

  @override
  String get cpActPartial => 'Đề xuất hoàn một phần';

  @override
  String get cpActReject => 'Từ chối';

  @override
  String get cpAmountLabel => 'Số tiền hoàn (trên giá sách)';

  @override
  String cpAmountInvalid(String max) {
    return 'Số tiền phải từ 1 đến $max.';
  }

  @override
  String get cpRejectReason => 'Lý do từ chối (nên kèm ảnh bằng chứng)';

  @override
  String get cpReasonInvalid => 'Lý do tối thiểu 10 ký tự.';

  @override
  String get cpRespondSubmit => 'Gửi phản hồi';

  @override
  String get cpResponded => 'Đã gửi phản hồi.';

  @override
  String get cpRespondNote => 'Người mua vẫn cần xác nhận kết quả.';

  @override
  String get cpAccept => 'Đồng ý';

  @override
  String get cpDisagree => 'Không đồng ý, chuyển admin';

  @override
  String get cpAcceptTitle => 'Đồng ý với phản hồi?';

  @override
  String get cpAcceptFull => 'Bạn được hoàn toàn bộ giá sách và phí ship.';

  @override
  String cpAcceptPartial(String amount) {
    return 'Bạn được hoàn $amount. Phần còn lại chuyển cho người bán.';
  }

  @override
  String get cpAcceptReject =>
      'Người bán đã từ chối. Bấm đồng ý nghĩa là bạn RÚT khiếu nại và tiền chuyển cho người bán.';

  @override
  String get cpDisagreeTitle => 'Chuyển cho quản trị viên?';

  @override
  String get cpDisagreeBody => 'Quản trị viên sẽ xem xét và phán quyết.';

  @override
  String get cpDecided => 'Đã ghi nhận quyết định.';

  @override
  String get cpMessageHint => 'Nhập tin nhắn…';

  @override
  String get cpSend => 'Gửi';

  @override
  String get cpMessageClosed => 'Khiếu nại đã đóng, không thể nhắn tin.';

  @override
  String get cpMessageNeed => 'Nhập nội dung hoặc đính kèm một tệp.';

  @override
  String get cpOpenVideo => 'Mở video';

  @override
  String get cpLockedNote =>
      'Tiền của đơn đang bị khóa cho tới khi khiếu nại được giải quyết.';

  @override
  String otpSentToEmail(String email) {
    return 'Mã đã gửi tới $email. Kiểm tra cả thư mục Spam/Quảng cáo.';
  }

  @override
  String get emailOtpHelper => 'Mã OTP sẽ được gửi tới email này.';

  @override
  String get emailNotSet => 'Chưa có email';

  @override
  String get errEmailTakenLogin =>
      'Email này đã thuộc tài khoản khác. Nếu là bạn, hãy đăng nhập.';

  @override
  String get errEmailRequired => 'Tài khoản chưa có email, hãy liên hệ hỗ trợ.';

  @override
  String get errOtpSendFailed => 'Không gửi được mã, hãy thử lại sau.';

  @override
  String get aoTitle => 'Đơn đấu giá';

  @override
  String get aoDetailTitle => 'Chi tiết đơn đấu giá';

  @override
  String get aoTabBuyer => 'Tôi thắng';

  @override
  String get aoTabSeller => 'Tôi bán';

  @override
  String get aoFilterAction => 'Cần xử lý';

  @override
  String get aoFilterShipping => 'Đang giao';

  @override
  String get aoFilterFinished => 'Đã xong';

  @override
  String get aoEmpty => 'Chưa có đơn đấu giá.';

  @override
  String get aoEmptyBuyerHint => 'Thắng một phiên đấu giá, đơn sẽ hiện ở đây.';

  @override
  String aoWinningPrice(String amount) {
    return 'Giá thắng $amount';
  }

  @override
  String get aoStatusAwaitingFee => 'Chờ phí ship';

  @override
  String get aoStatusReadyToShip => 'Chờ kho gửi';

  @override
  String get aoStatusInDelivery => 'Đang giao';

  @override
  String get aoStatusInStorage => 'Đang lưu kho';

  @override
  String get aoStatusDelivered => 'Đã giao';

  @override
  String get aoStatusPickedUp => 'Đã nhận tại kho';

  @override
  String get aoStatusStorageExpired => 'Hết hạn lưu kho';

  @override
  String get aoStatusDisputed => 'Đang khiếu nại';

  @override
  String get aoStatusCompleted => 'Hoàn tất';

  @override
  String get aoStatusRefunded => 'Đã hoàn tiền';

  @override
  String get aoStatusPartiallyRefunded => 'Hoàn một phần';

  @override
  String get aoPeAwaitingDecision => 'Chờ bạn chọn cách nhận sách';

  @override
  String get aoPeExtended => 'Đã gia hạn lưu kho';

  @override
  String get aoPeAwaitingLiquidation => 'Sách sẽ được thanh lý';

  @override
  String get aoPeLiquidated => 'Đã thanh lý';

  @override
  String get aoPeReleased => 'Kho đã giao sách';

  @override
  String get aoPeDecisionBody =>
      'Người bán đã được thanh toán, sách vẫn thuộc về bạn. Hãy chọn gia hạn, nhận tại kho hoặc giao lại trước hạn, nếu không sách sẽ bị thanh lý.';

  @override
  String aoDecisionLeft(String left) {
    return 'Còn $left để chọn';
  }

  @override
  String aoExtendButton(String fee, int n) {
    return 'Gia hạn $fee (còn $n lần)';
  }

  @override
  String get aoExtendTitle => 'Gia hạn lưu kho';

  @override
  String aoExtendBody(String fee, int days) {
    return 'Trả trước $fee để giữ sách thêm $days ngày.';
  }

  @override
  String aoExtendedUntil(String date) {
    return 'Đã gia hạn tới $date';
  }

  @override
  String get aoLiquidationBody =>
      'Bạn không chọn cách nhận sách kịp hạn. Admin sẽ thanh lý, tiền thu được (trừ phí) sẽ cộng vào ví.';

  @override
  String aoLiquidatedBody(String amount) {
    return '$amount đã được cộng vào ví (sau phí thanh lý).';
  }

  @override
  String get aoAddressRequiredTitle => 'Chưa có địa chỉ giao';

  @override
  String get aoAddressRequiredBody =>
      'Kho chỉ gửi được khi đơn có địa chỉ. Chọn một địa chỉ trong sổ địa chỉ.';

  @override
  String aoFeeNeededTitle(String amount) {
    return 'Cần $amount phí ship';
  }

  @override
  String aoFeeNeededBefore(String amount, String date) {
    return 'Cần $amount phí ship trước $date';
  }

  @override
  String get aoFeeNeededBody =>
      'Quá hạn kho vẫn gửi sách và phí ship sẽ bị trừ vào cọc.';

  @override
  String aoTimeLeft(String left) {
    return 'Còn $left';
  }

  @override
  String get aoPayFeeButton => 'Nạp và thanh toán phí ship';

  @override
  String get aoPayFeeTitle => 'Thanh toán phí ship';

  @override
  String aoPayFeeBody(String amount) {
    return 'Ví sẽ giữ $amount cho lần giao sắp tới.';
  }

  @override
  String aoPayFeeConfirm(String amount) {
    return 'Giữ $amount';
  }

  @override
  String get aoFeeHeld => 'Đã giữ phí ship';

  @override
  String get aoFeeHeldBody => 'Kho sẽ gửi sách sớm.';

  @override
  String get aoReadyTitle => 'Kho đang chuẩn bị gửi';

  @override
  String get aoReadyBody =>
      'Bạn vẫn đổi được địa chỉ cho tới khi sách rời kho.';

  @override
  String get aoInDeliveryTitle => 'Đang giao hàng';

  @override
  String aoInDeliveryBody(int count, int max) {
    return 'Lần giao $count/$max. Không giao được đủ số lần thì sách về kho lưu.';
  }

  @override
  String get aoInStorageTitle => 'Sách đang lưu kho';

  @override
  String aoInStorageBody(int max, String perDay, String accrued) {
    return 'Giao thất bại $max lần nên sách về kho. Phí lưu kho $perDay/ngày, đã cộng dồn $accrued (trừ vào cọc).';
  }

  @override
  String aoStorageLeft(String left) {
    return 'Lưu kho còn $left';
  }

  @override
  String get aoChosenPickup => 'Bạn đã chọn nhận tại kho.';

  @override
  String get aoChosenRedeliver => 'Bạn đã chọn giao lại.';

  @override
  String get aoPickup => 'Nhận tại kho';

  @override
  String get aoRedeliver => 'Giao lại';

  @override
  String get aoPickupTitle => 'Nhận tại kho';

  @override
  String get aoPickupBody =>
      'Bạn đến kho Oldbook nhận sách. Phí lưu kho tính tới ngày nhận.';

  @override
  String get aoRedeliverTitle => 'Giao lại';

  @override
  String aoRedeliverBody(String amount) {
    return 'Ví sẽ giữ thêm $amount phí ship cho lần giao lại.';
  }

  @override
  String get aoChoiceSaved => 'Đã ghi nhận lựa chọn.';

  @override
  String get aoDeliveredTitle => 'Đã giao thành công';

  @override
  String get aoPickedUpTitle => 'Đã nhận tại kho';

  @override
  String get aoComplaintWindowBody =>
      'Kiểm tra sách. Có vấn đề thì khiếu nại trong hạn, khiếu nại đi thẳng tới Oldbook.';

  @override
  String aoComplaintLeft(String left) {
    return 'Còn $left để khiếu nại';
  }

  @override
  String get aoComplain => 'Khiếu nại';

  @override
  String get aoDisputedTitle => 'Đang xử lý khiếu nại';

  @override
  String get aoDisputedBody =>
      'Oldbook đang xem xét bằng chứng và sẽ ra phán quyết.';

  @override
  String get aoViewComplaint => 'Xem khiếu nại';

  @override
  String aoFinishedAt(String date) {
    return 'Kết thúc lúc $date';
  }

  @override
  String get aoUnsupportedStatus =>
      'Trạng thái chưa hỗ trợ, hãy cập nhật ứng dụng.';

  @override
  String get aoDeadlinePassed => 'Đã quá hạn';

  @override
  String get aoSellerInProgress =>
      'Kho Oldbook đang xử lý giao sách cho người thắng. Bạn được thanh toán khi đơn hoàn tất.';

  @override
  String get aoSellerFinished => 'Đơn đã kết thúc.';

  @override
  String get aoMoneyTitle => 'Tiền';

  @override
  String get aoMoneyFinal => 'Giá thắng';

  @override
  String get aoMoneyDeposit => 'Cọc đang giữ';

  @override
  String get aoMoneyShipping => 'Phí ship mỗi lần giao';

  @override
  String get aoMoneyShippingUnpaid => 'Phí ship chưa thu (trừ vào cọc)';

  @override
  String get aoMoneyStorage => 'Phí lưu kho (trừ vào cọc)';

  @override
  String get aoMoneyCommission => 'Hoa hồng';

  @override
  String get aoMoneyNet => 'Bạn nhận';

  @override
  String get aoMoneyNote =>
      'Cọc được hoàn khi đơn hoàn tất, sau khi trừ phí ship chưa thu và phí lưu kho.';

  @override
  String get aoNoAddressYet => 'Chưa có địa chỉ giao hàng';

  @override
  String get aoChangeAddress => 'Đổi';

  @override
  String get aoNoAddress => 'Bạn chưa có địa chỉ nào, hãy thêm một địa chỉ.';

  @override
  String get aoAddressSaved => 'Đã cập nhật địa chỉ giao.';

  @override
  String get aoNeedAddressFirst => 'Hãy chọn địa chỉ giao trước.';

  @override
  String get aoDeliveryTitle => 'Giao hàng';

  @override
  String aoAttempt(int round, int n) {
    return 'Đợt $round · lần $n';
  }

  @override
  String get aoViewAuction => 'Xem phiên đấu giá';

  @override
  String get aucStatusAwaitingInbound => 'Chờ gửi kho';

  @override
  String get aucStatusPendingReview => 'Chờ duyệt';

  @override
  String get aucStatusNotEnough => 'Không đủ người';

  @override
  String get aucStatusRejected => 'Bị từ chối';

  @override
  String get aucStatusCancelled => 'Đã hủy';

  @override
  String get aucStatusConverted => 'Đã chuyển bán thường';

  @override
  String get aucStatusReturned => 'Đã trả sách';

  @override
  String get aucTimerInboundDeadline => 'Hạn gửi kho';

  @override
  String get aucTimerFallbackDeadline => 'Hạn chọn phương án';

  @override
  String aucSubRegistrationOpen(String time) {
    return 'Phiên bắt đầu $time.';
  }

  @override
  String get aucRegConfirmedTag => 'Đã xác nhận';

  @override
  String get aucRegCancelledTag => 'Đã hủy đăng ký';

  @override
  String get aucRegRefundedTag => 'Đã hoàn tiền';

  @override
  String get aucRegCompletedTag => 'Đã tham gia';

  @override
  String get aucReturnAwaitingFee => 'Chờ phí ship';

  @override
  String get aucReturnReady => 'Chờ kho gửi';

  @override
  String get aucReturnDispatched => 'Đã gửi';

  @override
  String aucNeedTopup(String amount) {
    return 'Ví còn thiếu $amount.';
  }

  @override
  String aucErrTooLowMin(String amount) {
    return 'Giá thấp hơn mức tối thiểu $amount.';
  }

  @override
  String bidConfirmTitle(String amount) {
    return 'Trả giá $amount?';
  }

  @override
  String bidConfirmHold(String amount) {
    return 'Ví sẽ tạm giữ $amount khi bạn đang dẫn đầu.';
  }

  @override
  String get bidConfirmOutbid => 'Bị vượt giá thì số tiền được trả về ví ngay.';

  @override
  String get aucWillHold => 'Sẽ tạm giữ';

  @override
  String get fbTitle => 'Chọn phương án';

  @override
  String get fbReschedule => 'Dời lịch';

  @override
  String fbRescheduleSub(int n) {
    return 'Mở đăng ký lại với giờ bắt đầu mới · còn $n lần';
  }

  @override
  String get fbConvert => 'Chuyển bán thường';

  @override
  String get fbConvertSub =>
      'Tạo tin bán với giá bạn đặt; kho gửi sách về bạn trước';

  @override
  String get fbReturn => 'Nhận lại sách';

  @override
  String get fbReturnSub => 'Kho gửi trả sách, bạn chịu phí ship';

  @override
  String get fbPickStart => 'Chọn giờ bắt đầu mới';

  @override
  String get fbPrice => 'Giá bán (đ)';

  @override
  String get fbPriceInvalid => 'Giá tối thiểu 1.000 đ';

  @override
  String get fbReturnNote => 'Phí ship trả sách sẽ được giữ từ ví của bạn.';

  @override
  String get fbConfirm => 'Xác nhận';

  @override
  String get fbDone => 'Đã ghi nhận phương án.';

  @override
  String get aucCancel => 'Hủy phiên';

  @override
  String get aucCancelConfirm =>
      'Hủy phiên này? Sách chưa về kho nên không mất phí.';

  @override
  String get aucCancelConfirmInWarehouse =>
      'Sách đã ở kho: hủy sẽ tạo lệnh trả sách và bạn chịu phí ship.';

  @override
  String get aucCancelledBySeller => 'Bạn đã hủy phiên.';

  @override
  String get aucCancelledTimeout =>
      'Kho chưa nhận sách đúng hạn nên phiên tự hủy.';

  @override
  String get aucPendingReviewTitle => 'Kho đã nhận sách';

  @override
  String get aucPendingReviewBody => 'Admin đang kiểm tra và duyệt phiên.';

  @override
  String get aucRejectedTitle => 'Phiên bị từ chối';

  @override
  String get aucSellerWaitingTitle => 'Đang chờ phiên diễn ra';

  @override
  String get aucNotEnoughTitle => 'Không đủ người tham gia';

  @override
  String get aucNoBidTitle => 'Phiên không có lượt trả giá';

  @override
  String get aucFallbackBody =>
      'Chọn dời lịch, chuyển bán thường hoặc nhận lại sách. Quá hạn hệ thống tự trả sách.';

  @override
  String aucFallbackLeft(String left) {
    return 'Còn $left để chọn';
  }

  @override
  String get aucFallbackExpired => 'Đã quá hạn chọn';

  @override
  String get aucSoldTitle => 'Phiên đã bán';

  @override
  String aucSoldBody(String amount) {
    return 'Giá chốt $amount. Bạn được thanh toán khi đơn hoàn tất.';
  }

  @override
  String get aucViewOrder => 'Xem đơn';

  @override
  String get aucConvertedTitle => 'Đã chuyển thành tin bán thường';

  @override
  String get aucConvertedBody =>
      'Kho gửi sách về bạn trước để bạn giao cho người mua.';

  @override
  String get aucViewListing => 'Xem tin bán';

  @override
  String get aucReturnedBody => 'Sách được trả về cho bạn.';

  @override
  String get aucSellerSection => 'Phiên của bạn';

  @override
  String get aucInboundHint =>
      'Ghi mã này lên gói sách rồi gửi tới kho trước hạn. Quá hạn phiên tự hủy.';

  @override
  String aucInboundLeft(String left) {
    return 'Còn $left để gửi sách';
  }

  @override
  String get aucInboundExpired => 'Đã quá hạn gửi sách';

  @override
  String get aucWarehouse => 'Địa chỉ kho';

  @override
  String get aucCopyShipping => 'Sao chép thông tin gửi';

  @override
  String get aucReturnTitle => 'Lệnh trả sách';

  @override
  String aucReturnFeeNeeded(String amount) {
    return 'Ví chưa đủ $amount phí ship trả sách. Nạp tiền, hệ thống tự giữ phí trong vòng một giờ.';
  }

  @override
  String aucReturnFee(String amount) {
    return 'Phí ship trả sách $amount.';
  }

  @override
  String aucReturnTracking(String carrier, String tracking) {
    return '$carrier · $tracking';
  }

  @override
  String get aucClosing => 'Đang chốt…';

  @override
  String get aucRealtimeOffline =>
      'Mất kết nối realtime, giá có thể chậm. Kéo xuống để tải lại.';

  @override
  String get aucBuyNowTag => 'Mua ngay';

  @override
  String aucOutbidToast(String amount) {
    return 'Bạn đã bị vượt giá ($amount). Tiền giữ đã về ví.';
  }

  @override
  String get aucEndedToast => 'Phiên đã kết thúc.';

  @override
  String aucUnregisterConfirm(String amount) {
    return 'Hủy đăng ký, $amount phí và cọc sẽ về ví.';
  }

  @override
  String get aucRegistrationUnavailable => 'Phiên không nhận đăng ký nữa.';

  @override
  String get myAuctionsShort => 'Của tôi';

  @override
  String get myAucTabSeller => 'Đang bán';

  @override
  String get myAucTabBidder => 'Đã tham gia';

  @override
  String get myAucTabLeading => 'Đang dẫn đầu';

  @override
  String get myAucTabWinner => 'Đã thắng';

  @override
  String get myAucCreate => 'Tạo phiên mới';

  @override
  String get myAucEmptySeller => 'Bạn chưa tạo phiên nào.';

  @override
  String get myAucEmptyLeading => 'Bạn không dẫn đầu phiên nào.';

  @override
  String get myAucEmptyWinner => 'Bạn chưa thắng phiên nào.';

  @override
  String get meAuctionOrdersSub => 'Phí ship, giao hàng, lưu kho';

  @override
  String get mlAuctionsLink => 'Phiên đấu giá của bạn';

  @override
  String get soAuctionOrdersLink => 'Đơn đấu giá';

  @override
  String get sellDoneViewAuction => 'Xem phiên';

  @override
  String get sellStartAt => 'Giờ bắt đầu mong muốn';

  @override
  String sellStartTooSoon(String date) {
    return 'Giờ bắt đầu quá sớm. Sớm nhất: $date. Đã cập nhật, hãy bấm tạo lại.';
  }

  @override
  String get copy => 'Sao chép';

  @override
  String get copied => 'Đã sao chép';

  @override
  String get loadMore => 'Tải thêm';

  @override
  String get errAuctionNotFound => 'Không tìm thấy phiên đấu giá.';

  @override
  String get errAuctionOwn => 'Đây là phiên của bạn.';

  @override
  String get errAuctionAlreadyRegistered => 'Bạn đã đăng ký phiên này.';

  @override
  String get errAuctionRegistrationNotFound =>
      'Bạn chưa đăng ký hoặc đã hủy đăng ký.';

  @override
  String get errAuctionStartTooSoon => 'Giờ bắt đầu quá sớm.';

  @override
  String get errAuctionRescheduleLimit => 'Đã hết số lần dời lịch.';

  @override
  String get errAuctionPhotoInvalid => 'Ảnh không hợp lệ, hãy chọn lại ảnh.';

  @override
  String get errAuctionOrderNotFound => 'Không tìm thấy đơn đấu giá.';

  @override
  String get errAuctionOrderAddressRequired => 'Hãy chọn địa chỉ giao trước.';

  @override
  String get errAuctionOrderExtensionLimit => 'Đã hết số lần gia hạn.';

  @override
  String get ckRemoveSelected => 'Xóa đã chọn';

  @override
  String get ckAll => 'Tất cả';

  @override
  String get ckSelectToPay => 'Chọn sách để thanh toán';

  @override
  String ckPay(String amount) {
    return 'Thanh toán $amount';
  }

  @override
  String ckSelectedCount(int count) {
    return '$count cuốn đã chọn';
  }

  @override
  String get ckNoneSelected => 'Chưa chọn cuốn nào';

  @override
  String get ckPayWith => 'Thanh toán bằng';

  @override
  String get ckWallet => 'Ví Oldbook';

  @override
  String ckWalletAfter(String balance, String left) {
    return 'Số dư $balance · còn $left sau khi trả';
  }

  @override
  String get ckChange => 'Đổi';

  @override
  String ckItemsCount(int count) {
    return '$count cuốn';
  }

  @override
  String ckPlacedCount(int count) {
    return 'Đã đặt $count đơn';
  }

  @override
  String ckTrackOrders(int count) {
    return 'Theo dõi $count đơn hàng';
  }

  @override
  String get ckNotifyHint =>
      'Bạn sẽ nhận thông báo khi từng đơn được gửi đi kèm mã vận đơn.';

  @override
  String get ckSeparateOrders =>
      'Mỗi sách tạo một đơn riêng. Tiền được giữ trong ví đến khi bạn nhận hàng.';

  @override
  String ckOrderLine(String code) {
    return 'ĐƠN #$code';
  }

  @override
  String ckAllOrNothing(int count) {
    return 'Tạo $count đơn riêng. Một đơn lỗi thì không đơn nào bị trừ tiền.';
  }

  @override
  String get ckPayTitle => 'Thanh toán';

  @override
  String get sellStepMode => 'Hình thức';

  @override
  String get sellStepBook => 'Sách';

  @override
  String get sellStepPrice => 'Giá';

  @override
  String get sellStepReview => 'Xem lại';

  @override
  String get sellModeQuestion => 'Bạn muốn bán thế nào?';

  @override
  String get sellModeHint =>
      'Chọn một hình thức. Bạn có thể đổi trước khi gửi duyệt.';

  @override
  String get sellModeFixedDesc =>
      'Đặt giá cố định, người mua đặt ngay. Hợp với sách thông dụng.';

  @override
  String get sellModeAuctionDesc =>
      'Người mua trả giá cạnh tranh trong phiên. Hợp với sách hiếm, bản cũ.';

  @override
  String get sellNext => 'Tiếp tục';

  @override
  String get sellBack => 'Quay lại';

  @override
  String get sellEdit => 'Sửa';

  @override
  String get sellReviewHeader => 'Người mua sẽ thấy';

  @override
  String get sellDoneAnother => 'Đăng thêm sách';

  @override
  String get sellReviewPrice => 'Giá';

  @override
  String get sellReviewDuration => 'Thời lượng';

  @override
  String get sellReviewStartAt => 'Bắt đầu';

  @override
  String get updateMenu => 'Kiểm tra cập nhật';

  @override
  String get updateTitle => 'Cập nhật ứng dụng';

  @override
  String get updateChecking => 'Đang kiểm tra bản mới...';

  @override
  String updateUpToDate(String v) {
    return 'Bạn đang dùng bản mới nhất ($v).';
  }

  @override
  String updateAvailable(String v, String current) {
    return 'Có bản mới $v (đang dùng $current).';
  }

  @override
  String updateSize(String mb) {
    return 'Dung lượng khoảng $mb MB';
  }

  @override
  String get updateInstall => 'Tải và cài đặt';

  @override
  String updateDownloading(int p) {
    return 'Đang tải $p%';
  }

  @override
  String get updateErrNetwork =>
      'Không kết nối được tới GitHub. Kiểm tra mạng rồi thử lại.';

  @override
  String get updateErrChecksum =>
      'File tải về không toàn vẹn, đã hủy. Hãy thử lại.';

  @override
  String get updateErrInstall =>
      'Không mở được trình cài đặt. Hãy cho phép cài ứng dụng từ nguồn này trong Cài đặt rồi thử lại.';

  @override
  String get updateAndroidOnly => 'Cập nhật tự động chỉ hỗ trợ Android.';

  @override
  String get aiAssistButton => 'Phân tích ảnh bằng AI';

  @override
  String get aiSheetTitle => 'Trợ lý AI đánh giá sách';

  @override
  String get aiSheetIntro =>
      'AI chạy ngay trên máy bạn, ảnh không rời khỏi điện thoại. Kết quả chỉ là gợi ý, bạn có thể sửa lại.';

  @override
  String get aiDownloadNote =>
      'Lần đầu cần tải mô hình AI khoảng 2,6 GB. Nên dùng Wi-Fi.';

  @override
  String get aiDownloadButton => 'Tải và phân tích';

  @override
  String aiDownloading(int percent) {
    return 'Đang tải mô hình… $percent%';
  }

  @override
  String get aiAnalyzing => 'Đang phân tích ảnh, có thể mất vài chục giây…';

  @override
  String get aiResultCondition => 'Tình trạng gợi ý';

  @override
  String get aiResultDescription => 'Mô tả gợi ý';

  @override
  String get aiApply => 'Áp dụng vào form';

  @override
  String get aiRetry => 'Thử lại';

  @override
  String get aiNeedPhoto =>
      'Hãy thêm ít nhất một ảnh mới chụp trước khi dùng AI.';

  @override
  String get aiErrUnsupported => 'Thiết bị này không hỗ trợ tính năng AI.';

  @override
  String get aiErrDownload =>
      'Không tải được mô hình AI. Kiểm tra mạng và dung lượng trống rồi thử lại.';

  @override
  String get aiErrModel =>
      'Không chạy được mô hình AI trên máy này (có thể thiếu RAM).';

  @override
  String get aiErrUnreadable =>
      'AI không đưa ra được kết quả rõ ràng. Hãy thử ảnh khác.';

  @override
  String get aiIncompatibleIntro =>
      'Thiết bị này chưa phù hợp để chạy AI trên máy:';

  @override
  String get aiIncompatibleManual =>
      'Bạn hãy tự chọn tình trạng và nhập mô tả sách bên dưới.';

  @override
  String get aiIssueNotAndroid => 'Tính năng AI chỉ hỗ trợ Android.';

  @override
  String aiIssueAndroidOld(int sdk, int min) {
    return 'Android $sdk quá cũ, cần Android 11 (API $min) trở lên.';
  }

  @override
  String get aiIssueNoArm64 => 'Chip của máy không phải arm64 (64-bit).';

  @override
  String aiIssueLowRam(String total, String min) {
    return 'RAM $total GB, cần tối thiểu $min GB.';
  }

  @override
  String aiIssueLowFreeRam(int free) {
    return 'RAM trống còn $free MB, hãy đóng bớt ứng dụng khác rồi thử lại.';
  }

  @override
  String get photoSourceTitle => 'Thêm ảnh sách';

  @override
  String get photoSourceCamera => 'Chụp ảnh';

  @override
  String get photoSourceCameraHint => 'Mở máy ảnh để chụp trực tiếp';

  @override
  String get photoSourceGallery => 'Chọn từ thư viện';

  @override
  String get photoSourceGalleryHint => 'Chọn nhiều ảnh cùng lúc';

  @override
  String get photoSourceGalleryHintSingle => 'Chọn một ảnh có sẵn';

  @override
  String photosSkipped(int n) {
    return 'Đã bỏ qua $n ảnh (sai định dạng, quá nặng hoặc vượt giới hạn).';
  }

  @override
  String photosAdded(int n) {
    return 'Đã thêm $n ảnh.';
  }

  @override
  String get aiErrEmpty =>
      'AI không trả về nội dung nào. Hãy thử lại hoặc dùng ảnh khác; nếu vẫn lỗi, hãy tự nhập tình trạng và mô tả.';

  @override
  String get aiReading => 'Đang đọc ảnh…';

  @override
  String get aiWriting => 'Đang ghi kết quả…';

  @override
  String get aiFieldTitle => 'Tiêu đề';

  @override
  String get aiFieldAuthor => 'Tác giả';

  @override
  String get aiFieldPublisher => 'Nhà xuất bản';

  @override
  String get aiFieldYear => 'Năm xuất bản';

  @override
  String get aiFieldDefects => 'Ghi chú lỗi';
}
