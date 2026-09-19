import '../../../core/l10n/app_localizations.dart';
import '../../../core/util/json_read.dart';

enum NotificationType {
  listingApproved('ListingApproved'),
  listingRejected('ListingRejected'),
  listingClosed('ListingClosed'),
  unknown('');

  const NotificationType(this.api);
  final String api;

  static NotificationType fromApi(String? v) => values.firstWhere(
    (t) => t.api == v && t != unknown,
    orElse: () => unknown,
  );

  /// Tiêu đề bản địa hóa; loại lạ thì dùng tiêu đề tiếng Anh của server.
  String? title(AppLocalizations l) => switch (this) {
    listingApproved => l.notifListingApproved,
    listingRejected => l.notifListingRejected,
    listingClosed => l.notifListingClosed,
    unknown => null,
  };
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.listingId,
    this.createdAt,
  });

  factory AppNotification.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return AppNotification(
      id: readString(j, 'id') ?? '',
      type: NotificationType.fromApi(readString(j, 'type')),
      title: readString(j, 'title') ?? '',
      body: readString(j, 'body') ?? '',
      isRead: readBool(j, 'isRead') ?? false,
      listingId: readString(j, 'listingId'),
      createdAt: readDate(j, 'createdAt'),
    );
  }

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final String? listingId;
  final DateTime? createdAt;

  AppNotification asRead() => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    isRead: true,
    listingId: listingId,
    createdAt: createdAt,
  );
}
