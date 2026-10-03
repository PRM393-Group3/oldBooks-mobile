import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'Book Marketplace'**
  String get appName;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải'**
  String get loading;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get navProfile;

  /// No description provided for @homePlaceholderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đang phát triển'**
  String get homePlaceholderTitle;

  /// No description provided for @homePlaceholderMessage.
  ///
  /// In vi, this message translates to:
  /// **'Màn hình trang chủ sẽ có ở phiên bản sau.'**
  String get homePlaceholderMessage;

  /// No description provided for @loginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng bạn quay lại chợ sách cũ.'**
  String get loginSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản?'**
  String get noAccountPrompt;

  /// No description provided for @registerLink.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get registerLink;

  /// No description provided for @registerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ mất một phút để bắt đầu mua bán sách cũ.'**
  String get registerSubtitle;

  /// No description provided for @registerButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get registerButton;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản?'**
  String get haveAccountPrompt;

  /// No description provided for @loginLink.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginLink;

  /// No description provided for @roleLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bạn muốn'**
  String get roleLabel;

  /// No description provided for @roleOptionBuyer.
  ///
  /// In vi, this message translates to:
  /// **'Mua sách'**
  String get roleOptionBuyer;

  /// No description provided for @roleOptionSeller.
  ///
  /// In vi, this message translates to:
  /// **'Bán sách'**
  String get roleOptionSeller;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn cần đăng nhập lại để tiếp tục sử dụng.'**
  String get logoutConfirmMessage;

  /// No description provided for @emailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get passwordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get phoneLabel;

  /// No description provided for @showPassword.
  ///
  /// In vi, this message translates to:
  /// **'Hiện mật khẩu'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn mật khẩu'**
  String get hidePassword;

  /// No description provided for @profileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In vi, this message translates to:
  /// **'Sửa hồ sơ'**
  String get editProfile;

  /// No description provided for @changeAvatar.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ảnh đại diện'**
  String get changeAvatar;

  /// No description provided for @changePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get changePassword;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get languageSystem;

  /// No description provided for @languageVi.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVi;

  /// No description provided for @languageEn.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @phoneNotSet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cập nhật'**
  String get phoneNotSet;

  /// No description provided for @memberSince.
  ///
  /// In vi, this message translates to:
  /// **'Ngày tham gia'**
  String get memberSince;

  /// No description provided for @roleBuyer.
  ///
  /// In vi, this message translates to:
  /// **'Người mua'**
  String get roleBuyer;

  /// No description provided for @roleSeller.
  ///
  /// In vi, this message translates to:
  /// **'Người bán'**
  String get roleSeller;

  /// No description provided for @roleInspector.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm định viên'**
  String get roleInspector;

  /// No description provided for @roleAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị viên'**
  String get roleAdmin;

  /// No description provided for @roleUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Người dùng'**
  String get roleUnknown;

  /// No description provided for @emailReadOnlyHelper.
  ///
  /// In vi, this message translates to:
  /// **'Email dùng để đăng nhập nên không thể thay đổi.'**
  String get emailReadOnlyHelper;

  /// No description provided for @profileUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật hồ sơ'**
  String get profileUpdated;

  /// No description provided for @avatarPreviewLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh đại diện'**
  String get avatarPreviewLabel;

  /// No description provided for @avatarHint.
  ///
  /// In vi, this message translates to:
  /// **'JPG, PNG hoặc WebP, tối đa 5 MB.'**
  String get avatarHint;

  /// No description provided for @chooseFromGallery.
  ///
  /// In vi, this message translates to:
  /// **'Chọn từ thư viện'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh'**
  String get takePhoto;

  /// No description provided for @saveAvatar.
  ///
  /// In vi, this message translates to:
  /// **'Lưu ảnh'**
  String get saveAvatar;

  /// No description provided for @removeAvatar.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ảnh đại diện'**
  String get removeAvatar;

  /// No description provided for @removeAvatarConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ảnh đại diện?'**
  String get removeAvatarConfirmTitle;

  /// No description provided for @removeAvatarConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh của bạn sẽ được thay bằng chữ cái đầu tên.'**
  String get removeAvatarConfirmMessage;

  /// No description provided for @avatarUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật ảnh đại diện'**
  String get avatarUpdated;

  /// No description provided for @avatarRemoved.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa ảnh đại diện'**
  String get avatarRemoved;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu hiện tại'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu mới'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordLengthHelper.
  ///
  /// In vi, this message translates to:
  /// **'Từ 8 đến 72 ký tự.'**
  String get passwordLengthHelper;

  /// No description provided for @passwordRuleHelper.
  ///
  /// In vi, this message translates to:
  /// **'Từ 8 đến 72 ký tự và khác mật khẩu hiện tại.'**
  String get passwordRuleHelper;

  /// No description provided for @passwordChangedOtherDevices.
  ///
  /// In vi, this message translates to:
  /// **'Các thiết bị khác sẽ được đăng xuất.'**
  String get passwordChangedOtherDevices;

  /// No description provided for @passwordChanged.
  ///
  /// In vi, this message translates to:
  /// **'Đã đổi mật khẩu'**
  String get passwordChanged;

  /// No description provided for @changePasswordLocked.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại sau {seconds} giây'**
  String changePasswordLocked(int seconds);

  /// No description provided for @validationFullNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ và tên.'**
  String get validationFullNameRequired;

  /// No description provided for @validationFullNameTooLong.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên tối đa 100 ký tự.'**
  String get validationFullNameTooLong;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại phải bắt đầu bằng 0 hoặc +84, theo sau là 9 hoặc 10 chữ số.'**
  String get validationPhoneInvalid;

  /// No description provided for @validationEmailRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Email chưa đúng định dạng.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu.'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordLength.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải từ 8 đến 72 ký tự.'**
  String get validationPasswordLength;

  /// No description provided for @validationPasswordSame.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới phải khác mật khẩu hiện tại.'**
  String get validationPasswordSame;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu nhập lại chưa khớp.'**
  String get validationPasswordMismatch;

  /// No description provided for @errorNetwork.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối mạng. Hãy kiểm tra mạng rồi thử lại.'**
  String get errorNetwork;

  /// No description provided for @errorValidation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin chưa hợp lệ. Hãy kiểm tra lại các ô bên trên.'**
  String get errorValidation;

  /// No description provided for @errorFieldInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị chưa hợp lệ.'**
  String get errorFieldInvalid;

  /// No description provided for @errorAvatarInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh không hợp lệ hoặc vượt quá 5 MB. Hãy chọn ảnh khác.'**
  String get errorAvatarInvalid;

  /// No description provided for @errorAvatarUnsupported.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ hỗ trợ ảnh JPG, PNG hoặc WebP. Hãy chọn ảnh khác.'**
  String get errorAvatarUnsupported;

  /// No description provided for @errorAvatarTooLarge.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh vượt quá 5 MB. Hãy chọn ảnh nhỏ hơn.'**
  String get errorAvatarTooLarge;

  /// No description provided for @errorPickImage.
  ///
  /// In vi, this message translates to:
  /// **'Không mở được ảnh. Hãy kiểm tra quyền truy cập rồi thử lại.'**
  String get errorPickImage;

  /// No description provided for @errorUploadFailed.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh lên thất bại. Hãy thử lại.'**
  String get errorUploadFailed;

  /// No description provided for @errorCurrentPasswordIncorrect.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu hiện tại chưa đúng.'**
  String get errorCurrentPasswordIncorrect;

  /// No description provided for @errorPasswordUnchanged.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới phải khác mật khẩu cũ.'**
  String get errorPasswordUnchanged;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In vi, this message translates to:
  /// **'Email hoặc mật khẩu chưa đúng.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorSessionExpired.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.'**
  String get errorSessionExpired;

  /// No description provided for @errorUserNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản không còn tồn tại.'**
  String get errorUserNotFound;

  /// No description provided for @errorInternal.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống đang gặp sự cố. Hãy thử lại sau ít phút.'**
  String get errorInternal;

  /// No description provided for @errorUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Đã có lỗi xảy ra. Hãy thử lại.'**
  String get errorUnknown;

  /// No description provided for @supportCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã hỗ trợ: {traceId}'**
  String supportCode(String traceId);

  /// No description provided for @navExplore.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get navExplore;

  /// No description provided for @navAuctions.
  ///
  /// In vi, this message translates to:
  /// **'Đấu giá'**
  String get navAuctions;

  /// No description provided for @navSell.
  ///
  /// In vi, this message translates to:
  /// **'Bán'**
  String get navSell;

  /// No description provided for @navWallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví'**
  String get navWallet;

  /// No description provided for @navMe.
  ///
  /// In vi, this message translates to:
  /// **'Tôi'**
  String get navMe;

  /// No description provided for @comingSoonTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sắp có'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng này đang được xây dựng.'**
  String get comingSoonBody;

  /// No description provided for @navMyListings.
  ///
  /// In vi, this message translates to:
  /// **'Tin của tôi'**
  String get navMyListings;

  /// No description provided for @navNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get navNotifications;

  /// No description provided for @navQueue.
  ///
  /// In vi, this message translates to:
  /// **'Hàng đợi'**
  String get navQueue;

  /// No description provided for @navClaimed.
  ///
  /// In vi, this message translates to:
  /// **'Đang giữ'**
  String get navClaimed;

  /// No description provided for @sellAction.
  ///
  /// In vi, this message translates to:
  /// **'Đăng bán'**
  String get sellAction;

  /// No description provided for @adminWebNote.
  ///
  /// In vi, this message translates to:
  /// **'Chức năng quản trị nằm ở cổng web.'**
  String get adminWebNote;

  /// No description provided for @loadMoreFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không tải thêm được. Chạm để thử lại.'**
  String get loadMoreFailed;

  /// No description provided for @optionalHint.
  ///
  /// In vi, this message translates to:
  /// **'Không bắt buộc'**
  String get optionalHint;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get done;

  /// No description provided for @comingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Mua hàng và đặt giá sẽ có ở phiên bản sau.'**
  String get comingSoon;

  /// No description provided for @emptyBrowseTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có sách nào'**
  String get emptyBrowseTitle;

  /// No description provided for @emptyBrowseMessage.
  ///
  /// In vi, this message translates to:
  /// **'Sách đã kiểm định sẽ xuất hiện ở đây.'**
  String get emptyBrowseMessage;

  /// No description provided for @emptyMineTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có tin nào'**
  String get emptyMineTitle;

  /// No description provided for @emptyMineMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bấm Đăng bán để tạo tin đầu tiên.'**
  String get emptyMineMessage;

  /// No description provided for @emptyQueueTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hàng đợi trống'**
  String get emptyQueueTitle;

  /// No description provided for @emptyQueueMessage.
  ///
  /// In vi, this message translates to:
  /// **'Không có tin nào đang chờ kiểm định.'**
  String get emptyQueueMessage;

  /// No description provided for @emptyClaimedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa giữ tin nào'**
  String get emptyClaimedTitle;

  /// No description provided for @emptyClaimedMessage.
  ///
  /// In vi, this message translates to:
  /// **'Nhận tin từ hàng đợi để bắt đầu kiểm định.'**
  String get emptyClaimedMessage;

  /// No description provided for @emptyNotificationsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thông báo'**
  String get emptyNotificationsTitle;

  /// No description provided for @emptyNotificationsMessage.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả kiểm định sẽ hiện ở đây.'**
  String get emptyNotificationsMessage;

  /// No description provided for @statusDraft.
  ///
  /// In vi, this message translates to:
  /// **'Nháp'**
  String get statusDraft;

  /// No description provided for @statusPendingInspection.
  ///
  /// In vi, this message translates to:
  /// **'Chờ kiểm định'**
  String get statusPendingInspection;

  /// No description provided for @statusInInspection.
  ///
  /// In vi, this message translates to:
  /// **'Đang kiểm định'**
  String get statusInInspection;

  /// No description provided for @statusRejected.
  ///
  /// In vi, this message translates to:
  /// **'Bị từ chối'**
  String get statusRejected;

  /// No description provided for @statusOnSale.
  ///
  /// In vi, this message translates to:
  /// **'Đang bán'**
  String get statusOnSale;

  /// No description provided for @statusAuctioning.
  ///
  /// In vi, this message translates to:
  /// **'Đang đấu giá'**
  String get statusAuctioning;

  /// No description provided for @statusClosed.
  ///
  /// In vi, this message translates to:
  /// **'Đã đóng'**
  String get statusClosed;

  /// No description provided for @statusUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Không rõ'**
  String get statusUnknown;

  /// No description provided for @filterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get filterAll;

  /// No description provided for @categoryAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả danh mục'**
  String get categoryAll;

  /// No description provided for @conditionLikeNew.
  ///
  /// In vi, this message translates to:
  /// **'Như mới'**
  String get conditionLikeNew;

  /// No description provided for @conditionLikeNewDesc.
  ///
  /// In vi, this message translates to:
  /// **'Gần như chưa qua sử dụng, không có dấu hiệu đã đọc.'**
  String get conditionLikeNewDesc;

  /// No description provided for @conditionVeryGood.
  ///
  /// In vi, this message translates to:
  /// **'Rất tốt'**
  String get conditionVeryGood;

  /// No description provided for @conditionVeryGoodDesc.
  ///
  /// In vi, this message translates to:
  /// **'Rất ít dấu hiệu sử dụng, không rách, không ghi chú.'**
  String get conditionVeryGoodDesc;

  /// No description provided for @conditionGood.
  ///
  /// In vi, this message translates to:
  /// **'Tốt'**
  String get conditionGood;

  /// No description provided for @conditionGoodDesc.
  ///
  /// In vi, this message translates to:
  /// **'Có dấu hiệu sử dụng nhẹ, nội dung nguyên vẹn.'**
  String get conditionGoodDesc;

  /// No description provided for @conditionFair.
  ///
  /// In vi, this message translates to:
  /// **'Khá'**
  String get conditionFair;

  /// No description provided for @conditionFairDesc.
  ///
  /// In vi, this message translates to:
  /// **'Có vết ố, gấp góc hoặc ghi chú nhưng đọc được đầy đủ.'**
  String get conditionFairDesc;

  /// No description provided for @conditionPoor.
  ///
  /// In vi, this message translates to:
  /// **'Cũ nhiều'**
  String get conditionPoor;

  /// No description provided for @conditionPoorDesc.
  ///
  /// In vi, this message translates to:
  /// **'Hư hỏng rõ rệt nhưng nội dung vẫn đầy đủ.'**
  String get conditionPoorDesc;

  /// No description provided for @coverPaperback.
  ///
  /// In vi, this message translates to:
  /// **'Bìa mềm'**
  String get coverPaperback;

  /// No description provided for @coverHardcover.
  ///
  /// In vi, this message translates to:
  /// **'Bìa cứng'**
  String get coverHardcover;

  /// No description provided for @imageFrontCover.
  ///
  /// In vi, this message translates to:
  /// **'Bìa trước'**
  String get imageFrontCover;

  /// No description provided for @imageBackCover.
  ///
  /// In vi, this message translates to:
  /// **'Bìa sau'**
  String get imageBackCover;

  /// No description provided for @imageSpine.
  ///
  /// In vi, this message translates to:
  /// **'Gáy sách'**
  String get imageSpine;

  /// No description provided for @imageInnerPage.
  ///
  /// In vi, this message translates to:
  /// **'Trang trong'**
  String get imageInnerPage;

  /// No description provided for @imageExtra.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh thêm'**
  String get imageExtra;

  /// No description provided for @saleFixedPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá cố định'**
  String get saleFixedPrice;

  /// No description provided for @saleAuction.
  ///
  /// In vi, this message translates to:
  /// **'Đấu giá'**
  String get saleAuction;

  /// No description provided for @startOnApproval.
  ///
  /// In vi, this message translates to:
  /// **'Ngay khi được duyệt'**
  String get startOnApproval;

  /// No description provided for @startScheduled.
  ///
  /// In vi, this message translates to:
  /// **'Hẹn giờ'**
  String get startScheduled;

  /// No description provided for @reasonBlurryPhotos.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh không đủ hoặc không rõ'**
  String get reasonBlurryPhotos;

  /// No description provided for @reasonDescriptionMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả không khớp hiện trạng'**
  String get reasonDescriptionMismatch;

  /// No description provided for @reasonSuspectedPirated.
  ///
  /// In vi, this message translates to:
  /// **'Nghi ngờ sách in lậu'**
  String get reasonSuspectedPirated;

  /// No description provided for @reasonProhibitedPublication.
  ///
  /// In vi, this message translates to:
  /// **'Xuất bản phẩm bị cấm lưu hành'**
  String get reasonProhibitedPublication;

  /// No description provided for @reasonDamageBeyondThreshold.
  ///
  /// In vi, this message translates to:
  /// **'Sách hư hỏng vượt ngưỡng chấp nhận'**
  String get reasonDamageBeyondThreshold;

  /// No description provided for @reasonWrongCatalogInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin thư mục sai'**
  String get reasonWrongCatalogInfo;

  /// No description provided for @reasonDuplicateListing.
  ///
  /// In vi, this message translates to:
  /// **'Trùng lặp tin đăng'**
  String get reasonDuplicateListing;

  /// No description provided for @notificationsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In vi, this message translates to:
  /// **'Đọc tất cả'**
  String get markAllRead;

  /// No description provided for @unreadOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đọc'**
  String get unreadOnly;

  /// No description provided for @notifListingApproved.
  ///
  /// In vi, this message translates to:
  /// **'Tin đăng của bạn đã được duyệt'**
  String get notifListingApproved;

  /// No description provided for @notifListingRejected.
  ///
  /// In vi, this message translates to:
  /// **'Tin đăng của bạn bị từ chối'**
  String get notifListingRejected;

  /// No description provided for @notifListingClosed.
  ///
  /// In vi, this message translates to:
  /// **'Tin đăng của bạn đã bị đóng'**
  String get notifListingClosed;

  /// No description provided for @wizardTitleNew.
  ///
  /// In vi, this message translates to:
  /// **'Đăng bán sách'**
  String get wizardTitleNew;

  /// No description provided for @wizardTitleEdit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa tin đăng'**
  String get wizardTitleEdit;

  /// No description provided for @wizardStepBook.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin sách'**
  String get wizardStepBook;

  /// No description provided for @wizardStepPhotos.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh'**
  String get wizardStepPhotos;

  /// No description provided for @wizardStepSale.
  ///
  /// In vi, this message translates to:
  /// **'Cách bán'**
  String get wizardStepSale;

  /// No description provided for @wizardStepReview.
  ///
  /// In vi, this message translates to:
  /// **'Xem lại'**
  String get wizardStepReview;

  /// No description provided for @wizardStepOf.
  ///
  /// In vi, this message translates to:
  /// **'Bước {current}/{total}'**
  String wizardStepOf(int current, int total);

  /// No description provided for @next.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp'**
  String get next;

  /// No description provided for @back.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get back;

  /// No description provided for @submitForInspection.
  ///
  /// In vi, this message translates to:
  /// **'Nộp kiểm định'**
  String get submitForInspection;

  /// No description provided for @draftSavedHint.
  ///
  /// In vi, this message translates to:
  /// **'Bản nháp được lưu sau mỗi bước.'**
  String get draftSavedHint;

  /// No description provided for @fieldTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tên sách'**
  String get fieldTitle;

  /// No description provided for @fieldAuthor.
  ///
  /// In vi, this message translates to:
  /// **'Tác giả'**
  String get fieldAuthor;

  /// No description provided for @fieldCategory.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get fieldCategory;

  /// No description provided for @fieldPublisher.
  ///
  /// In vi, this message translates to:
  /// **'Nhà xuất bản'**
  String get fieldPublisher;

  /// No description provided for @fieldIsbn.
  ///
  /// In vi, this message translates to:
  /// **'ISBN'**
  String get fieldIsbn;

  /// No description provided for @fieldYear.
  ///
  /// In vi, this message translates to:
  /// **'Năm xuất bản'**
  String get fieldYear;

  /// No description provided for @fieldLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ (mã 2 chữ cái)'**
  String get fieldLanguage;

  /// No description provided for @fieldLanguageHelper.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: vi, en'**
  String get fieldLanguageHelper;

  /// No description provided for @fieldPages.
  ///
  /// In vi, this message translates to:
  /// **'Số trang'**
  String get fieldPages;

  /// No description provided for @fieldCover.
  ///
  /// In vi, this message translates to:
  /// **'Loại bìa'**
  String get fieldCover;

  /// No description provided for @fieldCondition.
  ///
  /// In vi, this message translates to:
  /// **'Tình trạng sách'**
  String get fieldCondition;

  /// No description provided for @fieldConditionHelper.
  ///
  /// In vi, this message translates to:
  /// **'Chọn mức gần đúng nhất. Kiểm định viên sẽ xác nhận.'**
  String get fieldConditionHelper;

  /// No description provided for @fieldDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả'**
  String get fieldDescription;

  /// No description provided for @fieldDescriptionHelper.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu {min} ký tự ({count}/{min})'**
  String fieldDescriptionHelper(int min, int count);

  /// No description provided for @fieldDefects.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú khuyết điểm'**
  String get fieldDefects;

  /// No description provided for @chooseCategory.
  ///
  /// In vi, this message translates to:
  /// **'Chọn danh mục'**
  String get chooseCategory;

  /// No description provided for @categoryPickerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn danh mục'**
  String get categoryPickerTitle;

  /// No description provided for @validationFieldRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập {field}.'**
  String validationFieldRequired(String field);

  /// No description provided for @validationChooseCategory.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn danh mục.'**
  String get validationChooseCategory;

  /// No description provided for @validationChooseCondition.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn tình trạng sách.'**
  String get validationChooseCondition;

  /// No description provided for @validationIsbn.
  ///
  /// In vi, this message translates to:
  /// **'ISBN chưa hợp lệ (ISBN-10 hoặc ISBN-13).'**
  String get validationIsbn;

  /// No description provided for @validationYearRange.
  ///
  /// In vi, this message translates to:
  /// **'Năm từ {min} đến {max}.'**
  String validationYearRange(int min, int max);

  /// No description provided for @validationPagesRange.
  ///
  /// In vi, this message translates to:
  /// **'Số trang từ 1 đến 10000.'**
  String get validationPagesRange;

  /// No description provided for @validationLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã 2 chữ cái, ví dụ vi.'**
  String get validationLanguage;

  /// No description provided for @validationDescriptionMin.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả tối thiểu {min} ký tự.'**
  String validationDescriptionMin(int min);

  /// No description provided for @validationTooLong.
  ///
  /// In vi, this message translates to:
  /// **'Tối đa {max} ký tự.'**
  String validationTooLong(int max);

  /// No description provided for @photosHint.
  ///
  /// In vi, this message translates to:
  /// **'Cần {min} đến {max} ảnh, đủ 4 góc: bìa trước, bìa sau, gáy và trang trong.'**
  String photosHint(int min, int max);

  /// No description provided for @photosRequired.
  ///
  /// In vi, this message translates to:
  /// **'Bắt buộc'**
  String get photosRequired;

  /// No description provided for @photosExtraTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh thêm ({count}/{max})'**
  String photosExtraTitle(int count, int max);

  /// No description provided for @addPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ảnh'**
  String get addPhoto;

  /// No description provided for @photoUploading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải ảnh'**
  String get photoUploading;

  /// No description provided for @photoFailed.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh thất bại'**
  String get photoFailed;

  /// No description provided for @photoRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get photoRetry;

  /// No description provided for @removePhoto.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ảnh'**
  String get removePhoto;

  /// No description provided for @photosWaiting.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải ảnh, vui lòng đợi.'**
  String get photosWaiting;

  /// No description provided for @photosMissing.
  ///
  /// In vi, this message translates to:
  /// **'Còn thiếu ảnh bắt buộc.'**
  String get photosMissing;

  /// No description provided for @photoSlotLabel.
  ///
  /// In vi, this message translates to:
  /// **'{angle}, ảnh bắt buộc'**
  String photoSlotLabel(String angle);

  /// No description provided for @photoSlotEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ảnh'**
  String get photoSlotEmpty;

  /// No description provided for @saleMethodLabel.
  ///
  /// In vi, this message translates to:
  /// **'Cách bán'**
  String get saleMethodLabel;

  /// No description provided for @fieldPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá bán (₫)'**
  String get fieldPrice;

  /// No description provided for @fieldQuantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng'**
  String get fieldQuantity;

  /// No description provided for @fieldStartingPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá khởi điểm (₫)'**
  String get fieldStartingPrice;

  /// No description provided for @fieldMinIncrement.
  ///
  /// In vi, this message translates to:
  /// **'Bước giá tối thiểu (₫)'**
  String get fieldMinIncrement;

  /// No description provided for @minIncrementHelper.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu {amount}'**
  String minIncrementHelper(String amount);

  /// No description provided for @fieldDuration.
  ///
  /// In vi, this message translates to:
  /// **'Thời lượng phiên'**
  String get fieldDuration;

  /// No description provided for @durationDays.
  ///
  /// In vi, this message translates to:
  /// **'{days} ngày'**
  String durationDays(int days);

  /// No description provided for @fieldStartMode.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get fieldStartMode;

  /// No description provided for @fieldScheduledAt.
  ///
  /// In vi, this message translates to:
  /// **'Thời điểm bắt đầu'**
  String get fieldScheduledAt;

  /// No description provided for @pickDateTime.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày giờ'**
  String get pickDateTime;

  /// No description provided for @validationPriceRange.
  ///
  /// In vi, this message translates to:
  /// **'Giá từ {min} đến {max}.'**
  String validationPriceRange(String min, String max);

  /// No description provided for @validationQuantityRange.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng từ {min} đến {max}.'**
  String validationQuantityRange(int min, int max);

  /// No description provided for @validationMinIncrement.
  ///
  /// In vi, this message translates to:
  /// **'Bước giá tối thiểu là {amount}.'**
  String validationMinIncrement(String amount);

  /// No description provided for @validationScheduleRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn thời điểm bắt đầu.'**
  String get validationScheduleRequired;

  /// No description provided for @validationScheduleFuture.
  ///
  /// In vi, this message translates to:
  /// **'Thời điểm bắt đầu phải ở tương lai.'**
  String get validationScheduleFuture;

  /// No description provided for @changeMethodTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đổi cách bán?'**
  String get changeMethodTitle;

  /// No description provided for @changeMethodMessage.
  ///
  /// In vi, this message translates to:
  /// **'Cấu hình của cách bán còn lại sẽ bị xóa khi bạn lưu.'**
  String get changeMethodMessage;

  /// No description provided for @reviewBookSection.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin sách'**
  String get reviewBookSection;

  /// No description provided for @reviewPhotosSection.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh'**
  String get reviewPhotosSection;

  /// No description provided for @reviewSaleSection.
  ///
  /// In vi, this message translates to:
  /// **'Cách bán'**
  String get reviewSaleSection;

  /// No description provided for @submitSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã nộp kiểm định'**
  String get submitSuccessTitle;

  /// No description provided for @submitSuccessMessage.
  ///
  /// In vi, this message translates to:
  /// **'Dự kiến xử lý trong {hours} giờ. Bạn sẽ nhận thông báo khi có kết quả.'**
  String submitSuccessMessage(int hours);

  /// No description provided for @incompleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tin đăng còn thiếu'**
  String get incompleteTitle;

  /// No description provided for @incompleteMessage.
  ///
  /// In vi, this message translates to:
  /// **'Hãy bổ sung các mục sau rồi nộp lại.'**
  String get incompleteMessage;

  /// No description provided for @goToStep.
  ///
  /// In vi, this message translates to:
  /// **'Đến bước này'**
  String get goToStep;

  /// No description provided for @missingImages.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh (đủ 4 góc)'**
  String get missingImages;

  /// No description provided for @missingSaleMethod.
  ///
  /// In vi, this message translates to:
  /// **'Cách bán'**
  String get missingSaleMethod;

  /// No description provided for @missingPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá bán'**
  String get missingPrice;

  /// No description provided for @missingStartingPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá khởi điểm'**
  String get missingStartingPrice;

  /// No description provided for @missingCategory.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get missingCategory;

  /// No description provided for @myListingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tin của tôi'**
  String get myListingsTitle;

  /// No description provided for @continueDraft.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục soạn'**
  String get continueDraft;

  /// No description provided for @deleteListing.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tin'**
  String get deleteListing;

  /// No description provided for @deleteListingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tin này?'**
  String get deleteListingTitle;

  /// No description provided for @deleteListingMessage.
  ///
  /// In vi, this message translates to:
  /// **'Tin sẽ được đóng và không thể khôi phục.'**
  String get deleteListingMessage;

  /// No description provided for @listingDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa tin'**
  String get listingDeleted;

  /// No description provided for @editAndResubmit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa và nộp lại'**
  String get editAndResubmit;

  /// No description provided for @closeListing.
  ///
  /// In vi, this message translates to:
  /// **'Đóng tin'**
  String get closeListing;

  /// No description provided for @resubmitsLeft.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} lần nộp lại'**
  String resubmitsLeft(int count);

  /// No description provided for @noResubmitsLeft.
  ///
  /// In vi, this message translates to:
  /// **'Đã hết lượt nộp lại'**
  String get noResubmitsLeft;

  /// No description provided for @estimatedProcessing.
  ///
  /// In vi, this message translates to:
  /// **'Dự kiến xử lý trong {hours} giờ'**
  String estimatedProcessing(int hours);

  /// No description provided for @rejectedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tin bị từ chối'**
  String get rejectedTitle;

  /// No description provided for @closedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tin đã bị đóng'**
  String get closedTitle;

  /// No description provided for @reasonsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Lý do'**
  String get reasonsLabel;

  /// No description provided for @inspectorNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú của kiểm định viên'**
  String get inspectorNote;

  /// No description provided for @inspectionResult.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả kiểm định'**
  String get inspectionResult;

  /// No description provided for @inspectionApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt'**
  String get inspectionApproved;

  /// No description provided for @inspectionRejected.
  ///
  /// In vi, this message translates to:
  /// **'Bị từ chối'**
  String get inspectionRejected;

  /// No description provided for @inspectedOn.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kiểm định: {date}'**
  String inspectedOn(String date);

  /// No description provided for @sellerSection.
  ///
  /// In vi, this message translates to:
  /// **'Người bán'**
  String get sellerSection;

  /// No description provided for @bookDetails.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin sách'**
  String get bookDetails;

  /// No description provided for @detailAuthor.
  ///
  /// In vi, this message translates to:
  /// **'Tác giả'**
  String get detailAuthor;

  /// No description provided for @detailPublisher.
  ///
  /// In vi, this message translates to:
  /// **'Nhà xuất bản'**
  String get detailPublisher;

  /// No description provided for @detailYear.
  ///
  /// In vi, this message translates to:
  /// **'Năm xuất bản'**
  String get detailYear;

  /// No description provided for @detailLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get detailLanguage;

  /// No description provided for @detailPages.
  ///
  /// In vi, this message translates to:
  /// **'Số trang'**
  String get detailPages;

  /// No description provided for @detailCover.
  ///
  /// In vi, this message translates to:
  /// **'Loại bìa'**
  String get detailCover;

  /// No description provided for @detailCondition.
  ///
  /// In vi, this message translates to:
  /// **'Tình trạng'**
  String get detailCondition;

  /// No description provided for @detailCategory.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get detailCategory;

  /// No description provided for @detailQuantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng'**
  String get detailQuantity;

  /// No description provided for @auctionSection.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin đấu giá'**
  String get auctionSection;

  /// No description provided for @startingPriceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giá khởi điểm'**
  String get startingPriceLabel;

  /// No description provided for @minIncrementLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bước giá tối thiểu'**
  String get minIncrementLabel;

  /// No description provided for @auctionStarts.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get auctionStarts;

  /// No description provided for @auctionEnds.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc'**
  String get auctionEnds;

  /// No description provided for @auctionDuration.
  ///
  /// In vi, this message translates to:
  /// **'Thời lượng'**
  String get auctionDuration;

  /// No description provided for @startingFrom.
  ///
  /// In vi, this message translates to:
  /// **'Từ {price}'**
  String startingFrom(String price);

  /// No description provided for @listingPhotoLabel.
  ///
  /// In vi, this message translates to:
  /// **'{angle} của sách {title}'**
  String listingPhotoLabel(String angle, String title);

  /// No description provided for @description.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả'**
  String get description;

  /// No description provided for @defectNotesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khuyết điểm'**
  String get defectNotesTitle;

  /// No description provided for @submissionOf.
  ///
  /// In vi, this message translates to:
  /// **'Lần nộp {n}/{max}'**
  String submissionOf(int n, int max);

  /// No description provided for @queueTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hàng đợi kiểm định'**
  String get queueTitle;

  /// No description provided for @claimedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tin đang giữ'**
  String get claimedTitle;

  /// No description provided for @overdueTag.
  ///
  /// In vi, this message translates to:
  /// **'Quá hạn'**
  String get overdueTag;

  /// No description provided for @waitingHours.
  ///
  /// In vi, this message translates to:
  /// **'Chờ {hours} giờ'**
  String waitingHours(int hours);

  /// No description provided for @filterButton.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc'**
  String get filterButton;

  /// No description provided for @filterTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lọc hàng đợi'**
  String get filterTitle;

  /// No description provided for @priceFrom.
  ///
  /// In vi, this message translates to:
  /// **'Giá từ (₫)'**
  String get priceFrom;

  /// No description provided for @priceTo.
  ///
  /// In vi, this message translates to:
  /// **'Giá đến (₫)'**
  String get priceTo;

  /// No description provided for @applyFilter.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get applyFilter;

  /// No description provided for @clearFilter.
  ///
  /// In vi, this message translates to:
  /// **'Xóa lọc'**
  String get clearFilter;

  /// No description provided for @reviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm định'**
  String get reviewTitle;

  /// No description provided for @claimExpiresIn.
  ///
  /// In vi, this message translates to:
  /// **'Còn {time} để quyết định'**
  String claimExpiresIn(String time);

  /// No description provided for @claimExpired.
  ///
  /// In vi, this message translates to:
  /// **'Khóa đã hết hạn. Hãy nhận lại tin để tiếp tục.'**
  String get claimExpired;

  /// No description provided for @reclaim.
  ///
  /// In vi, this message translates to:
  /// **'Nhận lại tin'**
  String get reclaim;

  /// No description provided for @release.
  ///
  /// In vi, this message translates to:
  /// **'Nhả tin'**
  String get release;

  /// No description provided for @releaseTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhả tin này?'**
  String get releaseTitle;

  /// No description provided for @releaseMessage.
  ///
  /// In vi, this message translates to:
  /// **'Tin sẽ quay lại hàng đợi cho kiểm định viên khác.'**
  String get releaseMessage;

  /// No description provided for @approve.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get reject;

  /// No description provided for @approveTitle.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt tin đăng'**
  String get approveTitle;

  /// No description provided for @approveNoteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú (không bắt buộc)'**
  String get approveNoteLabel;

  /// No description provided for @rejectTitle.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối tin đăng'**
  String get rejectTitle;

  /// No description provided for @rejectReasonsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Lý do (chọn ít nhất 1)'**
  String get rejectReasonsLabel;

  /// No description provided for @rejectNoteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú cho người bán'**
  String get rejectNoteLabel;

  /// No description provided for @rejectNoteHelper.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu {min} ký tự'**
  String rejectNoteHelper(int min);

  /// No description provided for @validationRejectReasons.
  ///
  /// In vi, this message translates to:
  /// **'Hãy chọn ít nhất một lý do.'**
  String get validationRejectReasons;

  /// No description provided for @validationRejectNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú tối thiểu {min} ký tự.'**
  String validationRejectNote(int min);

  /// No description provided for @listingApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt tin'**
  String get listingApproved;

  /// No description provided for @listingRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đã từ chối tin'**
  String get listingRejected;

  /// No description provided for @listingReleased.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhả tin'**
  String get listingReleased;

  /// No description provided for @sellerDeclared.
  ///
  /// In vi, this message translates to:
  /// **'Người bán khai báo'**
  String get sellerDeclared;

  /// No description provided for @viewPhotos.
  ///
  /// In vi, this message translates to:
  /// **'Xem ảnh gốc'**
  String get viewPhotos;

  /// No description provided for @inspectionHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử kiểm định'**
  String get inspectionHistory;

  /// No description provided for @errorEmailTaken.
  ///
  /// In vi, this message translates to:
  /// **'Email này đã được sử dụng.'**
  String get errorEmailTaken;

  /// No description provided for @errorAccountDisabled.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản đã bị khóa. Hãy liên hệ quản trị viên.'**
  String get errorAccountDisabled;

  /// No description provided for @errorListingIncomplete.
  ///
  /// In vi, this message translates to:
  /// **'Tin đăng còn thiếu thông tin. Hãy bổ sung rồi nộp lại.'**
  String get errorListingIncomplete;

  /// No description provided for @errorListingImageInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Có ảnh không hợp lệ. Hãy chọn lại ảnh đó.'**
  String get errorListingImageInvalid;

  /// No description provided for @errorListingNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy tin đăng này.'**
  String get errorListingNotFound;

  /// No description provided for @errorListingInvalidState.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái tin đã thay đổi. Đang tải lại tin.'**
  String get errorListingInvalidState;

  /// No description provided for @errorSubmissionLimit.
  ///
  /// In vi, this message translates to:
  /// **'Tin đã hết lượt nộp lại.'**
  String get errorSubmissionLimit;

  /// No description provided for @errorConcurrentUpdate.
  ///
  /// In vi, this message translates to:
  /// **'Tin vừa được cập nhật ở nơi khác. Đang tải lại.'**
  String get errorConcurrentUpdate;

  /// No description provided for @errorAlreadyClaimed.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm định viên khác đang giữ tin này.'**
  String get errorAlreadyClaimed;

  /// No description provided for @errorClaimRequired.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không còn giữ tin này. Hãy nhận lại tin.'**
  String get errorClaimRequired;

  /// No description provided for @errorCategoryNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục không còn tồn tại.'**
  String get errorCategoryNotFound;

  /// No description provided for @errorNotificationNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy thông báo này.'**
  String get errorNotificationNotFound;

  /// No description provided for @errorPhotoTooLarge.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh vượt quá {mb} MB. Hãy chọn ảnh nhỏ hơn.'**
  String errorPhotoTooLarge(int mb);

  /// No description provided for @errorPhotosUploadPending.
  ///
  /// In vi, this message translates to:
  /// **'Có ảnh chưa tải xong hoặc bị lỗi. Hãy thử lại ảnh đó.'**
  String get errorPhotosUploadPending;

  /// No description provided for @brandName.
  ///
  /// In vi, this message translates to:
  /// **'Oldbook'**
  String get brandName;

  /// No description provided for @cartButton.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ · {count}'**
  String cartButton(int count);

  /// No description provided for @cartTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng'**
  String get cartTitle;

  /// No description provided for @searchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tên sách, tác giả, ISBN'**
  String get searchHint;

  /// No description provided for @resultsNew.
  ///
  /// In vi, this message translates to:
  /// **'Mới đăng'**
  String get resultsNew;

  /// No description provided for @resultsSearch.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả tìm kiếm'**
  String get resultsSearch;

  /// No description provided for @resultsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} cuốn'**
  String resultsCount(int count);

  /// No description provided for @noSearchResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sách phù hợp. Thử bỏ dấu hoặc đổi thể loại.'**
  String get noSearchResults;

  /// No description provided for @addToCart.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào giỏ'**
  String get addToCart;

  /// No description provided for @inCart.
  ///
  /// In vi, this message translates to:
  /// **'Đã trong giỏ'**
  String get inCart;

  /// No description provided for @buyNow.
  ///
  /// In vi, this message translates to:
  /// **'Mua ngay'**
  String get buyNow;

  /// No description provided for @addedToCart.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm vào giỏ'**
  String get addedToCart;

  /// No description provided for @alreadyInCart.
  ///
  /// In vi, this message translates to:
  /// **'Sách đã có trong giỏ'**
  String get alreadyInCart;

  /// No description provided for @shipPlus.
  ///
  /// In vi, this message translates to:
  /// **'+ ship {price}'**
  String shipPlus(String price);

  /// No description provided for @escrowNote.
  ///
  /// In vi, this message translates to:
  /// **'Tiền được giữ trong ví Oldbook đến khi bạn xác nhận nhận hàng. Có 3 ngày để khiếu nại sau khi giao.'**
  String get escrowNote;

  /// No description provided for @auctionListingNote.
  ///
  /// In vi, this message translates to:
  /// **'Sách này bán theo hình thức đấu giá.'**
  String get auctionListingNote;

  /// No description provided for @toastOrderCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy đơn, hoàn {amount}'**
  String toastOrderCancelled(String amount);

  /// No description provided for @toastOrderCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hoàn tất · cảm ơn bạn!'**
  String get toastOrderCompleted;

  /// No description provided for @toastComplaintOpened.
  ///
  /// In vi, this message translates to:
  /// **'Đã mở khiếu nại · tiền bị khóa'**
  String get toastComplaintOpened;

  /// No description provided for @toastOfferAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận hoàn {amount}'**
  String toastOfferAccepted(String amount);

  /// No description provided for @toastNoBooks.
  ///
  /// In vi, this message translates to:
  /// **'Không có sách khả dụng trong giỏ'**
  String get toastNoBooks;

  /// No description provided for @toastSellerShipped.
  ///
  /// In vi, this message translates to:
  /// **'Người bán đã nhập mã vận đơn'**
  String get toastSellerShipped;

  /// No description provided for @toastDeliveryFailed.
  ///
  /// In vi, this message translates to:
  /// **'Giao thất bại lần {n}'**
  String toastDeliveryFailed(int n);

  /// No description provided for @toastMovedToStorage.
  ///
  /// In vi, this message translates to:
  /// **'Giao thất bại lần 5 · sách vào lưu kho'**
  String get toastMovedToStorage;

  /// No description provided for @toastTopupOk.
  ///
  /// In vi, this message translates to:
  /// **'Nạp thành công +{amount}'**
  String toastTopupOk(String amount);

  /// No description provided for @toastWithdrawRequested.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi yêu cầu rút {amount}'**
  String toastWithdrawRequested(String amount);

  /// No description provided for @toastRated.
  ///
  /// In vi, this message translates to:
  /// **'Đã đánh giá {n} sao'**
  String toastRated(int n);

  /// No description provided for @toastRegistered.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng ký · giữ {amount}'**
  String toastRegistered(String amount);

  /// No description provided for @toastUnregistered.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy đăng ký, hoàn {amount}'**
  String toastUnregistered(String amount);

  /// No description provided for @toastLeading.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang dẫn đầu với {amount}'**
  String toastLeading(String amount);

  /// No description provided for @toastBuyNowStarted.
  ///
  /// In vi, this message translates to:
  /// **'Đã mua ngay · đếm ngược 30 phút bắt đầu'**
  String get toastBuyNowStarted;

  /// No description provided for @toastOutbid.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã bị vượt giá ở \"{title}\" · {amount}'**
  String toastOutbid(String title, String amount);

  /// No description provided for @toastAuctionWon.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã thắng \"{title}\" với giá {amount}'**
  String toastAuctionWon(String title, String amount);

  /// No description provided for @txnTopupVietQr.
  ///
  /// In vi, this message translates to:
  /// **'Nạp tiền qua VietQR'**
  String get txnTopupVietQr;

  /// No description provided for @txnHoldOrder.
  ///
  /// In vi, this message translates to:
  /// **'Giữ tiền đơn {arg}'**
  String txnHoldOrder(String arg);

  /// No description provided for @txnHoldOrders.
  ///
  /// In vi, this message translates to:
  /// **'Giữ tiền {n} đơn hàng'**
  String txnHoldOrders(int n);

  /// No description provided for @txnHoldAuctionRegistration.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký phiên \"{arg}\"'**
  String txnHoldAuctionRegistration(String arg);

  /// No description provided for @txnHoldBid.
  ///
  /// In vi, this message translates to:
  /// **'Trả giá \"{arg}\"'**
  String txnHoldBid(String arg);

  /// No description provided for @txnHoldBuyNow.
  ///
  /// In vi, this message translates to:
  /// **'Mua ngay \"{arg}\"'**
  String txnHoldBuyNow(String arg);

  /// No description provided for @txnHoldRedelivery.
  ///
  /// In vi, this message translates to:
  /// **'Phí giao lại {arg}'**
  String txnHoldRedelivery(String arg);

  /// No description provided for @txnReleaseOrderCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tiền hủy đơn {arg}'**
  String txnReleaseOrderCancelled(String arg);

  /// No description provided for @txnReleaseAuctionUnregistered.
  ///
  /// In vi, this message translates to:
  /// **'Hủy đăng ký \"{arg}\"'**
  String txnReleaseAuctionUnregistered(String arg);

  /// No description provided for @txnReleaseAuctionDeposit.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn cọc phiên \"{arg}\"'**
  String txnReleaseAuctionDeposit(String arg);

  /// No description provided for @txnPayoutSale.
  ///
  /// In vi, this message translates to:
  /// **'Nhận tiền bán \"{arg}\"'**
  String txnPayoutSale(String arg);

  /// No description provided for @txnCaptureOrder.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán đơn {arg} (từ tiền giữ)'**
  String txnCaptureOrder(String arg);

  /// No description provided for @txnRefundAgreement.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tiền thỏa thuận {arg}'**
  String txnRefundAgreement(String arg);

  /// No description provided for @txnRefundVerdict.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tiền theo phán quyết {arg}'**
  String txnRefundVerdict(String arg);

  /// No description provided for @txnWithdrawRequest.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu rút về Vietcombank · chờ duyệt'**
  String get txnWithdrawRequest;

  /// No description provided for @txnTypeTopup.
  ///
  /// In vi, this message translates to:
  /// **'Nạp tiền'**
  String get txnTypeTopup;

  /// No description provided for @txnTypeHold.
  ///
  /// In vi, this message translates to:
  /// **'Giữ tiền'**
  String get txnTypeHold;

  /// No description provided for @txnTypeRelease.
  ///
  /// In vi, this message translates to:
  /// **'Nhả tiền'**
  String get txnTypeRelease;

  /// No description provided for @txnTypePayout.
  ///
  /// In vi, this message translates to:
  /// **'Nhận tiền'**
  String get txnTypePayout;

  /// No description provided for @txnTypeRefund.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tiền'**
  String get txnTypeRefund;

  /// No description provided for @txnTypeCapture.
  ///
  /// In vi, this message translates to:
  /// **'Chốt thanh toán'**
  String get txnTypeCapture;

  /// No description provided for @txnTypeWithdraw.
  ///
  /// In vi, this message translates to:
  /// **'Rút tiền'**
  String get txnTypeWithdraw;

  /// No description provided for @orderStatusPaidAwaitingShipment.
  ///
  /// In vi, this message translates to:
  /// **'Chờ người bán gửi'**
  String get orderStatusPaidAwaitingShipment;

  /// No description provided for @orderStatusShipped.
  ///
  /// In vi, this message translates to:
  /// **'Đang vận chuyển'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In vi, this message translates to:
  /// **'Đã giao'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get orderStatusCancelled;

  /// No description provided for @orderStatusRefunded.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn tiền'**
  String get orderStatusRefunded;

  /// No description provided for @orderStatusPartiallyRefunded.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn một phần'**
  String get orderStatusPartiallyRefunded;

  /// No description provided for @orderStatusDisputed.
  ///
  /// In vi, this message translates to:
  /// **'Đang khiếu nại'**
  String get orderStatusDisputed;

  /// No description provided for @orderStatusReadyToShip.
  ///
  /// In vi, this message translates to:
  /// **'Chờ kho xuất'**
  String get orderStatusReadyToShip;

  /// No description provided for @orderStatusInDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Đang giao'**
  String get orderStatusInDelivery;

  /// No description provided for @orderStatusInStorage.
  ///
  /// In vi, this message translates to:
  /// **'Lưu kho'**
  String get orderStatusInStorage;

  /// No description provided for @orderStatusPickedUp.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận tại kho'**
  String get orderStatusPickedUp;

  /// No description provided for @orderKindSale.
  ///
  /// In vi, this message translates to:
  /// **'Bán thường'**
  String get orderKindSale;

  /// No description provided for @orderKindAuction.
  ///
  /// In vi, this message translates to:
  /// **'Đấu giá'**
  String get orderKindAuction;

  /// No description provided for @ordersTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đơn mua'**
  String get ordersTitle;

  /// No description provided for @orderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đơn {arg}'**
  String orderTitle(String arg);

  /// No description provided for @ordersEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có đơn mua nào.'**
  String get ordersEmpty;

  /// No description provided for @noteShipBy.
  ///
  /// In vi, this message translates to:
  /// **'Người bán gửi trước {date}'**
  String noteShipBy(String date);

  /// No description provided for @noteComplaintLeft.
  ///
  /// In vi, this message translates to:
  /// **'Còn {time} để khiếu nại'**
  String noteComplaintLeft(String time);

  /// No description provided for @noteDeliveryAttempt.
  ///
  /// In vi, this message translates to:
  /// **'Lần giao {n}/5 · {carrier}'**
  String noteDeliveryAttempt(int n, String carrier);

  /// No description provided for @noteStorage.
  ///
  /// In vi, this message translates to:
  /// **'Lưu kho {days} ngày · 5.000 đ/ngày trừ vào cọc'**
  String noteStorage(int days);

  /// No description provided for @notePacking.
  ///
  /// In vi, this message translates to:
  /// **'Kho đang đóng gói'**
  String get notePacking;

  /// No description provided for @noteFundsLocked.
  ///
  /// In vi, this message translates to:
  /// **'Tiền đang bị khóa'**
  String get noteFundsLocked;

  /// No description provided for @headPaidAwaitingShipment.
  ///
  /// In vi, this message translates to:
  /// **'Chờ người bán gửi hàng'**
  String get headPaidAwaitingShipment;

  /// No description provided for @headShipped.
  ///
  /// In vi, this message translates to:
  /// **'Sách đang trên đường đến'**
  String get headShipped;

  /// No description provided for @headDelivered.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã nhận được sách?'**
  String get headDelivered;

  /// No description provided for @headCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đã hoàn tất'**
  String get headCompleted;

  /// No description provided for @headDisputed.
  ///
  /// In vi, this message translates to:
  /// **'Khiếu nại đang được xử lý'**
  String get headDisputed;

  /// No description provided for @headCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đã hủy'**
  String get headCancelled;

  /// No description provided for @headRefunded.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn tiền'**
  String get headRefunded;

  /// No description provided for @headPartiallyRefunded.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn tiền một phần'**
  String get headPartiallyRefunded;

  /// No description provided for @headReadyToShip.
  ///
  /// In vi, this message translates to:
  /// **'Kho đang chuẩn bị giao'**
  String get headReadyToShip;

  /// No description provided for @headInDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Đang giao sách đấu giá'**
  String get headInDelivery;

  /// No description provided for @headInStorage.
  ///
  /// In vi, this message translates to:
  /// **'Sách đang được lưu kho'**
  String get headInStorage;

  /// No description provided for @headPickedUp.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận tại kho'**
  String get headPickedUp;

  /// No description provided for @detailNotePaid.
  ///
  /// In vi, this message translates to:
  /// **'Người bán phải gửi trước {date}. Quá hạn đơn tự hủy và hoàn 100%. Bạn có thể hủy miễn phí đến khi người bán gửi.'**
  String detailNotePaid(String date);

  /// No description provided for @detailNoteShipped.
  ///
  /// In vi, this message translates to:
  /// **'Bấm \"Đã nhận được hàng\" khi sách đến tay để bắt đầu 3 ngày kiểm tra.'**
  String get detailNoteShipped;

  /// No description provided for @detailNoteDelivered.
  ///
  /// In vi, this message translates to:
  /// **'Bạn còn {time} để khiếu nại. Hết hạn, đơn tự hoàn tất và tiền chuyển cho người bán.'**
  String detailNoteDelivered(String time);

  /// No description provided for @detailNoteCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Người bán đã nhận tiền sau khi trừ phí.'**
  String get detailNoteCompleted;

  /// No description provided for @detailNoteDisputed.
  ///
  /// In vi, this message translates to:
  /// **'Tiền bị khóa đến khi có thỏa thuận hoặc phán quyết.'**
  String get detailNoteDisputed;

  /// No description provided for @detailNoteCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Toàn bộ tiền giữ đã được nhả về ví.'**
  String get detailNoteCancelled;

  /// No description provided for @detailNoteRefunded.
  ///
  /// In vi, this message translates to:
  /// **'Tiền hoàn đã vào ví.'**
  String get detailNoteRefunded;

  /// No description provided for @detailNotePartiallyRefunded.
  ///
  /// In vi, this message translates to:
  /// **'Phần hoàn đã vào ví, phần còn lại chuyển người bán.'**
  String get detailNotePartiallyRefunded;

  /// No description provided for @detailNoteReadyToShip.
  ///
  /// In vi, this message translates to:
  /// **'Phí ship {amount} đã được giữ. Kho chụp ảnh đóng gói trước khi giao.'**
  String detailNoteReadyToShip(String amount);

  /// No description provided for @detailNoteInDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Lần giao {n}/5. Sau 5 lần thất bại, sách vào lưu kho (5.000 đ/ngày, tối đa 30 ngày).'**
  String detailNoteInDelivery(int n);

  /// No description provided for @detailNoteInStorage.
  ///
  /// In vi, this message translates to:
  /// **'Giao thất bại 5 lần. Phí lưu kho trừ vào cọc. Chọn nhận tại kho hoặc giao lại.'**
  String get detailNoteInStorage;

  /// No description provided for @stepSaleOrdered.
  ///
  /// In vi, this message translates to:
  /// **'Đã đặt · tiền được giữ'**
  String get stepSaleOrdered;

  /// No description provided for @stepSaleShipped.
  ///
  /// In vi, this message translates to:
  /// **'Người bán đã gửi'**
  String get stepSaleShipped;

  /// No description provided for @stepDelivered.
  ///
  /// In vi, this message translates to:
  /// **'Đã giao'**
  String get stepDelivered;

  /// No description provided for @stepSaleCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất · tiền chuyển cho người bán'**
  String get stepSaleCompleted;

  /// No description provided for @stepAuctionWon.
  ///
  /// In vi, this message translates to:
  /// **'Thắng phiên · kho nhận lệnh xuất'**
  String get stepAuctionWon;

  /// No description provided for @stepAuctionInDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Đang giao'**
  String get stepAuctionInDelivery;

  /// No description provided for @stepAuctionReceived.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận hàng'**
  String get stepAuctionReceived;

  /// No description provided for @stepAuctionCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất · hoàn cọc'**
  String get stepAuctionCompleted;

  /// No description provided for @stepCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy · tiền đã hoàn về ví'**
  String get stepCancelled;

  /// No description provided for @stepNext.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp theo'**
  String get stepNext;

  /// No description provided for @moneyBookPrice.
  ///
  /// In vi, this message translates to:
  /// **'Tiền sách'**
  String get moneyBookPrice;

  /// No description provided for @moneyWinPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá thắng'**
  String get moneyWinPrice;

  /// No description provided for @moneyShipping.
  ///
  /// In vi, this message translates to:
  /// **'Phí ship'**
  String get moneyShipping;

  /// No description provided for @moneyTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng'**
  String get moneyTotal;

  /// No description provided for @moneyNoteAuction.
  ///
  /// In vi, this message translates to:
  /// **'Giá thắng đã được chốt vào tài khoản trung gian. Cọc hoàn khi bạn nhận sách.'**
  String get moneyNoteAuction;

  /// No description provided for @moneyNoteSettled.
  ///
  /// In vi, this message translates to:
  /// **'Đã quyết toán.'**
  String get moneyNoteSettled;

  /// No description provided for @moneyNoteHeld.
  ///
  /// In vi, this message translates to:
  /// **'Đang giữ trong ví đến khi đơn hoàn tất.'**
  String get moneyNoteHeld;

  /// No description provided for @shipNoTracking.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mã vận đơn'**
  String get shipNoTracking;

  /// No description provided for @shipFromWarehouse.
  ///
  /// In vi, this message translates to:
  /// **'Giao từ kho Oldbook'**
  String get shipFromWarehouse;

  /// No description provided for @reviewSeller.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá người bán'**
  String get reviewSeller;

  /// No description provided for @reviewNoteNew.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá trong 14 ngày sau khi hoàn tất.'**
  String get reviewNoteNew;

  /// No description provided for @reviewNoteEdit.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể sửa đánh giá một lần trong 7 ngày.'**
  String get reviewNoteEdit;

  /// No description provided for @starLabel.
  ///
  /// In vi, this message translates to:
  /// **'{n} sao'**
  String starLabel(int n);

  /// No description provided for @actSimSellerShip.
  ///
  /// In vi, this message translates to:
  /// **'Mô phỏng: người bán gửi hàng'**
  String get actSimSellerShip;

  /// No description provided for @actCancelOrder.
  ///
  /// In vi, this message translates to:
  /// **'Hủy đơn · hoàn {amount}'**
  String actCancelOrder(String amount);

  /// No description provided for @actReceived.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận được hàng'**
  String get actReceived;

  /// No description provided for @actSimWarehouseShip.
  ///
  /// In vi, this message translates to:
  /// **'Mô phỏng: kho xuất hàng'**
  String get actSimWarehouseShip;

  /// No description provided for @actSimDeliverOk.
  ///
  /// In vi, this message translates to:
  /// **'Mô phỏng: giao thành công'**
  String get actSimDeliverOk;

  /// No description provided for @actSimDeliverFail.
  ///
  /// In vi, this message translates to:
  /// **'Mô phỏng: giao thất bại'**
  String get actSimDeliverFail;

  /// No description provided for @actPickUp.
  ///
  /// In vi, this message translates to:
  /// **'Đến nhận tại kho'**
  String get actPickUp;

  /// No description provided for @actRedeliver.
  ///
  /// In vi, this message translates to:
  /// **'Giao lại · thêm {amount}'**
  String actRedeliver(String amount);

  /// No description provided for @actCompleteOrder.
  ///
  /// In vi, this message translates to:
  /// **'Hài lòng, hoàn tất đơn'**
  String get actCompleteOrder;

  /// No description provided for @actComplaint.
  ///
  /// In vi, this message translates to:
  /// **'Khiếu nại'**
  String get actComplaint;

  /// No description provided for @actSimSellerOffer.
  ///
  /// In vi, this message translates to:
  /// **'Mô phỏng: người bán đề xuất hoàn 50%'**
  String get actSimSellerOffer;

  /// No description provided for @actAcceptOffer.
  ///
  /// In vi, this message translates to:
  /// **'Chấp nhận hoàn {amount}'**
  String actAcceptOffer(String amount);

  /// No description provided for @actEscalate.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối, chuyển Oldbook phân xử'**
  String get actEscalate;

  /// No description provided for @actSimAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Mô phỏng: admin phán hoàn 100%'**
  String get actSimAdmin;

  /// No description provided for @actNone.
  ///
  /// In vi, this message translates to:
  /// **'Không có thao tác nào cần làm.'**
  String get actNone;

  /// No description provided for @complaintCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khiếu nại · {status}'**
  String complaintCardTitle(String status);

  /// No description provided for @complaintStatusOpen.
  ///
  /// In vi, this message translates to:
  /// **'Chờ người bán phản hồi'**
  String get complaintStatusOpen;

  /// No description provided for @complaintStatusSellerResponded.
  ///
  /// In vi, this message translates to:
  /// **'Người bán đã đề xuất'**
  String get complaintStatusSellerResponded;

  /// No description provided for @complaintStatusEscalated.
  ///
  /// In vi, this message translates to:
  /// **'Oldbook đang phân xử'**
  String get complaintStatusEscalated;

  /// No description provided for @complaintStatusAgreed.
  ///
  /// In vi, this message translates to:
  /// **'Đã thỏa thuận'**
  String get complaintStatusAgreed;

  /// No description provided for @complaintStatusResolved.
  ///
  /// In vi, this message translates to:
  /// **'Đã phán quyết'**
  String get complaintStatusResolved;

  /// No description provided for @complaintTextOpenSale.
  ///
  /// In vi, this message translates to:
  /// **'Người bán có 2 ngày để phản hồi, quá hạn sẽ chuyển Oldbook phân xử.'**
  String get complaintTextOpenSale;

  /// No description provided for @complaintTextOpenAuction.
  ///
  /// In vi, this message translates to:
  /// **'Khiếu nại đấu giá được chuyển thẳng cho Oldbook.'**
  String get complaintTextOpenAuction;

  /// No description provided for @complaintTextSellerResponded.
  ///
  /// In vi, this message translates to:
  /// **'Người bán đề xuất hoàn {amount}. Bạn đồng ý hoặc chuyển Oldbook phân xử.'**
  String complaintTextSellerResponded(String amount);

  /// No description provided for @complaintTextEscalatedSale.
  ///
  /// In vi, this message translates to:
  /// **'Admin xem bằng chứng hai bên và ra phán quyết.'**
  String get complaintTextEscalatedSale;

  /// No description provided for @complaintTextEscalatedAuction.
  ///
  /// In vi, this message translates to:
  /// **'Admin xem bằng chứng hai bên, ảnh nhập/xuất kho và ra phán quyết.'**
  String get complaintTextEscalatedAuction;

  /// No description provided for @complaintTextAgreed.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn {amount} theo thỏa thuận.'**
  String complaintTextAgreed(String amount);

  /// No description provided for @complaintTextResolved.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn toàn bộ theo phán quyết.'**
  String get complaintTextResolved;

  /// No description provided for @complaintSheetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mở khiếu nại'**
  String get complaintSheetTitle;

  /// No description provided for @complaintSheetNote.
  ///
  /// In vi, this message translates to:
  /// **'Tiền sẽ bị khóa đến khi khiếu nại được giải quyết.'**
  String get complaintSheetNote;

  /// No description provided for @complaintReasonNotAsDescribed.
  ///
  /// In vi, this message translates to:
  /// **'Không đúng mô tả'**
  String get complaintReasonNotAsDescribed;

  /// No description provided for @complaintReasonDamaged.
  ///
  /// In vi, this message translates to:
  /// **'Sách bị hư hỏng'**
  String get complaintReasonDamaged;

  /// No description provided for @complaintReasonWrongItem.
  ///
  /// In vi, this message translates to:
  /// **'Giao sai sách'**
  String get complaintReasonWrongItem;

  /// No description provided for @complaintReasonOther.
  ///
  /// In vi, this message translates to:
  /// **'Lý do khác'**
  String get complaintReasonOther;

  /// No description provided for @complaintDescribeHint.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả vấn đề'**
  String get complaintDescribeHint;

  /// No description provided for @complaintAddEvidence.
  ///
  /// In vi, this message translates to:
  /// **'+ Thêm ảnh bằng chứng ({n}/10)'**
  String complaintAddEvidence(int n);

  /// No description provided for @complaintSubmit.
  ///
  /// In vi, this message translates to:
  /// **'Gửi khiếu nại'**
  String get complaintSubmit;

  /// No description provided for @complaintNeedReasonAndPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Chọn lý do và thêm ít nhất 1 ảnh'**
  String get complaintNeedReasonAndPhoto;

  /// No description provided for @cartEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng trống.'**
  String get cartEmpty;

  /// No description provided for @cartSeller.
  ///
  /// In vi, this message translates to:
  /// **'Người bán: {name}'**
  String cartSeller(String name);

  /// No description provided for @cartUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Không còn khả dụng · đã bán'**
  String get cartUnavailable;

  /// No description provided for @cartRemove.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get cartRemove;

  /// No description provided for @cartShipTo.
  ///
  /// In vi, this message translates to:
  /// **'Giao đến'**
  String get cartShipTo;

  /// No description provided for @cartSubtotal.
  ///
  /// In vi, this message translates to:
  /// **'Tiền sách ({n} cuốn)'**
  String cartSubtotal(int n);

  /// No description provided for @cartShippingFee.
  ///
  /// In vi, this message translates to:
  /// **'Phí ship (mỗi đơn {amount})'**
  String cartShippingFee(String amount);

  /// No description provided for @cartBalance.
  ///
  /// In vi, this message translates to:
  /// **'Số dư ví khả dụng'**
  String get cartBalance;

  /// No description provided for @cartNote.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi cuốn tạo một đơn riêng với người bán. Bạn có thể hủy đơn miễn phí khi người bán chưa gửi hàng.'**
  String get cartNote;

  /// No description provided for @cartPayTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thanh toán'**
  String get cartPayTotal;

  /// No description provided for @cartPlaceOrder.
  ///
  /// In vi, this message translates to:
  /// **'Đặt hàng · thanh toán bằng ví'**
  String get cartPlaceOrder;

  /// No description provided for @cartInsufficient.
  ///
  /// In vi, this message translates to:
  /// **'Số dư không đủ · nạp thêm'**
  String get cartInsufficient;

  /// No description provided for @cartNoAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Không có sách khả dụng'**
  String get cartNoAvailable;

  /// No description provided for @insufficientTitle.
  ///
  /// In vi, this message translates to:
  /// **'Số dư không đủ'**
  String get insufficientTitle;

  /// No description provided for @insufficientBody.
  ///
  /// In vi, this message translates to:
  /// **'Cần thêm {need} để tiếp tục. Số dư khả dụng hiện tại: {avail}.'**
  String insufficientBody(String need, String avail);

  /// No description provided for @insufficientTopup.
  ///
  /// In vi, this message translates to:
  /// **'Nạp {amount}'**
  String insufficientTopup(String amount);

  /// No description provided for @sheetClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get sheetClose;

  /// No description provided for @sheetLater.
  ///
  /// In vi, this message translates to:
  /// **'Để sau'**
  String get sheetLater;

  /// No description provided for @orderPlacedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt hàng thành công'**
  String get orderPlacedTitle;

  /// No description provided for @orderPlacedBody.
  ///
  /// In vi, this message translates to:
  /// **'Đã giữ {amount} từ ví cho {n} đơn. Người bán có 2 ngày làm việc để gửi hàng, nếu không đơn tự hủy và hoàn tiền.'**
  String orderPlacedBody(String amount, int n);

  /// No description provided for @orderPlacedView.
  ///
  /// In vi, this message translates to:
  /// **'Xem đơn hàng'**
  String get orderPlacedView;

  /// No description provided for @orderPlacedKeepShopping.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục mua'**
  String get orderPlacedKeepShopping;

  /// No description provided for @walletTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ví Oldbook'**
  String get walletTitle;

  /// No description provided for @walletAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Số dư khả dụng'**
  String get walletAvailable;

  /// No description provided for @walletHeld.
  ///
  /// In vi, this message translates to:
  /// **'Đang giữ'**
  String get walletHeld;

  /// No description provided for @walletTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng'**
  String get walletTotal;

  /// No description provided for @walletTopup.
  ///
  /// In vi, this message translates to:
  /// **'Nạp tiền'**
  String get walletTopup;

  /// No description provided for @walletWithdraw.
  ///
  /// In vi, this message translates to:
  /// **'Rút tiền'**
  String get walletWithdraw;

  /// No description provided for @walletNote.
  ///
  /// In vi, this message translates to:
  /// **'Tiền đang giữ dùng cho đơn hàng chưa hoàn tất, tiền cọc đấu giá và lượt trả giá đang dẫn đầu. Mọi giao dịch đi qua ví, không chuyển trực tiếp giữa người dùng.'**
  String get walletNote;

  /// No description provided for @walletHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử giao dịch'**
  String get walletHistory;

  /// No description provided for @walletNoTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch.'**
  String get walletNoTransactions;

  /// No description provided for @walletPayoutAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản nhận tiền'**
  String get walletPayoutAccount;

  /// No description provided for @topupSheetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nạp tiền vào ví'**
  String get topupSheetTitle;

  /// No description provided for @topupSheetNote.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán qua VietQR. Yêu cầu hết hạn sau 30 phút nếu chưa thanh toán.'**
  String get topupSheetNote;

  /// No description provided for @topupCreateCode.
  ///
  /// In vi, this message translates to:
  /// **'Tạo mã thanh toán · {amount}'**
  String topupCreateCode(String amount);

  /// No description provided for @topupScanTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã để thanh toán'**
  String get topupScanTitle;

  /// No description provided for @topupQrLabel.
  ///
  /// In vi, this message translates to:
  /// **'mã VietQR'**
  String get topupQrLabel;

  /// No description provided for @topupTransferContent.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung: OLDBOOK NAP 7K2Q9 · hết hạn sau 30:00'**
  String get topupTransferContent;

  /// No description provided for @topupConfirmNote.
  ///
  /// In vi, this message translates to:
  /// **'Số dư chỉ được cộng khi cổng thanh toán xác nhận.'**
  String get topupConfirmNote;

  /// No description provided for @topupSimConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Mô phỏng: cổng thanh toán xác nhận'**
  String get topupSimConfirm;

  /// No description provided for @withdrawSheetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Rút tiền'**
  String get withdrawSheetTitle;

  /// No description provided for @withdrawAmountHint.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền (tối thiểu 50.000 đ)'**
  String get withdrawAmountHint;

  /// No description provided for @withdrawHintAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Khả dụng: {amount}'**
  String withdrawHintAvailable(String amount);

  /// No description provided for @withdrawHintMin.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu 50.000 đ'**
  String get withdrawHintMin;

  /// No description provided for @withdrawHintOver.
  ///
  /// In vi, this message translates to:
  /// **'Vượt số dư khả dụng ({amount})'**
  String withdrawHintOver(String amount);

  /// No description provided for @withdrawHintHold.
  ///
  /// In vi, this message translates to:
  /// **'Sẽ giữ {amount} chờ duyệt'**
  String withdrawHintHold(String amount);

  /// No description provided for @withdrawNote.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền được giữ ngay và chuyển khoản sau khi Oldbook duyệt. Tên chủ tài khoản phải trùng họ tên hồ sơ.'**
  String get withdrawNote;

  /// No description provided for @withdrawSubmit.
  ///
  /// In vi, this message translates to:
  /// **'Gửi yêu cầu rút'**
  String get withdrawSubmit;

  /// No description provided for @remainingDaysHours.
  ///
  /// In vi, this message translates to:
  /// **'{days} ngày {hours} giờ'**
  String remainingDaysHours(int days, int hours);

  /// No description provided for @agoNow.
  ///
  /// In vi, this message translates to:
  /// **'vừa xong'**
  String get agoNow;

  /// No description provided for @agoMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{n} phút trước'**
  String agoMinutes(int n);

  /// No description provided for @agoHours.
  ///
  /// In vi, this message translates to:
  /// **'{n} giờ trước'**
  String agoHours(int n);

  /// No description provided for @agoDays.
  ///
  /// In vi, this message translates to:
  /// **'{n} ngày trước'**
  String agoDays(int n);

  /// No description provided for @meMyOrders.
  ///
  /// In vi, this message translates to:
  /// **'Đơn mua'**
  String get meMyOrders;

  /// No description provided for @meMyOrdersSub.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi giao hàng, xác nhận nhận hàng, khiếu nại'**
  String get meMyOrdersSub;

  /// No description provided for @aucTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đấu giá'**
  String get aucTitle;

  /// No description provided for @aucSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Sách đã được kiểm tra tại kho Oldbook trước khi lên sàn'**
  String get aucSubtitle;

  /// No description provided for @aucTabLive.
  ///
  /// In vi, this message translates to:
  /// **'Đang diễn ra'**
  String get aucTabLive;

  /// No description provided for @aucTabRegister.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get aucTabRegister;

  /// No description provided for @aucTabUpcoming.
  ///
  /// In vi, this message translates to:
  /// **'Sắp tới'**
  String get aucTabUpcoming;

  /// No description provided for @aucTabEnded.
  ///
  /// In vi, this message translates to:
  /// **'Đã xong'**
  String get aucTabEnded;

  /// No description provided for @aucEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có phiên nào ở trạng thái này.'**
  String get aucEmpty;

  /// No description provided for @aucStatusLive.
  ///
  /// In vi, this message translates to:
  /// **'Đang diễn ra'**
  String get aucStatusLive;

  /// No description provided for @aucStatusBuyNow.
  ///
  /// In vi, this message translates to:
  /// **'Đếm ngược mua ngay'**
  String get aucStatusBuyNow;

  /// No description provided for @aucStatusRegistration.
  ///
  /// In vi, this message translates to:
  /// **'Đang mở đăng ký'**
  String get aucStatusRegistration;

  /// No description provided for @aucStatusConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Sắp diễn ra'**
  String get aucStatusConfirmed;

  /// No description provided for @aucStatusEnded.
  ///
  /// In vi, this message translates to:
  /// **'Đã kết thúc'**
  String get aucStatusEnded;

  /// No description provided for @aucStatusNoBid.
  ///
  /// In vi, this message translates to:
  /// **'Không có lượt'**
  String get aucStatusNoBid;

  /// No description provided for @aucRegisteredTag.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng ký'**
  String get aucRegisteredTag;

  /// No description provided for @aucParticipants.
  ///
  /// In vi, this message translates to:
  /// **'{n} người tham gia'**
  String aucParticipants(int n);

  /// No description provided for @aucParticipantsMin.
  ///
  /// In vi, this message translates to:
  /// **'{n}/{min} người tối thiểu'**
  String aucParticipantsMin(int n, String min);

  /// No description provided for @aucPriceStarting.
  ///
  /// In vi, this message translates to:
  /// **'Giá khởi điểm'**
  String get aucPriceStarting;

  /// No description provided for @aucPriceCurrent.
  ///
  /// In vi, this message translates to:
  /// **'Giá hiện tại'**
  String get aucPriceCurrent;

  /// No description provided for @aucPriceWinning.
  ///
  /// In vi, this message translates to:
  /// **'Giá thắng'**
  String get aucPriceWinning;

  /// No description provided for @aucTimerEndsIn.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc sau'**
  String get aucTimerEndsIn;

  /// No description provided for @aucTimerCountdown.
  ///
  /// In vi, this message translates to:
  /// **'Đếm ngược'**
  String get aucTimerCountdown;

  /// No description provided for @aucTimerRegCloses.
  ///
  /// In vi, this message translates to:
  /// **'Đóng đăng ký sau'**
  String get aucTimerRegCloses;

  /// No description provided for @aucTimerStartsIn.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu sau'**
  String get aucTimerStartsIn;

  /// No description provided for @aucTimerEndedAt.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc lúc'**
  String get aucTimerEndedAt;

  /// No description provided for @aucSubLive.
  ///
  /// In vi, this message translates to:
  /// **'Lượt trả giá trong 2 phút cuối sẽ gia hạn phiên thêm 2 phút.'**
  String get aucSubLive;

  /// No description provided for @aucSubCountdown.
  ///
  /// In vi, this message translates to:
  /// **'Đã có người mua ngay. Mỗi lượt cao hơn đặt lại 30 phút · kết thúc muộn nhất {time}.'**
  String aucSubCountdown(String time);

  /// No description provided for @aucSubRegistration.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bắt đầu {time} · cần tối thiểu {min} người.'**
  String aucSubRegistration(String time, String min);

  /// No description provided for @aucSubConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Đã đủ người · bắt đầu {time}.'**
  String aucSubConfirmed(String time);

  /// No description provided for @aucLeaderMe.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang dẫn đầu'**
  String get aucLeaderMe;

  /// No description provided for @aucLeaderOther.
  ///
  /// In vi, this message translates to:
  /// **'Dẫn đầu: {name}'**
  String aucLeaderOther(String name);

  /// No description provided for @aucNoBids.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lượt trả giá'**
  String get aucNoBids;

  /// No description provided for @aucExtendedBanner.
  ///
  /// In vi, this message translates to:
  /// **'Phiên vừa được gia hạn thêm 2 phút (chống bắn tỉa)'**
  String get aucExtendedBanner;

  /// No description provided for @aucStatStart.
  ///
  /// In vi, this message translates to:
  /// **'Giá khởi điểm'**
  String get aucStatStart;

  /// No description provided for @aucStatStep.
  ///
  /// In vi, this message translates to:
  /// **'Bước nhảy'**
  String get aucStatStep;

  /// No description provided for @aucStatBuyNow.
  ///
  /// In vi, this message translates to:
  /// **'Giá mua ngay'**
  String get aucStatBuyNow;

  /// No description provided for @aucStatFeeDeposit.
  ///
  /// In vi, this message translates to:
  /// **'Phí tham gia · Cọc'**
  String get aucStatFeeDeposit;

  /// No description provided for @aucNone.
  ///
  /// In vi, this message translates to:
  /// **'Không có'**
  String get aucNone;

  /// No description provided for @aucBidHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử trả giá'**
  String get aucBidHistory;

  /// No description provided for @aucBidCount.
  ///
  /// In vi, this message translates to:
  /// **'{n} lượt'**
  String aucBidCount(int n);

  /// No description provided for @aucBidYou.
  ///
  /// In vi, this message translates to:
  /// **'Bạn'**
  String get aucBidYou;

  /// No description provided for @aucNoBidsYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lượt trả giá. Lượt đầu tiên phải từ giá khởi điểm.'**
  String get aucNoBidsYet;

  /// No description provided for @aucSellerLine.
  ///
  /// In vi, this message translates to:
  /// **'Người bán: {seller} · {part}'**
  String aucSellerLine(String seller, String part);

  /// No description provided for @aucHoldLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giữ phí tham gia + cọc'**
  String get aucHoldLabel;

  /// No description provided for @aucRegister.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký tham gia'**
  String get aucRegister;

  /// No description provided for @aucRegisteredTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã đăng ký'**
  String get aucRegisteredTitle;

  /// No description provided for @aucRegisteredSub.
  ///
  /// In vi, this message translates to:
  /// **'Đang giữ {amount} · hủy được trước khi đóng'**
  String aucRegisteredSub(String amount);

  /// No description provided for @aucUnregister.
  ///
  /// In vi, this message translates to:
  /// **'Hủy đăng ký'**
  String get aucUnregister;

  /// No description provided for @aucFilledTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đã đủ người'**
  String get aucFilledTitle;

  /// No description provided for @aucFilledSub.
  ///
  /// In vi, this message translates to:
  /// **'Phí tham gia đã thu, cọc {amount} tiếp tục được giữ. Chúng tôi sẽ nhắc bạn 1 giờ trước khi bắt đầu.'**
  String aucFilledSub(String amount);

  /// No description provided for @aucWatchTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang theo dõi phiên này'**
  String get aucWatchTitle;

  /// No description provided for @aucWatchSub.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký đã đóng 24 giờ trước giờ bắt đầu. Chỉ người đã đăng ký mới được trả giá.'**
  String get aucWatchSub;

  /// No description provided for @aucLeadingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang dẫn đầu'**
  String get aucLeadingTitle;

  /// No description provided for @aucLeadingSub.
  ///
  /// In vi, this message translates to:
  /// **'{amount} đang được giữ trong ví · sẽ nhả nếu bị vượt giá'**
  String aucLeadingSub(String amount);

  /// No description provided for @aucMinimum.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu {amount}'**
  String aucMinimum(String amount);

  /// No description provided for @aucBid.
  ///
  /// In vi, this message translates to:
  /// **'Trả giá'**
  String get aucBid;

  /// No description provided for @aucBuyNowButton.
  ///
  /// In vi, this message translates to:
  /// **'Mua ngay {amount}'**
  String aucBuyNowButton(String amount);

  /// No description provided for @aucEndedWon.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã thắng phiên này'**
  String get aucEndedWon;

  /// No description provided for @aucEndedLost.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không thắng phiên này'**
  String get aucEndedLost;

  /// No description provided for @aucEndedGeneric.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đã kết thúc'**
  String get aucEndedGeneric;

  /// No description provided for @aucEndedWonText.
  ///
  /// In vi, this message translates to:
  /// **'Đơn giao hàng đã được tạo trong Đơn mua. Cọc {amount} hoàn khi bạn nhận sách.'**
  String aucEndedWonText(String amount);

  /// No description provided for @aucEndedLostText.
  ///
  /// In vi, this message translates to:
  /// **'Cọc {amount} đã được nhả về ví.'**
  String aucEndedLostText(String amount);

  /// No description provided for @aucEndedOtherText.
  ///
  /// In vi, this message translates to:
  /// **'Giá thắng {amount}.'**
  String aucEndedOtherText(String amount);

  /// No description provided for @aucNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy phiên này.'**
  String get aucNotFound;

  /// No description provided for @aucErrEnded.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đã kết thúc, không thể trả giá.'**
  String get aucErrEnded;

  /// No description provided for @aucErrTooLow.
  ///
  /// In vi, this message translates to:
  /// **'Giá thấp hơn mức tối thiểu hiện tại.'**
  String get aucErrTooLow;

  /// No description provided for @aucErrState.
  ///
  /// In vi, this message translates to:
  /// **'Không thể thực hiện ở trạng thái hiện tại.'**
  String get aucErrState;

  /// No description provided for @regSheetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký tham gia phiên'**
  String get regSheetTitle;

  /// No description provided for @regFee.
  ///
  /// In vi, this message translates to:
  /// **'Phí tham gia (2% giá khởi điểm, 10.000–100.000 đ)'**
  String get regFee;

  /// No description provided for @regDeposit.
  ///
  /// In vi, this message translates to:
  /// **'Tiền cọc (10% giá khởi điểm)'**
  String get regDeposit;

  /// No description provided for @regHold.
  ///
  /// In vi, this message translates to:
  /// **'Tạm giữ từ ví'**
  String get regHold;

  /// No description provided for @regBalance.
  ///
  /// In vi, this message translates to:
  /// **'Số dư khả dụng'**
  String get regBalance;

  /// No description provided for @regNote1.
  ///
  /// In vi, this message translates to:
  /// **'• Phí tham gia chỉ thu khi phiên đủ 3 người; không đủ người sẽ hoàn toàn bộ.'**
  String get regNote1;

  /// No description provided for @regNote2.
  ///
  /// In vi, this message translates to:
  /// **'• Cọc hoàn khi phiên kết thúc (người thua) hoặc khi bạn nhận hàng (người thắng). Phí lưu kho 5.000 đ/ngày trừ vào cọc nếu không nhận hàng.'**
  String get regNote2;

  /// No description provided for @regNote3.
  ///
  /// In vi, this message translates to:
  /// **'• Hủy đăng ký miễn phí trước {time}.'**
  String regNote3(String time);

  /// No description provided for @regConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận · giữ {amount}'**
  String regConfirm(String amount);

  /// No description provided for @regInsufficient.
  ///
  /// In vi, this message translates to:
  /// **'Số dư không đủ · nạp thêm'**
  String get regInsufficient;

  /// No description provided for @buyNowTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mua ngay với giá {amount}?'**
  String buyNowTitle(String amount);

  /// No description provided for @buyNowNote1.
  ///
  /// In vi, this message translates to:
  /// **'• {amount} được giữ từ ví và bạn trở thành người dẫn đầu.'**
  String buyNowNote1(String amount);

  /// No description provided for @buyNowNote2.
  ///
  /// In vi, this message translates to:
  /// **'• Phiên chuyển sang đếm ngược 30 phút. Mỗi lượt trả giá cao hơn sẽ đặt lại 30 phút.'**
  String get buyNowNote2;

  /// No description provided for @buyNowNote3.
  ///
  /// In vi, this message translates to:
  /// **'• Phiên kết thúc chậm nhất 24 giờ sau khi bấm mua ngay.'**
  String get buyNowNote3;

  /// No description provided for @buyNowConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mua ngay'**
  String get buyNowConfirm;

  /// No description provided for @myAuctionsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên tôi tham gia'**
  String get myAuctionsTitle;

  /// No description provided for @myAuctionsEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa đăng ký phiên nào.'**
  String get myAuctionsEmpty;

  /// No description provided for @myAucWon.
  ///
  /// In vi, this message translates to:
  /// **'Đã thắng · {amount}'**
  String myAucWon(String amount);

  /// No description provided for @myAucLeading.
  ///
  /// In vi, this message translates to:
  /// **'Đang dẫn đầu · {amount}'**
  String myAucLeading(String amount);

  /// No description provided for @myAucLost.
  ///
  /// In vi, this message translates to:
  /// **'Không thắng'**
  String get myAucLost;

  /// No description provided for @myAucOutbid.
  ///
  /// In vi, this message translates to:
  /// **'Đã bị vượt giá'**
  String get myAucOutbid;

  /// No description provided for @myAucRegistered.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng ký'**
  String get myAucRegistered;

  /// No description provided for @homeLiveAuctions.
  ///
  /// In vi, this message translates to:
  /// **'Đang đấu giá'**
  String get homeLiveAuctions;

  /// No description provided for @homeSeeAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get homeSeeAll;

  /// No description provided for @simNotifBuyNowTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên \"{arg}\" đang đếm ngược mua ngay'**
  String simNotifBuyNowTitle(String arg);

  /// No description provided for @simNotifBuyNowBody.
  ///
  /// In vi, this message translates to:
  /// **'Có người bấm mua ngay. Trả giá cao hơn để đặt lại đếm ngược 30 phút.'**
  String get simNotifBuyNowBody;

  /// No description provided for @simNotifDeliveredTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đơn {arg} đã giao'**
  String simNotifDeliveredTitle(String arg);

  /// No description provided for @simNotifDeliveredBody.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có 3 ngày để kiểm tra sách và khiếu nại nếu có vấn đề.'**
  String get simNotifDeliveredBody;

  /// No description provided for @simNotifFilledTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên \"{arg}\" đã đủ người'**
  String simNotifFilledTitle(String arg);

  /// No description provided for @simNotifFilledBody.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bắt đầu sau vài giờ. Cọc {amount} tiếp tục được giữ.'**
  String simNotifFilledBody(String amount);

  /// No description provided for @simNotifTopupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nạp tiền thành công'**
  String get simNotifTopupTitle;

  /// No description provided for @simNotifTopupBody.
  ///
  /// In vi, this message translates to:
  /// **'+{amount} đã vào ví.'**
  String simNotifTopupBody(String amount);

  /// No description provided for @simNotifRegisteredTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thành công'**
  String get simNotifRegisteredTitle;

  /// No description provided for @simNotifRegisteredBody.
  ///
  /// In vi, this message translates to:
  /// **'\"{arg}\" · đã giữ {amount}'**
  String simNotifRegisteredBody(String arg, String amount);

  /// No description provided for @simNotifOutbidTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã bị vượt giá'**
  String get simNotifOutbidTitle;

  /// No description provided for @simNotifOutbidBody.
  ///
  /// In vi, this message translates to:
  /// **'\"{arg}\" · giá mới {amount}. Tiền giữ đã được nhả về ví.'**
  String simNotifOutbidBody(String arg, String amount);

  /// No description provided for @simNotifWonTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã thắng phiên \"{arg}\"'**
  String simNotifWonTitle(String arg);

  /// No description provided for @simNotifWonBody.
  ///
  /// In vi, this message translates to:
  /// **'Giá thắng {amount}. Đơn giao hàng đã được tạo trong Đơn mua.'**
  String simNotifWonBody(String amount);

  /// No description provided for @meStatOpenOrders.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đang mua'**
  String get meStatOpenOrders;

  /// No description provided for @meStatListings.
  ///
  /// In vi, this message translates to:
  /// **'Tin đang đăng'**
  String get meStatListings;

  /// No description provided for @meStatAuctions.
  ///
  /// In vi, this message translates to:
  /// **'Phiên tham gia'**
  String get meStatAuctions;

  /// No description provided for @meMyListings.
  ///
  /// In vi, this message translates to:
  /// **'Tin đăng của tôi'**
  String get meMyListings;

  /// No description provided for @meMyListingsSub.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái duyệt, cần sửa, đã bán'**
  String get meMyListingsSub;

  /// No description provided for @meMyAuctionsSub.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng ký, đang dẫn đầu, đã thắng'**
  String get meMyAuctionsSub;

  /// No description provided for @meNotificationsSub.
  ///
  /// In vi, this message translates to:
  /// **'{n} chưa đọc'**
  String meNotificationsSub(int n);

  /// No description provided for @meNotificationsAllRead.
  ///
  /// In vi, this message translates to:
  /// **'Đã đọc hết'**
  String get meNotificationsAllRead;

  /// No description provided for @meDefaultAddress.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ mặc định'**
  String get meDefaultAddress;

  /// No description provided for @sellTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng bán'**
  String get sellTitle;

  /// No description provided for @sellModeFixed.
  ///
  /// In vi, this message translates to:
  /// **'Bán giá cố định'**
  String get sellModeFixed;

  /// No description provided for @sellModeAuction.
  ///
  /// In vi, this message translates to:
  /// **'Đấu giá'**
  String get sellModeAuction;

  /// No description provided for @sellAuctionNote.
  ///
  /// In vi, this message translates to:
  /// **'Sách đấu giá được gửi về kho Oldbook trong 5 ngày để kiểm tra và chụp ảnh lại. Sau khi duyệt, phiên mở đăng ký tối thiểu 3 ngày và cần ít nhất 3 người tham gia.'**
  String get sellAuctionNote;

  /// No description provided for @sellPhotos.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh sách'**
  String get sellPhotos;

  /// No description provided for @sellPhotoCount.
  ///
  /// In vi, this message translates to:
  /// **'{n}/10 · tối thiểu 4'**
  String sellPhotoCount(int n);

  /// No description provided for @sellPhotoAdd.
  ///
  /// In vi, this message translates to:
  /// **'+ thêm'**
  String get sellPhotoAdd;

  /// No description provided for @sellFieldTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tên sách'**
  String get sellFieldTitle;

  /// No description provided for @sellFieldTitleHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Số đỏ'**
  String get sellFieldTitleHint;

  /// No description provided for @sellFieldAuthor.
  ///
  /// In vi, this message translates to:
  /// **'Tác giả'**
  String get sellFieldAuthor;

  /// No description provided for @sellFieldAuthorHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Vũ Trọng Phụng'**
  String get sellFieldAuthorHint;

  /// No description provided for @sellFieldCategory.
  ///
  /// In vi, this message translates to:
  /// **'Thể loại'**
  String get sellFieldCategory;

  /// No description provided for @sellFieldCondition.
  ///
  /// In vi, this message translates to:
  /// **'Tình trạng'**
  String get sellFieldCondition;

  /// No description provided for @sellFieldPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá bán (đ)'**
  String get sellFieldPrice;

  /// No description provided for @sellFieldPriceHint.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu 1.000'**
  String get sellFieldPriceHint;

  /// No description provided for @sellFieldStart.
  ///
  /// In vi, this message translates to:
  /// **'Giá khởi điểm'**
  String get sellFieldStart;

  /// No description provided for @sellFieldStartHint.
  ///
  /// In vi, this message translates to:
  /// **'≥ 10.000'**
  String get sellFieldStartHint;

  /// No description provided for @sellFieldStep.
  ///
  /// In vi, this message translates to:
  /// **'Bước nhảy'**
  String get sellFieldStep;

  /// No description provided for @sellFieldBuyNow.
  ///
  /// In vi, this message translates to:
  /// **'Giá mua ngay'**
  String get sellFieldBuyNow;

  /// No description provided for @sellFieldBuyNowOptional.
  ///
  /// In vi, this message translates to:
  /// **'(tùy chọn, ≥ 1,5 × giá khởi điểm)'**
  String get sellFieldBuyNowOptional;

  /// No description provided for @sellBuyNowHintEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Để trống nếu không dùng'**
  String get sellBuyNowHintEmpty;

  /// No description provided for @sellBuyNowHint.
  ///
  /// In vi, this message translates to:
  /// **'≥ {amount}'**
  String sellBuyNowHint(String amount);

  /// No description provided for @sellStepHintEmpty.
  ///
  /// In vi, this message translates to:
  /// **'1–10% giá KĐ'**
  String get sellStepHintEmpty;

  /// No description provided for @sellDuration.
  ///
  /// In vi, this message translates to:
  /// **'Thời lượng phiên'**
  String get sellDuration;

  /// No description provided for @sellDuration1h.
  ///
  /// In vi, this message translates to:
  /// **'1 giờ'**
  String get sellDuration1h;

  /// No description provided for @sellDuration1d.
  ///
  /// In vi, this message translates to:
  /// **'1 ngày'**
  String get sellDuration1d;

  /// No description provided for @sellDuration3d.
  ///
  /// In vi, this message translates to:
  /// **'3 ngày'**
  String get sellDuration3d;

  /// No description provided for @sellDuration7d.
  ///
  /// In vi, this message translates to:
  /// **'7 ngày'**
  String get sellDuration7d;

  /// No description provided for @sellEarliestStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu sớm nhất: {time} (5 ngày gửi kho + 3 ngày đăng ký + 24 giờ)'**
  String sellEarliestStart(String time);

  /// No description provided for @sellFieldDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả & lỗi (nếu có)'**
  String get sellFieldDesc;

  /// No description provided for @sellFieldDescHint.
  ///
  /// In vi, this message translates to:
  /// **'Năm xuất bản, NXB, ghi chú, trang bị ố…'**
  String get sellFieldDescHint;

  /// No description provided for @sellPreviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'Dự tính'**
  String get sellPreviewTitle;

  /// No description provided for @sellPreviewPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá bán'**
  String get sellPreviewPrice;

  /// No description provided for @sellPreviewFee.
  ///
  /// In vi, this message translates to:
  /// **'Phí bán Oldbook (5%)'**
  String get sellPreviewFee;

  /// No description provided for @sellPreviewReceive.
  ///
  /// In vi, this message translates to:
  /// **'Bạn nhận'**
  String get sellPreviewReceive;

  /// No description provided for @sellPreviewShip.
  ///
  /// In vi, this message translates to:
  /// **'Phí ship (người mua trả)'**
  String get sellPreviewShip;

  /// No description provided for @sellPreviewPlayerFee.
  ///
  /// In vi, this message translates to:
  /// **'Người chơi trả phí tham gia'**
  String get sellPreviewPlayerFee;

  /// No description provided for @sellPreviewPlayerDeposit.
  ///
  /// In vi, this message translates to:
  /// **'Người chơi đặt cọc'**
  String get sellPreviewPlayerDeposit;

  /// No description provided for @sellPreviewCommission.
  ///
  /// In vi, this message translates to:
  /// **'Hoa hồng Oldbook (10% giá thắng)'**
  String get sellPreviewCommission;

  /// No description provided for @sellPreviewReceiveAtStart.
  ///
  /// In vi, this message translates to:
  /// **'Bạn nhận nếu bán ở giá khởi điểm'**
  String get sellPreviewReceiveAtStart;

  /// No description provided for @sellSubmitSale.
  ///
  /// In vi, this message translates to:
  /// **'Gửi duyệt'**
  String get sellSubmitSale;

  /// No description provided for @sellSubmitAuction.
  ///
  /// In vi, this message translates to:
  /// **'Tạo phiên & nhận mã gửi kho'**
  String get sellSubmitAuction;

  /// No description provided for @sellErrPhotos.
  ///
  /// In vi, this message translates to:
  /// **'Cần ít nhất 4 ảnh (hiện có {n})'**
  String sellErrPhotos(int n);

  /// No description provided for @sellErrTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tên sách'**
  String get sellErrTitle;

  /// No description provided for @sellErrAuthor.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tác giả'**
  String get sellErrAuthor;

  /// No description provided for @sellErrPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá bán tối thiểu 1.000 đ'**
  String get sellErrPrice;

  /// No description provided for @sellErrStart.
  ///
  /// In vi, this message translates to:
  /// **'Giá khởi điểm tối thiểu 10.000 đ'**
  String get sellErrStart;

  /// No description provided for @sellErrStep.
  ///
  /// In vi, this message translates to:
  /// **'Bước nhảy phải từ {lo} đến {hi}'**
  String sellErrStep(String lo, String hi);

  /// No description provided for @sellErrBuyNow.
  ///
  /// In vi, this message translates to:
  /// **'Giá mua ngay tối thiểu {amount}'**
  String sellErrBuyNow(String amount);

  /// No description provided for @sellErrDesc.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mô tả'**
  String get sellErrDesc;

  /// No description provided for @sellDoneSaleTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi duyệt'**
  String get sellDoneSaleTitle;

  /// No description provided for @sellDoneSaleBody.
  ///
  /// In vi, this message translates to:
  /// **'Oldbook sẽ duyệt \"{title}\" trong 24 giờ và thông báo cho bạn.'**
  String sellDoneSaleBody(String title);

  /// No description provided for @sellDoneAuctionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo phiên đấu giá'**
  String get sellDoneAuctionTitle;

  /// No description provided for @sellDoneAuctionBody.
  ///
  /// In vi, this message translates to:
  /// **'Gửi sách về kho trong 5 ngày kèm mã dưới đây. Quá hạn phiên tự hủy. Phí ship gửi kho do bạn trả.'**
  String get sellDoneAuctionBody;

  /// No description provided for @sellDoneCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã nhập kho'**
  String get sellDoneCode;

  /// No description provided for @sellDoneWarehouse.
  ///
  /// In vi, this message translates to:
  /// **'Kho Oldbook HN · 25 Lê Văn Lương, Thanh Xuân, Hà Nội'**
  String get sellDoneWarehouse;

  /// No description provided for @sellDoneView.
  ///
  /// In vi, this message translates to:
  /// **'Xem tin đăng của tôi'**
  String get sellDoneView;

  /// No description provided for @myListingsEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có tin đăng nào.'**
  String get myListingsEmpty;

  /// No description provided for @myListingStatusPublished.
  ///
  /// In vi, this message translates to:
  /// **'Đang bán'**
  String get myListingStatusPublished;

  /// No description provided for @myListingStatusPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt'**
  String get myListingStatusPending;

  /// No description provided for @myListingStatusNeedsChanges.
  ///
  /// In vi, this message translates to:
  /// **'Cần sửa'**
  String get myListingStatusNeedsChanges;

  /// No description provided for @myListingStatusAwaitingInbound.
  ///
  /// In vi, this message translates to:
  /// **'Chờ gửi về kho'**
  String get myListingStatusAwaitingInbound;

  /// No description provided for @myListingStatusSold.
  ///
  /// In vi, this message translates to:
  /// **'Đã bán'**
  String get myListingStatusSold;

  /// No description provided for @myListingKindFixed.
  ///
  /// In vi, this message translates to:
  /// **'Bán thường · {price}'**
  String myListingKindFixed(String price);

  /// No description provided for @myListingKindAuction.
  ///
  /// In vi, this message translates to:
  /// **'Đấu giá · khởi điểm {price}'**
  String myListingKindAuction(String price);

  /// No description provided for @myListingNotePublished.
  ///
  /// In vi, this message translates to:
  /// **'Đăng {days} ngày trước · {views} lượt xem'**
  String myListingNotePublished(int days, String views);

  /// No description provided for @myListingNotePending.
  ///
  /// In vi, this message translates to:
  /// **'Gửi duyệt {hours} giờ trước · duyệt trong 24 giờ'**
  String myListingNotePending(int hours);

  /// No description provided for @myListingNotePendingNow.
  ///
  /// In vi, this message translates to:
  /// **'Vừa gửi duyệt · duyệt trong 24 giờ'**
  String get myListingNotePendingNow;

  /// No description provided for @myListingNoteNeedsChanges.
  ///
  /// In vi, this message translates to:
  /// **'Admin: {reason}'**
  String myListingNoteNeedsChanges(String reason);

  /// No description provided for @myListingNoteInbound.
  ///
  /// In vi, this message translates to:
  /// **'Gửi sách về kho trước {date} · mã {code}'**
  String myListingNoteInbound(String date, String code);

  /// No description provided for @myListingNoteSold.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận {amount} (sau phí 5%, gồm ship)'**
  String myListingNoteSold(String amount);

  /// No description provided for @sellCatLiterature.
  ///
  /// In vi, this message translates to:
  /// **'Văn học'**
  String get sellCatLiterature;

  /// No description provided for @sellCatHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get sellCatHistory;

  /// No description provided for @sellCatChildren.
  ///
  /// In vi, this message translates to:
  /// **'Thiếu nhi'**
  String get sellCatChildren;

  /// No description provided for @sellCatScience.
  ///
  /// In vi, this message translates to:
  /// **'Khoa học'**
  String get sellCatScience;

  /// No description provided for @sellCatForeign.
  ///
  /// In vi, this message translates to:
  /// **'Ngoại văn'**
  String get sellCatForeign;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
