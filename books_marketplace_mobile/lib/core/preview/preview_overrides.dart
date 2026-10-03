// ignore_for_file: use_super_parameters
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/auth_session.dart';
import '../../features/auth/domain/user_role.dart';
import '../../features/categories/application/category_providers.dart';
import '../../features/categories/data/category_repository.dart';
import '../../features/categories/domain/category.dart';
import '../../features/listings/application/listing_providers.dart';
import '../../features/listings/data/listing_repository.dart';
import '../../features/listings/domain/listing.dart';
import '../../features/listings/domain/listing_enums.dart';
import '../../features/notifications/application/notification_providers.dart';
import '../../features/notifications/data/notification_repository.dart';
import '../../features/notifications/domain/app_notification.dart';
import '../../features/profile/application/profile_controller.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/domain/profile.dart';
import '../network/api_client.dart';
import '../network/paged_result.dart';
import '../storage/storage_providers.dart';
import '../storage/token_store.dart';

/// Token giả luôn "đã đăng nhập" để vào thẳng app khi xem trước giao diện.
class PreviewTokenStore extends TokenStore {
  String? _access = 'preview-access';
  String? _refresh = 'preview-refresh';

  @override
  String? get accessToken => _access;
  @override
  String? get refreshToken => _refresh;
  @override
  bool get hasSession => _refresh != null;

  @override
  Future<void> load() async {}

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

Profile _previewProfile() => Profile(
  id: 'u-preview',
  email: 'minhanh@oldbook.vn',
  fullName: 'Nguyễn Minh Anh',
  phoneNumber: '0912345482',
  role: UserRole.buyer,
  createdAt: DateTime.utc(2026, 9, 1),
);

/// Đăng nhập và đăng ký chấp nhận mọi thông tin.
class PreviewAuthRepository extends AuthRepository {
  PreviewAuthRepository(ApiClient api, TokenStore tokens)
    : _store = tokens,
      super(api, tokens);

  final TokenStore _store;

  Future<AuthSession> _ok() async {
    await _store.save(
      accessToken: 'preview-access',
      refreshToken: 'preview-refresh',
    );
    final exp = DateTime.now().add(const Duration(days: 30)).toIso8601String();
    return AuthSession.fromJson({
      'accessToken': 'preview-access',
      'accessTokenExpiresAt': exp,
      'refreshToken': 'preview-refresh',
      'refreshTokenExpiresAt': exp,
      'user': {
        'id': 'u-preview',
        'email': 'minhanh@oldbook.vn',
        'fullName': 'Nguyễn Minh Anh',
        'role': UserRole.buyer.apiValue,
      },
    });
  }

  @override
  Future<void> sendOtp({required String phone}) async {}

  @override
  Future<AuthSession> login({
    required String phone,
    required String password,
  }) => _ok();

  @override
  Future<AuthSession> register({
    required String phone,
    required String otp,
    required String password,
    required String fullName,
  }) => _ok();

  @override
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {}

  @override
  Future<void> logout() => _store.clear();
}

class PreviewProfileRepository extends ProfileRepository {
  PreviewProfileRepository(ApiClient api, TokenStore tokens)
    : super(api, Dio(), tokens);

  Profile _profile = _previewProfile();

  @override
  Future<Profile> getProfile() async => _profile;

  @override
  Future<Profile> updateProfile({
    required String fullName,
    required String? phoneNumber,
  }) async => _profile = Profile(
    id: _profile.id,
    email: _profile.email,
    fullName: fullName.trim(),
    phoneNumber: phoneNumber,
    avatarUrl: _profile.avatarUrl,
    role: _profile.role,
    createdAt: _profile.createdAt,
  );

