import React, { useState } from 'react';
import { ScreenId, InspectionCheckItem } from '../../../core/types';
import { IMAGES } from '../../../core/constants/assets';

interface InspectorAuditScreenProps {
  onNavigate: (screen: ScreenId) => void;
  onOpenDrawer: () => void;
  checklist: InspectionCheckItem[];
  onToggleChecklist: (id: number) => void;
  onApprove: () => void;
  onReject: (reason: string, notes: string) => void;
  onOpenZoom: (data: { title: string; url: string; note: string }) => void;
}

const EVIDENCE_PHOTOS = [
  { id: 'front', label: 'Front Cover', url: IMAGES.sicpFront, note: 'Front cover laminate intact. No creasing along front gutter hinge.' },
  { id: 'spine', label: 'Spine & Binding', url: IMAGES.sicpSpine, note: 'Spine square and uncracked. Hot-melt PUR adhesive fully bound.' },
  { id: 'back', label: 'Back Cover & Barcode', url: IMAGES.sicpBack, note: 'Back cover UPC barcode scannable. Clean surface without sticker residue.' },
  { id: 'isbn', label: 'Copyright & Colophon', url: IMAGES.sicpIsbn, note: 'Colophon confirms MIT Press 2nd edition 1996 1st print run line.' }
];

