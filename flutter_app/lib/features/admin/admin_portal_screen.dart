import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/all_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/assets.dart';

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  int _activeTab = 0; // 0: Disputes, 1: User Reputation, 2: Ledger Stream

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircleAvatar(radius: 4, backgroundColor: AppTheme.crimsonRed),
                  SizedBox(width: 6),
                  Text(
                    'Super Admin & Escrow',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(AppAssets.alexanderAdmin),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Grid (6 Cards)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildKpiCard('Total Escrow', '\$148.2k', '+12% wk', AppTheme.primary),
                _buildKpiCard('Open Disputes', '2 Cases', 'SLA < 24h', AppTheme.crimsonRed),
                _buildKpiCard('Audit Volume', '318 Books', '99.4% Pass', AppTheme.emeraldGreen),
                _buildKpiCard('Active Sellers', '84 Dealers', 'Vetted', AppTheme.secondaryContainer),
                _buildKpiCard('Auction GMV', '\$89.5k', 'This Month', AppTheme.primary),
                _buildKpiCard('Ledger Blocks', '12,410', 'Immutable', AppTheme.emeraldGreen),
              ],
            ),

            const SizedBox(height: 16),

            // Tab Selector
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildTabButton(0, 'Dispute Queue (2)', Icons.gavel),
                  _buildTabButton(1, 'Reputation Index', Icons.verified_user),
                  _buildTabButton(2, 'Ledger Stream', Icons.history_edu),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Content
            if (_activeTab == 0) _buildDisputeQueue(context, appState),
            if (_activeTab == 1) _buildReputationIndex(context, appState),
            if (_activeTab == 2) _buildLedgerStream(context, appState),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 8, color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          ),
          Text(sub, style: const TextStyle(fontSize: 7, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDisputeQueue(BuildContext context, AppState appState) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appState.disputes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final d = appState.disputes[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(d.thumbnail, width: 50, height: 70, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              d.id,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: d.frozen ? AppTheme.crimsonBg : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                d.status,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: d.frozen ? AppTheme.crimsonRed : AppTheme.secondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          d.itemTitle,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Escrow in Custody: \$${d.escrowAmount.toStringAsFixed(2)} • SLA: ${d.slaCountdown ?? 'N/A'}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => appState.toggleFreezeEscrow(d.id),
                      icon: Icon(d.frozen ? Icons.lock_open : Icons.lock, size: 14),
                      label: Text(d.frozen ? 'Unfreeze' : 'Freeze Escrow', style: const TextStyle(fontSize: 10)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: d.frozen ? AppTheme.emeraldGreen : AppTheme.crimsonRed,
                        side: BorderSide(color: d.frozen ? AppTheme.emeraldGreen : AppTheme.crimsonRed),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => appState.resolveDispute(d.id),
                      icon: const Icon(Icons.check_circle, size: 14),
                      label: const Text('Refund Buyer', style: TextStyle(fontSize: 10)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReputationIndex(BuildContext context, AppState appState) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appState.users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = appState.users[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: user.isHighRisk ? AppTheme.crimsonRed.withValues(alpha: 0.5) : AppTheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(user.avatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.isHighRisk ? AppTheme.crimsonBg : AppTheme.emeraldBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.trustGrade,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: user.isHighRisk ? AppTheme.crimsonRed : AppTheme.emeraldGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(user.role, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                    const SizedBox(height: 2),
                    Text(user.statsDescription, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLedgerStream(BuildContext context, AppState appState) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appState.ledgerStream.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = appState.ledgerStream[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.hash,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppTheme.textSecondary),
                  ),
                  Text(
                    entry.timestamp,
                    style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                entry.title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Certified by ${entry.inspector}',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  ),
                  Text(
                    entry.grade,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
