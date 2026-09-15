import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/all_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/assets.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _escrowReleased = false;

  void _releaseEscrow() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Receipt & Release Escrow?'),
        content: const Text(
          'By releasing escrow, \$179.50 will be settled to the seller. Please ensure the volume condition matches the verified Grade 9.2 audit.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Inspect Further'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _escrowReleased = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Escrow settled and released to seller! Thank you for using SafeTrade.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldGreen),
            child: const Text('Confirm & Release'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateTo(AppScreen.buyerHome),
        ),
        title: const Text('Order & Escrow Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'SafeTrade Dispute Help',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support ticket initialized. 24/7 Escrow arbitration available.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Escrow Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _escrowReleased ? AppTheme.emeraldBg : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _escrowReleased ? AppTheme.emeraldGreen : AppTheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ORDER #ORD-8109',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _escrowReleased ? AppTheme.emeraldGreen : AppTheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _escrowReleased ? 'SETTLED & RELEASED' : 'ESCROW LOCKED IN VAULT',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(AppAssets.duneCover, width: 50, height: 70, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Dune (1965 First Chilton Edition)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Frank Herbert • Grade 9.2 Certified',
                              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Escrow Deposit: \$179.50 (Includes Insured Shipping)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Visual Delivery Map simulation
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(AppAssets.deliveryMap, fit: BoxFit.cover),
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.local_shipping, color: AppTheme.secondaryContainer, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Courier En Route: 4 stops away (ETA Today by 3:30 PM)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5 Progressive Milestones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SafeTrade Escrow & Transit Milestones',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 14),
                  _buildMilestone(
                    title: '1. Order Funded & SafeTrade Escrow Activated',
                    subtitle: 'Funds locked in neutral smart ledger vault.',
                    isDone: true,
                    time: 'Sep 14, 09:15 AM',
                  ),
                  _buildMilestone(
                    title: '2. Physical Verification at Brooklyn Audit Desk',
                    subtitle: 'Certified Grade 9.2 Fine/Mint with tamper-proof holographic seal.',
                    isDone: true,
                    time: 'Sep 14, 11:40 AM',
                  ),
                  _buildMilestone(
                    title: '3. Handed to Insured Priority Courier',
                    subtitle: 'Tracking #USPS-9400-1102-4891 • Signature required.',
                    isDone: true,
                    time: 'Sep 14, 01:20 PM',
                  ),
                  _buildMilestone(
                    title: '4. Out for Delivery to Manhattan',
                    subtitle: 'Delivery vehicle in final transit zone.',
                    isDone: true,
                    isActive: true,
                    time: 'Sep 14, 02:45 PM',
                  ),
                  _buildMilestone(
                    title: '5. Delivery Acceptance & Escrow Release',
                    subtitle: 'Buyer inspects volume and releases \$179.50 to seller.',
                    isDone: _escrowReleased,
                    isLast: true,
                    time: _escrowReleased ? 'Sep 14, 03:32 PM' : 'Pending inspection',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons: Release Escrow or Open Dispute
            if (!_escrowReleased) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _releaseEscrow,
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Confirm Physical Condition & Release Escrow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispute filed: Escrow automatically frozen pending review.')),
                    );
                    appState.navigateTo(AppScreen.adminPortal);
                  },
                  icon: const Icon(Icons.report_problem_outlined, color: AppTheme.crimsonRed, size: 18),
                  label: const Text('Report Flaw / Open Escrow Dispute', style: TextStyle(color: AppTheme.crimsonRed)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.crimsonRed),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.emeraldGreen),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified, color: AppTheme.emeraldGreen, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Transaction Completed. Funds successfully disbursed to seller. Certificate added to your digital collection.',
                        style: TextStyle(fontSize: 11, color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone({
    required String title,
    required String subtitle,
    required bool isDone,
    bool isActive = false,
    bool isLast = false,
    required String time,
  }) {
    Color dotColor = AppTheme.outlineVariant;
    if (isDone) dotColor = AppTheme.emeraldGreen;
    if (isActive) dotColor = AppTheme.secondaryContainer;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : (isActive ? const Center(child: CircleAvatar(radius: 2, backgroundColor: Colors.white)) : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: isDone ? AppTheme.emeraldGreen.withValues(alpha: 0.5) : AppTheme.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDone || isActive ? AppTheme.primary : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
