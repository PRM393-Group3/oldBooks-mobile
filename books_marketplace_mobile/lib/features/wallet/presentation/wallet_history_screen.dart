import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_paged_list.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../application/wallet_providers.dart';
import '../domain/wallet_models.dart';

/// Lịch sử yêu cầu nạp và rút. Trạng thái cuối của yêu cầu rút kèm lý do khi
/// bị từ chối hoặc thất bại (tiền đã trả về ví).
class WalletHistoryScreen extends StatelessWidget {
  const WalletHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.historyTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.historyTopups),
              Tab(text: l.historyWithdrawals),
            ],
          ),
        ),
        body: const TabBarView(children: [_TopupList(), _WithdrawalList()]),
      ),
    );
  }
}

class _TopupList extends ConsumerWidget {
  const _TopupList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final state = ref.watch(topupsProvider);
    final notifier = ref.read(topupsProvider.notifier);
    return AppPagedList<Topup>(
      value: state,
      onLoadMore: notifier.loadMore,
      onRefresh: notifier.reload,
      empty: AppEmptyView(
        icon: Icons.account_balance_wallet_outlined,
        title: l.historyEmpty,
      ),
      separator: const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, t) {
        final (String label, AppTagTone tone) = switch (t.status) {
          TopupStatus.paid => (l.topupStatusPaid, AppTagTone.success),
          TopupStatus.expired => (l.topupStatusExpired, AppTagTone.warning),
          TopupStatus.failed => (l.topupStatusFailed, AppTagTone.error),
          _ => (l.topupStatusPending, AppTagTone.info),
        };
        return AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatVnd(t.amount, locale),
                      style: context.text.labelLarge,
                    ),
                    if (t.createdAt != null)
                      Text(
                        formatDateTime(t.createdAt!, locale),
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              AppTag(label: label, tone: tone),
            ],
          ),
        );
      },
    );
  }
}

class _WithdrawalList extends ConsumerWidget {
  const _WithdrawalList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final colors = context.colors;
    final state = ref.watch(withdrawalsProvider);
    final notifier = ref.read(withdrawalsProvider.notifier);
    return AppPagedList<Withdrawal>(
      value: state,
      onLoadMore: notifier.loadMore,
      onRefresh: notifier.reload,
      empty: AppEmptyView(
        icon: Icons.account_balance_outlined,
        title: l.historyEmpty,
      ),
      separator: const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, w) {
        final (String label, AppTagTone tone) = switch (w.status) {
          WithdrawalStatus.requested => (l.wdStatusRequested, AppTagTone.info),
          WithdrawalStatus.approved => (l.wdStatusApproved, AppTagTone.info),
          WithdrawalStatus.submitted => (l.wdStatusSubmitted, AppTagTone.info),
          WithdrawalStatus.paid => (l.wdStatusPaid, AppTagTone.success),
          WithdrawalStatus.rejected => (l.wdStatusRejected, AppTagTone.error),
          WithdrawalStatus.failed => (l.wdStatusFailed, AppTagTone.error),
          WithdrawalStatus.unknown => (l.wdStatusUnknown, AppTagTone.neutral),
        };
        final reason = w.rejectReason ?? w.failureReason;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatVnd(w.amount, locale),
                      style: context.text.labelLarge,
                    ),
                  ),
                  AppTag(label: label, tone: tone),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${w.bankName} ${w.accountNumberMasked}',
                style: context.text.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (reason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    l.wdReason(reason),
                    style: context.text.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
              // Mốc thời gian: lúc tạo, rồi lúc duyệt/từ chối hoặc chuyển tiền.
              if (w.createdAt != null)
                Text(
                  l.wdTimeline(formatDateTime(w.createdAt!, locale)),
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              if ((w.paidAt ?? w.reviewedAt) != null)
                Text(
                  '$label · ${formatDateTime((w.paidAt ?? w.reviewedAt)!, locale)}',
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
