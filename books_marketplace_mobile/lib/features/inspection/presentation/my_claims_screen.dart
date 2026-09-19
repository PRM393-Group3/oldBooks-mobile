import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_countdown.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/listing_card.dart';
import '../application/inspection_providers.dart';

/// Tab "Đang giữ": tin tôi đã nhận, kèm thời gian khóa còn lại.
class MyClaimsScreen extends ConsumerWidget {
  const MyClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(myClaimsProvider);

    return AppPage(
      title: l.claimedTitle,
      scrollable: false,
      child: state.when(
        skipLoadingOnReload: true,
        loading: () => const AppLoadingView(),
        error: (e, _) => AppErrorView(
          error: e,
          onRetry: () => ref.invalidate(myClaimsProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () async => ref.refresh(myClaimsProvider.future),
          child: items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxl),
                      child: AppEmptyView(
                        icon: Icons.assignment_outlined,
                        title: l.emptyClaimedTitle,
                        message: l.emptyClaimedMessage,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSpacing.screenPadding,
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return ListingCard(
                      listing: item.listing,
                      showStatus: false,
                      footer: item.claimExpiresAt == null
                          ? null
                          : AppCountdown(
                              until: item.claimExpiresAt!,
                              builder: (_, remaining) => AppTag(
                                label: l.claimExpiresIn(
                                  formatCountdown(remaining),
                                ),
                                tone: remaining.inMinutes < 5
                                    ? AppTagTone.auction
                                    : AppTagTone.info,
                                icon: Icons.timer_outlined,
                              ),
                            ),
                      onTap: () =>
                          context.push('/inspection/${item.listing.id}'),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
