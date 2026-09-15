import { IMAGES } from '../constants/assets';
import { 
  BookItem, 
  CartItem, 
  BidRecord, 
  InspectionCheckItem, 
  DisputeCase, 
  UserReputation, 
  InspectorLedgerEntry, 
  SellerListing,
  Role,
  ScreenId 
} from '../types';

export interface AppState {
  currentRole: Role;
  currentScreen: ScreenId;
  selectedBookId: string;
  cartItems: CartItem[];
  bookmarkedBookIds: string[];
  auctionCurrentBid: number;
  auctionBidsCount: number;
  userIsHighBidder: boolean;
  bidHistory: BidRecord[];
  inspectorChecklist: InspectionCheckItem[];
  inspectionApproved: boolean;
  rejectionModalOpen: boolean;
  activeSellerTab: 'All' | 'Pending' | 'Approved' | 'Rejected' | 'Sold';
  disputes: DisputeCase[];
  selectedDelivery: 'standard' | 'express';
  selectedPayment: 'apple_pay' | 'card' | 'wallet';
  promoDiscount: number;
  promoCodeInput: string;
  toastMessage: string | null;
  zoomImage: { title: string; url: string; note: string } | null;
  drawerOpen: boolean;
}

export const INITIAL_RECOMMENDED_BOOKS: BookItem[] = [
  {
    id: 'atomic-habits',
    title: 'Atomic Habits',
    author: 'James Clear',
    condition: 'Mint / Like New',
    price: 12.50,
    originalPrice: 27.00,
    rating: 4.9,
    reviewCount: 128,
    coverImage: IMAGES.atomicHabits,
    category: 'Business',
    sellerName: 'AlexBooks',
    verified: true
  },
  {
    id: 'designing-data',
    title: 'Designing Data-Intensive',
    author: 'Martin Kleppmann',
    condition: 'Good',
    price: 28.00,
    rating: 5.0,
    reviewCount: 42,
    coverImage: IMAGES.designingData,
    category: 'Technology',
    sellerName: 'TechTome Hub',
    verified: true
  },
  {
    id: 'great-gatsby',
    title: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    condition: 'Acceptable',
    price: 6.00,
    rating: 4.7,
    reviewCount: 95,
    coverImage: IMAGES.greatGatsby,
    category: 'Fiction',
    sellerName: 'VintageBookCo',
    verified: true
  }
];

export const INITIAL_AUCTIONS: BookItem[] = [
  {
    id: 'dune-1965',
    title: 'Dune (1965 1st Edition)',
    author: 'Book Club • Frank Herbert',
    condition: 'Very Good',
    price: 165.00,
    isAuction: true,
    currentBid: 165.00,
    bidCount: 24,
    timeLeft: '01h 48m left',
    coverImage: IMAGES.duneAuction,
    category: 'Sci-Fi',
    sellerName: 'RareTome Vault',
    verified: true
  },
  {
    id: 'clean-code-signed',
    title: 'Clean Code: Handbook',
    author: 'Signed Copy • Robert C. Martin',
    condition: 'Very Good',
    price: 42.00,
    isAuction: true,
    currentBid: 42.00,
    bidCount: 9,
    timeLeft: '45m left',
    coverImage: IMAGES.cleanCode,
    category: 'Technology',
    sellerName: 'CodeVault',
    verified: true
  }
];