  @override
  Future<Profile> changeAvatar({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async => _profile;

  @override
  Future<void> deleteAvatar() async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}
}

const _seed = [
  (
    'l1',
    'Nhà giả kim',
    'Paulo Coelho',
    'Văn học',
    BookCondition.good,
    45000,
    'Minh Thư',
    'NXB Hội Nhà Văn',
    2017,
    '9786045337563',
    'Gáy hơi cong nhẹ',
    'Bản dịch Lê Chu Cầu. Giấy còn trắng, không ghi chú, không mất trang.',
  ),
  (
    'l2',
    'Lược sử thời gian',
    'Stephen Hawking',
    'Khoa học',
    BookCondition.fair,
    62000,
    'Quang Huy',
    'NXB Trẻ',
    2015,
    '9786041074745',
    'Vài trang gạch chân bút chì',
    'Bản dịch Cao Chi, Phạm Văn Thiều. Bìa mềm, góc bìa sờn.',
  ),
  (
    'l3',
    'Hoàng tử bé (bìa cứng)',
    'Antoine de Saint-Exupéry',
    'Thiếu nhi',
    BookCondition.good,
    85000,
    'Thu Hà',
    'NXB Kim Đồng',
    2005,
    '',
    'Áo bìa rách nhỏ mép trên',
    'Bản bìa cứng in màu, minh họa gốc của tác giả.',
  ),
  (
    'l4',
    'Việt Nam sử lược',
    'Trần Trọng Kim',
    'Lịch sử',
    BookCondition.poor,
    120000,
    'Đức Anh',
    'NXB Văn hóa Thông tin',
    1999,
    '',
    'Ố vàng, bìa đã bọc lại',
    'Trọn bộ một cuốn, chữ rõ, không mất trang.',
  ),
  (
    'l5',
    'Norwegian Wood',
    'Haruki Murakami',
    'Ngoại văn',
    BookCondition.likeNew,
    150000,
    'Lan Chi',
    'Vintage',
    2003,
    '9780099448822',
    'Không',
    'Bản tiếng Anh, chưa đọc, còn seal.',
  ),
  (
    'l6',
    'Tôi thấy hoa vàng trên cỏ xanh',
    'Nguyễn Nhật Ánh',
    'Văn học',
    BookCondition.good,
    38000,
    'Minh Thư',
    'NXB Trẻ',
    2018,
    '9786041135637',
    'Không',
    'Bìa mềm, giấy tốt, không ghi chú.',
  ),
  (
    'l7',
    'Sapiens: Lược sử loài người',
    'Yuval Noah Harari',
    'Lịch sử',
    BookCondition.fair,
    95000,
    'Quang Huy',
    'NXB Tri Thức',
    2017,
    '9786047722350',
    'Bìa trầy nhẹ',
    'Bản dịch Nguyễn Thủy Chung.',
  ),
];

/// Tin công khai mẫu lấy từ prototype; không có ảnh nên bìa vẽ theo tên sách.
class PreviewListingRepository extends ListingRepository {
  PreviewListingRepository(ApiClient api) : super(api);

  late final List<Listing> _all = [
    for (final s in _seed)
      Listing(
        id: s.$1,
        status: ListingStatus.onSale,
        saleMethod: SaleMethod.fixedPrice,
        seller: PersonRef(id: 's-${s.$7}', name: s.$7),
        category: PersonRef(id: 'cat-${s.$4}', name: s.$4),
        bookInfo: BookInfo(
          title: s.$2,
          author: s.$3,
          condition: s.$5,
          publisher: s.$8,
          publicationYear: s.$9,
          isbn: s.$10.isEmpty ? null : s.$10,
          defectNotes: s.$11,
          description: s.$12,
        ),
        fixedPrice: FixedPriceConfig(price: s.$6, quantity: 1),
      ),
  ];

  @override
  Future<PagedResult<Listing>> browse({
    String? categoryId,
    required int page,
    required int pageSize,
  }) async {
    final items = [
      for (final l in _all)
        if (categoryId == null || l.category?.id == categoryId) l,
    ];
    return PagedResult(
      items: page == 1 ? items : const [],
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<Listing> get(String id) async =>
      _all.firstWhere((l) => l.id == id, orElse: () => _all.first);
}

class PreviewCategoryRepository extends CategoryRepository {
  PreviewCategoryRepository(ApiClient api) : super(api);

  @override
  Future<List<CategoryNode>> tree() async => [
    for (final n in [
      'Văn học',
      'Lịch sử',
      'Thiếu nhi',
      'Khoa học',
      'Ngoại văn',
    ])
      CategoryNode(id: 'cat-$n', name: n),
  ];
}

/// Thông báo backend để trống; thông báo đơn, ví, đấu giá đến từ kho mô phỏng.
class PreviewNotificationRepository extends NotificationRepository {
  PreviewNotificationRepository(ApiClient api) : super(api);

  @override
  Future<PagedResult<AppNotification>> list({
    bool unreadOnly = false,
    required int page,
    required int pageSize,
  }) async => PagedResult(items: const [], page: page, pageSize: pageSize);

  @override
  Future<int> unreadCount() async => 0;

  @override
  Future<void> markRead(String id) async {}

  @override
  Future<void> markAllRead() async {}
}

/// Các provider thay bằng dữ liệu mẫu khi [Env.uiPreview] bật.
List<Override> previewOverrides(TokenStore tokens) {
  final api = ApiClient(Dio());
  return [
    tokenStoreProvider.overrideWithValue(tokens),
    authRepositoryProvider.overrideWithValue(
      PreviewAuthRepository(api, tokens),
    ),
    profileRepositoryProvider.overrideWithValue(
      PreviewProfileRepository(api, tokens),
    ),
    listingRepositoryProvider.overrideWithValue(PreviewListingRepository(api)),
    categoryRepositoryProvider.overrideWithValue(
      PreviewCategoryRepository(api),
    ),
    notificationRepositoryProvider.overrideWithValue(
      PreviewNotificationRepository(api),
    ),
  ];
}
