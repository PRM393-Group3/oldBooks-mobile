import React, { useState } from 'react';
import { BookItem, ScreenId } from '../../../core/types';
import { IMAGES } from '../../../core/constants/assets';

interface BuyerHomeScreenProps {
  onNavigate: (screen: ScreenId) => void;
  onOpenDrawer: () => void;
  onAddToCart: (book: BookItem) => void;
  cartCount: number;
}

const CATEGORIES = [
  { id: 'all', label: 'All', icon: 'auto_stories' },
  { id: 'fiction', label: 'Fiction', icon: 'menu_book' },
  { id: 'business', label: 'Business', icon: 'trending_up' },
  { id: 'tech', label: 'Technology', icon: 'memory' },
  { id: 'education', label: 'Education', icon: 'school' },
  { id: 'scifi', label: 'Sci-Fi', icon: 'rocket_launch' }
];

export const BuyerHomeScreen: React.FC<BuyerHomeScreenProps> = ({
  onNavigate,
  onOpenDrawer,
  onAddToCart,
  cartCount
}) => {
  const [activeCategory, setActiveCategory] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <div className="min-h-screen bg-surface text-on-surface pb-24">
      {/* Top Application Header */}
      <header className="sticky top-0 z-30 bg-surface/90 backdrop-blur-md px-4 pt-3 pb-3 border-b border-outline-variant/40">
        <div className="max-w-md mx-auto flex items-center justify-between">
          {/* Role pill trigger */}
          <button
            onClick={onOpenDrawer}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-surface-container-low border border-outline-variant/60 hover:bg-surface-container active:scale-95 transition-all"
          >
            <span className="w-2 h-2 rounded-full bg-emerald-500"></span>
            <span className="font-label-md text-xs font-bold text-primary">Buyer Mode</span>
            <span className="material-symbols-outlined text-[16px] text-on-surface-variant">expand_more</span>
          </button>

          {/* Verified Guarantee Badge */}
          <div className="flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-primary-fixed text-on-primary-fixed text-[11px] font-bold">
            <span className="material-symbols-outlined text-[14px]">verified</span>
            <span>VERIFIED</span>
          </div>

          {/* User Profile and Notification */}
          <div className="flex items-center gap-2">
            <button
              onClick={() => onNavigate('cart_checkout')}
              className="relative w-9 h-9 rounded-full flex items-center justify-center bg-surface-container-low text-on-surface hover:bg-surface-container transition-all"
              title="Cart"
            >
              <span className="material-symbols-outlined text-[20px]">shopping_cart</span>
              {cartCount > 0 && (
                <span className="absolute -top-1 -right-1 bg-secondary-container text-white text-[10px] font-bold w-4 h-4 rounded-full flex items-center justify-center">
                  {cartCount}
                </span>
              )}
            </button>

            <button
              onClick={onOpenDrawer}
              className="relative w-9 h-9 rounded-full overflow-hidden border border-outline-variant active:scale-95 transition-all"
            >
              <img
                src={IMAGES.alexanderAvatar}
                alt="Alexander Vance"
                className="w-full h-full object-cover"
              />
            </button>
          </div>
        </div>

        {/* Greeting */}
        <div className="max-w-md mx-auto mt-2">
          <h1 className="text-xl font-headline-md font-extrabold text-primary tracking-tight">
            Hello, Alex 👋
          </h1>
          <p className="text-xs text-on-surface-variant font-medium">
            Explore authentic first-editions and verified pre-owned volumes
          </p>
        </div>

        {/* Search Bar */}
        <div className="max-w-md mx-auto mt-3 relative">
          <div className="flex items-center bg-surface-container-lowest border border-outline-variant/70 rounded-xl px-3 py-2.5 shadow-xs focus-within:ring-2 focus-within:ring-primary/20 transition-all">
            <span className="material-symbols-outlined text-[20px] text-on-surface-variant mr-2">search</span>
            <input
              type="text"
              placeholder="Search title, author, or ISBN..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-transparent border-none outline-hidden text-sm text-on-surface placeholder:text-on-surface-variant/60"
            />
            <button className="text-on-surface-variant hover:text-primary mr-1" title="Voice Search">
              <span className="material-symbols-outlined text-[20px]">mic</span>
            </button>
            <button className="text-on-surface-variant hover:text-primary" title="Filter Options">
              <span className="material-symbols-outlined text-[20px]">tune</span>
            </button>
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-md mx-auto px-4 pt-3 space-y-5">
        {/* Category Carousel */}
        <div className="flex items-center gap-2 overflow-x-auto no-scrollbar py-1">
          {CATEGORIES.map((cat) => {
            const isActive = activeCategory === cat.id;
            return (
              <button
                key={cat.id}
                onClick={() => setActiveCategory(cat.id)}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-all active:scale-95 ${
                  isActive
                    ? 'bg-primary text-white shadow-xs'
                    : 'bg-surface-container-lowest border border-outline-variant/60 text-on-surface-variant hover:text-on-surface'
                }`}
              >
                <span className="material-symbols-outlined text-[16px]">{cat.icon}</span>
                <span>{cat.label}</span>
              </button>
            );
          })}
        </div>

        {/* Rare Book Auction Week Hero Banner */}
        <div 
          onClick={() => onNavigate('auction_detail')}
          className="relative rounded-2xl overflow-hidden shadow-md cursor-pointer group transition-all hover:shadow-lg"
        >
          <div className="h-44 w-full bg-primary-container relative">
            <img
              src={IMAGES.rareAuctionWeek}
              alt="Rare Book Auction Week"
              className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500 opacity-80"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-primary via-primary/60 to-transparent"></div>

            <div className="absolute top-3 left-3 flex items-center gap-1 bg-secondary-container text-white px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider shadow-sm">
              <span className="material-symbols-outlined text-[13px]">timer</span>
              Ending in 14h 22m
            </div>

            <div className="absolute bottom-3 left-3 right-3 flex items-end justify-between">
              <div>
                <span className="text-[10px] uppercase font-bold tracking-widest text-secondary-fixed block">
                  FEATURED CURATION
                </span>
                <h2 className="text-lg font-headline-sm font-extrabold text-white leading-tight mt-0.5">
                  Rare Book Auction Week
                </h2>
                <p className="text-xs text-white/80 mt-0.5">
                  Hand-inspected 1st editions with Escrow Guarantee
                </p>
              </div>
              <button className="px-3 py-1.5 bg-white text-primary text-xs font-bold rounded-lg shadow-sm hover:bg-surface-container-low transition-all shrink-0">
                Explore Drops
              </button>
            </div>
          </div>
        </div>

        {/* Live Auctions Section */}
        <div>
          <div className="flex items-center justify-between mb-2.5">
            <div className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-red-500 animate-ping"></span>
              <h3 className="font-headline-sm text-sm font-extrabold text-primary uppercase tracking-wide">
                Live Auctions
              </h3>
            </div>
            <button 
              onClick={() => onNavigate('auction_detail')}
              className="text-xs font-bold text-secondary-container hover:underline"
            >
              View All (18)
            </button>
          </div>

          <div className="grid grid-cols-2 gap-3">
            {/* Dune Card */}
            <div 
              onClick={() => onNavigate('auction_detail')}
              className="bg-surface-container-lowest rounded-xl p-2.5 border border-outline-variant/60 shadow-xs hover:shadow-md transition-all cursor-pointer flex flex-col justify-between group"
            >
              <div className="relative rounded-lg overflow-hidden h-36 bg-surface-container-low mb-2 book-shadow">
                <img
                  src={IMAGES.duneAuction}
                  alt="Dune 1965 First Edition"
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                <div className="absolute top-1.5 left-1.5 bg-black/60 backdrop-blur-xs text-white px-2 py-0.5 rounded-md text-[9px] font-bold">
                  01h 48m left
                </div>
                <div className="absolute bottom-1.5 right-1.5 bg-primary/80 backdrop-blur-xs text-white px-1.5 py-0.5 rounded text-[9px] font-semibold">
                  Very Good
                </div>
              </div>

              <div>
                <span className="text-[10px] font-semibold text-secondary-container uppercase tracking-wide">
                  Rare Sci-Fi
                </span>
                <h4 className="font-headline-sm text-xs font-bold text-primary truncate mt-0.5">
                  Dune (1965 1st Edition)
                </h4>
                <p className="text-[11px] text-on-surface-variant truncate">Frank Herbert • Chilton</p>

                <div className="mt-2 pt-2 border-t border-outline-variant/40 flex items-center justify-between">
                  <div>
                    <span className="text-[9px] text-on-surface-variant uppercase font-medium block">Current Bid</span>
                    <span className="text-sm font-extrabold text-primary">$165.00</span>
                  </div>
                  <span className="px-2 py-1 bg-primary text-white text-[10px] font-bold rounded-md group-hover:bg-secondary-container transition-colors">
                    Place Bid
                  </span>
                </div>
              </div>
            </div>

            {/* Clean Code Card */}
            <div 
              onClick={() => onNavigate('auction_detail')}
              className="bg-surface-container-lowest rounded-xl p-2.5 border border-outline-variant/60 shadow-xs hover:shadow-md transition-all cursor-pointer flex flex-col justify-between group"
            >
              <div className="relative rounded-lg overflow-hidden h-36 bg-surface-container-low mb-2 book-shadow">
                <img
                  src={IMAGES.cleanCode}
                  alt="Clean Code Handbook"
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                <div className="absolute top-1.5 left-1.5 bg-black/60 backdrop-blur-xs text-white px-2 py-0.5 rounded-md text-[9px] font-bold">
                  45m left
                </div>
                <div className="absolute bottom-1.5 right-1.5 bg-primary/80 backdrop-blur-xs text-white px-1.5 py-0.5 rounded text-[9px] font-semibold">
                  Very Good
                </div>
              </div>

              <div>
                <span className="text-[10px] font-semibold text-secondary-container uppercase tracking-wide">
                  Technology
                </span>
                <h4 className="font-headline-sm text-xs font-bold text-primary truncate mt-0.5">
                  Clean Code: Handbook
                </h4>
                <p className="text-[11px] text-on-surface-variant truncate">Signed Copy • Robert Martin</p>

                <div className="mt-2 pt-2 border-t border-outline-variant/40 flex items-center justify-between">
                  <div>
                    <span className="text-[9px] text-on-surface-variant uppercase font-medium block">Current Bid</span>
                    <span className="text-sm font-extrabold text-primary">$42.00</span>
                  </div>
                  <span className="px-2 py-1 bg-primary text-white text-[10px] font-bold rounded-md group-hover:bg-secondary-container transition-colors">
                    Place Bid
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Recommended For You Section */}
        <div>
          <div className="flex items-center justify-between mb-2.5">
            <h3 className="font-headline-sm text-sm font-extrabold text-primary uppercase tracking-wide">
              Recommended For You
            </h3>
            <span className="text-xs text-on-surface-variant font-medium">3,420 Verified Books</span>
          </div>

          <div className="grid grid-cols-2 gap-3">
            {/* Book 1: Atomic Habits */}
            <div className="bg-surface-container-lowest rounded-xl p-2.5 border border-outline-variant/60 shadow-xs flex flex-col justify-between group">
              <div className="relative rounded-lg overflow-hidden h-36 bg-surface-container-low mb-2 book-shadow">
                <img
                  src={IMAGES.atomicHabits}
                  alt="Atomic Habits"
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                <span className="absolute top-1.5 left-1.5 bg-emerald-600 text-white text-[9px] font-bold px-1.5 py-0.5 rounded">
                  Like New
                </span>
                <span className="absolute bottom-1.5 right-1.5 bg-white/90 backdrop-blur-xs text-primary text-[10px] font-bold px-1.5 py-0.5 rounded flex items-center gap-0.5 shadow-xs">
                  <span className="material-symbols-outlined text-[12px] text-amber-500 fill">star</span>
                  4.9
                </span>
              </div>

              <div>
                <h4 className="font-headline-sm text-xs font-bold text-primary truncate">Atomic Habits</h4>
                <p className="text-[11px] text-on-surface-variant truncate">James Clear</p>

                <div className="mt-1 flex items-baseline gap-1.5">
                  <span className="text-sm font-extrabold text-primary">$12.50</span>
                  <span className="text-[10px] text-on-surface-variant line-through">$27.00</span>
                </div>

                <button
                  onClick={() => {
                    onAddToCart({
                      id: 'atomic-habits',
                      title: 'Atomic Habits',
                      author: 'James Clear',
                      condition: 'Mint / Like New',
                      price: 12.50,
                      coverImage: IMAGES.atomicHabits,
                      category: 'Business',
                      sellerName: 'AlexBooks'
                    });
                  }}
                  className="w-full mt-2 py-1.5 bg-surface-container-high hover:bg-primary hover:text-white text-primary text-xs font-bold rounded-lg transition-all flex items-center justify-center gap-1 active:scale-95"
                >
                  <span className="material-symbols-outlined text-[15px]">add_shopping_cart</span>
                  Add to Cart
                </button>
              </div>
            </div>

            {/* Book 2: Designing Data-Intensive */}
            <div className="bg-surface-container-lowest rounded-xl p-2.5 border border-outline-variant/60 shadow-xs flex flex-col justify-between group">
              <div className="relative rounded-lg overflow-hidden h-36 bg-surface-container-low mb-2 book-shadow">
                <img
                  src={IMAGES.designingData}
                  alt="Designing Data-Intensive Applications"
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                <span className="absolute top-1.5 left-1.5 bg-blue-600 text-white text-[9px] font-bold px-1.5 py-0.5 rounded">
                  Good
                </span>
                <span className="absolute bottom-1.5 right-1.5 bg-white/90 backdrop-blur-xs text-primary text-[10px] font-bold px-1.5 py-0.5 rounded flex items-center gap-0.5 shadow-xs">
                  <span className="material-symbols-outlined text-[12px] text-amber-500 fill">star</span>
                  5.0
                </span>
              </div>

              <div>
                <h4 className="font-headline-sm text-xs font-bold text-primary truncate">Designing Data-Intensive</h4>
                <p className="text-[11px] text-on-surface-variant truncate">Martin Kleppmann</p>

                <div className="mt-1 flex items-baseline gap-1.5">
                  <span className="text-sm font-extrabold text-primary">$28.00</span>
                </div>

                <button
                  onClick={() => {
                    onAddToCart({
                      id: 'designing-data',
                      title: 'Designing Data-Intensive Applications',
                      author: 'Martin Kleppmann',
                      condition: 'Good',
                      price: 28.00,
                      coverImage: IMAGES.designingData,
                      category: 'Technology',
                      sellerName: 'TechTome Hub'
                    });
                  }}
                  className="w-full mt-2 py-1.5 bg-surface-container-high hover:bg-primary hover:text-white text-primary text-xs font-bold rounded-lg transition-all flex items-center justify-center gap-1 active:scale-95"
                >
                  <span className="material-symbols-outlined text-[15px]">add_shopping_cart</span>
                  Add to Cart
                </button>
              </div>
            </div>

            {/* Book 3: Great Gatsby */}
            <div className="bg-surface-container-lowest rounded-xl p-2.5 border border-outline-variant/60 shadow-xs flex flex-col justify-between group">
              <div className="relative rounded-lg overflow-hidden h-36 bg-surface-container-low mb-2 book-shadow">
                <img
                  src={IMAGES.greatGatsby}
                  alt="The Great Gatsby"
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                <span className="absolute top-1.5 left-1.5 bg-amber-600 text-white text-[9px] font-bold px-1.5 py-0.5 rounded">
                  Acceptable
                </span>
                <span className="absolute bottom-1.5 right-1.5 bg-white/90 backdrop-blur-xs text-primary text-[10px] font-bold px-1.5 py-0.5 rounded flex items-center gap-0.5 shadow-xs">
                  <span className="material-symbols-outlined text-[12px] text-amber-500 fill">star</span>
                  4.7
                </span>
              </div>

              <div>
                <h4 className="font-headline-sm text-xs font-bold text-primary truncate">The Great Gatsby</h4>
                <p className="text-[11px] text-on-surface-variant truncate">F. Scott Fitzgerald</p>

                <div className="mt-1 flex items-baseline gap-1.5">
                  <span className="text-sm font-extrabold text-primary">$6.00</span>
                </div>

                <button
                  onClick={() => {
                    onAddToCart({
                      id: 'great-gatsby',
                      title: 'The Great Gatsby',
                      author: 'F. Scott Fitzgerald',
                      condition: 'Acceptable',
                      price: 6.00,
                      coverImage: IMAGES.greatGatsby,
                      category: 'Fiction',
                      sellerName: 'VintageBookCo'
                    });
                  }}
                  className="w-full mt-2 py-1.5 bg-surface-container-high hover:bg-primary hover:text-white text-primary text-xs font-bold rounded-lg transition-all flex items-center justify-center gap-1 active:scale-95"
                >
                  <span className="material-symbols-outlined text-[15px]">add_shopping_cart</span>
                  Add to Cart
                </button>
              </div>
            </div>

            {/* Bento Inspector Hub spotlight */}
            <div 
              onClick={() => onNavigate('inspector_audit')}
              className="bg-primary text-white rounded-xl p-3 shadow-sm hover:bg-primary-container transition-all cursor-pointer flex flex-col justify-between"
            >
              <div>
                <div className="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center mb-2">
                  <span className="material-symbols-outlined text-[20px] text-secondary-container">
                    verified_user
                  </span>
                </div>
                <h4 className="font-headline-sm text-xs font-bold">Physical Audit Hub</h4>
                <p className="text-[11px] text-white/80 mt-1 line-clamp-3">
                  Every collector volume is certified by an in-person inspector before escrow release.
                </p>
              </div>

              <div className="mt-3 pt-2 border-t border-white/10 flex items-center justify-between text-xs font-bold text-secondary-fixed">
                <span>Audit Console</span>
                <span className="material-symbols-outlined text-[16px]">arrow_forward</span>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};
