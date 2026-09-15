import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/all_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/assets.dart';

class NewBookListingScreen extends StatefulWidget {
  const NewBookListingScreen({super.key});

  @override
  State<NewBookListingScreen> createState() => _NewBookListingScreenState();
}

class _NewBookListingScreenState extends State<NewBookListingScreen> {
  String _sellingFormat = 'auction';
  String _condition = 'Very Good';
  final _titleController = TextEditingController(text: 'Neuromancer (30th Anniversary Edition)');
  final _authorController = TextEditingController(text: 'William Gibson • Ace Books');
  final _isbnController = TextEditingController(text: '978-0441569595');
  final _startPriceController = TextEditingController(text: '25.00');
  final _reservePriceController = TextEditingController(text: '60.00');
  final _notesController = TextEditingController(
    text: 'Minor corner bump on lower back edge. Crisp uncreased spine. Clean text block.',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _startPriceController.dispose();
    _reservePriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitListing(AppState appState) {
    final price = double.tryParse(_startPriceController.text) ?? 25.0;
    final newListing = SellerListing(
      id: 'lst-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      author: _authorController.text,
      edition: 'Ace 30th Anniversary',
      format: 'Paperback',
      price: price,
      priceType: _sellingFormat == 'auction' ? 'Live Auction' : 'Fixed Price',
      status: 'WAITING FOR INSPECTOR APPROVAL',
      coverImage: AppAssets.neuromancerCover,
      timeAgo: 'Just now',
      extraInfo: 'Queue Position: #4 in Brooklyn',
    );

    appState.addListing(newListing);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book submitted to Brooklyn Inspection Queue!')),
    );
    appState.navigateTo(AppScreen.sellerHub);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateTo(AppScreen.sellerHub),
        ),
        title: const Text('Listing Spec & Inspection Prep'),
        actions: [
          TextButton(
            onPressed: () => appState.navigateTo(AppScreen.sellerHub),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photographic Evidence Slots (4 Slots)
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
                      Row(
                        children: const [
                          Icon(Icons.add_a_photo, size: 16, color: AppTheme.secondaryContainer),
                          SizedBox(width: 6),
                          Text(
                            'Physical Audit Photos (4 Angles)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '3 Uploaded',
                          style: TextStyle(fontSize: 10, color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'High clarity, unedited photos are inspected by our specialist team before the book is listed.',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPhotoSlot('Front', AppAssets.neuromancerCover),
                      const SizedBox(width: 8),
                      _buildPhotoSlot('Spine', AppAssets.duneSpine),
                      const SizedBox(width: 8),
                      _buildPhotoSlot('Back', AppAssets.sicpBack),
                      const SizedBox(width: 8),
                      _buildAddPhotoSlot('ISBN Page'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bibliographic Details
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
                    'Bibliographic Details',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 10),
                  _buildInputField('Book Title', _titleController),
                  const SizedBox(height: 10),
                  _buildInputField('Author & Publisher', _authorController),
                  const SizedBox(height: 10),
                  _buildInputField('ISBN-13', _isbnController),
                  const SizedBox(height: 12),

                  // Condition Pills
                  const Text(
                    'Self-Assessed Condition',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['Mint', 'Very Good', 'Good', 'Acceptable'].map((c) {
                      final isSelected = _condition == c;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: ChoiceChip(
                            label: Text(c, style: const TextStyle(fontSize: 10)),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _condition = c),
                            selectedColor: AppTheme.primary,
                            backgroundColor: AppTheme.surfaceContainerLow,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),
                  _buildInputField('Flaws & Inspector Notes', _notesController, maxLines: 2),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Selling Format & Pricing
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
                    'Selling Format & Pricing',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _sellingFormat = 'auction'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _sellingFormat == 'auction' ? AppTheme.secondaryContainer : AppTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _sellingFormat == 'auction' ? AppTheme.secondaryContainer : AppTheme.outlineVariant,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.gavel,
                                  color: _sellingFormat == 'auction' ? Colors.white : AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Live Auction',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _sellingFormat == 'auction' ? Colors.white : AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Competitive bids',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: _sellingFormat == 'auction' ? Colors.white70 : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _sellingFormat = 'fixed'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _sellingFormat == 'fixed' ? AppTheme.primary : AppTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _sellingFormat == 'fixed' ? AppTheme.primary : AppTheme.outlineVariant,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.sell,
                                  color: _sellingFormat == 'fixed' ? Colors.white : AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fixed Price',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _sellingFormat == 'fixed' ? Colors.white : AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Instant checkout',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: _sellingFormat == 'fixed' ? Colors.white70 : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField('Starting / Base Price (\$)', _startPriceController),
                      ),
                      if (_sellingFormat == 'auction') ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInputField('Reserve Price (\$)', _reservePriceController),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _submitListing(appState),
                icon: const Icon(Icons.verified, size: 18),
                label: const Text('Submit for Physical Inspection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryContainer,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSlot(String label, String url) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(url, fit: BoxFit.cover),
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPhotoSlot(String label) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.secondaryContainer.withValues(alpha: 0.5), style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle, color: AppTheme.secondaryContainer, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.secondaryContainer),
                textAlign: TextAlign.center,
              ),
              const Text('Required', style: TextStyle(fontSize: 7, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
