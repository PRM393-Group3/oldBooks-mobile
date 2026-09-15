import React, { useState } from 'react';
import { ScreenId, SellerListing } from '../../../core/types';
import { IMAGES } from '../../../core/constants/assets';

interface SellerHubScreenProps {
  onNavigate: (screen: ScreenId) => void;
  onOpenDrawer: () => void;
  listings: SellerListing[];
}

export const SellerHubScreen: React.FC<SellerHubScreenProps> = ({
  onNavigate,
  onOpenDrawer,
  listings
}) => {
  const [activeTab, setActiveTab] = useState<'All' | 'Pending' | 'Approved' | 'Rejected' | 'Sold'>('All');
  const [searchQuery, setSearchQuery] = useState('');

  const filteredListings = listings.filter((l) => {
    if (activeTab === 'Pending') return l.status === 'WAITING FOR INSPECTOR APPROVAL';
    if (activeTab === 'Rejected') return l.status === 'REJECTED BY INSPECTOR';
    if (activeTab === 'Approved') return l.status === 'PUBLISHED' || l.status === 'LIVE AUCTION';
    if (activeTab === 'Sold') return l.status === 'SOLD';
    return true;
  }).filter((l) => l.title.toLowerCase().includes(searchQuery.toLowerCase()) || l.author.toLowerCase().includes(searchQuery.toLowerCase()));

  return (
    <div className="min-h-screen bg-surface text-on-surface pb-24">
      {/* Top Application Header */}
      <header className="sticky top-0 z-30 bg-surface/90 backdrop-blur-md px-4 py-3 border-b border-outline-variant/40 flex items-center justify-between">
        <button
          onClick={onOpenDrawer}
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-surface-container-low border border-outline-variant/60 hover:bg-surface-container active:scale-95 transition-all"
        >
          <span className="w-2 h-2 rounded-full bg-secondary-container"></span>
          <span className="font-label-md text-xs font-bold text-primary">Seller Hub</span>
          <span className="material-symbols-outlined text-[16px] text-on-surface-variant">expand_more</span>
        </button>

        <div className="flex items-center gap-2">
          <button
            onClick={() => onNavigate('new_listing')}
            className="flex items-center gap-1 px-3 py-1.5 rounded-full bg-secondary-container text-white text-xs font-bold shadow-xs hover:bg-secondary-container/90 active:scale-95 transition-all"
          >
            <span className="material-symbols-outlined text-[16px]">add</span>
            <span>New Listing</span>
          </button>

          <button
            onClick={onOpenDrawer}
            className="w-9 h-9 rounded-full overflow-hidden border border-outline-variant"
          >
            <img src={IMAGES.alexanderAvatar} alt="Alexander" className="w-full h-full object-cover" />
          </button>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* Seller Profile Summary */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-full overflow-hidden border border-outline-variant">
              <img src={IMAGES.alexanderAvatar} alt="Alex" className="w-full h-full object-cover" />
            </div>
            <div>
              <div className="flex items-center gap-1.5">
                <h2 className="font-headline-sm text-sm font-extrabold text-primary">Alexander Vance</h2>
                <span className="text-[10px] bg-emerald-100 text-emerald-800 font-bold px-1.5 py-0.5 rounded">
                  Level 2
                </span>
              </div>
              <p className="text-xs text-on-surface-variant font-medium">Brooklyn Antiquarian Vault • 99.1% Trust</p>
            </div>
          </div>
          <button
            onClick={onOpenDrawer}
            className="text-xs font-bold text-secondary-container hover:underline"
          >
            Switch Role
          </button>
        </div>

        {/* 4 Metric Bento Cards */}
        <div className="grid grid-cols-2 gap-2.5">
          <div className="bg-surface-container-lowest rounded-xl p-3 border border-outline-variant/60 shadow-xs">
            <div className="flex items-center justify-between text-on-surface-variant">
              <span className="text-[11px] font-semibold">Total Revenue</span>
              <span className="material-symbols-outlined text-[18px] text-emerald-600">payments</span>
            </div>
            <div className="text-xl font-extrabold text-primary mt-1">$3,420.50</div>
            <span className="text-[10px] text-emerald-600 font-bold flex items-center gap-0.5 mt-0.5">
              <span className="material-symbols-outlined text-[12px]">trending_up</span>
              +14% vs last mo
            </span>
          </div>

          <div className="bg-surface-container-lowest rounded-xl p-3 border border-outline-variant/60 shadow-xs">
            <div className="flex items-center justify-between text-on-surface-variant">
              <span className="text-[11px] font-semibold">Active Listings</span>
              <span className="material-symbols-outlined text-[18px] text-primary">menu_book</span>
            </div>
            <div className="text-xl font-extrabold text-primary mt-1">38 Books</div>
            <span className="text-[10px] text-on-surface-variant font-medium mt-0.5 block">
              4 in Inspection
            </span>
          </div>

          <div className="bg-surface-container-lowest rounded-xl p-3 border border-outline-variant/60 shadow-xs">
            <div className="flex items-center justify-between text-on-surface-variant">
              <span className="text-[11px] font-semibold">Live Auctions</span>
              <span className="material-symbols-outlined text-[18px] text-secondary-container">gavel</span>
            </div>
            <div className="text-xl font-extrabold text-primary mt-1">5 Live</div>
            <span className="text-[10px] text-secondary-container font-bold mt-0.5 block">
              High bid $165.00
            </span>
          </div>

          <div className="bg-surface-container-lowest rounded-xl p-3 border border-outline-variant/60 shadow-xs">
            <div className="flex items-center justify-between text-on-surface-variant">
              <span className="text-[11px] font-semibold">Orders Pending</span>
              <span className="material-symbols-outlined text-[18px] text-amber-600">local_shipping</span>
            </div>
            <div className="text-xl font-extrabold text-primary mt-1">4 to Ship</div>
            <span className="text-[10px] text-amber-700 font-bold mt-0.5 block">
              2 Due Today
            </span>
          </div>
        </div>

        {/* Action Callout: Ready to sell? */}
        <div className="bg-primary text-white rounded-2xl p-4 shadow-sm flex items-center justify-between">
          <div>
            <h3 className="font-headline-sm text-sm font-bold">List a Verified Book</h3>
            <p className="text-xs text-white/80 mt-0.5">Submit photos to an in-person inspector.</p>
          </div>
          <button
            onClick={() => onNavigate('new_listing')}
            className="px-3.5 py-2 bg-secondary-container text-white text-xs font-bold rounded-xl shadow-xs hover:bg-secondary-container/90 active:scale-95 transition-all shrink-0"
          >
            Start Listing
          </button>
        </div>

        {/* Orders to Ship Accelerator */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-3">
          <div className="flex items-center justify-between">
            <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-amber-500"></span>
              Orders to Pack & Ship
            </h3>
            <span className="text-xs font-bold text-secondary-container">Order #BK-9082</span>
          </div>

          <div className="p-3 bg-surface-container-low rounded-xl flex items-center gap-3">
            <div className="w-12 h-16 rounded bg-surface-container overflow-hidden shrink-0 book-shadow">
              <img
                src={IMAGES.leftHandDarkness}
                alt="The Left Hand of Darkness"
                className="w-full h-full object-cover"
              />
            </div>
            <div className="min-w-0 flex-1">
              <h4 className="font-headline-sm text-xs font-bold text-primary truncate">
                The Left Hand of Darkness (1st Ace)
              </h4>
              <p className="text-[11px] text-on-surface-variant">Buyer: Elena Rostova • Brooklyn, NY</p>
              <div className="mt-1 flex items-center gap-2 text-xs font-bold text-primary">
                <span>$42.00</span>
                <span className="text-[10px] text-emerald-700 bg-emerald-100 px-1.5 rounded font-semibold">
                  Escrow Funded
                </span>
              </div>
            </div>
            <button
              onClick={() => onNavigate('order_tracking')}
              className="px-2.5 py-1.5 bg-primary text-white text-[11px] font-bold rounded-lg shrink-0 shadow-xs hover:bg-primary-container transition-all"
            >
              Pack Book
            </button>
          </div>
        </div>

        {/* Listing Management Tabs & Search */}
        <div>
          <div className="flex items-center justify-between mb-2">
            <h3 className="font-headline-sm text-sm font-extrabold text-primary uppercase tracking-wide">
              Listing Inventory
            </h3>
            <span className="text-xs text-on-surface-variant font-medium">43 Total</span>
          </div>

          {/* Filter tabs */}
          <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar pb-1">
            {(['All', 'Pending', 'Approved', 'Rejected', 'Sold'] as const).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`px-3 py-1 rounded-full text-xs font-bold transition-all whitespace-nowrap active:scale-95 ${
                  activeTab === tab
                    ? 'bg-primary text-white shadow-xs'
                    : 'bg-surface-container-lowest border border-outline-variant/60 text-on-surface-variant hover:text-on-surface'
                }`}
              >
                {tab}
              </button>
            ))}
          </div>

          {/* Search bar */}
          <div className="mt-2.5 relative">
            <input
              type="text"
              placeholder="Search active seller listings..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-surface-container-lowest border border-outline-variant/70 rounded-xl pl-9 pr-3 py-2 text-xs text-on-surface outline-hidden focus:ring-2 focus:ring-primary/20"
            />
            <span className="material-symbols-outlined text-[18px] text-on-surface-variant absolute left-2.5 top-2">
              search
            </span>
          </div>

          {/* Listings List */}
          <div className="mt-3 space-y-2.5">
            {filteredListings.map((listing) => {
              const isWaiting = listing.status === 'WAITING FOR INSPECTOR APPROVAL';
              const isRejected = listing.status === 'REJECTED BY INSPECTOR';
              const isLive = listing.status === 'LIVE AUCTION';
              const isPublished = listing.status === 'PUBLISHED';

              return (
                <div
                  key={listing.id}
                  className="bg-surface-container-lowest rounded-xl p-3 border border-outline-variant/60 shadow-xs flex items-start gap-3"
                >
                  <div className="w-14 h-20 rounded bg-surface-container overflow-hidden shrink-0 book-shadow">
                    <img
                      src={listing.coverImage}
                      alt={listing.title}
                      className="w-full h-full object-cover"
                    />
                  </div>

                  <div className="flex-1 min-w-0">
                    {/* Status Badge */}
                    <div className="flex items-center gap-1.5 mb-1">
                      {isWaiting && (
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-amber-100 text-amber-800 flex items-center gap-1">
                          <span className="material-symbols-outlined text-[12px]">hourglass_top</span>
                          WAITING APPROVAL
                        </span>
                      )}
                      {isRejected && (
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-red-100 text-red-800 flex items-center gap-1">
                          <span className="material-symbols-outlined text-[12px]">error</span>
                          REJECTED BY INSPECTOR
                        </span>
                      )}
                      {isLive && (
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-blue-100 text-blue-800 flex items-center gap-1">
                          <span className="w-1.5 h-1.5 rounded-full bg-blue-600 animate-pulse"></span>
                          LIVE AUCTION
                        </span>
                      )}
                      {isPublished && (
                        <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-emerald-100 text-emerald-800 flex items-center gap-1">
                          <span className="material-symbols-outlined text-[12px]">check_circle</span>
                          PUBLISHED
                        </span>
                      )}
                    </div>

                    <h4 className="font-headline-sm text-xs font-bold text-primary truncate">
                      {listing.title}
                    </h4>
                    <p className="text-[11px] text-on-surface-variant truncate">
                      {listing.author} • {listing.edition}
                    </p>

                    <div className="mt-1.5 flex items-center justify-between text-xs">
                      <div>
                        <span className="font-extrabold text-primary">${listing.price.toFixed(2)}</span>
                        <span className="text-[10px] text-on-surface-variant ml-1">({listing.priceType})</span>
                      </div>
                      <span className="text-[10px] text-on-surface-variant">{listing.extraInfo}</span>
                    </div>

                    {/* Rejection Note */}
                    {isRejected && listing.inspectorNote && (
                      <div className="mt-2 p-2 rounded-lg bg-red-50 text-[11px] text-red-900 border border-red-200">
                        <strong>Inspector Note:</strong> {listing.inspectorNote}
                        <div className="mt-1.5 flex items-center gap-2">
                          <button
                            onClick={() => onNavigate('new_listing')}
                            className="px-2 py-0.5 bg-red-700 text-white font-bold rounded text-[10px] hover:bg-red-800"
                          >
                            Edit & Resubmit
                          </button>
                        </div>
                      </div>
                    )}

                    {/* Live Auction Controls */}
                    {isLive && (
                      <div className="mt-2 flex items-center justify-between pt-1 border-t border-outline-variant/40">
                        <span className="text-[10px] font-bold text-secondary-container">{listing.timeLeft}</span>
                        <button
                          onClick={() => onNavigate('auction_detail')}
                          className="text-[11px] font-bold text-primary underline"
                        >
                          View Console
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </main>
    </div>
  );
};
