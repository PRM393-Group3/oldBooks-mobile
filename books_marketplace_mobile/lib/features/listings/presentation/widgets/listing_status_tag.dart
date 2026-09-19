import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../domain/listing_enums.dart';

/// Badge trạng thái tin: ánh xạ 7 trạng thái sang tông màu và biểu tượng.
class ListingStatusTag extends StatelessWidget {
  const ListingStatusTag({super.key, required this.status});

  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final (AppTagTone tone, IconData icon) = switch (status) {
      ListingStatus.draft => (AppTagTone.neutral, Icons.edit_note),
      ListingStatus.pendingInspection => (AppTagTone.info, Icons.schedule),
      ListingStatus.inInspection => (AppTagTone.info, Icons.search),
      ListingStatus.rejected => (AppTagTone.error, Icons.cancel_outlined),
      ListingStatus.onSale => (AppTagTone.success, Icons.check_circle_outline),
      ListingStatus.auctioning => (AppTagTone.auction, Icons.gavel),
      ListingStatus.closed => (AppTagTone.neutral, Icons.lock_outline),
      ListingStatus.unknown => (AppTagTone.neutral, Icons.help_outline),
    };
    return AppTag(label: status.label(context.l10n), tone: tone, icon: icon);
  }
}
