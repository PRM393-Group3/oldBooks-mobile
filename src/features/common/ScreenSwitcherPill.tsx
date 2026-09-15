import React, { useState } from 'react';
import { ScreenId, Role } from '../../core/types';

interface ScreenSwitcherPillProps {
  currentScreen: ScreenId;
  currentRole: Role;
  onNavigate: (screen: ScreenId, role?: Role) => void;
  onOpenDrawer: () => void;
}

const SCREENS: { id: ScreenId; role: Role; label: string; number: string; icon: string }[] = [
  { id: 'buyer_home', role: 'buyer', label: 'Marketplace', number: '1', icon: 'storefront' },
  { id: 'auction_detail', role: 'buyer', label: 'Live Auction', number: '2', icon: 'gavel' },
  { id: 'seller_hub', role: 'seller', label: 'Seller Hub', number: '3', icon: 'inventory_2' },
  { id: 'inspector_audit', role: 'inspector', label: 'Inspector Audit', number: '4', icon: 'verified' },
  { id: 'admin_portal', role: 'admin', label: 'Admin Portal', number: '5', icon: 'admin_panel_settings' },
  { id: 'new_listing', role: 'seller', label: 'New Listing', number: '6', icon: 'add_circle' },
  { id: 'cart_checkout', role: 'buyer', label: 'Checkout', number: '7', icon: 'shopping_cart_checkout' },
  { id: 'order_tracking', role: 'buyer', label: 'Order Tracking', number: '8', icon: 'local_shipping' },
];

export const ScreenSwitcherPill: React.FC<ScreenSwitcherPillProps> = ({
  currentScreen,
  currentRole,
  onNavigate,
  onOpenDrawer
}) => {
  const [collapsed, setCollapsed] = useState(false);
  const activeScreenInfo = SCREENS.find((s) => s.id === currentScreen) || SCREENS[0];

  return (
    <div className="sticky top-0 z-50 bg-primary/95 text-white backdrop-blur-md border-b border-primary-container shadow-md transition-all">
      <div className="max-w-6xl mx-auto px-3 py-1.5 flex items-center justify-between gap-2">
        {/* Left: Quick Drawer button & Active indicator */}
        <div className="flex items-center gap-2">
          <button
            onClick={onOpenDrawer}
            className="flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-white/10 hover:bg-white/20 active:scale-95 text-xs font-semibold text-primary-fixed transition-all"
            title="Switch Perspective / Open Navigation Drawer"
          >
            <span className="material-symbols-outlined text-[16px]">menu</span>
            <span className="hidden sm:inline">Perspective:</span>
            <span className="capitalize font-bold text-white underline decoration-secondary-container decoration-2 underline-offset-2">
              {currentRole}
            </span>
          </button>

          <span className="text-[11px] text-white/80 hidden md:inline-flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
            Screen {activeScreenInfo.number}: <strong>{activeScreenInfo.label}</strong>
          </span>
        </div>

        {/* Right: Direct 8-Screen Switcher Pills */}
        <div className="flex items-center gap-1 overflow-x-auto no-scrollbar py-0.5">
          <button
            onClick={() => setCollapsed(!collapsed)}
            className="text-[10px] text-white/70 hover:text-white px-1.5 py-0.5 rounded bg-white/5 md:hidden"
          >
            {collapsed ? 'Screens ▾' : 'Hide ▴'}
          </button>

          <div className={`flex items-center gap-1 ${collapsed ? 'hidden md:flex' : 'flex'}`}>
            {SCREENS.map((screen) => {
              const isActive = currentScreen === screen.id;
              return (
                <button
                  key={screen.id}
                  onClick={() => onNavigate(screen.id, screen.role)}
                  className={`flex items-center gap-1 px-2 py-1 rounded-md text-[11px] font-medium transition-all whitespace-nowrap active:scale-95 ${
                    isActive
                      ? 'bg-secondary-container text-white font-bold shadow-xs ring-1 ring-white/30'
                      : 'text-white/80 hover:text-white hover:bg-white/10'
                  }`}
                  title={`${screen.number}. ${screen.label} (${screen.role})`}
                >
                  <span className="w-4 h-4 rounded-full bg-black/25 flex items-center justify-center text-[10px] font-bold">
                    {screen.number}
                  </span>
                  <span className="hidden sm:inline">{screen.label}</span>
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
};
