import React, { useState, useEffect } from 'react';
import { ScreenId, BidRecord } from '../../../core/types';
import { IMAGES } from '../../../core/constants/assets';

interface LiveAuctionDetailScreenProps {
  onNavigate: (screen: ScreenId) => void;
  currentHighBid: number;
  bidsCount: number;
  userIsHighBidder: boolean;
  bidHistory: BidRecord[];
  onPlaceBid: (amount: number) => void;
  onOpenZoom: (data: { title: string; url: string; note: string }) => void;
}

export const LiveAuctionDetailScreen: React.FC<LiveAuctionDetailScreenProps> = ({
  onNavigate,
  currentHighBid,
  bidsCount,
  userIsHighBidder,
  bidHistory,
  onPlaceBid,
  onOpenZoom
}) => {
  const [bookmarked, setBookmarked] = useState(false);
  const [selectedIncrement, setSelectedIncrement] = useState<number>(5);
  const [customBid, setCustomBid] = useState<string>('');
  const [showHistory, setShowHistory] = useState(false);
  const [secondsRemaining, setSecondsRemaining] = useState(6492); // ~1h 48m 12s

  useEffect(() => {
    const timer = setInterval(() => {
      setSecondsRemaining((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const hours = Math.floor(secondsRemaining / 3600);
  const minutes = Math.floor((secondsRemaining % 3600) / 60);
  const seconds = secondsRemaining % 60;
  const timeString = `${String(hours).padStart(2, '0')}h ${String(minutes).padStart(2, '0')}m ${String(seconds).padStart(2, '0')}s`;

  const calculatedBidAmount = customBid ? parseFloat(customBid) : currentHighBid + selectedIncrement;

  const handleBidSubmit = () => {
    if (calculatedBidAmount > currentHighBid) {
      onPlaceBid(calculatedBidAmount);
      setCustomBid('');
    }
  };

  return (
    <div className="min-h-screen bg-surface text-on-surface pb-28">
      {/* Top App Bar */}
      <header className="sticky top-0 z-30 bg-surface/90 backdrop-blur-md px-4 py-3 border-b border-outline-variant/40 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <button
            onClick={() => onNavigate('buyer_home')}
            className="w-9 h-9 rounded-full bg-surface-container-low flex items-center justify-center text-primary hover:bg-surface-container active:scale-95 transition-all"
            aria-label="Back"
          >
            <span className="material-symbols-outlined text-[20px]">arrow_back</span>
          </button>
          <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-red-100 text-red-700 text-xs font-bold">
            <span className="w-2 h-2 rounded-full bg-red-600 animate-pulse"></span>
            LIVE AUCTION
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setBookmarked(!bookmarked)}
            className={`w-9 h-9 rounded-full flex items-center justify-center transition-all ${
              bookmarked
                ? 'bg-secondary-fixed text-on-secondary-fixed'
                : 'bg-surface-container-low text-on-surface hover:bg-surface-container'
            }`}
            title="Save to Watchlist"
          >
            <span className={`material-symbols-outlined text-[20px] ${bookmarked ? 'fill' : ''}`}>
              bookmark
            </span>
          </button>
          <button
            onClick={() => {
              if (navigator.share) {
                navigator.share({ title: 'Dune (1965 1st Edition)', url: window.location.href });
              }
            }}
            className="w-9 h-9 rounded-full bg-surface-container-low flex items-center justify-center text-on-surface hover:bg-surface-container transition-all"
            title="Share"
          >
            <span className="material-symbols-outlined text-[20px]">share</span>
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* Book Cover Canvas */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs relative">
          <div 
            onClick={() => onOpenZoom({
              title: 'Dune (1965 First Edition) - Cover & Spine Scan',
              url: IMAGES.duneDetail,
              note: 'Verified Chilton Book Company 1st Edition imprint. DJ unclipped $5.95 price point.'
            })}
            className="relative h-72 w-full flex items-center justify-center bg-surface-container-low rounded-xl overflow-hidden cursor-zoom-in group"
          >
            <img
              src={IMAGES.duneDetail}
              alt="Dune 1965 First Edition"
              className="h-full w-auto object-contain book-shadow group-hover:scale-105 transition-transform duration-300"
            />
            {/* Spine shadow simulation */}
            <div className="absolute inset-y-0 left-12 w-2 bg-gradient-to-r from-black/25 to-transparent pointer-events-none"></div>

            {/* Tap to zoom badge */}
            <div className="absolute bottom-2 right-2 bg-black/60 backdrop-blur-xs text-white px-2 py-1 rounded-md text-[10px] font-semibold flex items-center gap-1">
              <span className="material-symbols-outlined text-[14px]">zoom_in</span>
              1 of 5 Photos
            </div>

            {/* Inspection Stamp Badge */}
            <div className="absolute top-2 left-2 bg-primary/90 backdrop-blur-xs text-white px-2 py-1 rounded-md text-[10px] font-bold flex items-center gap-1 shadow-xs">
              <span className="material-symbols-outlined text-[13px] text-emerald-400">verified</span>
              Grade 8.5 • VF
            </div>
          </div>
        </div>

        {/* Title & Metadata */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs">
          <div className="flex items-start justify-between gap-2">
            <div>
              <span className="text-xs font-bold text-secondary-container uppercase tracking-wider">
                Rare Sci-Fi • 1st Edition
              </span>
              <h1 className="text-lg font-headline-md font-extrabold text-primary leading-tight mt-0.5">
                Dune (1965 1st Edition, 2nd State)
              </h1>
              <p className="text-xs text-on-surface-variant font-medium mt-0.5">
                by Frank Herbert • Chilton Book Company, Philadelphia
              </p>
            </div>
          </div>

          {/* Quick Specifications Grid */}
          <div className="grid grid-cols-2 gap-2 mt-3 p-3 bg-surface-container-low rounded-xl text-xs">
            <div>
              <span className="text-[10px] text-on-surface-variant uppercase font-semibold block">Format & Binding</span>
              <span className="font-bold text-primary">Hardcover with Mylar DJ</span>
            </div>
            <div>
              <span className="text-[10px] text-on-surface-variant uppercase font-semibold block">Publication Year</span>
              <span className="font-bold text-primary">1965 (Chilton)</span>
            </div>
            <div>
              <span className="text-[10px] text-on-surface-variant uppercase font-semibold block">ISBN-13</span>
              <span className="font-bold text-primary font-mono">978-0441172719</span>
            </div>
            <div>
              <span className="text-[10px] text-on-surface-variant uppercase font-semibold block">Page Count</span>
              <span className="font-bold text-primary">412 Pages</span>
            </div>
          </div>

          <div className="mt-3 text-xs text-on-surface-variant">
            <span className="font-semibold text-primary">Condition Summary: </span>
            Clean crisp spine with minor bottom edge bumping. Interior pages without foxing or marginalia. Dust jacket priced at $5.95 intact.
          </div>
        </div>

        {/* Live Auction Bento Card */}
        <div className="bg-primary text-white rounded-2xl p-4 shadow-md relative overflow-hidden">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-1.5 text-xs text-secondary-fixed font-bold">
              <span className="material-symbols-outlined text-[16px]">schedule</span>
              TIME REMAINING
            </div>
            <div className="font-mono text-sm font-extrabold text-white bg-white/10 px-2.5 py-0.5 rounded-full">
              {timeString}
            </div>
          </div>

          <div className="mt-4 flex items-end justify-between">
            <div>
              <span className="text-xs text-white/80 font-medium block">Current Highest Bid</span>
              <div className="text-3xl font-extrabold text-white mt-0.5 flex items-baseline gap-2">
                ${currentHighBid.toFixed(2)}
                <span className="text-xs text-emerald-400 font-bold bg-emerald-950/60 px-2 py-0.5 rounded-full border border-emerald-500/30">
                  Reserve Met
                </span>
              </div>
            </div>
            <div className="text-right">
              <span className="text-xs text-white/80 block">{bidsCount} Total Bids</span>
              <span className="text-[11px] text-secondary-fixed block">Min Incr: +$5.00</span>
            </div>
          </div>

          {/* User Bid Status Pill */}
          <div className="mt-3 p-2.5 rounded-xl bg-white/10 backdrop-blur-xs flex items-center justify-between text-xs">
            <div className="flex items-center gap-2">
              <span className={`material-symbols-outlined text-[18px] ${userIsHighBidder ? 'text-emerald-400' : 'text-amber-300'}`}>
                {userIsHighBidder ? 'verified_user' : 'warning'}
              </span>
              <span>
                {userIsHighBidder ? (
                  <strong className="text-emerald-300">You are the highest bidder! ($ {currentHighBid.toFixed(2)})</strong>
                ) : (
                  <span>Outbid by <strong>user_8829</strong></span>
                )}
              </span>
            </div>
            <button
              onClick={() => setShowHistory(!showHistory)}
              className="text-secondary-fixed text-xs font-bold underline cursor-pointer"
            >
              {showHistory ? 'Hide Bids' : 'History'}
            </button>
          </div>

          {/* Expandable Bid History */}
          {showHistory && (
            <div className="mt-3 pt-3 border-t border-white/20 space-y-2 max-h-48 overflow-y-auto no-scrollbar">
              <span className="text-[11px] text-white/80 font-bold uppercase tracking-wider block">
                Bidder Audit Trail
              </span>
              {bidHistory.map((bid) => (
                <div key={bid.id} className="flex items-center justify-between text-xs bg-white/5 px-2.5 py-1.5 rounded-lg">
                  <div className="flex items-center gap-2">
                    <span className="w-5 h-5 rounded-full bg-secondary-container text-white text-[10px] font-bold flex items-center justify-center">
                      {bid.avatarLetter}
                    </span>
                    <span className="font-semibold">{bid.bidder}</span>
                    {bid.isUser && (
                      <span className="text-[9px] bg-white/20 px-1 rounded text-white font-bold">YOU</span>
                    )}
                  </div>
                  <div className="text-right">
                    <span className="font-extrabold text-white">${bid.amount.toFixed(2)}</span>
                    <span className="text-[10px] text-white/60 block">{bid.timestamp}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Quick Bid Console */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-3">
          <h3 className="font-headline-sm text-sm font-bold text-primary flex items-center gap-1.5">
            <span className="material-symbols-outlined text-[18px] text-secondary-container">gavel</span>
            Quick Bid Console
          </h3>

          {/* Preset increment buttons */}
          <div className="grid grid-cols-3 gap-2">
            {[5, 10, 25].map((inc) => (
              <button
                key={inc}
                onClick={() => {
                  setSelectedIncrement(inc);
                  setCustomBid('');
                }}
                className={`py-2 px-1 rounded-xl text-xs font-bold transition-all active:scale-95 ${
                  selectedIncrement === inc && !customBid
                    ? 'bg-primary text-white shadow-xs'
                    : 'bg-surface-container-low border border-outline-variant text-on-surface hover:bg-surface-container'
                }`}
              >
                +${inc} (${(currentHighBid + inc).toFixed(2)})
              </button>
            ))}
          </div>

          {/* Custom Bid Input */}
          <div className="flex items-center gap-2">
            <div className="relative flex-1">
              <span className="absolute left-3 top-2.5 text-xs text-on-surface-variant font-bold">$</span>
              <input
                type="number"
                placeholder={`Min: $${(currentHighBid + 5).toFixed(2)}`}
                value={customBid}
                onChange={(e) => setCustomBid(e.target.value)}
                className="w-full pl-7 pr-3 py-2 bg-surface-container-low border border-outline-variant/80 rounded-xl text-xs font-bold text-primary outline-hidden focus:ring-2 focus:ring-primary/20"
              />
            </div>
            <button
              onClick={handleBidSubmit}
              disabled={calculatedBidAmount <= currentHighBid}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition-all shadow-xs active:scale-95 ${
                calculatedBidAmount > currentHighBid
                  ? 'bg-secondary-container text-white hover:bg-secondary-container/90'
                  : 'bg-surface-container text-on-surface-variant/50 cursor-not-allowed'
              }`}
            >
              Bid ${calculatedBidAmount.toFixed(2)}
            </button>
          </div>
        </div>

        {/* Physical Inspection & Escrow Certificate */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs flex items-start gap-3">
          <div className="w-10 h-10 rounded-xl bg-primary-fixed flex items-center justify-center text-on-primary-fixed shrink-0">
            <span className="material-symbols-outlined text-[24px]">verified</span>
          </div>
          <div>
            <h4 className="font-headline-sm text-xs font-bold text-primary">
              BookHub Escrow & Certified Audit
            </h4>
            <p className="text-[11px] text-on-surface-variant mt-0.5 leading-relaxed">
              Certificate <strong>#BK-78902-DX</strong>. Funds remain securely locked in Escrow until the book is received, authenticated, and approved by the buyer.
            </p>
            <button
              onClick={() => onNavigate('inspector_audit')}
              className="mt-2 text-xs font-bold text-secondary-container hover:underline inline-flex items-center gap-1"
            >
              <span>View Certified Inspector Ledger</span>
              <span className="material-symbols-outlined text-[14px]">open_in_new</span>
            </button>
          </div>
        </div>
      </main>

      {/* Sticky Bottom Bid Confirmation Bar */}
      <div className="fixed bottom-16 left-0 w-full z-30 bg-surface-container-lowest border-t border-outline-variant/60 px-4 py-2 shadow-lg">
        <div className="max-w-md mx-auto flex items-center justify-between gap-3">
          <div>
            <span className="text-[10px] text-on-surface-variant uppercase font-medium block">Next Minimum Bid</span>
            <span className="text-base font-extrabold text-primary">${calculatedBidAmount.toFixed(2)}</span>
          </div>
          <button
            onClick={handleBidSubmit}
            className="flex-1 py-2.5 px-4 bg-primary hover:bg-primary-container text-white text-xs font-bold rounded-xl shadow-md transition-all flex items-center justify-center gap-2 active:scale-95"
          >
            <span className="material-symbols-outlined text-[18px]">gavel</span>
            <span>Confirm & Place Bid</span>
          </button>
        </div>
      </div>
    </div>
  );
};