export const INITIAL_SELLER_LISTINGS: SellerListing[] = [
  {
    id: 'neuromancer-draft',
    title: 'Neuromancer',
    author: 'by William Gibson',
    edition: 'Ace Science Fiction 1984',
    format: 'Paperback',
    price: 18.00,
    priceType: 'Fixed Price',
    status: 'WAITING FOR INSPECTOR APPROVAL',
    coverImage: IMAGES.neuromancer,
    timeAgo: '3h ago',
    extraInfo: 'Queue Position: #3 in Brooklyn'
  },
  {
    id: 'sapiens-rejected',
    title: 'Sapiens: A Brief History of Humankind',
    author: 'by Yuval Noah Harari',
    edition: 'Harper 1st US Edition',
    format: 'Hardcover',
    price: 22.00,
    priceType: 'Fixed Price',
    status: 'REJECTED BY INSPECTOR',
    coverImage: IMAGES.sapiens,
    timeAgo: 'Yesterday',
    extraInfo: 'Action Needed',
    inspectorNote: 'Book condition does not match uploaded photos (creased cover). Click to edit & resubmit.'
  },
  {
    id: 'pragmatic-programmer-auction',
    title: 'The Pragmatic Programmer (20th Anniv)',
    author: 'by David Thomas & Andrew Hunt',
    edition: 'Addison-Wesley 2019',
    format: 'Hardcover',
    price: 46.00,
    priceType: 'Live Auction',
    status: 'LIVE AUCTION',
    coverImage: IMAGES.pragmaticProgrammer,
    timeAgo: '4h left',
    extraInfo: 'Reserve Price Met ($30.00)',
    bidsCount: 12,
    timeLeft: 'Ends in 4h 18m'
  },
  {
    id: 'algorithms-published',
    title: 'Introduction to Algorithms (CLRS 3rd Ed)',
    author: 'by Cormen, Leiserson, Rivest, Stein',
    edition: 'MIT Press 2009',
    format: 'Hardcover',
    price: 55.00,
    priceType: 'Fixed Price',
    status: 'PUBLISHED',
    coverImage: IMAGES.introAlgorithms,
    timeAgo: 'Listed 4 days ago',
    extraInfo: 'Grade 9.0 Near Mint',
    savesCount: 6
  }
];

export const INITIAL_DISPUTES: DisputeCase[] = [
  {
    id: 'DSP-904',
    title: 'Item Not as Described - First Edition Fake',
    itemTitle: "The Great Gatsby (1925 Scribner's A-Tree Colophon)",
    thumbnail: IMAGES.disputeGatsby,
    status: 'Escalated',
    escrowAmount: 4250.00,
    reporter: 'Dr. Julian Sterling',
    reporterRole: 'Buyer',
    counterparty: 'RareManuscripts_UK',
    counterpartyRole: 'Seller',
    slaCountdown: '03h 42m remaining',
    evidenceCount: 4,
    assignedInspector: 'Alexander Vance',
    frozen: false
  },
  {
    id: 'DSP-899',
    title: 'Damaged Spine in Transit',
    itemTitle: 'Dune (1965 Chilton First Edition, Signed)',
    thumbnail: IMAGES.disputeDune,
    status: 'Under Review',
    escrowAmount: 860.00,
    reporter: 'Evelyn Reed',
    reporterRole: 'Buyer',
    counterparty: 'ArchivalBooksNYC',
    counterpartyRole: 'Seller',
    trackingNumber: 'FedEx Express #7489211',
    evidenceCount: 3,
    frozen: false
  },
  {
    id: 'DSP-882',
    title: 'Late Shipment - Seller Unresponsive',
    itemTitle: "Curtis's Botanical Magazine Folio (1812)",
    thumbnail: IMAGES.disputeCurtis,
    status: '72h Breach',
    escrowAmount: 340.00,
    reporter: 'Marcus H. Holloway',
    reporterRole: 'Buyer',
    counterparty: 'OldeWorldPrintworks',
    counterpartyRole: 'Suspended Seller',
    slaCountdown: 'Auto-Cancellation in 4 hours',
    frozen: true
  }
];

export const INITIAL_USERS: UserReputation[] = [
  {
    id: 'USR-219',
    name: 'Clara Rosenthal',
    avatar: IMAGES.claraRosenthal,
    role: 'Inspector',
    status: 'Active',
    trustScore: 99.4,
    trustGrade: 'Grade A+',
    statsDescription: '842 Successful Condition Ledger Certifications'
  },
  {
    id: 'USR-841',
    name: 'Marcus Holloway',
    avatar: IMAGES.marcusHolloway,
    role: 'Seller',
    status: 'Active',
    trustScore: 98.0,
    trustGrade: 'Verified',
    statsDescription: '$42,900 Total Escrow Volume Completed'
  },
  {
    id: 'USR-007',
    name: 'Anonymous_Bidder_7',
    avatar: IMAGES.anonymousBidder,
    role: 'Buyer',
    status: 'Suspended',
    trustScore: 42.1,
    trustGrade: 'High Risk',
    statsDescription: '3 Unpaid Auction Bids & Chargeback Flags',
    isHighRisk: true
  }
];

