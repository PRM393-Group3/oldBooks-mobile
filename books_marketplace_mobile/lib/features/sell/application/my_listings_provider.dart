import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/clock.dart';
import '../domain/my_listing.dart';
import '../domain/sell_rules.dart';

/// Tin đăng của tôi, lưu trong bộ nhớ. Khi có API `/me/listings` thì thay bằng
/// repository; giao diện chỉ đọc qua provider này.
class MyListingsNotifier extends Notifier<List<MyListing>> {
  DateTime get _now => ref.read(clockProvider)();

  @override
  List<MyListing> build() {
    final now = _now;
    const d = Duration(days: 1);
    const h = Duration(hours: 1);
    return [
      MyListing(
        id: 'm1',
        title: 'Rừng Na Uy',
        status: MyListingStatus.published,
        isAuction: false,
        price: 70000,
        createdAt: now.subtract(d * 4),
        views: 31,
      ),
      MyListing(
        id: 'm2',
        title: 'Đắc nhân tâm',
        status: MyListingStatus.pendingReview,
        isAuction: false,
        price: 40000,
        createdAt: now.subtract(h * 3),
      ),
      MyListing(
        id: 'm3',
        title: 'Tuổi thơ dữ dội',
        status: MyListingStatus.needsChanges,
        isAuction: false,
        price: 65000,
        createdAt: now.subtract(d * 2),
        adminReason: 'Ảnh bìa bị mờ, vui lòng chụp lại.',
      ),
      MyListing(
        id: 'm4',
        title: 'Truyện ngắn Nam Cao (1960)',
        status: MyListingStatus.awaitingInbound,
        isAuction: true,
        price: 400000,
        createdAt: now,
        inboundCode: 'OB-IN-4M8R',
        inboundDeadline: now.add(d * 3),
      ),
      MyListing(
        id: 'm5',
        title: 'Bố già',
        status: MyListingStatus.sold,
        isAuction: false,
        price: 150000,
        createdAt: now.subtract(d * 20),
        received: 167500,
      ),
    ];
  }

  /// Thêm tin vừa tạo và trả về mã nhập kho (chỉ có với đấu giá).
  String? add(
    SellForm form,
    List<int>? cover,
    String Function() codeGenerator,
  ) {
    final now = _now;
    final code = form.isAuction ? codeGenerator() : null;
    final item = MyListing(
      id: 'm${state.length + 1}-${now.microsecondsSinceEpoch}',
      title: form.title.trim(),
      status: form.isAuction
          ? MyListingStatus.awaitingInbound
          : MyListingStatus.pendingReview,
      isAuction: form.isAuction,
      price: form.isAuction ? form.startingPrice : form.price,
      createdAt: now,
      inboundCode: code,
      inboundDeadline: form.isAuction ? now.add(const Duration(days: 5)) : null,
      photoBytes: cover,
    );
    state = [item, ...state];
    return code;
  }
}

final myListingsProvider =
    NotifierProvider<MyListingsNotifier, List<MyListing>>(
      MyListingsNotifier.new,
    );
