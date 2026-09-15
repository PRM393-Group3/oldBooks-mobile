import React, { useState } from 'react';
import { ScreenId, SellerListing } from '../../../core/types';
import { IMAGES } from '../../../core/constants/assets';

interface NewBookListingScreenProps {
  onNavigate: (screen: ScreenId) => void;
  onSubmitListing: (newListing: Partial<SellerListing>) => void;
}

export const NewBookListingScreen: React.FC<NewBookListingScreenProps> = ({
  onNavigate,
  onSubmitListing
}) => {
  const [sellingFormat, setSellingFormat] = useState<'auction' | 'fixed'>('auction');
  const [selectedCondition, setSelectedCondition] = useState('Very Good');
  const [title, setTitle] = useState('Neuromancer (30th Anniversary Edition)');
  const [author, setAuthor] = useState('William Gibson • Ace Books');
  const [isbn, setIsbn] = useState('978-0441569595');
  const [startPrice, setStartPrice] = useState('25.00');
  const [reservePrice, setReservePrice] = useState('60.00');
  const [duration, setDuration] = useState('5 Days');
  const [flawNotes, setFlawNotes] = useState('Minor corner bump on lower back edge. Crisp uncreased spine. Clean text block.');

  const handleSubmit = () => {
    onSubmitListing({
      title,
      author,
      edition: 'Ace 30th Anniversary',
      format: 'Paperback',
      price: parseFloat(startPrice) || 25.00,
      priceType: sellingFormat === 'auction' ? 'Live Auction' : 'Fixed Price',
      status: 'WAITING FOR INSPECTOR APPROVAL',
      coverImage: IMAGES.neuromancerFront,
      timeAgo: 'Just now',
      extraInfo: 'Queue Position: #4 in Brooklyn'
    });
    onNavigate('seller_hub');
  };

  return (
    <div className="min-h-screen bg-surface text-on-surface pb-28">
      {/* Top Header */}
      <header className="sticky top-0 z-30 bg-surface/90 backdrop-blur-md px-4 py-3 border-b border-outline-variant/40">
        <div className="flex items-center justify-between">
          <button
            onClick={() => onNavigate('seller_hub')}
            className="w-9 h-9 rounded-full bg-surface-container-low flex items-center justify-center text-primary hover:bg-surface-container active:scale-95 transition-all"
          >
            <span className="material-symbols-outlined text-[20px]">arrow_back</span>
          </button>
          <div className="text-center">
            <span className="text-[10px] text-on-surface-variant font-bold uppercase tracking-wider block">
              Step 2 of 2
            </span>
            <h1 className="font-headline-sm text-xs font-bold text-primary">Listing Spec & Inspection Prep</h1>
          </div>
          <button
            onClick={() => onNavigate('seller_hub')}
            className="text-xs font-bold text-on-surface-variant hover:text-primary"
          >
            Cancel
          </button>
        </div>

        {/* Linear Stepper bar */}
        <div className="mt-2.5 h-1.5 w-full bg-surface-container-high rounded-full overflow-hidden">
          <div className="h-full bg-secondary-container rounded-full w-full"></div>
        </div>
      </header>

      {/* Main Form Content */}
      <main className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* Inspection Photographs (4 slots) */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-2.5">
          <div className="flex items-center justify-between">
            <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider flex items-center gap-1.5">
              <span className="material-symbols-outlined text-[16px] text-secondary-container">add_a_photo</span>
              Photographs for Physical Audit (4 Slots)
            </h3>
            <span className="text-[10px] font-bold text-emerald-700 bg-emerald-100 px-2 py-0.5 rounded">
              3 Uploaded
            </span>
          </div>
          <p className="text-[11px] text-on-surface-variant">
            High clarity, unedited photos are inspected by our specialist team before the book is listed.
          </p>

          <div className="grid grid-cols-4 gap-2">
            {/* Slot 1: Front */}
            <div className="relative rounded-xl overflow-hidden bg-surface-container-low border border-outline-variant aspect-3/4 book-shadow">
              <img src={IMAGES.neuromancerFront} alt="Front" className="w-full h-full object-cover" />
              <span className="absolute bottom-1 left-1 bg-black/60 text-white text-[8px] font-bold px-1 rounded">
                Front
              </span>
            </div>

            {/* Slot 2: Spine */}
            <div className="relative rounded-xl overflow-hidden bg-surface-container-low border border-outline-variant aspect-3/4 book-shadow">
              <img src={IMAGES.neuromancerSpine} alt="Spine" className="w-full h-full object-cover" />
              <span className="absolute bottom-1 left-1 bg-black/60 text-white text-[8px] font-bold px-1 rounded">
                Spine
              </span>
            </div>

            {/* Slot 3: Back */}
            <div className="relative rounded-xl overflow-hidden bg-surface-container-low border border-outline-variant aspect-3/4 book-shadow">
              <img src={IMAGES.neuromancerBack} alt="Back" className="w-full h-full object-cover" />
              <span className="absolute bottom-1 left-1 bg-black/60 text-white text-[8px] font-bold px-1 rounded">
                Back
              </span>
            </div>

            {/* Slot 4: ISBN/Copyright Required */}
            <div className="relative rounded-xl border-2 border-dashed border-secondary-container/60 bg-secondary-fixed/10 aspect-3/4 flex flex-col items-center justify-center p-1 text-center cursor-pointer hover:bg-secondary-fixed/20 transition-all">
              <span className="material-symbols-outlined text-[20px] text-secondary-container">add_circle</span>
              <span className="text-[9px] font-bold text-secondary-container mt-1">ISBN Page</span>
              <span className="text-[8px] text-on-surface-variant">Required</span>
            </div>
          </div>
        </div>

        {/* Book Details Inputs */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-3">
          <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider">
            Bibliographic Details
          </h3>

          <div>
            <label className="text-[11px] font-bold text-primary block mb-1">Book Title</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full bg-surface-container-low border border-outline-variant/80 rounded-xl px-3 py-2 text-xs font-medium text-primary outline-hidden focus:ring-2 focus:ring-primary/20"
            />
          </div>

          <div>
            <label className="text-[11px] font-bold text-primary block mb-1">Author & Publisher</label>
            <input
              type="text"
              value={author}
              onChange={(e) => setAuthor(e.target.value)}
              className="w-full bg-surface-container-low border border-outline-variant/80 rounded-xl px-3 py-2 text-xs font-medium text-primary outline-hidden focus:ring-2 focus:ring-primary/20"
            />
          </div>

          <div className="grid grid-cols-2 gap-2">
            <div>
              <label className="text-[11px] font-bold text-primary block mb-1">ISBN-13</label>
              <div className="flex items-center bg-surface-container-low border border-outline-variant/80 rounded-xl px-2.5 py-2">
                <input
                  type="text"
                  value={isbn}
                  onChange={(e) => setIsbn(e.target.value)}
                  className="w-full bg-transparent border-none outline-hidden text-xs font-mono font-bold text-primary"
                />
                <span className="material-symbols-outlined text-[16px] text-emerald-600">verified</span>
              </div>
            </div>

            <div>
              <label className="text-[11px] font-bold text-primary block mb-1">Category</label>
              <select className="w-full bg-surface-container-low border border-outline-variant/80 rounded-xl px-2.5 py-2 text-xs font-semibold text-primary outline-hidden">
                <option>Sci-Fi & Cyberpunk</option>
                <option>Fiction & Literature</option>
                <option>Antiquarian Folio</option>
                <option>Technology & Code</option>
              </select>
            </div>
          </div>

          {/* Condition Pills */}
          <div>
            <label className="text-[11px] font-bold text-primary block mb-1.5">Self-Assessed Condition</label>
            <div className="grid grid-cols-4 gap-1.5">
              {['Mint', 'Very Good', 'Good', 'Acceptable'].map((c) => (
                <button
                  key={c}
                  type="button"
                  onClick={() => setSelectedCondition(c)}
                  className={`py-1.5 px-1 rounded-xl text-xs font-bold text-center transition-all ${
                    selectedCondition === c
                      ? 'bg-primary text-white shadow-xs'
                      : 'bg-surface-container-low border border-outline-variant text-on-surface hover:bg-surface-container'
                  }`}
                >
                  {c}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="text-[11px] font-bold text-primary block mb-1">Flaws & Inspector Notes</label>
            <textarea
              rows={2}
              value={flawNotes}
              onChange={(e) => setFlawNotes(e.target.value)}
              className="w-full bg-surface-container-low border border-outline-variant/80 rounded-xl px-3 py-2 text-xs text-on-surface outline-hidden focus:ring-2 focus:ring-primary/20"
            />
          </div>
        </div>

        {/* Selling Method Toggle & Parameters */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-3">
          <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider">
            Selling Format & Pricing
          </h3>

          <div className="grid grid-cols-2 gap-2">
            <button
              type="button"
              onClick={() => setSellingFormat('auction')}
              className={`p-3 rounded-xl border text-left transition-all ${
                sellingFormat === 'auction'
                  ? 'bg-secondary-container text-white border-secondary-container shadow-xs'
                  : 'bg-surface-container-low border-outline-variant text-on-surface'
              }`}
            >
              <div className="flex items-center justify-between">
                <span className="material-symbols-outlined text-[20px]">gavel</span>
                <span className="text-[9px] font-bold px-1.5 py-0.5 rounded bg-white/20 text-white">RECOMMENDED</span>
              </div>
              <div className="font-bold text-xs mt-1">Live Auction</div>
              <div className="text-[10px] opacity-80 mt-0.5">Competitive bidding with reserve</div>
            </button>

            <button
              type="button"
              onClick={() => setSellingFormat('fixed')}
              className={`p-3 rounded-xl border text-left transition-all ${
                sellingFormat === 'fixed'
                  ? 'bg-primary text-white border-primary shadow-xs'
                  : 'bg-surface-container-low border-outline-variant text-on-surface'
              }`}
            >
              <div className="flex items-center justify-between">
                <span className="material-symbols-outlined text-[20px]">sell</span>
                <span className="text-[9px] font-bold px-1.5 py-0.5 rounded bg-surface-container text-on-surface-variant">INSTANT</span>
              </div>
              <div className="font-bold text-xs mt-1">Fixed Price</div>
              <div className="text-[10px] opacity-80 mt-0.5">Instant checkout to buyer</div>
            </button>
          </div>

          {sellingFormat === 'auction' ? (
            <div className="space-y-2.5 pt-1">
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="text-[11px] font-bold text-primary block mb-1">Starting Price ($)</label>
                  <input
                    type="number"
                    value={startPrice}
                    onChange={(e) => setStartPrice(e.target.value)}
                    className="w-full bg-surface-container-low border border-outline-variant rounded-xl px-3 py-2 text-xs font-bold text-primary outline-hidden"
                  />
                </div>
                <div>
                  <label className="text-[11px] font-bold text-primary block mb-1">Reserve Price ($)</label>
                  <input
                    type="number"
                    value={reservePrice}
                    onChange={(e) => setReservePrice(e.target.value)}
                    className="w-full bg-surface-container-low border border-outline-variant rounded-xl px-3 py-2 text-xs font-bold text-primary outline-hidden"
                  />
                </div>
              </div>

              <div>
                <label className="text-[11px] font-bold text-primary block mb-1">Auction Duration</label>
                <div className="grid grid-cols-3 gap-2">
                  {['3 Days', '5 Days', '7 Days'].map((d) => (
                    <button
                      key={d}
                      type="button"
                      onClick={() => setDuration(d)}
                      className={`py-1.5 px-2 rounded-xl text-xs font-bold text-center transition-all ${
                        duration === d
                          ? 'bg-primary text-white shadow-xs'
                          : 'bg-surface-container-low border border-outline-variant text-on-surface'
                      }`}
                    >
                      {d}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          ) : (
            <div>
              <label className="text-[11px] font-bold text-primary block mb-1">Fixed Price ($)</label>
              <input
                type="number"
                value={startPrice}
                onChange={(e) => setStartPrice(e.target.value)}
                className="w-full bg-surface-container-low border border-outline-variant rounded-xl px-3 py-2 text-xs font-bold text-primary outline-hidden"
              />
            </div>
          )}
        </div>

        {/* Escrow Guarantee Notice */}
        <div className="p-3 rounded-xl bg-surface-container-low border border-outline-variant/60 flex items-center gap-2.5 text-xs text-on-surface-variant">
          <span className="material-symbols-outlined text-[20px] text-secondary-container shrink-0">
            verified
          </span>
          <div>
            <span className="font-bold text-primary block">Physical Audit Routing</span>
            <span className="text-[11px] text-on-surface-variant">
              Upon submission, your listing will be dispatched to the Brooklyn Inspection Ledger queue.
            </span>
          </div>
        </div>
      </main>

      {/* Sticky Bottom Dock */}
      <div className="fixed bottom-0 left-0 w-full z-30 bg-surface-container-lowest border-t border-outline-variant/60 px-4 py-3 pb-safe shadow-lg">
        <div className="max-w-md mx-auto flex items-center gap-3">
          <button
            onClick={() => onNavigate('seller_hub')}
            className="py-2.5 px-4 rounded-xl border border-outline-variant text-xs font-bold text-primary hover:bg-surface-container transition-all"
          >
            Save Draft
          </button>
          <button
            onClick={handleSubmit}
            className="flex-1 py-2.5 px-4 bg-secondary-container hover:bg-secondary-container/90 text-white text-xs font-bold rounded-xl shadow-md transition-all flex items-center justify-center gap-1.5 active:scale-95"
          >
            <span className="material-symbols-outlined text-[18px]">verified</span>
            <span>Submit for Inspection</span>
          </button>
        </div>
      </div>
    </div>
  );
};
