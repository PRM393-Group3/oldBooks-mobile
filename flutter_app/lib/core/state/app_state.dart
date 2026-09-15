import 'package:flutter/material.dart';
import '../models/all_models.dart';
import '../constants/assets.dart';

class AppState extends ChangeNotifier {
  AppRole _currentRole = AppRole.buyer;
  AppScreen _currentScreen = AppScreen.buyerHome;

  // Cart
  final List<CartItem> _cartItems = [];

  // Auction State
  double _currentHighBid = 165.00;
  int _bidsCount = 24;
  bool _userIsHighBidder = true;
  final List<BidRecord> _bidHistory = [
    BidRecord(
      id: 'b1',
      bidderName: 'Alexander (You)',
      bidderAvatar: AppAssets.alexanderAvatar,
      amount: 165.00,
      timeAgo: '2m ago',
      isLeading: true,
    ),
    BidRecord(
      id: 'b2',
      bidderName: 'Marcus V.',
      bidderAvatar: AppAssets.marcusAvatar,
      amount: 155.00,
      timeAgo: '14m ago',
    ),
    BidRecord(
      id: 'b3',
      bidderName: 'Sarah J.',
      bidderAvatar: AppAssets.sarahAvatar,
      amount: 140.00,
      timeAgo: '1h ago',
    ),
  ];

  // Seller Listings
  final List<SellerListing> _sellerListings = [
    SellerListing(
      id: 'lst-01',
      title: 'Dune (1965 First Chilton Edition)',
      author: 'Frank Herbert • Chilton Books',
      edition: '1st Edition, 1st Printing',
      format: 'Hardcover with DJ',
      price: 165.00,
      priceType: 'Live Auction',
      status: 'APPROVED & LIVE',
      coverImage: AppAssets.duneCover,
      timeAgo: '2h 14m left',
      extraInfo: '24 Bids • Reserve Met',
    ),
    SellerListing(
      id: 'lst-02',
      title: 'Structure & Interpretation of Computer Programs (SICP)',
      author: 'Abelson & Sussman • MIT Press',
      edition: '2nd Edition (1996)',
      format: 'Paperback',
      price: 40.00,
      priceType: 'Auction (\$40 / \$75)',
      status: 'WAITING FOR INSPECTOR APPROVAL',
      coverImage: AppAssets.sicpFront,
      timeAgo: 'Submitted 45m ago',
      extraInfo: 'Queue #1 in Brooklyn Facility',
    ),
    SellerListing(
      id: 'lst-03',
      title: 'The Lord of the Rings (1954 1st Deluxe Set)',
      author: 'J.R.R. Tolkien • George Allen & Unwin',
      edition: 'Deluxe India Paper Edition',
      format: 'Full Black Leather Buckram',
      price: 240.00,
      priceType: 'Fixed Price',
      status: 'REJECTED_AUDIT',
      coverImage: AppAssets.lordOfTheRingsCover,
      timeAgo: 'Audited yesterday',
      extraInfo: 'Defect: Binding split on page 412',
      rejectionReason: 'Physical condition differs from submitted photographs',
      inspectorNotes: 'Fold-out map contains a 2cm tear along fold hinge. Re-photograph and adjust grade.',
    ),
  ];

  // Inspection Checklist
  final List<InspectionCheckItem> _checklist = [
    InspectionCheckItem(
      id: 1,
      title: '1. Cover & Gutter Hinge Integrity',
      description: 'Zero unauthorized tape, clear laminate adhesion, corner tips sharp.',
      completed: true,
    ),
    InspectionCheckItem(
      id: 2,
      title: '2. Spine Squareness & Hot-Melt Binding',
      description: 'Check for concave spine curvature and PUR adhesive page detachment.',
      completed: true,
    ),
    InspectionCheckItem(
      id: 3,
      title: '3. First Edition Colophon Verification',
      description: 'Check print number line "10 9 8 7 6 5 4 3 2 1" and copyright date.',
      completed: true,
    ),
    InspectionCheckItem(
      id: 4,
      title: '4. Text Block Foxing & Tanning Inspection',
      description: 'Page edges free of mold, moisture undulation, and heavy foxing.',
      completed: true,
    ),
    InspectionCheckItem(
      id: 5,
      title: '5. Barcode & ISBN-13 Integrity',
      description: 'Back cover UPC barcode resolves to canonical publisher registry.',
      completed: true,
    ),
    InspectionCheckItem(
      id: 6,
      title: '6. Reserve Price & Valuation Fair Market Check',
      description: 'Assessed value conforms to recent certified auction comp indices.',
      completed: true,
    ),
  ];

