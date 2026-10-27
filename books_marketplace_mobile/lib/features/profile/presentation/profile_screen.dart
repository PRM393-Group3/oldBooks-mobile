import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_section.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../auth/application/auth_controller.dart';
import '../../sell/application/my_listings_provider.dart';
import '../../orders/application/order_providers.dart';
import '../application/address_providers.dart';
import '../../kyc/presentation/kyc_profile_tile.dart';
import '../../notifications/application/notification_providers.dart';
import '../../auctions/application/auction_providers.dart';
import '../../kyc/application/kyc_providers.dart';
import '../application/profile_controller.dart';
import '../domain/profile.dart';
import '../../app_update/presentation/update_sheet.dart';
import 'language_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    return state.when(
      skipLoadingOnReload: true,
      loading: () => AppPage(
        title: l.profileTitle,
        scrollable: false,
        child: const AppLoadingView(),
      ),
      error: (error, _) => AppPage(
        title: l.profileTitle,
        scrollable: false,
        child: AppErrorView(error: error, onRetry: controller.reload),
      ),
      data: (profile) => AppPage(
        title: l.profileTitle,
        onRefresh: () async {
          ref.invalidate(kycStateProvider);
          await controller.reload();
        },
        child: _ProfileBody(profile: profile),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final localeName = Localizations.localeOf(context).toString();
    final joined = DateFormat.yMMMMd(localeName)
        .format(profile.createdAt.toLocal());
    final unread = ref.watch(totalUnreadProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Thẻ hồ sơ: nền thẻ, viền 1px.
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            children: [
              AppAvatar(
                name: profile.fullName,
                imageUrl: profile.avatarUrl,
                size: AppSizes.avatarLarge,
                showEditBadge: true,
                semanticLabel: l.changeAvatar,
                onTap: () => context.push('/me/avatar'),
              ),
              const SizedBox(height: AppSpacing.md),
              NameWithBadge(
                profile.fullName,
                verified: profile.isVerified,
                style: context.text.titleLarge,
                textAlign: TextAlign.center,
                badgeSize: 22,
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                profile.phoneNumber ?? l.phoneNotSet,
                style: context.text.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTag(
                label: profile.role.label(l),
                tone: AppTagTone.brand,
                icon: Icons.verified_user_outlined,
              ),
            ],
          ),
        ),
        if (profile.isStaff) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.infoContainer,
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colors.onInfoContainer),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l.adminWebNote,
                    style: context.text.bodySmall?.copyWith(
                      color: colors.onInfoContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        const _StatTiles(),
        const SizedBox(height: AppSpacing.md),
        AppSection(
          children: [
            AppInfoRow(
              icon: Icons.phone_outlined,
              label: l.phoneLabel,
              value: profile.phoneNumber ?? l.phoneNotSet,
              muted: profile.phoneNumber == null,
            ),
            AppInfoRow(
              icon: Icons.mail_outline,
              label: l.emailLabel,
              value: profile.email ?? l.emailNotSet,
              muted: profile.email == null,
            ),
            AppInfoRow(
              icon: Icons.calendar_today_outlined,
              label: l.memberSince,
              value: joined,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const KycProfileTile(),
        const SizedBox(height: AppSpacing.md),
        AppSection(
          children: [
            AppMenuTile(
              icon: Icons.receipt_long_outlined,
              title: l.meMyOrders,
              subtitle: l.meMyOrdersSub,
              onTap: () => context.push('/me/orders'),
            ),
            AppMenuTile(
              icon: Icons.gavel_outlined,
              title: l.cpListTitle,
              onTap: () => context.push('/me/complaints'),
            ),
            AppMenuTile(
              icon: Icons.inventory_2_outlined,
              title: l.meMyListings,
              subtitle: l.meMyListingsSub,
              onTap: () => context.push('/me/listings'),
            ),
            AppMenuTile(
              icon: Icons.gavel_outlined,
              title: l.myAuctionsTitle,
              subtitle: l.meMyAuctionsSub,
              onTap: () => context.push('/auctions/mine'),
            ),
            AppMenuTile(
              icon: Icons.local_shipping_outlined,
              title: l.aoTitle,
              subtitle: l.meAuctionOrdersSub,
              onTap: () => context.push('/me/auction-orders'),
            ),
            AppMenuTile(
              icon: Icons.notifications_none,
              title: l.notificationsTitle,
              subtitle: unread > 0
                  ? l.meNotificationsSub(unread)
                  : l.meNotificationsAllRead,
              onTap: () => context.push('/notifications'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppSection(
          children: [
            AppMenuTile(
              icon: Icons.location_on_outlined,
              title: l.addrTitle,
              subtitle: l.addrSub,
              onTap: () => context.push('/me/addresses'),
            ),
            AppMenuTile(
              icon: Icons.account_balance_outlined,
              title: l.bankTitle,
              subtitle: l.bankSub,
              onTap: () => context.push('/me/bank-accounts'),
            ),
            AppMenuTile(
              icon: Icons.edit_outlined,
              title: l.editProfile,
              onTap: () => context.push('/me/edit'),
            ),
            AppMenuTile(
              icon: Icons.photo_camera_outlined,
              title: l.changeAvatar,
              onTap: () => context.push('/me/avatar'),
            ),
            AppMenuTile(
              icon: Icons.lock_outline,
              title: l.changePassword,
              onTap: () => context.push('/me/password'),
            ),
            AppMenuTile(
              icon: Icons.tune,
              title: l.notifSettingsTitle,
              onTap: () => context.push('/me/notification-settings'),
            ),
            AppMenuTile(
              icon: Icons.language,
              title: l.language,
              onTap: () => showLanguageSheet(context),
            ),
            AppMenuTile(
              icon: Icons.system_update_outlined,
              title: l.updateMenu,
              onTap: () => showUpdateSheet(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const _DefaultAddressCard(),
        const SizedBox(height: AppSpacing.md),
        AppSection(
          children: [
            AppMenuTile(
              icon: Icons.logout,
              title: l.logout,
              destructive: true,
              onTap: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: l.logoutConfirmTitle,
                  message: l.logoutConfirmMessage,
                  confirmLabel: l.logout,
                  destructive: true,
                );
                if (ok) {
                  await ref.read(authControllerProvider.notifier).logout();
                }
              },
            ),
            AppMenuTile(
              icon: Icons.devices_other_outlined,
              title: l.logoutAll,
              destructive: true,
              onTap: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: l.logoutAllConfirmTitle,
                  message: l.logoutAllConfirmMessage,
                  confirmLabel: l.logoutAll,
                  destructive: true,
                );
                if (ok) {
                  await ref
                      .read(authControllerProvider.notifier)
                      .logout(allDevices: true);
                }
              },
            ),
            // Tài khoản quản trị không tự xóa được (403 USER_ROLE_NOT_ALLOWED).
            if (!profile.isStaff)
              AppMenuTile(
                icon: Icons.delete_forever_outlined,
                title: l.deleteAccountEntry,
                destructive: true,
                onTap: () => context.push('/me/delete-account'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

/// Ba ô số liệu: đơn đang mua, tin đang đăng, phiên đang tham gia.
class _StatTiles extends ConsumerWidget {
  const _StatTiles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final orders = ref.watch(openBuyOrderCountProvider).value ?? 0;
    final activeListings = ref.watch(publishedListingCountProvider).value ?? 0;
    final auctions = ref.watch(myBidderAuctionCountProvider).value ?? 0;

    Widget tile(String value, String label, VoidCallback onTap) => Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      children: [
        tile('$orders', l.meStatOpenOrders, () => context.push('/me/orders')),
        const SizedBox(width: AppSpacing.xs),
        tile(
          '$activeListings',
          l.meStatListings,
          () => context.push('/me/listings'),
        ),
        const SizedBox(width: AppSpacing.xs),
        tile(
          '$auctions',
          l.meStatAuctions,
          () => context.push('/auctions/mine'),
        ),
      ],
    );
  }
}

/// Địa chỉ mặc định, dẫn tới sổ địa chỉ.
class _DefaultAddressCard extends ConsumerWidget {
  const _DefaultAddressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final a = ref.watch(defaultAddressProvider);
    return AppCard(
      onTap: () => context.push('/me/addresses'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.meDefaultAddress,
            style: context.text.labelSmall?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 3),
          Text(
            a == null ? l.addrNone : '${a.recipient} · ${a.phone}',
            style: context.text.labelLarge,
          ),
          if (a != null) ...[
            const SizedBox(height: 2),
            Text(
              a.fullLine,
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
