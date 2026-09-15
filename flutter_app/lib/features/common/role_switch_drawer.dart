import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/all_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/assets.dart';

class RoleSwitchDrawer extends StatelessWidget {
  const RoleSwitchDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(AppAssets.alexanderAvatar),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alexander Vance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Collector & Certified Auditor',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldGreen.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Trust Score: 99.4% (AAA+)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'SWITCH SYSTEM PERSPECTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            // Role items
            _buildRoleTile(
              context,
              role: AppRole.buyer,
              currentRole: appState.currentRole,
              title: 'Buyer Mode',
              subtitle: 'Browse marketplace, bid in auctions, track escrow',
              icon: Icons.storefront,
              badgeColor: AppTheme.primary,
              onTap: () {
                appState.setRole(AppRole.buyer);
                Navigator.of(context).pop();
              },
            ),

            _buildRoleTile(
              context,
              role: AppRole.seller,
              currentRole: appState.currentRole,
              title: 'Seller Hub',
              subtitle: 'Manage book inventory, reserve prices, shipping',
              icon: Icons.inventory_2,
              badgeColor: AppTheme.secondaryContainer,
              onTap: () {
                appState.setRole(AppRole.seller);
                Navigator.of(context).pop();
              },
            ),

            _buildRoleTile(
              context,
              role: AppRole.inspector,
              currentRole: appState.currentRole,
              title: 'Inspector Ledger Portal',
              subtitle: '4-angle forensic audits, grade sealing & certification',
              icon: Icons.fact_check,
              badgeColor: AppTheme.emeraldGreen,
              onTap: () {
                appState.setRole(AppRole.inspector);
                Navigator.of(context).pop();
              },
            ),

            _buildRoleTile(
              context,
              role: AppRole.admin,
              currentRole: appState.currentRole,
              title: 'Super Admin & Escrow',
              subtitle: 'Resolve buyer disputes, freeze custody, monitor SLA',
              icon: Icons.admin_panel_settings,
              badgeColor: AppTheme.crimsonRed,
              onTap: () {
                appState.setRole(AppRole.admin);
                Navigator.of(context).pop();
              },
            ),

            const Spacer(),
            const Divider(color: AppTheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'BookHub SafeTrade Escrow Protocol v2.4',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTile(
    BuildContext context, {
    required AppRole role,
    required AppRole currentRole,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    final isSelected = currentRole == role;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? badgeColor.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected ? BorderSide(color: badgeColor, width: 1.5) : BorderSide.none,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: badgeColor, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? badgeColor : AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: badgeColor, size: 18)
              : const Icon(Icons.chevron_right, color: AppTheme.outlineVariant, size: 18),
        ),
      ),
    );
  }
}
