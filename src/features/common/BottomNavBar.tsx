import React from 'react';
import { ScreenId, Role } from '../../core/types';

interface BottomNavBarProps {
  currentRole: Role;
  currentScreen: ScreenId;
  onNavigate: (screen: ScreenId) => void;
  cartCount?: number;
  ordersCount?: number;
}

export const BottomNavBar: React.FC<BottomNavBarProps> = ({
  currentRole,
  currentScreen,
  onNavigate,
  cartCount = 2,
  ordersCount = 4
}) => {
  // If in Inspector mode, show inspector tabs
  if (currentRole === 'inspector') {
    return (
      <nav className="fixed bottom-0 left-0 w-full z-40 bg-surface-container-lowest border-t border-outline-variant/60 shadow-md">
        <div className="max-w-md mx-auto flex justify-around items-center h-16 px-2 pb-safe">
          <button
            onClick={() => onNavigate('inspector_audit')}
            className={`flex flex-col items-center justify-center px-4 py-1 rounded-full transition-all active:scale-95 ${
              currentScreen === 'inspector_audit'
                ? 'bg-primary-container text-white font-bold'
                : 'text-on-surface-variant hover:text-primary'
            }`}
          >
            <span className="material-symbols-outlined text-[20px]">checklist</span>
            <span className="text-[11px] font-semibold">Queue</span>
          </button>

          <button
            onClick={() => onNavigate('admin_portal')}
            className="flex flex-col items-center justify-center text-on-surface-variant hover:text-primary px-3 py-1 rounded-xl transition-all active:scale-95"
          >
            <span className="material-symbols-outlined text-[20px]">history</span>
            <span className="text-[11px]">History</span>
          </button>

          <button
            onClick={() => onNavigate('buyer_home')}
            className="flex flex-col items-center justify-center text-on-surface-variant hover:text-primary px-3 py-1 rounded-xl transition-all active:scale-95"
          >
            <span className="material-symbols-outlined text-[20px]">menu_book</span>
            <span className="text-[11px]">Guidelines</span>
          </button>

          <button
            onClick={() => onNavigate('admin_portal')}
            className="flex flex-col items-center justify-center text-on-surface-variant hover:text-primary px-3 py-1 rounded-xl transition-all active:scale-95"
          >
            <span className="material-symbols-outlined text-[20px]">badge</span>
            <span className="text-[11px]">Profile</span>
          </button>
        </div>
      </nav>
    );
  }

  // Seller bottom bar
  if (currentRole === 'seller') {
    return (
      <nav className="fixed bottom-0 left-0 w-full z-40 bg-surface-container-lowest border-t border-outline-variant/60 shadow-md">
        <div className="max-w-md mx-auto flex justify-around items-center h-16 px-2 pb-safe">
          <button
            onClick={() => onNavigate('seller_hub')}
            className={`flex flex-col items-center justify-center px-4 py-1 rounded-full transition-all active:scale-95 ${
              currentScreen === 'seller_hub'
                ? 'bg-primary-container text-white font-bold'
                : 'text-on-surface-variant hover:text-primary'
            }`}
          >
            <span className="material-symbols-outlined text-[20px]">storefront</span>
            <span className="text-[11px]">Dashboard</span>
          </button>

          <button
            onClick={() => onNavigate('new_listing')}
            className={`flex flex-col items-center justify-center px-3 py-1 rounded-xl transition-all active:scale-95 ${
              currentScreen === 'new_listing'
                ? 'bg-primary-container text-white font-bold'
                : 'text-on-surface-variant hover:text-primary'
            }`}
          >
            <span className="material-symbols-outlined text-[20px]">add_circle</span>
            <span className="text-[11px]">New List</span>
          </button>

          <button
            onClick={() => onNavigate('auction_detail')}
            className="flex flex-col items-center justify-center text-on-surface-variant hover:text-primary px-3 py-1 rounded-xl transition-all active:scale-95"
          >
            <span className="material-symbols-outlined text-[20px]">gavel</span>
            <span className="text-[11px]">Auctions</span>
          </button>

          <button
            onClick={() => onNavigate('order_tracking')}
            className={`flex flex-col items-center justify-center px-3 py-1 rounded-xl transition-all active:scale-95 relative ${
              currentScreen === 'order_tracking'
                ? 'bg-primary-container text-white font-bold'
                : 'text-on-surface-variant hover:text-primary'
            }`}
          >
            <div className="relative">
              <span className="material-symbols-outlined text-[20px]">receipt_long</span>
              <span className="absolute -top-1 -right-2 bg-secondary-container text-white text-[9px] font-bold px-1 rounded-full">
                {ordersCount}
              </span>
            </div>
            <span className="text-[11px]">Orders</span>
          </button>

          <button
            onClick={() => onNavigate('admin_portal')}
            className="flex flex-col items-center justify-center text-on-surface-variant hover:text-primary px-3 py-1 rounded-xl transition-all active:scale-95"
          >
            <span className="material-symbols-outlined text-[20px]">person</span>
            <span className="text-[11px]">Profile</span>
          </button>
        </div>
      </nav>
    );
  }

  // Buyer bottom bar (Default)
  return (
    <nav className="fixed bottom-0 left-0 w-full z-40 flex justify-around items-center px-2 h-16 pb-safe bg-surface-container-lowest shadow-md border-t border-outline-variant/60">
      {/* Home */}
      <button
        onClick={() => onNavigate('buyer_home')}
        className={`flex flex-col items-center justify-center rounded-full px-4 py-1 transition-all active:scale-95 ${
          currentScreen === 'buyer_home'
            ? 'bg-primary-container text-white font-bold'
            : 'text-on-surface-variant hover:text-primary'
        }`}
      >
        <span className="material-symbols-outlined text-[20px]">storefront</span>
        <span className="text-[11px]">Home</span>
      </button>

      {/* Explore / Cart */}
      <button
        onClick={() => onNavigate('cart_checkout')}
        className={`flex flex-col items-center justify-center px-3 py-1 rounded-xl transition-all active:scale-95 relative ${
          currentScreen === 'cart_checkout'
            ? 'bg-primary-container text-white font-bold'
            : 'text-on-surface-variant hover:text-primary'
        }`}
      >
        <div className="relative">
          <span className="material-symbols-outlined text-[20px]">shopping_cart</span>
          {cartCount > 0 && (
            <span className="absolute -top-1 -right-2 min-w-[14px] h-[14px] px-0.5 bg-secondary-container text-white text-[9px] font-bold rounded-full flex items-center justify-center leading-none">
              {cartCount}
            </span>
          )}
        </div>
        <span className="text-[11px]">Cart</span>
      </button>

      {/* Auctions */}
      <button
        onClick={() => onNavigate('auction_detail')}
        className={`flex flex-col items-center justify-center px-3 py-1 rounded-xl transition-all active:scale-95 ${
          currentScreen === 'auction_detail'
            ? 'bg-primary-container text-white font-bold'
            : 'text-on-surface-variant hover:text-primary'
        }`}
      >
        <span className="material-symbols-outlined text-[20px]">gavel</span>
        <span className="text-[11px]">Auctions</span>
      </button>

      {/* Orders */}
      <button
        onClick={() => onNavigate('order_tracking')}
        className={`flex flex-col items-center justify-center px-3 py-1 rounded-xl transition-all active:scale-95 relative ${
          currentScreen === 'order_tracking'
            ? 'bg-primary-container text-white font-bold'
            : 'text-on-surface-variant hover:text-primary'
        }`}
      >
        <div className="relative">
          <span className="material-symbols-outlined text-[20px]">receipt_long</span>
          <span className="absolute -top-1 -right-2 min-w-[14px] h-[14px] px-0.5 bg-secondary-container text-white text-[9px] font-bold rounded-full flex items-center justify-center leading-none">
            2
          </span>
        </div>
        <span className="text-[11px]">Orders</span>
      </button>

      {/* Profile / Admin */}
      <button
        onClick={() => onNavigate('admin_portal')}
        className={`flex flex-col items-center justify-center px-3 py-1 rounded-xl transition-all active:scale-95 ${
          currentScreen === 'admin_portal'
            ? 'bg-primary-container text-white font-bold'
            : 'text-on-surface-variant hover:text-primary'
        }`}
      >
        <span className="material-symbols-outlined text-[20px]">person</span>
        <span className="text-[11px]">Profile</span>
      </button>
    </nav>
  );
};
