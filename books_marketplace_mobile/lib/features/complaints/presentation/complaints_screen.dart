import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_paged_list.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../application/complaint_providers.dart';
import '../domain/complaint_case.dart';
import 'complaint_text.dart';

/// Khiếu nại của tôi: tab người mua (tôi khiếu nại) và người bán (về đơn của tôi).
class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.cpListTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.cpTabBuy),
              Tab(text: l.cpTabSell),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _List(role: 'BUYER'),
            _List(role: 'SELLER'),
          ],
        ),
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.role});

  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final provider = complaintsProvider(role);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return AppPagedList<ComplaintCase>(
      value: state,
      onLoadMore: notifier.loadMore,
      onRefresh: () async {
        refreshComplaints(ref);
        await notifier.reload();
      },
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen + 4,
        AppSpacing.md,
        AppSpacing.screen + 4,
        AppSpacing.xl,
      ),
      separator: const SizedBox(height: 12),
      empty: AppEmptyView(icon: Icons.gavel_outlined, title: l.cpEmpty),
      itemBuilder: (context, c) => AppCard(
        onTap: () => context.push('/me/complaints/${c.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.order?.bookTitle ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                AppTag(
                  label: caseStatusLabel(l, c.status),
                  tone: caseStatusTone(c.status),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (c.reason != null)
              Text(
                caseReasonLabel(l, c.reason!),
                style: context.text.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            if (c.createdAt != null)
              Text(
                formatDateTime(c.createdAt!, locale),
                style: context.text.labelSmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