  // Admin Disputes
  final List<DisputeCase> _disputes = [
    DisputeCase(
      id: 'DSP-8821',
      title: 'Spine split not disclosed on vintage paperback',
      itemTitle: 'Neuromancer (1984 1st Ace Edition)',
      reporter: 'Julian Hayes',
      reporterRole: 'Buyer',
      counterparty: 'VintageVault NY',
      counterpartyRole: 'Seller',
      escrowAmount: 65.00,
      status: 'Escrow Frozen',
      frozen: true,
      thumbnail: AppAssets.neuromancerCover,
      slaCountdown: '4h 12m left',
    ),
    DisputeCase(
      id: 'DSP-8824',
      title: 'Missing foldout map in Volume 1',
      itemTitle: 'The Fellowship of the Ring (1966 2nd Ed)',
      reporter: 'Elena Rostova',
      reporterRole: 'Buyer',
      counterparty: 'Antiquarian Brook',
      counterpartyRole: 'Seller',
      escrowAmount: 110.00,
      status: 'Under Evidence Review',
      frozen: false,
      thumbnail: AppAssets.lordOfTheRingsCover,
      slaCountdown: '11h 40m left',
    ),
  ];

  // Admin Users
  final List<UserReputation> _users = [
    UserReputation(
      id: 'usr-1',
      name: 'Alexander Vance',
      avatar: AppAssets.alexanderAvatar,
      role: 'Top Rated Buyer / Collector',
      trustScore: 99,
      trustGrade: 'AAA+ Sovereign',
      statsDescription: '48 verified transactions • 0 disputes filed',
    ),
    UserReputation(
      id: 'usr-2',
      name: 'RareBookCellar NY',
      avatar: AppAssets.marcusAvatar,
      role: 'Certified Gold Seller',
      trustScore: 98,
      trustGrade: 'AA+ Premier',
      statsDescription: '412 sales • 99.1% condition match',
    ),
    UserReputation(
      id: 'usr-3',
      name: 'BookBargains_US',
      avatar: AppAssets.davidAvatar,
      role: 'Probationary Seller',
      trustScore: 42,
      trustGrade: 'Flagged - High Risk',
      statsDescription: '4 disputes in 14 days • Condition mismatches',
      isHighRisk: true,
    ),
  ];

  // Ledger stream
  final List<InspectorLedgerEntry> _ledgerStream = [
    InspectorLedgerEntry(
      id: 'led-1',
      hash: '0x8a92f03b...1104e792',
      title: 'Structure & Interpretation of Computer Programs (SICP)',
      inspector: '#INSP-402 (Alexander V.)',
      grade: 'Grade 9.4 Mint',
      timestamp: '2 mins ago',
    ),
    InspectorLedgerEntry(
      id: 'led-2',
      hash: '0x3c41ea99...87bf1024',
      title: 'Dune (1965 First Chilton Edition)',
      inspector: '#INSP-109 (Marcus S.)',
      grade: 'Grade 9.2 Fine',
      timestamp: '18 mins ago',
    ),
  ];

  // Recommended Books
  final List<BookItem> _recommendedBooks = [
    BookItem(
      id: 'dune-1965',
      title: 'Dune (1965 First Chilton Edition)',
      author: 'Frank Herbert • Chilton Books',
      edition: '1st Edition, 1st Printing',
      format: 'Hardcover with DJ',
      price: 165.00,
      condition: 'Fine / Grade 9.2',
      coverImage: AppAssets.duneCover,
      isAuction: true,
      currentBid: 165.00,
      bidsCount: 24,
      timeLeft: '2h 14m left',
      sellerRating: 4.9,
      sellerReviews: 120,
    ),
    BookItem(
      id: 'clean-code-signed',
      title: 'Clean Code: A Handbook of Agile Craft',
      author: 'Robert C. Martin • Prentice Hall',
      edition: '1st Edition (Signed)',
      format: 'Paperback',
      price: 85.00,
      condition: 'Very Good / Grade 8.8',
      coverImage: AppAssets.cleanCodeCover,
      isAuction: true,
      currentBid: 85.00,
      bidsCount: 16,
      timeLeft: '4h 50m left',
      sellerRating: 5.0,
      sellerReviews: 84,
    ),
    BookItem(
      id: 'lotr-1954',
      title: 'The Lord of the Rings (3-Volume Deluxe Set)',
      author: 'J.R.R. Tolkien • George Allen & Unwin',
      edition: 'Deluxe India Paper Edition (1969)',
      format: 'Leather Buckram in Slipcase',
      price: 240.00,
      condition: 'Near Mint / Grade 9.6',
      coverImage: AppAssets.lordOfTheRingsCover,
      sellerRating: 4.9,
      sellerReviews: 210,
    ),
    BookItem(
      id: '1984-orwell',
      title: 'Nineteen Eighty-Four (1984)',
      author: 'George Orwell • Secker & Warburg',
      edition: 'Collector Hardcover',
      format: 'Clothbound Hardcover',
      price: 95.00,
      condition: 'Very Good / Grade 8.5',
      coverImage: AppAssets.nineteenEightyFourCover,
      sellerRating: 4.8,
      sellerReviews: 95,
    ),
    BookItem(
      id: 'design-things',
      title: 'The Design of Everyday Things',
      author: 'Don Norman • Basic Books',
      edition: 'Revised and Expanded Edition',
      format: 'Paperback',
      price: 32.00,
      condition: 'Fine / Grade 9.0',
      coverImage: AppAssets.designOfEverydayThings,
      sellerRating: 4.9,
      sellerReviews: 68,
    ),
    BookItem(
      id: 'left-hand-darkness',
      title: 'The Left Hand of Darkness',
      author: 'Ursula K. Le Guin • Ace Books',
      edition: '1st Ace Edition 1969',
      format: 'Paperback',
      price: 42.00,
      condition: 'Very Good / Grade 8.5',
      coverImage: AppAssets.leftHandOfDarkness,
      sellerRating: 5.0,
      sellerReviews: 142,
    ),
  ];

