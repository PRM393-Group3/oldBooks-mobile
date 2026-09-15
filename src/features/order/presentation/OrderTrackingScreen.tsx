import React, { useState } from 'react';
import { ScreenId } from '../../../core/types';
import { IMAGES } from '../../../core/constants/assets';

interface OrderTrackingScreenProps {
  onNavigate: (screen: ScreenId) => void;
  onOpenDrawer: () => void;
}

const MILESTONES = [
  { id: 1, title: 'Order Confirmed', time: 'Oct 21, 10:14 AM', completed: true, note: 'Payment deposited into BookHub Escrow custody' },
  { id: 2, title: 'Physical Inspection & Seal', time: 'Oct 21, 04:30 PM', completed: true, note: 'Verified Grade 8.5 by Inspector #INSP-402' },
  { id: 3, title: 'Shipped via Courier', time: 'Oct 22, 09:15 AM', completed: true, active: true, note: 'In transit to Brooklyn Distribution Center' },
  { id: 4, title: 'Out for Delivery', time: 'Tomorrow, Oct 24 Morning', completed: false, note: 'Courier route optimization active' },
  { id: 5, title: 'Delivered & Escrow Released', time: 'Pending Delivery', completed: false, note: 'Buyer receives 48-hour inspection grace period' }
];

