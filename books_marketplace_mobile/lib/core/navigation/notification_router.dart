import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/domain/app_notification.dart';

/// Đích điều hướng của một thông báo. Tách khỏi việc điều hướng để test được
/// và để push (sau này) dùng chung với danh sách trong app.
class NotificationTarget {
  const NotificationTarget(this.paths, {this.switchTab = false});

  /// Các route mở lần lượt (route sau chồng lên route trước).
  final List<String> paths;

  /// Đích là một tab (`go`), không chồng lên màn hiện tại.
  final bool switchTab;

  void open(BuildContext context) {
    final router = GoRouter.of(context);
    if (switchTab) {
      router.go(paths.first);
      return;
    }
    for (final p in paths) {
      router.push(p);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is NotificationTarget &&
      other.switchTab == switchTab &&
      other.paths.length == paths.length &&
      [for (var i = 0; i < paths.length; i++) other.paths[i] == paths[i]]
          .every((e) => e);

  @override
  int get hashCode => Object.hash(switchTab, Object.hashAll(paths));

  @override
  String toString() => 'NotificationTarget($paths, tab: $switchTab)';
}

/// Đích khi bấm vào [n], hoặc `null` nếu không có màn hình phù hợp.
///
/// Thông báo đấu giá được xét TRƯỚC nhánh `orderId`/`complaintId` để thông
/// báo đơn đấu giá không bị mở nhầm sang đơn bán thường.
NotificationTarget? notificationTarget(AppNotification n) {
  final type = n.type;
  if (type.isAdminOnly) return null;

  if (type.isAuction) {
    final auction = n.auctionId == null ? null : '/auctions/${n.auctionId}';
    final order = n.auctionOrderId == null
        ? null
        : '/me/auction-orders/${n.auctionOrderId}';
    if (type.opensAuctionThenOrder) {
      return switch ((auction, order)) {
        (final a?, final o?) => NotificationTarget([a, o]),
        (final a?, null) => NotificationTarget([a]),
        (null, final o?) => NotificationTarget([o]),
        _ => null,
      };
    }
    if (type.opensAuctionOrder) {
      final dest = order ?? auction;
      return dest == null ? null : NotificationTarget([dest]);
    }
    final dest = auction ?? order;
    return dest == null ? null : NotificationTarget([dest]);
  }

  if (type.isWallet) {
    return const NotificationTarget(['/wallet'], switchTab: true);
  }
  // Thông báo khiếu nại ưu tiên khiếu nại (cũng có orderId); đơn hàng mở đơn.
  if (n.complaintId != null) {
    return NotificationTarget(['/me/complaints/${n.complaintId}']);
  }
  if (n.orderId != null) return NotificationTarget(['/me/orders/${n.orderId}']);
  if (n.listingId != null) {
    return NotificationTarget(['/home/book/${n.listingId}']);
  }
  // Loại lạ nhưng có id đấu giá: vẫn mở được.
  if (n.auctionOrderId != null) {
    return NotificationTarget(['/me/auction-orders/${n.auctionOrderId}']);
  }
  if (n.auctionId != null) {
    return NotificationTarget(['/auctions/${n.auctionId}']);
  }
  return null;
}