export const INITIAL_CHECKLIST: InspectionCheckItem[] = [
  {
    id: 1,
    title: '1. Book condition strictly matches uploaded description & photos',
    description: 'No undocumented foxing, dog-ears, or spine tears identified.',
    completed: true
  },
  {
    id: 2,
    title: '2. Cover, spine, and binding integrity verified',
    description: 'Binding glue intact, textbook opens flat without leaf separation.',
    completed: true
  },
  {
    id: 3,
    title: '3. ISBN (978-0262510875) authenticated against publisher database',
    description: 'Matched: MIT Press 1996 Second Edition Softcover entry #8824-A.',
    completed: true
  },
  {
    id: 4,
    title: '4. All uploaded photographs are authentic and high clarity',
    description: 'EXIF metadata verifies raw device capture with no synthetic generative artifacts.',
    completed: true
  },
  {
    id: 5,
    title: '5. Zero prohibited, pirated, or counterfeit material detected',
    description: 'Paper weight (80gsm) and watermark align with MIT standard runs.',
    completed: true
  },
  {
    id: 6,
    title: '6. Pricing and auction parameters comply with marketplace guidelines',
    description: 'Reserve price ($75.00) sits within 1.9x standard starting bid ceiling ($40.00).',
    completed: false,
    required: true
  }
];

export const INITIAL_LEDGER: InspectorLedgerEntry[] = [
  {
    id: 'l1',
    timestamp: '14:22:09 UTC',
    title: 'Hobbit (1937 1st Edition 1st Impression)',
    inspector: 'Clara Rosenthal (Lead)',
    grade: 'Grade 9.4 - Near Mint',
    colophonStatus: 'Authentic Run',
    hash: '0x89F4...A12B'
  },
  {
    id: 'l2',
    timestamp: '14:18:45 UTC',
    title: 'Frankenstein (1818 Lacking Half-Titles)',
    inspector: 'Alexander Vance',
    grade: 'Grade 7.8 - Fine',
    colophonStatus: 'Spine Rebacked',
    hash: '0x33EC...99FD'
  },
  {
    id: 'l3',
    timestamp: '14:02:11 UTC',
    title: 'Alice in Wonderland (1866 Second Ed.)',
    inspector: 'Julian Sterling',
    grade: 'Grade 8.9 - Very Fine',
    colophonStatus: 'Tenniel Plates Intact',
    hash: '0x55FA...210C'
  }
];

export const INITIAL_BID_HISTORY: BidRecord[] = [
  { id: 'b1', bidder: 'Alexander', avatarLetter: 'A', amount: 165.00, timestamp: '2m ago', isUser: true },
  { id: 'b2', bidder: 'Sarah_K', avatarLetter: 'S', amount: 160.00, timestamp: '8m ago' },
  { id: 'b3', bidder: 'bookworm99', avatarLetter: 'B', amount: 150.00, timestamp: '15m ago' }
];

export const INITIAL_CART: CartItem[] = [
  {
    book: {
      id: 'designing-data',
      title: 'Designing Data-Intensive Applications',
      author: 'Martin Kleppmann',
      condition: 'Good',
      price: 28.00,
      coverImage: IMAGES.designingDataCart,
      category: 'Technology',
      sellerName: 'TechTome Hub',
      grade: '8.0'
    },
    quantity: 1
  },
  {
    book: {
      id: 'atomic-habits',
      title: 'Atomic Habits',
      author: 'James Clear',
      condition: 'Mint / Like New',
      price: 12.50,
      coverImage: IMAGES.atomicHabitsCart,
      category: 'Business',
      sellerName: 'AlexBooks',
      verified: true
    },
    quantity: 1
  }
];