export const OrderTrackingScreen: React.FC<OrderTrackingScreenProps> = ({
  onNavigate,
  onOpenDrawer
}) => {
  const [escrowReleased, setEscrowReleased] = useState(false);
  const [copied, setCopied] = useState(false);

  const handleCopyTracking = () => {
    navigator.clipboard?.writeText('9400 1000 8921 4452 10');
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleReleaseEscrow = () => {
    setEscrowReleased(true);
  };

  return (
    <div className="min-h-screen bg-surface text-on-surface pb-28">
      {/* Top Header */}
      <header className="sticky top-0 z-30 bg-surface/90 backdrop-blur-md px-4 py-3 border-b border-outline-variant/40 flex items-center justify-between">
        <button
          onClick={() => onNavigate('buyer_home')}
          className="w-9 h-9 rounded-full bg-surface-container-low flex items-center justify-center text-primary hover:bg-surface-container active:scale-95 transition-all"
        >
          <span className="material-symbols-outlined text-[20px]">arrow_back</span>
        </button>

        <div className="text-center">
          <span className="text-[10px] text-on-surface-variant font-bold uppercase tracking-wider block">
            Escrow Track
          </span>
          <h1 className="font-headline-sm text-xs font-bold text-primary">Order #BK-9082</h1>
        </div>

        <button
          onClick={onOpenDrawer}
          className="w-9 h-9 rounded-full overflow-hidden border border-outline-variant"
        >
          <img src={IMAGES.alexanderAvatar} alt="Alexander" className="w-full h-full object-cover" />
        </button>
      </header>

      {/* Main Content */}
      <main className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* Status Hero Card */}
        <div className="bg-primary text-white rounded-2xl p-4 shadow-sm relative overflow-hidden">
          <div className="flex items-center justify-between">
            <span className="text-[10px] uppercase font-bold text-secondary-fixed tracking-wider flex items-center gap-1">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
              IN TRANSIT
            </span>
            <span className="font-mono text-xs font-bold text-white bg-white/10 px-2 py-0.5 rounded">
              USPS Media Mail
            </span>
          </div>

          <h2 className="text-lg font-headline-sm font-extrabold mt-2">
            Tomorrow, Oct 24 by 4:00 PM
          </h2>
          <p className="text-xs text-white/80 mt-0.5">
            Arriving to Brooklyn, NY • Escrow Secured ($46.50)
          </p>

          <div className="mt-3 pt-3 border-t border-white/10 flex items-center justify-between text-xs">
            <span className="text-white/80">Escrow Status:</span>
            <span className="font-bold text-emerald-300 flex items-center gap-1">
              <span className="material-symbols-outlined text-[15px]">verified_user</span>
              {escrowReleased ? 'Released to Seller ✓' : 'Protected in Vault'}
            </span>
          </div>
        </div>

        {/* Live Courier Tracking & Map */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-3">
          <div className="flex items-center justify-between">
            <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider flex items-center gap-1.5">
              <span className="material-symbols-outlined text-[16px] text-primary">local_shipping</span>
              Courier Route & Checkpoint
            </h3>
            <span className="text-[10px] text-emerald-700 font-bold bg-emerald-100 px-2 py-0.5 rounded">
              On Schedule
            </span>
          </div>

          {/* Map image preview */}
          <div className="relative rounded-xl overflow-hidden h-32 w-full bg-surface-container-low border border-outline-variant/60">
            <img
              src={IMAGES.deliveryMap}
              alt="Delivery Map"
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
            <div className="absolute bottom-2 left-3 text-white text-xs font-bold flex items-center gap-1">
              <span className="material-symbols-outlined text-[16px] text-secondary-container">navigation</span>
              <span>Jersey City Sorting Facility ➔ Brooklyn Hub</span>
            </div>
          </div>

          <div className="p-2.5 bg-surface-container-low rounded-xl flex items-center justify-between text-xs">
            <div>
              <span className="text-[10px] text-on-surface-variant font-medium block">Tracking Number</span>
              <span className="font-mono font-bold text-primary">9400 1000 8921 4452 10</span>
            </div>
            <button
              onClick={handleCopyTracking}
              className="px-2.5 py-1 bg-surface-container text-primary rounded-lg font-bold text-[11px] hover:bg-surface-container-high transition-all"
            >
              {copied ? 'Copied ✓' : 'Copy'}
            </button>
          </div>
        </div>

        {/* 5-Milestone Tracking Stepper */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-3">
          <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider">
            Verification & Delivery Milestones
          </h3>

          <div className="space-y-3 relative pl-6 before:absolute before:left-2.5 before:top-2 before:bottom-2 before:w-0.5 before:bg-outline-variant/40">
            {MILESTONES.map((step) => (
              <div key={step.id} className="relative">
                <span className={`absolute -left-6 top-0.5 w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold ${
                  step.active
                    ? 'bg-secondary-container text-white ring-4 ring-secondary-fixed/40 animate-pulse'
                    : step.completed
                    ? 'bg-emerald-600 text-white'
                    : 'bg-surface-container text-on-surface-variant'
                }`}>
                  {step.completed ? '✓' : step.id}
                </span>

                <div>
                  <div className="flex items-center justify-between">
                    <h4 className={`text-xs font-bold ${step.active ? 'text-secondary-container' : 'text-primary'}`}>
                      {step.title}
                    </h4>
                    <span className="text-[10px] text-on-surface-variant">{step.time}</span>
                  </div>
                  <p className="text-[11px] text-on-surface-variant mt-0.5">
                    {step.note}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Item Details Card */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-2.5">
          <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider">
            Purchased Volume
          </h3>

          <div className="flex items-start gap-3 p-3 bg-surface-container-low rounded-xl">
            <div className="w-14 h-20 rounded bg-surface-container overflow-hidden shrink-0 book-shadow">
              <img
                src={IMAGES.leftHandDarknessTrack}
                alt="The Left Hand of Darkness"
                className="w-full h-full object-cover"
              />
            </div>

            <div className="flex-1 min-w-0">
              <h4 className="font-headline-sm text-xs font-bold text-primary truncate">
                The Left Hand of Darkness (1st Ace Edition)
              </h4>
              <p className="text-[11px] text-on-surface-variant truncate">
                Ursula K. Le Guin • 1969 Vintage
              </p>
              <div className="mt-1 flex items-center gap-1 text-[10px] text-emerald-800 font-bold">
                <span className="material-symbols-outlined text-[12px]">verified</span>
                <span>Certified Grade 8.5 Very Good</span>
              </div>
              <div className="mt-1 font-extrabold text-primary text-xs">
                $42.00
              </div>
            </div>
          </div>
        </div>

        {/* Delivery Address & Escrow Release Actions */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-3">
          <div className="flex justify-between items-start text-xs">
            <div>
              <span className="font-bold text-primary block">Recipient</span>
              <span className="text-on-surface-variant">Elena Rostova • 340 Atlantic Ave Apt 4B</span>
              <span className="text-on-surface-variant block">Brooklyn, NY 11201</span>
            </div>
            <div className="text-right">
              <span className="font-bold text-primary block">Total Paid</span>
              <span className="text-on-surface-variant">$46.50 (Escrow)</span>
            </div>
          </div>

          <div className="pt-2 border-t border-outline-variant/40 space-y-2">
            {!escrowReleased ? (
              <button
                onClick={handleReleaseEscrow}
                className="w-full py-2.5 bg-emerald-700 hover:bg-emerald-800 text-white text-xs font-bold rounded-xl shadow-xs transition-all flex items-center justify-center gap-1.5 active:scale-95"
              >
                <span className="material-symbols-outlined text-[16px]">task_alt</span>
                <span>Confirm Book Received & Release Escrow</span>
              </button>
            ) : (
              <div className="p-2.5 bg-emerald-50 border border-emerald-300 rounded-xl text-center text-xs font-bold text-emerald-800">
                Escrow funds successfully released to seller. Thank you!
              </div>
            )}

            <button
              onClick={() => onNavigate('admin_portal')}
              className="w-full py-2 text-on-surface-variant hover:text-red-700 text-xs font-semibold flex items-center justify-center gap-1"
            >
              <span className="material-symbols-outlined text-[16px]">report_problem</span>
              <span>Report Condition Issue or Open Escrow Dispute</span>
            </button>
          </div>
        </div>
      </main>
    </div>
  );
};