  // Getters
  AppRole get currentRole => _currentRole;
  AppScreen get currentScreen => _currentScreen;
  List<CartItem> get cartItems => _cartItems;
  double get currentHighBid => _currentHighBid;
  int get bidsCount => _bidsCount;
  bool get userIsHighBidder => _userIsHighBidder;
  List<BidRecord> get bidHistory => _bidHistory;
  List<SellerListing> get sellerListings => _sellerListings;
  List<InspectionCheckItem> get checklist => _checklist;
  List<DisputeCase> get disputes => _disputes;
  List<UserReputation> get users => _users;
  List<InspectorLedgerEntry> get ledgerStream => _ledgerStream;
  List<BookItem> get recommendedBooks => _recommendedBooks;

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartSubtotal => _cartItems.fold(0, (sum, item) => sum + (item.book.price * item.quantity));

  // Navigation
  void navigateTo(AppScreen screen, {AppRole? role}) {
    _currentScreen = screen;
    if (role != null) {
      _currentRole = role;
    } else {
      if (screen == AppScreen.buyerHome ||
          screen == AppScreen.auctionDetail ||
          screen == AppScreen.cartCheckout ||
          screen == AppScreen.orderTracking) {
        _currentRole = AppRole.buyer;
      } else if (screen == AppScreen.sellerHub || screen == AppScreen.newListing) {
        _currentRole = AppRole.seller;
      } else if (screen == AppScreen.inspectorAudit) {
        _currentRole = AppRole.inspector;
      } else if (screen == AppScreen.adminPortal) {
        _currentRole = AppRole.admin;
      }
    }
    notifyListeners();
  }

  void setRole(AppRole role) {
    _currentRole = role;
    if (role == AppRole.buyer) _currentScreen = AppScreen.buyerHome;
    if (role == AppRole.seller) _currentScreen = AppScreen.sellerHub;
    if (role == AppRole.inspector) _currentScreen = AppScreen.inspectorAudit;
    if (role == AppRole.admin) _currentScreen = AppScreen.adminPortal;
    notifyListeners();
  }

  // Cart Operations
  void addToCart(BookItem book) {
    final index = _cartItems.indexWhere((item) => item.book.id == book.id);
    if (index >= 0) {
      _cartItems[index].quantity += 1;
    } else {
      _cartItems.add(CartItem(book: book, quantity: 1));
    }
    notifyListeners();
  }

  void updateCartQuantity(String bookId, int delta) {
    final index = _cartItems.indexWhere((item) => item.book.id == bookId);
    if (index >= 0) {
      final newQty = _cartItems[index].quantity + delta;
      if (newQty > 0) {
        _cartItems[index].quantity = newQty;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String bookId) {
    _cartItems.removeWhere((item) => item.book.id == bookId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Auction Bidding
  void placeBid(double amount) {
    _currentHighBid = amount;
    _bidsCount += 1;
    _userIsHighBidder = true;
    _bidHistory.insert(
      0,
      BidRecord(
        id: 'bid-${DateTime.now().millisecondsSinceEpoch}',
        bidderName: 'Alexander (You)',
        bidderAvatar: AppAssets.alexanderAvatar,
        amount: amount,
        timeAgo: 'Just now',
        isLeading: true,
      ),
    );
    notifyListeners();
  }

  // Inspector Checklist
  void toggleChecklistItem(int id) {
    final index = _checklist.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _checklist[index].completed = !_checklist[index].completed;
      notifyListeners();
    }
  }

  void approveInspection() {
    for (var item in _checklist) {
      item.completed = true;
    }
    _ledgerStream.insert(
      0,
      InspectorLedgerEntry(
        id: 'led-${DateTime.now().millisecondsSinceEpoch}',
        hash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}...cert',
        title: 'Structure & Interpretation of Computer Programs (SICP)',
        inspector: '#INSP-402 (Alexander V.)',
        grade: 'Grade 9.4 Mint',
        timestamp: 'Just now',
      ),
    );
    notifyListeners();
  }

  // Seller Listing
  void addListing(SellerListing listing) {
    _sellerListings.insert(0, listing);
    notifyListeners();
  }

  // Admin Actions
  void toggleFreezeEscrow(String disputeId) {
    final index = _disputes.indexWhere((d) => d.id == disputeId);
    if (index >= 0) {
      _disputes[index].frozen = !_disputes[index].frozen;
      _disputes[index].status = _disputes[index].frozen ? 'Escrow Frozen' : 'Under Review';
      notifyListeners();
    }
  }

  void resolveDispute(String disputeId) {
    final index = _disputes.indexWhere((d) => d.id == disputeId);
    if (index >= 0) {
      _disputes[index].status = 'Resolved & Refunded';
      notifyListeners();
    }
  }
}
