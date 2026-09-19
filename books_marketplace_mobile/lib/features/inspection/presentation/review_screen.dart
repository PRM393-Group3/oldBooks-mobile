import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/api_error_l10n.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_countdown.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../listings/application/listing_providers.dart';
import '../../listings/presentation/widgets/inspection_block.dart';
import '../../listings/presentation/widgets/listing_gallery.dart';
import '../../listings/presentation/widgets/listing_info_block.dart';
import '../application/inspection_providers.dart';
import '../domain/inspection.dart';
import 'reject_sheet.dart';

/// Màn hình kiểm định: nhận khóa khi mở, đồng hồ 30 phút, duyệt hoặc từ chối.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final provider = reviewControllerProvider(listingId);
    final state = ref.watch(provider);

    return state.when(
      loading: () => AppPage(
        title: l.reviewTitle,
        scrollable: false,
        child: const AppLoadingView(),
      ),
      error: (e, _) => AppPage(
        title: l.reviewTitle,
        scrollable: false,
        child: AppErrorView(
          error: e,
          onRetry: () => ref.read(provider.notifier).reclaim(),
        ),
      ),
      data: (claimed) => _Review(listingId: listingId, claimed: claimed),
    );
  }
}

class _Review extends ConsumerStatefulWidget {
  const _Review({required this.listingId, required this.claimed});

  final String listingId;
  final ClaimedListing claimed;

  @override
  ConsumerState<_Review> createState() => _ReviewState();
}

class _ReviewState extends ConsumerState<_Review> {
  bool _busy = false;

  /// Khóa hết hạn theo đồng hồ hoặc theo phản hồi `INSPECTION_CLAIM_REQUIRED`.
  bool _expired = false;

  ReviewController get _controller =>
      ref.read(reviewControllerProvider(widget.listingId).notifier);

  Future<void> _decide(
    Future<void> Function() action,
    String doneMessage,
  ) async {
    if (_busy) return;
    final l = context.l10n;
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      AppSnackbar.success(context, doneMessage);
      context.pop();
    } on ApiError catch (e) {
      if (!mounted) return;
      if (e.code == ApiErrorCode.claimRequired) {
        // Banner cố định đã báo và đổi nút thành "Nhận lại tin"; một snackbar
        // nổi thêm sẽ lặp thông điệp và che mất chính nút đó trong vài giây.
        setState(() => _expired = true);
      } else {
        AppSnackbar.show(
          context,
          e.localized(l),
          type: AppSnackbarType.error,
          detail: e.supportCode(l),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _approve() async {
    final l = context.l10n;
    // Controller sống trong dialog riêng để dispose đúng lúc: hủy ngay sau
    // showDialog trả về sẽ crash, vì màn hình vẫn đang chạy hoạt ảnh đóng.
    final note = await showDialog<String>(
      context: context,
      builder: (_) => const _ApproveDialog(),
    );
    if (note == null || !mounted) return;
    await _decide(() => _controller.approve(note: note), l.listingApproved);
  }

  Future<void> _reject() async {
    final l = context.l10n;
    final rules = await ref.read(listingRulesProvider.future);
    if (!mounted) return;
    final result = await showRejectSheet(
      context,
      minNote: rules.minRejectNoteLength,
    );
    if (result == null || !mounted) return;
    await _decide(
      () => _controller.reject(reasons: result.reasons, note: result.note),
      l.listingRejected,
    );
  }

  Future<void> _release() async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.releaseTitle,
      message: l.releaseMessage,
      confirmLabel: l.release,
    );
    if (!ok || !mounted) return;
    await _decide(_controller.release, l.listingReleased);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final listing = widget.claimed.listing;
    final rules = ref.watch(listingRulesProvider).value;

    return AppPage(
      title: l.reviewTitle,
      actions: [
        PopupMenuButton<void>(
          tooltip: l.release,
          itemBuilder: (_) => [
            PopupMenuItem(onTap: _release, child: Text(l.release)),
          ],
        ),
      ],
      bottom: _expired
          ? AppButton(
              label: l.reclaim,
              icon: Icons.lock_open,
              onPressed: () async {
                setState(() => _expired = false);
                await _controller.reclaim();
              },
            )
          : Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l.reject,
                    variant: AppButtonVariant.secondary,
                    onPressed: _busy ? null : _reject,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: l.approve,
                    loading: _busy,
                    onPressed: _busy ? null : _approve,
                  ),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCountdown(
            until: widget.claimed.expiresAt,
            onExpired: () {
              if (mounted) setState(() => _expired = true);
            },
            builder: (context, remaining) {
              final expired = _expired || remaining == Duration.zero;
              final urgent = remaining.inMinutes < 5;
              final bg = expired
                  ? colors.errorContainer
                  : (urgent ? colors.auctionContainer : colors.infoContainer);
              final fg = expired
                  ? colors.onErrorContainer
                  : (urgent
                        ? colors.onAuctionContainer
                        : colors.onInfoContainer);
              return Semantics(
                liveRegion: expired,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        expired ? Icons.lock_clock : Icons.timer_outlined,
                        color: fg,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          expired
                              ? l.claimExpired
                              : l.claimExpiresIn(formatCountdown(remaining)),
                          style: context.text.labelMedium?.copyWith(color: fg),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(listing.title, style: context.text.titleLarge),
          if (listing.submissionCount > 0) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l.submissionOf(
                listing.submissionCount,
                rules?.maxSubmissions ?? listing.maxSubmissions,
              ),
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(l.viewPhotos, style: context.text.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          ListingGallery(listing: listing),
          const SizedBox(height: AppSpacing.md),
          if (listing.latestInspection != null) ...[
            InspectionBlock(inspection: listing.latestInspection!),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(l.sellerDeclared, style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          ListingInfoBlock(listing: listing),
          if (listing.seller != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '${l.sellerSection}: ${listing.seller!.name}',
              style: context.text.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Hộp thoại nhập ghi chú khi duyệt. Controller là State riêng của dialog nên
/// chỉ dispose khi route thật sự bị gỡ, không phải ngay khi `showDialog` trả về
/// (route vẫn còn hoạt ảnh đóng khi đó).
class _ApproveDialog extends StatefulWidget {
  const _ApproveDialog();

  @override
  State<_ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<_ApproveDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.approveTitle),
      content: AppTextField(
        label: l.approveNoteLabel,
        controller: _note,
        maxLines: 3,
        minLines: 2,
        keyboardType: TextInputType.multiline,
      ),
      actions: [
        AppButton(
          label: l.cancel,
          variant: AppButtonVariant.text,
          expanded: false,
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(
          label: l.approve,
          expanded: false,
          onPressed: () => Navigator.pop(context, _note.text),
        ),
      ],
    );
  }
}