export const InspectorAuditScreen: React.FC<InspectorAuditScreenProps> = ({
  onNavigate,
  onOpenDrawer,
  checklist,
  onToggleChecklist,
  onApprove,
  onReject,
  onOpenZoom
}) => {
  const [showRejectModal, setShowRejectModal] = useState(false);
  const [rejectReason, setRejectReason] = useState('condition_mismatch');
  const [rejectNotes, setRejectNotes] = useState('');

  const completedCount = checklist.filter((c) => c.completed).length;
  const isFullyApproved = completedCount === checklist.length;

  const handleConfirmReject = () => {
    onReject(rejectReason, rejectNotes || 'Condition grading and photographic evidence do not match.');
    setShowRejectModal(false);
  };

  return (
    <div className="min-h-screen bg-surface text-on-surface pb-28">
      {/* Top Application Header */}
      <header className="sticky top-0 z-30 bg-surface/90 backdrop-blur-md px-4 py-3 border-b border-outline-variant/40 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <button
            onClick={onOpenDrawer}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-surface-container-low border border-outline-variant/60 hover:bg-surface-container active:scale-95 transition-all"
          >
            <span className="w-2 h-2 rounded-full bg-emerald-500"></span>
            <span className="font-label-md text-xs font-bold text-primary">Inspector Portal</span>
            <span className="material-symbols-outlined text-[16px] text-on-surface-variant">expand_more</span>
          </button>
          <span className="text-[10px] bg-primary text-white font-mono px-2 py-0.5 rounded-full font-bold">
            #INSP-402
          </span>
        </div>

        <div className="flex items-center gap-2">
          <div className="text-right hidden sm:block">
            <span className="text-[10px] text-on-surface-variant font-medium block">Active Ledger Queue</span>
            <span className="text-xs font-bold text-primary">6 Pending • 14 Done</span>
          </div>

          <button
            onClick={onOpenDrawer}
            className="w-9 h-9 rounded-full overflow-hidden border border-outline-variant"
          >
            <img src={IMAGES.alexanderAvatar} alt="Inspector Alexander" className="w-full h-full object-cover" />
          </button>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* Book Under Audit Card */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs">
          <div className="flex items-start justify-between">
            <span className="text-[10px] font-mono uppercase tracking-wider text-on-surface-variant bg-surface-container px-2 py-0.5 rounded font-bold">
              Item Audit #419-MIT
            </span>
            <span className="text-[10px] font-bold text-secondary-container flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-secondary-container animate-ping"></span>
              Live Queue #1
            </span>
          </div>

          <h1 className="font-headline-sm text-base font-extrabold text-primary leading-tight mt-1.5">
            Structure and Interpretation of Computer Programs (SICP)
          </h1>
          <p className="text-xs text-on-surface-variant font-medium mt-0.5">
            Harold Abelson & Gerald Jay Sussman • MIT Press (2nd Edition, 1996)
          </p>

          <div className="mt-3 grid grid-cols-3 gap-2 p-2.5 bg-surface-container-low rounded-xl text-center">
            <div>
              <span className="text-[9px] text-on-surface-variant block uppercase font-semibold">Claimed Grade</span>
              <span className="text-xs font-bold text-emerald-700">9.4 Mint</span>
            </div>
            <div>
              <span className="text-[9px] text-on-surface-variant block uppercase font-semibold">Format</span>
              <span className="text-xs font-bold text-primary">Auction ($40 / $75)</span>
            </div>
            <div>
              <span className="text-[9px] text-on-surface-variant block uppercase font-semibold">Seller Trust</span>
              <span className="text-xs font-bold text-primary">98.2% (412 sales)</span>
            </div>
          </div>
        </div>

        {/* Photographic Evidence Gallery (4 slots) */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-2.5">
          <div className="flex items-center justify-between">
            <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider flex items-center gap-1.5">
              <span className="material-symbols-outlined text-[16px] text-secondary-container">photo_camera</span>
              Physical Evidence Gallery (4 Angles)
            </h3>
            <span className="text-[10px] text-on-surface-variant font-semibold">Tap to Zoom</span>
          </div>

          <div className="grid grid-cols-2 gap-2.5">
            {EVIDENCE_PHOTOS.map((photo) => (
              <div
                key={photo.id}
                onClick={() => onOpenZoom({
                  title: `SICP 2nd Edition - ${photo.label}`,
                  url: photo.url,
                  note: photo.note
                })}
                className="group relative rounded-xl overflow-hidden bg-surface-container-low border border-outline-variant/60 p-1.5 cursor-zoom-in hover:border-primary transition-all"
              >
                <div className="h-28 w-full rounded-lg overflow-hidden relative">
                  <img
                    src={photo.url}
                    alt={photo.label}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent"></div>
                  <span className="absolute bottom-1.5 left-2 text-[10px] font-bold text-white">
                    {photo.label}
                  </span>
                  <span className="absolute top-1.5 right-1.5 w-5 h-5 rounded-full bg-black/50 text-white flex items-center justify-center text-[12px]">
                    <span className="material-symbols-outlined text-[14px]">zoom_in</span>
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Verification Checklist */}
        <div className="bg-surface-container-lowest rounded-2xl p-4 border border-outline-variant/60 shadow-xs space-y-3">
          <div className="flex items-center justify-between">
            <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wider flex items-center gap-1.5">
              <span className="material-symbols-outlined text-[16px] text-primary">task_alt</span>
              Inspection Audit Checklist
            </h3>
            <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${
              isFullyApproved ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'
            }`}>
              {completedCount} / {checklist.length} Verified
            </span>
          </div>

          <p className="text-[11px] text-on-surface-variant">
            Inspector certification is digitally anchored to the immutable escrow ledger before public listing.
          </p>

          <div className="space-y-2">
            {checklist.map((item) => (
              <div
                key={item.id}
                onClick={() => onToggleChecklist(item.id)}
                className={`p-3 rounded-xl border transition-all cursor-pointer flex items-start gap-3 select-none ${
                  item.completed
                    ? 'bg-emerald-50/50 border-emerald-300 text-on-surface'
                    : 'bg-surface-container-low border-outline-variant text-on-surface hover:bg-surface-container'
                }`}
              >
                <div className={`w-5 h-5 rounded-md flex items-center justify-center shrink-0 mt-0.5 transition-colors ${
                  item.completed ? 'bg-emerald-600 text-white' : 'border-2 border-outline-variant bg-white'
                }`}>
                  {item.completed && (
                    <span className="material-symbols-outlined text-[16px]">check</span>
                  )}
                </div>

                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <span className={`text-xs font-bold ${item.completed ? 'text-primary' : 'text-on-surface'}`}>
                      {item.title}
                    </span>
                    {item.required && !item.completed && (
                      <span className="text-[9px] bg-amber-200 text-amber-900 font-bold px-1.5 py-0.2 rounded">
                        Required
                      </span>
                    )}
                  </div>
                  <p className="text-[11px] text-on-surface-variant mt-0.5">
                    {item.description}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Ledger Hash & Escrow Seal Notice */}
        <div className="p-3 rounded-xl bg-surface-container-low border border-outline-variant/60 flex items-center gap-2.5 text-xs text-on-surface-variant">
          <span className="material-symbols-outlined text-[20px] text-primary shrink-0">
            shield_lock
          </span>
          <div className="min-w-0">
            <span className="font-bold text-primary block">Immutable Audit Protocol</span>
            <span className="text-[10px] text-on-surface-variant font-mono truncate block">
              Sha256: 0x8a92f03b...1104e792 | Inspector: #INSP-402
            </span>
          </div>
        </div>
      </main>

      {/* Sticky Bottom Inspection Decision Authority Dock */}
      <div className="fixed bottom-16 left-0 w-full z-30 bg-surface-container-lowest border-t border-outline-variant/60 px-4 py-2.5 shadow-lg">
        <div className="max-w-md mx-auto flex items-center gap-2.5">
          {/* Reject Button */}
          <button
            onClick={() => setShowRejectModal(true)}
            className="px-3.5 py-2.5 rounded-xl border border-red-300 bg-red-50 text-red-700 hover:bg-red-100 text-xs font-bold transition-all flex items-center justify-center gap-1 active:scale-95 shrink-0"
          >
            <span className="material-symbols-outlined text-[16px]">cancel</span>
            <span>Reject</span>
          </button>

          {/* Approve Button */}
          <button
            onClick={onApprove}
            disabled={!isFullyApproved}
            className={`flex-1 py-2.5 px-4 rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-2 shadow-md active:scale-95 ${
              isFullyApproved
                ? 'bg-emerald-700 hover:bg-emerald-800 text-white'
                : 'bg-surface-container text-on-surface-variant/50 cursor-not-allowed'
            }`}
          >
            <span className="material-symbols-outlined text-[18px]">verified</span>
            <span>Approve & Publish Listing</span>
          </button>
        </div>
      </div>

      {/* Rejection Modal */}
      {showRejectModal && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-surface-container-lowest rounded-2xl max-w-sm w-full p-4 border border-outline-variant shadow-2xl space-y-3">
            <div className="flex items-center justify-between">
              <h3 className="font-headline-sm text-sm font-bold text-red-700 flex items-center gap-1">
                <span className="material-symbols-outlined text-[18px]">warning</span>
                Reject Listing #419-MIT
              </h3>
              <button onClick={() => setShowRejectModal(false)} className="text-on-surface-variant">
                <span className="material-symbols-outlined text-[18px]">close</span>
              </button>
            </div>

            <p className="text-xs text-on-surface-variant">
              Select the primary non-compliance issue. The seller will be notified with actionable guidance to rectify their submission.
            </p>

            <div>
              <label className="text-[11px] font-bold text-primary block mb-1">Violation Reason</label>
              <select
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2 text-xs font-medium text-primary outline-hidden"
              >
                <option value="condition_mismatch">Physical condition differs from photos (creasing/tears)</option>
                <option value="isbn_colophon_mismatch">ISBN or publisher colophon does not match 1st edition</option>
                <option value="photo_quality">Uploaded photos blurry or lacking mandatory spine angle</option>
                <option value="pricing_guidelines">Reserve price exceeds ceiling parameters</option>
                <option value="counterfeit_suspected">Suspected reproduction or unauthorized facsimile</option>
              </select>
            </div>

            <div>
              <label className="text-[11px] font-bold text-primary block mb-1">Inspector Notes for Seller</label>
              <textarea
                rows={3}
                placeholder="Provide constructive feedback for seller remediation..."
                value={rejectNotes}
                onChange={(e) => setRejectNotes(e.target.value)}
                className="w-full bg-surface-container-low border border-outline-variant rounded-lg p-2 text-xs text-on-surface outline-hidden focus:ring-2 focus:ring-primary/20"
              />
            </div>

            <div className="flex items-center justify-end gap-2 pt-2 border-t border-outline-variant/40">
              <button
                onClick={() => setShowRejectModal(false)}
                className="px-3 py-1.5 text-xs font-bold text-on-surface-variant hover:text-primary"
              >
                Cancel
              </button>
              <button
                onClick={handleConfirmReject}
                className="px-4 py-1.5 bg-red-700 text-white text-xs font-bold rounded-lg shadow-xs hover:bg-red-800"
              >
                Confirm Rejection
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
