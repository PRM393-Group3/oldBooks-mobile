export type Role = 'buyer' | 'seller' | 'inspector' | 'admin';

export type ScreenId = 
  | 'buyer_home'
  | 'auction_detail'
  | 'seller_hub'
  | 'inspector_audit'
  | 'admin_portal'
  | 'new_listing'
  | 'cart_checkout'
  | 'order_tracking';

export interface BookItem {
  id: string;
  title: string;
  author: string;
  publisher?: string;
  year?: number;
  isbn?: string;
  pages?: number;
  condition: 'Mint / Like New' | 'Very Good' | 'Good' | 'Acceptable';
  conditionNote?: string;
  grade?: string;
  price: number;
  originalPrice?: number;
  rating?: number;
  reviewCount?: number;
  coverImage: string;
  category: string;
  isAuction?: boolean;
  currentBid?: number;
  bidCount?: number;
  timeLeft?: string;
  sellerName: string;
  sellerRating?: number;
  verified?: boolean;
}

export interface CartItem {
  book: BookItem;
  quantity: number;
}

export interface BidRecord {
  id: string;
  bidder: string;
  avatarLetter: string;
  amount: number;
  timestamp: string;
  isUser?: boolean;
}

export interface InspectionCheckItem {
  id: number;
  title: string;
  description: string;
  completed: boolean;
  required?: boolean;
}

export interface DisputeCase {
  id: string;
  title: string;
  itemTitle: string;
  thumbnail: string;
  status: 'Escalated' | 'Under Review' | '72h Breach' | 'Resolved';
  escrowAmount: number;
  reporter: string;
  reporterRole: 'Buyer' | 'Seller';
  counterparty: string;
  counterpartyRole: 'Buyer' | 'Seller' | 'Suspended Seller';
  slaCountdown?: string;
  trackingNumber?: string;
  evidenceCount?: number;
  assignedInspector?: string;
  frozen?: boolean;
}

export interface UserReputation {
  id: string;
  name: string;
  email?: string;
  avatar: string;
  role: 'Inspector' | 'Seller' | 'Buyer';
  status: 'Active' | 'Suspended';
  trustScore: number;
  trustGrade: string;
  statsDescription: string;
  isHighRisk?: boolean;
}

export interface InspectorLedgerEntry {
  id: string;
  timestamp: string;
  title: string;
  inspector: string;
  grade: string;
  colophonStatus: string;
  hash: string;
}

export interface SellerListing {
  id: string;
  title: string;
  author: string;
  edition: string;
  format: 'Hardcover' | 'Paperback';
  price: number;
  priceType: 'Fixed Price' | 'Live Auction';
  status: 'WAITING FOR INSPECTOR APPROVAL' | 'REJECTED BY INSPECTOR' | 'LIVE AUCTION' | 'PUBLISHED' | 'SOLD';
  coverImage: string;
  timeAgo: string;
  extraInfo: string;
  inspectorNote?: string;
  bidsCount?: number;
  savesCount?: number;
  timeLeft?: string;
}
