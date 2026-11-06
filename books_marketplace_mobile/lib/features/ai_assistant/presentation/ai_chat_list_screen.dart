import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_paged_list.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../application/ai_providers.dart';
import '../domain/ai_models.dart';

/// Danh sách cuộc trò chuyện với Trợ lý đăng bài. Chưa có gói thì hiện lời mời.
class AiChatListScreen extends ConsumerWidget {
  const AiChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final status = ref.watch(aiStatusProvider);
    final route = ref.watch(aiRouteProvider);
    final theme = context;

    Widget body;
    if (status.isLoading && !status.hasValue) {
      body = const AppLoadingView();
    } else if (route != AiRoute.claude) {
      body = AiUpsell(unavailable: status.value?.claudeAvailable == false);
    } else {
      final value = ref.watch(aiConversationsProvider);
      final notifier = ref.read(aiConversationsProvider.notifier);
      body = AppPagedList<AiConversation>(
        value: value,
        onLoadMore: notifier.loadMore,
        onRefresh: notifier.reload,
        empty: AppEmptyView(
          icon: Icons.chat_bubble_outline,
          title: l.aiChatEmpty,
          message: l.aiChatEmptyHint,
        ),
        itemBuilder: (context, c) => _ConversationTile(conversation: c),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.aiChatTitle)),
      floatingActionButton: route == AiRoute.claude
          ? FloatingActionButton.extended(
              backgroundColor: theme.colors.primary,
              foregroundColor: theme.colors.onPrimary,
              onPressed: () async {
                await context.push('/me/ai/chat/new');
                ref.invalidate(aiConversationsProvider);
              },
              icon: const Icon(Icons.add),
              label: Text(l.aiChatNew),
            )
          : null,
      body: SafeArea(child: body),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({required this.conversation});

  final AiConversation conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final date = conversation.updatedAt ?? conversation.createdAt;
    return AppCard(
      onTap: () async {
        await context.push('/me/ai/chat/${conversation.id}');
        ref.invalidate(aiConversationsProvider);
      },
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title ?? l.aiChatUntitled,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
                if (date != null)
                  Text(
                    formatDateTime(date, l.localeName),
                    style: context.text.bodySmall,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.aiChatDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showConfirmDialog(
                context,
                title: l.aiChatDelete,
                message: l.aiChatDeleteConfirm,
                confirmLabel: l.aiChatDelete,
                destructive: true,
              );
              if (!ok) return;
              try {
                await ref
                    .read(aiRepositoryProvider)
                    .deleteConversation(conversation.id);
                ref
                    .read(aiConversationsProvider.notifier)
                    .remove(conversation.id);
              } catch (_) {
                if (context.mounted) {
                  AppSnackbar.show(
                    context,
                    l.errorNetwork,
                    type: AppSnackbarType.error,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Lời mời đăng ký gói, dùng khi chưa có gói hoặc dịch vụ chưa bật.
class AiUpsell extends StatelessWidget {
  const AiUpsell({super.key, this.unavailable = false});

  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 56, color: context.colors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              unavailable ? l.aiChatUnavailable : l.aiChatUpsellTitle,
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (!unavailable)
              Text(l.aiChatUpsellBody, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l.aiChatUpsellButton,
              expanded: false,
              onPressed: () => context.push('/me/ai'),
            ),
          ],
        ),
      ),
    );
  }
}
