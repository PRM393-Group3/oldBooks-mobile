import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../application/notification_providers.dart';

/// Tùy chọn nhận push. Thông báo giao dịch, bảo mật và tiền luôn gửi.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    Future<void> change({bool? marketing, bool? auctionWatch}) async {
      try {
        await notifier.change(marketing: marketing, auctionWatch: auctionWatch);
      } on ApiError catch (e) {
        if (context.mounted) AppSnackbar.apiError(context, e);
      }
    }

    return AppPage(
      title: l.notifSettingsTitle,
      scrollable: false,
      child: state.when(
        skipLoadingOnReload: true,
        loading: () => const AppLoadingView(),
        error: (error, _) =>
            AppErrorView(error: error, onRetry: notifier.reload),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screen + 4),
          children: [
            SwitchListTile(
              value: settings.marketing,
              onChanged: (v) => change(marketing: v),
              title: Text(l.notifSettingsMarketing),
              subtitle: Text(l.notifSettingsMarketingSub),
            ),
            SwitchListTile(
              value: settings.auctionWatch,
              onChanged: (v) => change(auctionWatch: v),
              title: Text(l.notifSettingsAuction),
              subtitle: Text(l.notifSettingsAuctionSub),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l.notifSettingsAlways,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
