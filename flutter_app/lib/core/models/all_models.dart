enum AppRole { buyer, seller, inspector, admin }

enum AppScreen {
  buyerHome,
  auctionDetail,
  sellerHub,
  newListing,
  inspectorAudit,
  adminPortal,
  cartCheckout,
  orderTracking,
}

class BookItem {
  final String id;
  final String title;
  final String author;
  final String edition;
  final String format;
  final double price;
  final String condition;
  final String coverImage;
  final bool isAuction;
  final double? currentBid;
  final int? bidsCount;
  final String? timeLeft;
  final double sellerRating;
  final int sellerReviews;
  final String? inspectorSeal;

  BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.edition,
    required this.format,
    required this.price,
    required this.condition,
    required this.coverImage,
    this.isAuction = false,
    this.currentBid,
    this.bidsCount,
    this.timeLeft,
    this.sellerRating = 4.9,
    this.sellerReviews = 120,
    this.inspectorSeal = 'Verified 9.2 Fine',
  });
}

class CartItem {
  final BookItem book;
  int quantity;

  CartItem({required this.book, this.quantity = 1});
}

class BidRecord {
  final String id;
  final String bidderName;
  final String bidderAvatar;
  final double amount;
  final String timeAgo;
  final bool isLeading;

  BidRecord({
    required this.id,
    required this.bidderName,
    required this.bidderAvatar,
    required this.amount,
    required this.timeAgo,
    this.isLeading = false,
  });
}

class SellerListing {
  final String id;
  final String title;
  final String author;
  final String edition;
  final String format;
  final double price;
  final String priceType;
  String status; // 'APPROVED & LIVE', 'WAITING FOR INSPECTOR APPROVAL', 'REJECTED_AUDIT', 'SOLD'
  final String coverImage;
  final String timeAgo;
  final String extraInfo;
  final String? rejectionReason;
  final String? inspectorNotes;

  SellerListing({
    required this.id,
    required this.title,
    required this.author,
    required this.edition,
    required this.format,
    required this.price,
    required this.priceType,
    required this.status,
    required this.coverImage,
    required this.timeAgo,
    required this.extraInfo,
    this.rejectionReason,
    this.inspectorNotes,
  });
}

class InspectionCheckItem {
  final int id;
  final String title;
  final String description;
  bool completed;
  final bool required;

  InspectionCheckItem({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
    this.required = true,
  });
}

class DisputeCase {
  final String id;
  final String title;
  final String itemTitle;
  final String reporter;
  final String reporterRole;
  final String counterparty;
  final String counterpartyRole;
  final double escrowAmount;
  String status;
  bool frozen;
  final String thumbnail;
  final String? slaCountdown;

  DisputeCase({
    required this.id,
    required this.title,
    required this.itemTitle,
    required this.reporter,
    required this.reporterRole,
    required this.counterparty,
    required this.counterpartyRole,
    required this.escrowAmount,
    required this.status,
    this.frozen = false,
    required this.thumbnail,
    this.slaCountdown,
  });
}

class UserReputation {
  final String id;
  final String name;
  final String avatar;
  final String role;
  final int trustScore;
  final String trustGrade;
  final String statsDescription;
  final bool isHighRisk;

  UserReputation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.role,
    required this.trustScore,
    required this.trustGrade,
    required this.statsDescription,
    this.isHighRisk = false,
  });
}

class InspectorLedgerEntry {
  final String id;
  final String hash;
  final String title;
  final String inspector;
  final String grade;
  final String timestamp;

  InspectorLedgerEntry({
    required this.id,
    required this.hash,
    required this.title,
    required this.inspector,
    required this.grade,
    required this.timestamp,
  });
}
