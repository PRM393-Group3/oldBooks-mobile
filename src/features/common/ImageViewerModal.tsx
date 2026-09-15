import React from 'react';

interface ImageViewerModalProps {
  data: { title: string; url: string; note: string } | null;
  onClose: () => void;
}

export const ImageViewerModal: React.FC<ImageViewerModalProps> = ({ data, onClose }) => {
  if (!data) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-4">
      <div className="bg-surface-container-lowest rounded-2xl max-w-lg w-full overflow-hidden shadow-2xl border border-outline-variant animate-in zoom-in-95 duration-200">
        <div className="p-4 border-b border-outline-variant flex items-center justify-between bg-surface-container-low">
          <div>
            <h3 className="font-headline-sm text-sm font-bold text-primary">{data.title}</h3>
            <p className="font-body-sm text-xs text-on-surface-variant">High-Resolution Physical Verification Scan</p>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-surface-container flex items-center justify-center text-on-surface-variant hover:text-primary transition-all"
          >
            <span className="material-symbols-outlined text-[18px]">close</span>
          </button>
        </div>

        <div className="p-4 flex items-center justify-center bg-black/90 min-h-[340px]">
          <img
            src={data.url}
            alt={data.title}
            className="max-h-[65vh] w-auto object-contain rounded-lg shadow-lg"
          />
        </div>

        <div className="p-4 bg-surface-container-low border-t border-outline-variant text-xs text-on-surface-variant flex items-start gap-2">
          <span className="material-symbols-outlined text-[18px] text-secondary-container shrink-0 mt-0.5">
            verified
          </span>
          <div>
            <p className="font-semibold text-primary">Inspection Evidence Forensic Log</p>
            <p className="mt-0.5">{data.note}</p>
          </div>
        </div>
      </div>
    </div>
  );
};
