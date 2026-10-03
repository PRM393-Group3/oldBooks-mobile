import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_error.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_section.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../auth/domain/user_role.dart';
import '../../../profile/application/profile_controller.dart';
import '../../application/listing_providers.dart';
import '../../domain/listing.dart';
import '../../domain/listing_enums.dart';
import '../widgets/inspection_block.dart';
import '../widgets/listing_format.dart';
import '../widgets/listing_gallery.dart';
import '../widgets/listing_info_block.dart';
import '../widgets/listing_status_tag.dart';

/// Chi tiết tin, dùng chung cho chủ tin, Buyer và Inspector. Hành động hiển thị
/// theo quyền sở hữu và trạng thái; quyền thật do server quyết định.
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(listingDetailProvider(listingId));

    return state.when(
      loading: () => AppPage(
        title: l.navHome,
        scrollable: false,
        child: const AppLoadingView(),
      ),
      error: (e, _) => AppPage(
        title: l.navHome,
        scrollable: false,
        child: AppErrorView(
          error: e,
          onRetry: () => ref.invalidate(listingDetailProvider(listingId)),
        ),
      ),
      data: (listing) => _Detail(listing: listing),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final profile = ref.watch(profileControllerProvider).value;
    final isOwner = profile != null && listing.seller?.id == profile.id;
    final canSeeInspection =
        isOwner ||
        profile?.role == UserRole.inspector ||
        profile?.role == UserRole.admin;
    final info = listing.bookInfo;
    final price = listingPriceText(listing, l, locale);

    Widget? bottom;
    if (isOwner && listing.status == ListingStatus.draft) {
      bottom = AppButton(
        label: l.continueDraft,
        icon: Icons.edit_outlined,
        onPressed: () => context.push('/sell/listing/${listing.id}/edit'),
      );
    } else if (isOwner && listing.status == ListingStatus.rejected) {
      bottom = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            listing.submissionsLeft > 0
                ? l.resubmitsLeft(listing.submissionsLeft)
                : l.noResubmitsLeft,
            style: context.text.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: l.editAndResubmit,
            icon: Icons.edit_outlined,
            onPressed: listing.submissionsLeft > 0
                ? () => context.push('/sell/listing/${listing.id}/edit')
                : null,
          ),
        ],
      );
    }

    return AppPage(
      title: info.title ?? l.navHome,
      bottom: bottom,
      actions: [
        if (isOwner && listing.status.isEditable)
          PopupMenuButton<void>(
            tooltip: l.deleteListing,
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () => _delete(context, ref),
                child: Text(
                  listing.status == ListingStatus.draft
                      ? l.deleteListing
                      : l.closeListing,
                ),
              ),
            ],
          ),
      ],
      onRefresh: () async {
        ref.invalidate(listingDetailProvider(listing.id));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListingGallery(listing: listing),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(info.title ?? '', style: context.text.titleLarge),
              ),
              const SizedBox(width: AppSpacing.xs),
              ListingStatusTag(status: listing.status),
            ],
          ),
          if (price != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              price,
              style: context.text.headlineMedium?.copyWith(
                color: colors.primary,
              ),
            ),
          ],
          if (isOwner &&
              (listing.status == ListingStatus.pendingInspection ||
                  listing.status == ListingStatus.inInspection)) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.estimatedProcessing(
                ref
                        .watch(listingRulesProvider)
                        .value
                        ?.estimatedProcessingHours ??
                    24,
              ),
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          if (canSeeInspection && listing.latestInspection != null) ...[
            const SizedBox(height: AppSpacing.md),
            InspectionBlock(inspection: listing.latestInspection!),
          ],
          if (isOwner && listing.status == ListingStatus.closed) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l.closedTitle,
              style: context.text.labelMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ListingInfoBlock(listing: listing),
          if (!isOwner && listing.seller != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppSection(
              title: l.sellerSection,
              children: [
                AppKeyValueRow(
                  label: l.sellerSection,
                  value: listing.seller!.name,
                ),
              ],
            ),
          ],
          if (listing.status.isPublic && !isOwner) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l.comingSoon,
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    // PopupMenu đóng sau khi onTap chạy; đợi một frame trước khi mở hộp thoại.
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;
    final ok = await showConfirmDialog(
      context,
      title: l.deleteListingTitle,
      message: l.deleteListingMessage,
      confirmLabel: listing.status == ListingStatus.draft
          ? l.deleteListing
          : l.closeListing,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(listingActionsProvider).delete(listing.id);
      if (!context.mounted) return;
      AppSnackbar.success(context, l.listingDeleted);
      context.pop();
    } on ApiError catch (e) {
      if (!context.mounted) return;
      AppSnackbar.apiError(context, e);
      if (e.needsReload) ref.invalidate(listingDetailProvider(listing.id));
    }
  }
}
