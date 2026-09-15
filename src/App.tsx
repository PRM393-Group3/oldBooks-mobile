import React, { useState, useEffect } from 'react';
import { Role, ScreenId, BookItem, CartItem, SellerListing, DisputeCase, InspectionCheckItem, BidRecord } from './core/types';
import { 
  INITIAL_CART, 
  INITIAL_SELLER_LISTINGS, 
  INITIAL_DISPUTES, 
  INITIAL_USERS, 
  INITIAL_CHECKLIST, 
  INITIAL_LEDGER, 
  INITIAL_BID_HISTORY 
} from './core/storage/marketplace_store';
import { auctionRepository } from './features/auction/data/auction_repository';
import { sellerRepository } from './features/seller/data/seller_repository';
import { inspectorRepository } from './features/inspector/data/inspector_repository';
import { adminRepository } from './features/admin/data/admin_repository';
import { cartRepository } from './features/cart/data/cart_repository';

// Components
import { ScreenSwitcherPill } from './features/common/ScreenSwitcherPill';
import { RoleSwitchDrawer } from './features/common/RoleSwitchDrawer';
import { BottomNavBar } from './features/common/BottomNavBar';
import { ImageViewerModal } from './features/common/ImageViewerModal';

// Screens
import { BuyerHomeScreen } from './features/marketplace/presentation/BuyerHomeScreen';
import { LiveAuctionDetailScreen } from './features/auction/presentation/LiveAuctionDetailScreen';
import { SellerHubScreen } from './features/seller/presentation/SellerHubScreen';
import { InspectorAuditScreen } from './features/inspector/presentation/InspectorAuditScreen';
import { AdminPortalScreen } from './features/admin/presentation/AdminPortalScreen';
import { NewBookListingScreen } from './features/seller/presentation/NewBookListingScreen';
import { CartCheckoutScreen } from './features/cart/presentation/CartCheckoutScreen';
import { OrderTrackingScreen } from './features/order/presentation/OrderTrackingScreen';

