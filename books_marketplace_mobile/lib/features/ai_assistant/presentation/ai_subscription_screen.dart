import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/api_error_l10n.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/util/idempotency.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../wallet/application/wallet_providers.dart';
import '../../wallet/presentation/topup_sheet.dart';
import '../application/ai_providers.dart';

/// Gói Trợ lý AI: giá, hạn dùng, số dư ví, mua/gia hạn bằng ví.
class AiSubscriptionScreen extends ConsumerStatefulWidget {
  const AiSubscriptionScreen({super.key});

  @override
  ConsumerState<AiSubscriptionScreen> createState() => _State();
}

class _State extends ConsumerState<AiSubscriptionScreen> {
  final _action = IdempotentAction();
  bool _busy = false;
  ApiError? _error;

  Future<void> _buy() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final status = await ref
          .read(aiRepositoryProvider)
          .subscribe(idempotencyKey: _action.key);
      _action.settle();
      ref.read(aiStatusProvider.notifier).set(status);
      ref.read(walletProvider.notifier).refresh();
      if (mounted) {
        AppSnackbar.show(
          context,
          context.l10n.aiPlanBought,
          type: AppSnackbarType.success,
        );
      }
    } catch (e) {
      _action.settle(e);
      if (mounted) {
        setState(() => _error = e is ApiError ? e : const ApiError.network());
      }
      if (e is ApiError && e.code == ApiErrorCode.aiUnavailable) {
        ref.read(aiStatusProvider.notifier).refresh();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final async = ref.watch(aiStatusProvider);
    final wallet = ref.watch(walletProvider).value;
    final locale = l.localeName;
    return AppPage(
      title: l.aiPlanTitle,
      onRefresh: () => ref.read(aiStatusProvider.notifier).refresh(),
      child: async.when(
        skipLoadingOnReload: true,
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 80),
          child: AppLoadingView(),
        ),
        error: (e, _) => AppErrorView(
          error: e,
          onRetry: () => ref.invalidate(aiStatusProvider),
        ),
        data: (s) {
          final now = DateTime.now().toUtc();
          final days = s.daysRemaining(now);
          final price = formatVnd(s.priceVnd, locale);
          final insufficient = _error?.code == ApiErrorCode.insufficientBalance;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: context.colors.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            l.aiPlanHeadline,
                            style: context.text.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l.aiPlanBenefits, style: context.text.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l.aiPlanPrice(price, s.durationDays),
                      style: context.text.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppTag(
                        label: s.subscribed
                            ? l.aiPlanStatusActive
                            : (s.expiresAt != null
                                  ? l.aiPlanStatusExpired
                                  : l.aiPlanStatusNone),
                        tone: s.subscribed
                            ? AppTagTone.success
                            : AppTagTone.neutral,
                      ),
                    ),
                    if (s.subscribed && s.expiresAt != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l.aiPlanExpires(formatDate(s.expiresAt!, locale), days),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        s.dailyQuota > 0
                            ? l.aiPlanQuota(s.usedToday, s.dailyQuota)
                            : l.aiPlanUsedToday(s.usedToday),
                        style: context.text.bodySmall,
                      ),
                    ],
                    if (wallet != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l.aiPlanBalance(formatVnd(wallet.available, locale)),
                        style: context.text.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (!s.claudeAvailable)
                AppBanner(
                  message: l.aiPlanUnavailable,
                  tone: AppTagTone.warning,
                  icon: Icons.cloud_off_outlined,
                ),
              if (_error != null && !insufficient) ...[
                AppBanner(
                  message: _error!.localized(l),
                  tone: AppTagTone.error,
                  icon: Icons.error_outline,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (insufficient) ...[
                AppBanner(
                  message: l.aiPlanInsufficient(
                    formatVnd(
                      _error!.detailAmount('required') ?? s.priceVnd,
                      locale,
                    ),
                    formatVnd(
                      _error!.detailAmount('available') ??
                          wallet?.available ??
                          0,
                      locale,
                    ),
                  ),
                  tone: AppTagTone.error,
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: l.aiPlanTopup,
                  icon: Icons.add_card_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: () async {
                    await showWalletTopupSheet(
                      context,
                      initialAmount: _error!.detailAmount('required'),
                    );
                    ref.read(walletProvider.notifier).refresh();
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (s.claudeAvailable)
                AppButton(
                  label: s.subscribed
                      ? l.aiPlanRenew(price)
                      : l.aiPlanBuy(price),
                  icon: Icons.auto_awesome,
                  loading: _busy,
                  onPressed: _busy ? null : _buy,
                ),
              if (s.subscribed) ...[
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: l.aiPlanOpenChat,
                  icon: Icons.chat_bubble_outline,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.push('/me/ai/chat'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
