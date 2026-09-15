import React from 'react';
import { Role, ScreenId } from '../../core/types';
import { IMAGES } from '../../core/constants/assets';

interface RoleSwitchDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  currentRole: Role;
  onSelectRole: (role: Role, targetScreen?: ScreenId) => void;
}

export const RoleSwitchDrawer: React.FC<RoleSwitchDrawerProps> = ({
  isOpen,
  onClose,
  currentRole,
  onSelectRole,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs transition-opacity duration-300 flex">
      <aside 
        className="w-80 max-w-[85vw] h-full bg-surface-container-lowest border-r border-outline-variant shadow-2xl flex flex-col animate-in slide-in-from-left duration-300"
      >
        {/* Header Profile Block */}
        <div className="p-5 border-b border-outline-variant/50 bg-surface-container-low">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-1.5">
              <span className="text-xl font-headline-md text-primary tracking-tight font-extrabold">BookHub</span>
              <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded-full bg-primary-fixed text-on-primary-fixed">
                Network
              </span>
            </div>
            <button
              onClick={onClose}
              className="w-8 h-8 rounded-full flex items-center justify-center text-on-surface-variant hover:bg-surface-container active:scale-95 transition-all"
              aria-label="Close drawer"
            >
              <span className="material-symbols-outlined text-[20px]">close</span>
            </button>
          </div>

          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-full overflow-hidden border-2 border-primary shrink-0 shadow-sm">
              <img
                src={IMAGES.alexanderDrawer}
                alt="Alexander Vance"
                className="w-full h-full object-cover"
              />
            </div>
            <div className="min-w-0">
              <h4 className="font-headline-sm text-base text-primary font-bold truncate">Alexander Vance</h4>
              <p className="font-body-sm text-xs text-on-surface-variant truncate">alexander.vance@bookhub.io</p>
              <span className="inline-flex items-center gap-1 mt-1 text-[11px] font-semibold text-secondary-container">
                <span className="material-symbols-outlined text-[14px]">verified</span>
                Role: Verified Inspector
              </span>
            </div>
          </div>
        </div>

        {/* Role Navigation Tabs */}
        <div className="flex flex-col p-4 space-y-2 flex-1 overflow-y-auto">
          <span className="font-label-sm text-[11px] uppercase tracking-wider text-on-surface-variant px-2 pb-1 block">
            Active Perspective
          </span>

          {/* Buyer Mode */}
          <button
            onClick={() => {
              onSelectRole('buyer', 'buyer_home');
              onClose();
            }}
            className={`w-full flex items-center gap-3 rounded-xl px-4 py-3 font-semibold transition-all duration-150 text-left ${
              currentRole === 'buyer'
                ? 'bg-secondary-container text-on-secondary-container shadow-sm'
                : 'text-on-surface-variant hover:bg-surface-container hover:text-on-surface'
            }`}
          >
            <span className={`material-symbols-outlined text-[22px] ${currentRole === 'buyer' ? 'text-white' : ''}`}>
              shopping_bag
            </span>
            <div className="flex-1">
              <span className={`font-label-lg text-sm block ${currentRole === 'buyer' ? 'text-white font-bold' : ''}`}>
                Buyer Mode
              </span>
              <span className={`text-[11px] font-normal ${currentRole === 'buyer' ? 'text-white/80' : 'text-on-surface-variant/80'}`}>
                Browse, bid, and purchase
              </span>
            </div>
            {currentRole === 'buyer' && (
              <span className="material-symbols-outlined text-white text-[18px]">check</span>
            )}
          </button>

          {/* Seller Hub */}
          <button
            onClick={() => {
              onSelectRole('seller', 'seller_hub');
              onClose();
            }}
            className={`w-full flex items-center gap-3 rounded-xl px-4 py-3 font-semibold transition-all duration-150 text-left ${
              currentRole === 'seller'
                ? 'bg-secondary-container text-on-secondary-container shadow-sm'
                : 'text-on-surface-variant hover:bg-surface-container hover:text-on-surface'
            }`}
          >
            <span className={`material-symbols-outlined text-[22px] ${currentRole === 'seller' ? 'text-white' : ''}`}>
              inventory_2
            </span>
            <div className="flex-1">
              <span className={`font-label-lg text-sm block ${currentRole === 'seller' ? 'text-white font-bold' : ''}`}>
                Seller Hub
              </span>
              <span className={`text-[11px] font-normal ${currentRole === 'seller' ? 'text-white/80' : 'text-on-surface-variant/80'}`}>
                List books & manage sales
              </span>
            </div>
            {currentRole === 'seller' && (
              <span className="material-symbols-outlined text-white text-[18px]">check</span>
            )}
          </button>

          {/* Inspector Ledger */}
          <button
            onClick={() => {
              onSelectRole('inspector', 'inspector_audit');
              onClose();
            }}
            className={`w-full flex items-center gap-3 rounded-xl px-4 py-3 font-semibold transition-all duration-150 text-left ${
              currentRole === 'inspector'
                ? 'bg-secondary-container text-on-secondary-container shadow-sm'
                : 'text-on-surface-variant hover:bg-surface-container hover:text-on-surface'
            }`}
          >
            <span className={`material-symbols-outlined text-[22px] ${currentRole === 'inspector' ? 'text-white' : 'text-primary'}`}>
              verified
            </span>
            <div className="flex-1">
              <span className={`font-label-lg text-sm block ${currentRole === 'inspector' ? 'text-white font-bold' : ''}`}>
                Inspector Ledger
              </span>
              <span className={`text-[11px] font-normal ${currentRole === 'inspector' ? 'text-white/80' : 'text-on-surface-variant/80'}`}>
                Grade, seal, and verify
              </span>
            </div>
            {currentRole === 'inspector' ? (
              <span className="material-symbols-outlined text-white text-[18px]">check</span>
            ) : (
              <span className="w-2 h-2 rounded-full bg-secondary-container"></span>
            )}
          </button>

          {/* Admin Portal */}
          <button
            onClick={() => {
              onSelectRole('admin', 'admin_portal');
              onClose();
            }}
            className={`w-full flex items-center gap-3 rounded-xl px-4 py-3 font-semibold transition-all duration-150 text-left ${
              currentRole === 'admin'
                ? 'bg-secondary-container text-on-secondary-container shadow-sm'
                : 'text-on-surface-variant hover:bg-surface-container hover:text-on-surface'
            }`}
          >
            <span className={`material-symbols-outlined text-[22px] ${currentRole === 'admin' ? 'text-white' : ''}`}>
              admin_panel_settings
            </span>
            <div className="flex-1">
              <span className={`font-label-lg text-sm block ${currentRole === 'admin' ? 'text-white font-bold' : ''}`}>
                Admin Portal
              </span>
              <span className={`text-[11px] font-normal ${currentRole === 'admin' ? 'text-white/80' : 'text-on-surface-variant/80'}`}>
                Disputes & system policies
              </span>
            </div>
            {currentRole === 'admin' && (
              <span className="material-symbols-outlined text-white text-[18px]">check</span>
            )}
          </button>
        </div>

        {/* Drawer Footer */}
        <div className="p-4 border-t border-outline-variant/40 bg-surface-container-low flex items-center justify-between">
          <div className="flex items-center gap-2 text-on-surface-variant">
            <span className="material-symbols-outlined text-[18px]">security</span>
            <span className="font-label-sm text-xs">Encrypted Escrow</span>
          </div>
          <span className="font-label-sm text-xs text-on-surface-variant">v2.4.1</span>
        </div>
      </aside>
      <div className="flex-1" onClick={onClose}></div>
    </div>
  );
};
