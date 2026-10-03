import '../../../core/util/json_read.dart';

/// Trạng thái khiếu nại (`10-complaints`). Mã lạ rơi vào [unknown].
enum CaseStatus {
  open('OPEN'),
  sellerResponded('SELLER_RESPONDED'),
  escalated('ESCALATED'),
  agreed('AGREED'),
  resolved('RESOLVED'),
  unknown('');

  const CaseStatus(this.api);
  final String api;

  static CaseStatus fromApi(String? v) => values.firstWhere(
    (s) => s.api == v && s != unknown,
    orElse: () => unknown,
  );

  /// Đã kết thúc: tiền đã được thực hiện.
  bool get isFinal => this == agreed || this == resolved;
}

enum CaseReason {
  notAsDescribed('NOT_AS_DESCRIBED'),
  damaged('DAMAGED'),
  wrongItem('WRONG_ITEM'),
  other('OTHER');

  const CaseReason(this.api);
  final String api;

  static CaseReason? fromApi(String? v) {
    for (final r in values) {
      if (r.api == v) return r;
    }
    return null;
  }
}

/// Cách người bán phản hồi.
enum SellerAction {
  acceptRefund('ACCEPT_REFUND'),
  proposePartial('PROPOSE_PARTIAL'),
  reject('REJECT');

  const SellerAction(this.api);
  final String api;

  static SellerAction? fromApi(String? v) {
    for (final a in values) {
      if (a.api == v) return a;
    }
    return null;
  }
}

enum CaseOutcome {
  fullRefund('FULL_REFUND'),
  partialRefund('PARTIAL_REFUND'),
  releaseToSeller('RELEASE_TO_SELLER');

  const CaseOutcome(this.api);
  final String api;

  static CaseOutcome? fromApi(String? v) {
    for (final o in values) {
      if (o.api == v) return o;
    }
    return null;
  }
}

enum CaseEntryKind {
  opened('OPENED'),
  sellerResponse('SELLER_RESPONSE'),
  buyerDecision('BUYER_DECISION'),
  message('MESSAGE'),
  escalated('ESCALATED'),
  resolved('RESOLVED'),
  unknown('');

  const CaseEntryKind(this.api);
  final String api;

  static CaseEntryKind fromApi(String? v) => values.firstWhere(
    (k) => k.api == v && k != unknown,
    orElse: () => unknown,
  );
}

enum CaseAuthorRole {
  buyer('BUYER'),
  seller('SELLER'),
  admin('ADMIN'),
  system('SYSTEM'),
  unknown('');

  const CaseAuthorRole(this.api);
  final String api;

  static CaseAuthorRole fromApi(String? v) => values.firstWhere(
    (r) => r.api == v && r != unknown,
    orElse: () => unknown,
  );
}

/// Tệp bằng chứng. `url` có chữ ký, hết hạn sau 15 phút (`expiresAt`): dùng ngay
/// để hiển thị, không lưu lâu; tải lại khiếu nại khi hết hạn.
class CaseAttachment {
  const CaseAttachment({
    required this.id,
    required this.isVideo,
    required this.contentType,
    required this.url,
    this.sizeBytes,
    this.expiresAt,
  });

  factory CaseAttachment.fromJson(Map<dynamic, dynamic> j) {
    final type = readString(j, 'contentType') ?? '';
    final kind = readString(j, 'kind');
    return CaseAttachment(
      id: readString(j, 'id') ?? '',
      isVideo: kind == 'VIDEO' || type.startsWith('video/'),
      contentType: type,
      sizeBytes: readInt(j, 'sizeBytes'),
      url: readString(j, 'url') ?? '',
      expiresAt: readDate(j, 'expiresAt'),
    );
  }

  final String id;
  final bool isVideo;
  final String contentType;
  final int? sizeBytes;
  final String url;
  final DateTime? expiresAt;
}

class CaseEntry {
  const CaseEntry({
    required this.id,
    required this.kind,
    required this.authorRole,
    this.authorName,
    this.body,
    this.amount,
    this.attachments = const [],
    this.createdAt,
  });

  factory CaseEntry.fromJson(Map<dynamic, dynamic> j) => CaseEntry(
    id: readString(j, 'id') ?? '',
    kind: CaseEntryKind.fromApi(readString(j, 'kind')),
    authorRole: CaseAuthorRole.fromApi(readString(j, 'authorRole')),
    authorName: readString(j, 'authorName'),
    body: readString(j, 'body'),
    amount: readInt(j, 'amount'),
    attachments: [
      for (final a in readList(j, 'attachments'))
        if (a is Map<dynamic, dynamic>) CaseAttachment.fromJson(a),
    ],
    createdAt: readDate(j, 'createdAt'),
  );

  final String id;
  final CaseEntryKind kind;
  final CaseAuthorRole authorRole;
  final String? authorName;
  final String? body;

  /// Số tiền hoàn (`SELLER_RESPONSE`, `RESOLVED`).
  final int? amount;
  final List<CaseAttachment> attachments;
  final DateTime? createdAt;
}

class SellerResponse {
  const SellerResponse({
    required this.action,
    this.amount,
    this.reason,
    this.respondedAt,
  });

  factory SellerResponse.fromJson(Map<dynamic, dynamic> j) => SellerResponse(
    action: SellerAction.fromApi(readString(j, 'action')),
    amount: readInt(j, 'amount'),
    reason: readString(j, 'reason'),
    respondedAt: readDate(j, 'respondedAt'),
  );

