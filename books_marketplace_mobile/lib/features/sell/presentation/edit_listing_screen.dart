import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../listings/application/listing_providers.dart';
import 'sell_screen.dart';

/// Tải tin rồi mở form đăng bán ở chế độ sửa. Tải lại mỗi lần mở để thấy trạng
/// thái mới nhất (server từ chối sửa khi tin đang chờ duyệt hoặc đã có đơn).
class EditListingScreen extends ConsumerWidget {
  const EditListingScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listingDetailProvider(listingId));
    return state.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(context.l10n.sellEditTitle)),
        body: const AppLoadingView(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.sellEditTitle)),
        body: AppErrorView(
          error: e,
          onRetry: () => ref.invalidate(listingDetailProvider(listingId)),
        ),
      ),
      data: (listing) => SellScreen(editing: listing),
    );
  }
}
