import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/all_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/assets.dart';

class SellerHubScreen extends StatefulWidget {
  const SellerHubScreen({super.key});

  @override
  State<SellerHubScreen> createState() => _SellerHubScreenState();
}

class _SellerHubScreenState extends State<SellerHubScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final filteredListings = appState.sellerListings.where((item) {
      if (_filter == 'All') return true;
      if (_filter == 'Approved') return item.status == 'APPROVED & LIVE';
      if (_filter == 'Pending') return item.status == 'WAITING FOR INSPECTOR APPROVAL';
      if (_filter == 'Rejected') return item.status == 'REJECTED_AUDIT';
      return true;
    }).toList();

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
                  CircleAvatar(radius: 4, backgroundColor: AppTheme.secondaryContainer),
                  SizedBox(width: 6),
                  Text(
                    'Seller Hub',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.secondaryContainer),
            onPressed: () => appState.navigateTo(AppScreen.newListing),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(AppAssets.marcusAvatar),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance Metrics Bento Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Escrow Volume',
                    value: '\$4,820',
                    subtitle: 'Funds in vault',
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Active Listings',
                    value: '14 Books',
                    subtitle: '3 In Inspection',
                    color: AppTheme.secondaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Seller Rating',
                    value: '99.1%',
                    subtitle: '412 Reviews',
                    color: AppTheme.emeraldGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Banner: Submit New Book
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'List a Rare or Vintage Book',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Photographed copies are verified at the Brooklyn audit center before buyer release.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => appState.navigateTo(AppScreen.newListing),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Listing', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.secondaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filters Tabs
            Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 6),
                _buildFilterChip('Approved'),
                const SizedBox(width: 6),
                _buildFilterChip('Pending'),
                const SizedBox(width: 6),
                _buildFilterChip('Rejected'),
              ],
            ),

            const SizedBox(height: 12),

            // Inventory Listing Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredListings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredListings[index];
                return _buildListingCard(context, item, appState);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
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
          Text(title, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = label),
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.surfaceContainerLow,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, SellerListing item, AppState appState) {
    Color statusColor = AppTheme.emeraldGreen;
    Color statusBg = AppTheme.emeraldBg;

    if (item.status.contains('WAITING')) {
      statusColor = AppTheme.secondaryContainer;
      statusBg = const Color(0xFFFEF3C7);
    } else if (item.status.contains('REJECTED')) {
      statusColor = AppTheme.crimsonRed;
      statusBg = AppTheme.crimsonBg;
    }

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
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.coverImage,
                  width: 60,
                  height: 85,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.author,
                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)} (${item.priceType})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        Text(
                          item.timeAgo,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // If rejected, show inspector remediation notes
          if (item.rejectionReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.crimsonBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.crimsonRed.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning, color: AppTheme.crimsonRed, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Audit Non-Compliance Notice',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.crimsonRed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.rejectionReason!,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.inspectorNotes ?? '',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