  final SellerAction? action;
  final int? amount;
  final String? reason;
  final DateTime? respondedAt;
}

class CaseResolution {
  const CaseResolution({
    required this.outcome,
    this.refundAmount,
    this.reason,
    this.returnRequired = false,
    this.byAdmin = false,
    this.resolvedAt,
  });

  factory CaseResolution.fromJson(Map<dynamic, dynamic> j) => CaseResolution(
    outcome: CaseOutcome.fromApi(readString(j, 'outcome')),
    refundAmount: readInt(j, 'refundAmount'),
    reason: readString(j, 'reason'),
    returnRequired: readBool(j, 'returnRequired') ?? false,
    byAdmin: readBool(j, 'byAdmin') ?? false,
    resolvedAt: readDate(j, 'resolvedAt'),
  );

  final CaseOutcome? outcome;
  final int? refundAmount;
  final String? reason;

  /// Admin yêu cầu người mua gửi trả sách (thực hiện ngoài hệ thống).
  final bool returnRequired;
  final bool byAdmin;
  final DateTime? resolvedAt;
}

class CaseActions {
  const CaseActions({
    this.canRespond = false,
    this.canDecide = false,
    this.canMessage = false,
    this.canResolve = false,
  });

  factory CaseActions.fromJson(Map<dynamic, dynamic> j) => CaseActions(
    canRespond: readBool(j, 'canRespond') ?? false,
    canDecide: readBool(j, 'canDecide') ?? false,
    canMessage: readBool(j, 'canMessage') ?? false,
    canResolve: readBool(j, 'canResolve') ?? false,
  );

  final bool canRespond;
  final bool canDecide;
  final bool canMessage;
  final bool canResolve;
}

class CaseOrderRef {
  const CaseOrderRef({
    required this.id,
    required this.bookTitle,
    this.price = 0,
    this.shippingFee = 0,
    this.totalAmount = 0,
    this.deliveredAt,
  });

  factory CaseOrderRef.fromJson(Map<dynamic, dynamic> j) => CaseOrderRef(
    id: readString(j, 'id') ?? '',
    bookTitle: readString(j, 'bookTitle') ?? '',
    price: readInt(j, 'price') ?? 0,
    shippingFee: readInt(j, 'shippingFee') ?? 0,
    totalAmount: readInt(j, 'totalAmount') ?? 0,
    deliveredAt: readDate(j, 'deliveredAt'),
  );

  final String id;
  final String bookTitle;
  final int price;
  final int shippingFee;
  final int totalAmount;
  final DateTime? deliveredAt;
}

/// Khiếu nại. Dùng chung cho `ComplaintDto` và `ComplaintSummaryDto`.
class ComplaintCase {
  const ComplaintCase({
    required this.id,
    required this.status,
    this.order,
    this.reason,
    this.description,
    this.role,
    this.buyerName,
    this.sellerName,
    this.sellerDeadlineAt,
    this.buyerDeadlineAt,
    this.sellerResponse,
    this.escalationCause,
    this.resolution,
    this.actions = const CaseActions(),
    this.entries = const [],
    this.createdAt,
  });

  factory ComplaintCase.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    final order = readMap(j, 'order');
    final resp = readMap(j, 'sellerResponse');
    final res = readMap(j, 'resolution');
    final actions = readMap(j, 'actions');
    String? name(String key) {
      final m = readMap(j, key);
      return m == null ? null : readString(m, 'fullName');
    }

    // Dòng rút gọn có thể phẳng (bookTitle ở gốc) thay vì lồng trong `order`.
    final flatTitle = readString(j, 'bookTitle');
    return ComplaintCase(
      id: readString(j, 'id') ?? '',
      status: CaseStatus.fromApi(readString(j, 'status')),
      order: order != null
          ? CaseOrderRef.fromJson(order)
          : (flatTitle != null
                ? CaseOrderRef(
                    id: readString(j, 'orderId') ?? '',
                    bookTitle: flatTitle,
                  )
                : null),
      reason: CaseReason.fromApi(readString(j, 'reason')),
      description: readString(j, 'description'),
      role: readString(j, 'role'),
      buyerName: name('buyer'),
      sellerName: name('seller'),
      sellerDeadlineAt: readDate(j, 'sellerDeadlineAt'),
      buyerDeadlineAt: readDate(j, 'buyerDeadlineAt'),
      sellerResponse: resp == null ? null : SellerResponse.fromJson(resp),
      escalationCause: readString(j, 'escalationCause'),
      resolution: res == null ? null : CaseResolution.fromJson(res),
      actions: actions == null
          ? const CaseActions()
          : CaseActions.fromJson(actions),
      entries: [
        for (final e in readList(j, 'entries'))
          if (e is Map<dynamic, dynamic>) CaseEntry.fromJson(e),
      ],
      createdAt: readDate(j, 'createdAt'),
    );
  }

  final String id;
  final CaseStatus status;
  final CaseOrderRef? order;
  final CaseReason? reason;
  final String? description;

  /// `BUYER`/`SELLER`; admin là `null`.
  final String? role;
  final String? buyerName;
  final String? sellerName;
  final DateTime? sellerDeadlineAt;
  final DateTime? buyerDeadlineAt;
  final SellerResponse? sellerResponse;
  final String? escalationCause;
  final CaseResolution? resolution;
  final CaseActions actions;
  final List<CaseEntry> entries;
  final DateTime? createdAt;

  bool get isBuyer => role == 'BUYER';
  bool get isSeller => role == 'SELLER';
}