export default function App() {
  const [currentRole, setCurrentRole] = useState<Role>('buyer');
  const [currentScreen, setCurrentScreen] = useState<ScreenId>('buyer_home');
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [zoomImage, setZoomImage] = useState<{ title: string; url: string; note: string } | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  // Cart state
  const [cartItems, setCartItems] = useState<CartItem[]>(INITIAL_CART);

  // Auction state
  const [currentHighBid, setCurrentHighBid] = useState<number>(165.00);
  const [bidsCount, setBidsCount] = useState<number>(24);
  const [userIsHighBidder, setUserIsHighBidder] = useState<boolean>(true);
  const [bidHistory, setBidHistory] = useState<BidRecord[]>(INITIAL_BID_HISTORY);

  // Seller listings state
  const [sellerListings, setSellerListings] = useState<SellerListing[]>(INITIAL_SELLER_LISTINGS);

  // Inspector state
  const [checklist, setChecklist] = useState<InspectionCheckItem[]>(INITIAL_CHECKLIST);

  // Admin state
  const [disputes, setDisputes] = useState<DisputeCase[]>(INITIAL_DISPUTES);
  const [users] = useState(INITIAL_USERS);
  const [ledgerStream] = useState(INITIAL_LEDGER);

  // Trigger floating toast
  const showToast = (message: string) => {
    setToast(message);
    setTimeout(() => {
      setToast(null);
    }, 3500);
  };

  // Switch role and optional screen
  const handleSelectRole = (role: Role, targetScreen?: ScreenId) => {
    setCurrentRole(role);
    if (targetScreen) {
      setCurrentScreen(targetScreen);
    } else {
      if (role === 'buyer') setCurrentScreen('buyer_home');
      else if (role === 'seller') setCurrentScreen('seller_hub');
      else if (role === 'inspector') setCurrentScreen('inspector_audit');
      else if (role === 'admin') setCurrentScreen('admin_portal');
    }
  };

  // Direct navigation
  const handleNavigate = (screen: ScreenId, role?: Role) => {
    setCurrentScreen(screen);
    if (role) {
      setCurrentRole(role);
    } else {
      if (screen === 'buyer_home' || screen === 'auction_detail' || screen === 'cart_checkout' || screen === 'order_tracking') {
        setCurrentRole('buyer');
      } else if (screen === 'seller_hub' || screen === 'new_listing') {
        setCurrentRole('seller');
      } else if (screen === 'inspector_audit') {
        setCurrentRole('inspector');
      } else if (screen === 'admin_portal') {
        setCurrentRole('admin');
      }
    }
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Cart operations
  const handleAddToCart = (book: BookItem) => {
    setCartItems((prev) => {
      const existing = prev.find((item) => item.book.id === book.id);
      if (existing) {
        return prev.map((item) =>
          item.book.id === book.id ? { ...item, quantity: item.quantity + 1 } : item
        );
      }
      return [...prev, { book, quantity: 1 }];
    });
    showToast(`Added "${book.title}" to cart!`);
  };

  const handleUpdateQuantity = (bookId: string, delta: number) => {
    setCartItems((prev) =>
      prev
        .map((item) => {
          if (item.book.id === bookId) {
            const newQty = item.quantity + delta;
            return newQty > 0 ? { ...item, quantity: newQty } : null;
          }
          return item;
        })
        .filter(Boolean) as CartItem[]
    );
  };

  const handleRemoveItem = (bookId: string) => {
    setCartItems((prev) => prev.filter((item) => item.book.id !== bookId));
    showToast('Item removed from cart.');
  };

  // Auction Bidding
  const handlePlaceBid = async (amount: number) => {
    try {
      const res = await auctionRepository.placeBid('dune-1965', amount, 'Alexander');
      if (res.success) {
        setCurrentHighBid(amount);
        setBidsCount((prev) => prev + 1);
        setUserIsHighBidder(true);
        setBidHistory((prev) => [res.newBid, ...prev]);
        showToast(`Bid of $${amount.toFixed(2)} confirmed! You are currently the highest bidder.`);
      }
    } catch (err: any) {
      showToast(err.message || 'Failed to place bid.');
    }
  };

  // Inspector actions
  const handleToggleChecklist = (id: number) => {
    setChecklist((prev) =>
      prev.map((item) => (item.id === id ? { ...item, completed: !item.completed } : item))
    );
  };

  const handleApproveInspection = async () => {
    try {
      const res = await inspectorRepository.approveListing('419-MIT');
      showToast(`Audit Approved! Certificate ${res.certificateId} anchored to Escrow Ledger.`);
      // Update checklist
      setChecklist((prev) => prev.map((c) => ({ ...c, completed: true })));
    } catch (err: any) {
      showToast(err.message || 'Failed to approve listing.');
    }
  };

  const handleRejectInspection = async (reason: string, notes: string) => {
    try {
      await inspectorRepository.rejectListing('419-MIT', reason, notes);
      showToast('Listing rejected and routed to Seller Remediation Queue.');
    } catch (err: any) {
      showToast(err.message || 'Failed to record rejection.');
    }
  };

  // Seller submission
  const handleSubmitListing = async (newListingData: Partial<SellerListing>) => {
    try {
      const created = await sellerRepository.createListing(newListingData);
      setSellerListings((prev) => [created, ...prev]);
      showToast(`Listing "${created.title}" submitted to Brooklyn Inspection Queue.`);
    } catch (err: any) {
      showToast(err.message || 'Error submitting listing.');
    }
  };

  // Admin actions
  const handleFreezeEscrow = async (disputeId: string) => {
    try {
      await adminRepository.freezeEscrow(disputeId);
      setDisputes((prev) =>
        prev.map((d) => (d.id === disputeId ? { ...d, frozen: !d.frozen } : d))
      );
      showToast(`Escrow state updated for Dispute #${disputeId}.`);
    } catch (err: any) {
      showToast(err.message || 'Failed to freeze escrow.');
    }
  };

  const handleRefundDispute = (disputeId: string) => {
    setDisputes((prev) =>
      prev.map((d) => (d.id === disputeId ? { ...d, status: 'Resolved' } : d))
    );
    showToast(`Dispute #${disputeId} resolved and buyer escrow refunded.`);
  };

  // Checkout submission
  const handlePlaceOrder = async (total: number) => {
    try {
      await cartRepository.placeOrder({ total, items: cartItems });
      showToast(`Order #BK-9082 placed with $${total.toFixed(2)} deposited into Escrow!`);
      // Clear cart
      setCartItems([]);
      // Navigate to order tracking
      handleNavigate('order_tracking', 'buyer');
    } catch (err: any) {
      showToast(err.message || 'Failed to place order.');
    }
  };

  const totalCartCount = cartItems.reduce((acc, i) => acc + i.quantity, 0);

  return (
    <div className="min-h-screen bg-surface font-sans text-on-surface flex flex-col relative antialiased selection:bg-secondary-fixed selection:text-on-secondary-fixed">
      {/* Universal 8-Screen Jumper Bar */}
      <ScreenSwitcherPill
        currentScreen={currentScreen}
        currentRole={currentRole}
        onNavigate={handleNavigate}
        onOpenDrawer={() => setDrawerOpen(true)}
      />

      {/* Screen Views */}
      <div className="flex-1">
        {currentScreen === 'buyer_home' && (
          <BuyerHomeScreen
            onNavigate={handleNavigate}
            onOpenDrawer={() => setDrawerOpen(true)}
            onAddToCart={handleAddToCart}
            cartCount={totalCartCount}
          />
        )}

        {currentScreen === 'auction_detail' && (
          <LiveAuctionDetailScreen
            onNavigate={handleNavigate}
            currentHighBid={currentHighBid}
            bidsCount={bidsCount}
            userIsHighBidder={userIsHighBidder}
            bidHistory={bidHistory}
            onPlaceBid={handlePlaceBid}
            onOpenZoom={setZoomImage}
          />
        )}

        {currentScreen === 'seller_hub' && (
          <SellerHubScreen
            onNavigate={handleNavigate}
            onOpenDrawer={() => setDrawerOpen(true)}
            listings={sellerListings}
          />
        )}

        {currentScreen === 'inspector_audit' && (
          <InspectorAuditScreen
            onNavigate={handleNavigate}
            onOpenDrawer={() => setDrawerOpen(true)}
            checklist={checklist}
            onToggleChecklist={handleToggleChecklist}
            onApprove={handleApproveInspection}
            onReject={handleRejectInspection}
            onOpenZoom={setZoomImage}
          />
        )}

        {currentScreen === 'admin_portal' && (
          <AdminPortalScreen
            onNavigate={handleNavigate}
            onOpenDrawer={() => setDrawerOpen(true)}
            disputes={disputes}
            users={users}
            ledgerStream={ledgerStream}
            onFreezeEscrow={handleFreezeEscrow}
            onRefundDispute={handleRefundDispute}
          />
        )}

        {currentScreen === 'new_listing' && (
          <NewBookListingScreen
            onNavigate={handleNavigate}
            onSubmitListing={handleSubmitListing}
          />
        )}

        {currentScreen === 'cart_checkout' && (
          <CartCheckoutScreen
            onNavigate={handleNavigate}
            cartItems={cartItems}
            onUpdateQuantity={handleUpdateQuantity}
            onRemoveItem={handleRemoveItem}
            onPlaceOrder={handlePlaceOrder}
          />
        )}

        {currentScreen === 'order_tracking' && (
          <OrderTrackingScreen
            onNavigate={handleNavigate}
            onOpenDrawer={() => setDrawerOpen(true)}
          />
        )}
      </div>

      {/* Universal Context-Aware Bottom Navigation */}
      {currentScreen !== 'new_listing' && currentScreen !== 'cart_checkout' && (
        <BottomNavBar
          currentRole={currentRole}
          currentScreen={currentScreen}
          onNavigate={handleNavigate}
          cartCount={totalCartCount}
          ordersCount={4}
        />
      )}

      {/* Role Navigation Drawer */}
      <RoleSwitchDrawer
        isOpen={drawerOpen}
        onClose={() => setDrawerOpen(false)}
        currentRole={currentRole}
        onSelectRole={handleSelectRole}
      />

      {/* High-Resolution Forensic Scan Lightbox Modal */}
      <ImageViewerModal data={zoomImage} onClose={() => setZoomImage(null)} />

      {/* Floating Notification Toast */}
      {toast && (
        <div className="fixed bottom-20 left-1/2 -translate-x-1/2 z-50 bg-primary text-white text-xs font-semibold px-4 py-2.5 rounded-full shadow-xl flex items-center gap-2 border border-white/20 animate-in fade-in slide-in-from-bottom-3 duration-200 pointer-events-none max-w-sm text-center">
          <span className="material-symbols-outlined text-[16px] text-secondary-fixed">info</span>
          <span>{toast}</span>
        </div>
      )}
    </div>
  );
}
