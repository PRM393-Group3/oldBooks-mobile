import React, { useState } from 'react';
import { ScreenId, DisputeCase, UserReputation, InspectorLedgerEntry } from '../../../core/types';
import { IMAGES } from '../../../core/constants/assets';

interface AdminPortalScreenProps {
  onNavigate: (screen: ScreenId) => void;
  onOpenDrawer: () => void;
  disputes: DisputeCase[];
  users: UserReputation[];
  ledgerStream: InspectorLedgerEntry[];
  onFreezeEscrow: (disputeId: string) => void;
  onRefundDispute: (disputeId: string) => void;
}

export const AdminPortalScreen: React.FC<AdminPortalScreenProps> = ({
  onNavigate,
  onOpenDrawer,
  disputes,
  users,
  ledgerStream,
  onFreezeEscrow,
  onRefundDispute
}) => {
  const [activeTab, setActiveTab] = useState<'disputes' | 'users' | 'ledger'>('disputes');

  return (
    <div className="min-h-screen bg-surface text-on-surface pb-24">
      {/* Top Application Header */}
      <header className="sticky top-0 z-30 bg-surface/90 backdrop-blur-md px-4 py-3 border-b border-outline-variant/40 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <button
            onClick={onOpenDrawer}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-surface-container-low border border-outline-variant/60 hover:bg-surface-container active:scale-95 transition-all"
          >
            <span className="w-2 h-2 rounded-full bg-red-500"></span>
            <span className="font-label-md text-xs font-bold text-primary">Admin Portal</span>
            <span className="material-symbols-outlined text-[16px] text-on-surface-variant">expand_more</span>
          </button>
          <div className="flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-bold">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-600 animate-pulse"></span>
            LEDGER LIVE
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={onOpenDrawer}
            className="w-9 h-9 rounded-full overflow-hidden border border-outline-variant"
          >
            <img src={IMAGES.alexanderAdmin} alt="Admin Alexander" className="w-full h-full object-cover" />
          </button>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-md mx-auto px-4 pt-3 space-y-4">
        {/* Governance Operations Banner */}
        <div className="bg-primary text-white rounded-2xl p-4 shadow-sm flex items-center justify-between">
          <div>
            <span className="text-[10px] uppercase font-bold text-secondary-fixed tracking-wider">
              SUPER GOVERNANCE
            </span>
            <h1 className="font-headline-sm text-sm font-extrabold mt-0.5">Operations & Escrow Oversight</h1>
            <p className="text-xs text-white/80 mt-0.5">24h SLA 100% On-Time • 99.8% Nominal</p>
          </div>
          <div className="flex flex-col gap-1.5">
            <button
              onClick={() => alert('Audited snapshot exported to encrypted CSV.')}
              className="px-2.5 py-1 bg-white/10 hover:bg-white/20 text-white rounded text-[11px] font-bold transition-all"
            >
              Export
            </button>
            <button
              onClick={() => alert('Emergency Escrow Lock Triggered. All unreleased escrows paused.')}
              className="px-2.5 py-1 bg-red-500/80 hover:bg-red-500 text-white rounded text-[11px] font-bold transition-all"
            >
              Lock
            </button>
          </div>
        </div>

        {/* 6 KPI Bento Statistics */}
        <div className="grid grid-cols-3 gap-2">
          <div className="bg-surface-container-lowest rounded-xl p-2.5 border border-outline-variant/60 shadow-xs text-center">
            <span className="text-[10px] text-on-surface-variant font-medium block">Total Users</span>
            <span className="text-base font-extrabold text-primary block mt-0.5">12,480</span>
            <span className="text-[9px] text-emerald-600 font-bold">+8.2%</span>
          </div>

          <div className="bg-surface-container-lowest rounded-xl p-2.5 border border-outline-variant/60 shadow-xs text-center">
            <span className="text-[10px] text-on-surface-variant font-medium block">Listings</span>
            <span className="text-base font-extrabold text-primary block mt-0.5">8,920</span>
            <span className="text-[9px] text-primary font-bold">1,240 Sellers</span>
          </div>

          <div className="bg-surface-container-lowest rounded-xl p-2.5 border border-outline-variant/60 shadow-xs text-center">
            <span className="text-[10px] text-on-surface-variant font-medium block">Disputes</span>
            <span className="text-base font-extrabold text-red-700 block mt-0.5">6 Open</span>
            <span className="text-[9px] text-red-700 font-bold">Urgent SLA</span>
          </div>
        </div>

        {/* Admin Section Tabs */}
        <div className="flex items-center gap-2 border-b border-outline-variant/60 pb-1">
          <button
            onClick={() => setActiveTab('disputes')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'disputes'
                ? 'bg-primary text-white shadow-xs'
                : 'text-on-surface-variant hover:text-primary'
            }`}
          >
            Disputes (3 Urgent)
          </button>
          <button
            onClick={() => setActiveTab('users')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'users'
                ? 'bg-primary text-white shadow-xs'
                : 'text-on-surface-variant hover:text-primary'
            }`}
          >
            Reputation Ledger
          </button>
          <button
            onClick={() => setActiveTab('ledger')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'ledger'
                ? 'bg-primary text-white shadow-xs'
                : 'text-on-surface-variant hover:text-primary'
            }`}
          >
            Audit Stream
          </button>
        </div>

        {/* TAB 1: Disputes Queue */}
        {activeTab === 'disputes' && (
          <div className="space-y-3">
            {disputes.map((dispute) => (
              <div
                key={dispute.id}
                className="bg-surface-container-lowest rounded-2xl p-3.5 border border-outline-variant/60 shadow-xs space-y-2.5"
              >
                <div className="flex items-start justify-between gap-2">
                  <div className="flex items-center gap-1.5">
                    <span className="font-mono text-xs font-bold text-red-700 bg-red-100 px-1.5 py-0.5 rounded">
                      #{dispute.id}
                    </span>
                    <span className="text-xs font-bold text-primary truncate max-w-[200px]">
                      {dispute.title}
                    </span>
                  </div>
                  <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                    dispute.frozen ? 'bg-blue-100 text-blue-800' : 'bg-amber-100 text-amber-800'
                  }`}>
                    {dispute.frozen ? 'Escrow Frozen' : dispute.status}
                  </span>
                </div>

                <div className="flex items-center gap-3 p-2 rounded-xl bg-surface-container-low">
                  <div className="w-12 h-16 rounded bg-surface-container overflow-hidden shrink-0 book-shadow">
                    <img src={dispute.thumbnail} alt={dispute.itemTitle} className="w-full h-full object-cover" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <h4 className="font-headline-sm text-xs font-bold text-primary truncate">
                      {dispute.itemTitle}
                    </h4>
                    <p className="text-[11px] text-on-surface-variant">
                      {dispute.reporter} ({dispute.reporterRole}) vs {dispute.counterparty} ({dispute.counterpartyRole})
                    </p>
                    <div className="mt-1 flex items-center justify-between text-xs font-bold text-primary">
                      <span>Escrow: ${dispute.escrowAmount.toFixed(2)}</span>
                      {dispute.slaCountdown && (
                        <span className="text-[10px] text-red-600 font-semibold">{dispute.slaCountdown}</span>
                      )}
                    </div>
                  </div>
                </div>

                <div className="flex items-center justify-end gap-2 pt-1">
                  <button
                    onClick={() => onFreezeEscrow(dispute.id)}
                    className="px-2.5 py-1.5 text-xs font-bold rounded-lg border border-outline-variant bg-surface-container-low text-primary hover:bg-surface-container transition-all"
                  >
                    {dispute.frozen ? 'Escrow Locked' : 'Freeze Escrow'}
                  </button>
                  <button
                    onClick={() => onRefundDispute(dispute.id)}
                    className="px-3 py-1.5 text-xs font-bold rounded-lg bg-primary text-white hover:bg-primary-container transition-all shadow-xs"
                  >
                    Resolve & Refund
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* TAB 2: User Governance & Reputation */}
        {activeTab === 'users' && (
          <div className="space-y-2.5">
            {users.map((user) => (
              <div
                key={user.id}
                className={`bg-surface-container-lowest rounded-xl p-3 border shadow-xs flex items-center justify-between gap-3 ${
                  user.isHighRisk ? 'border-red-300 bg-red-50/20' : 'border-outline-variant/60'
                }`}
              >
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-10 h-10 rounded-full overflow-hidden border border-outline-variant shrink-0">
                    <img src={user.avatar} alt={user.name} className="w-full h-full object-cover" />
                  </div>
                  <div className="min-w-0">
                    <div className="flex items-center gap-1.5">
                      <h4 className="font-headline-sm text-xs font-bold text-primary truncate">{user.name}</h4>
                      <span className="text-[10px] font-bold px-1.5 rounded bg-surface-container text-on-surface-variant">
                        {user.role}
                      </span>
                    </div>
                    <p className="text-[10px] text-on-surface-variant truncate mt-0.5">{user.statsDescription}</p>
                  </div>
                </div>

                <div className="text-right shrink-0">
                  <div className={`text-xs font-extrabold ${user.trustScore < 50 ? 'text-red-600' : 'text-emerald-700'}`}>
                    {user.trustScore}%
                  </div>
                  <span className={`text-[10px] font-bold block ${user.isHighRisk ? 'text-red-700' : 'text-on-surface-variant'}`}>
                    {user.trustGrade}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* TAB 3: Realtime Certified Inspector Stream */}
        {activeTab === 'ledger' && (
          <div className="bg-surface-container-lowest rounded-2xl p-3 border border-outline-variant/60 shadow-xs space-y-2">
            <h3 className="font-headline-sm text-xs font-extrabold text-primary uppercase tracking-wide">
              Live Inspection Colophon Feed
            </h3>
            <div className="space-y-2">
              {ledgerStream.map((item) => (
                <div key={item.id} className="p-2.5 rounded-xl bg-surface-container-low text-xs space-y-1">
                  <div className="flex items-center justify-between text-on-surface-variant text-[10px]">
                    <span>{item.timestamp}</span>
                    <span className="font-mono text-primary font-bold">{item.hash}</span>
                  </div>
                  <div className="font-bold text-primary truncate">{item.title}</div>
                  <div className="flex items-center justify-between text-[11px]">
                    <span className="text-emerald-800 font-semibold">{item.grade}</span>
                    <span className="text-on-surface-variant">{item.inspector}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </main>
    </div>
  );
};
