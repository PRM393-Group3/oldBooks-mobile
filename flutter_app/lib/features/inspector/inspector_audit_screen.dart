import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/all_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/assets.dart';
import '../common/image_viewer_dialog.dart';

class InspectorAuditScreen extends StatefulWidget {
  const InspectorAuditScreen({super.key});

  @override
  State<InspectorAuditScreen> createState() => _InspectorAuditScreenState();
}

class _InspectorAuditScreenState extends State<InspectorAuditScreen> {
  final List<Map<String, String>> _photos = [
    {
      'label': 'Front Cover',
      'url': AppAssets.sicpFront,
      'note': 'Front cover laminate intact. Zero creasing along front gutter hinge.',
    },
    {
      'label': 'Spine & Binding',
      'url': AppAssets.sicpSpine,
      'note': 'Spine square and uncracked. Hot-melt PUR adhesive fully bound.',
    },
    {
      'label': 'Back Cover',
      'url': AppAssets.sicpBack,
      'note': 'Back cover UPC barcode scannable. Clean surface without sticker residue.',
    },
    {
      'label': 'Copyright & Colophon',
      'url': AppAssets.sicpIsbn,
      'note': 'Colophon confirms MIT Press 2nd edition 1996 1st print run line.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final completedCount = appState.checklist.where((c) => c.completed).length;
    final isFullyApproved = completedCount == appState.checklist.length;

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
                  CircleAvatar(radius: 4, backgroundColor: AppTheme.emeraldGreen),
                  SizedBox(width: 6),
                  Text(
                    'Inspector Portal',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '#INSP-402',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(AppAssets.alexanderAvatar),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Under Audit Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'AUDIT ITEM #419-MIT',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        ),
                      ),
                      const Text(
                        'Live Queue #1',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Structure and Interpretation of Computer Programs (SICP)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Abelson & Sussman • MIT Press (2nd Edition, 1996)',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildInfoPill('Claimed Grade', '9.4 Mint', AppTheme.emeraldGreen),
                      const SizedBox(width: 8),
                      _buildInfoPill('Format', 'Auction (\$40)', AppTheme.primary),
                      const SizedBox(width: 8),
                      _buildInfoPill('Seller Trust', '98.2% (412 sales)', AppTheme.primary),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Photographic Evidence Gallery (4 Angles)
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Physical Evidence Gallery (4 Angles)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                      Text(
                        'Tap to Zoom 4K',
                        style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _photos.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final item = _photos[index];
                      return GestureDetector(
                        onTap: () {
                          ImageViewerDialog.show(
                            context,
                            title: 'SICP Audit - ${item['label']}',
                            imageUrl: item['url']!,
                            note: item['note']!,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.outlineVariant),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(item['url']!, fit: BoxFit.cover),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  color: Colors.black.withValues(alpha: 0.65),
                                  child: Text(
                                    item['label']!,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                                  child: const Icon(Icons.zoom_in, color: Colors.white, size: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Checklist
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Physical Audit Verification Checklist',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isFullyApproved ? AppTheme.emeraldBg : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$completedCount / ${appState.checklist.length} Verified',
                          style: TextStyle(
                            fontSize: 10,
                            color: isFullyApproved ? AppTheme.emeraldGreen : AppTheme.secondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appState.checklist.length,
                    separatorBuilder: (_, __) => const Divider(color: AppTheme.outlineVariant, height: 12),
                    itemBuilder: (context, index) {
                      final item = appState.checklist[index];
                      return InkWell(
                        onTap: () => appState.toggleChecklistItem(item.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                item.completed ? Icons.check_box : Icons.check_box_outline_blank,
                                color: item.completed ? AppTheme.emeraldGreen : AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: item.completed ? AppTheme.primary : AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.description,
                                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Decision Buttons
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rejection notice sent to seller with remediation guidance.')),
                      );
                    },
                    icon: const Icon(Icons.cancel, color: AppTheme.crimsonRed, size: 16),
                    label: const Text('Reject', style: TextStyle(color: AppTheme.crimsonRed, fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.crimsonRed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isFullyApproved
                        ? () {
                            appState.approveInspection();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Audit Approved! Anchored to Escrow Ledger.')),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.verified, size: 16),
                    label: const Text('Approve & Publish Listing', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                      disabledBackgroundColor: AppTheme.surfaceContainer,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 8, color: AppTheme.textSecondary)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: valueColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
