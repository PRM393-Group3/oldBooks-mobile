import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_section.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user_role.dart';
import '../application/profile_controller.dart';
import '../domain/profile.dart';
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
        onRefresh: controller.reload,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Thẻ hero: nền gradient lavender nhạt, avatar viền gradient.
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: colors.heroGradient,
            borderRadius: AppRadius.lgAll,
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
              Text(
                profile.fullName,
                style: context.text.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                profile.email,
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
        if (profile.role == UserRole.admin) ...[
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
        const SizedBox(height: AppSpacing.lg),
        AppSection(
          children: [
            AppInfoRow(
              icon: Icons.phone_outlined,
              label: l.phoneLabel,
              value: profile.phoneNumber ?? l.phoneNotSet,
              muted: profile.phoneNumber == null,
            ),
            AppInfoRow(
              icon: Icons.calendar_today_outlined,
              label: l.memberSince,
              value: joined,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppSection(
          children: [
            AppMenuTile(
              icon: Icons.receipt_long_outlined,
              title: l.meMyOrders,
              onTap: () => context.push('/me/orders'),
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
              icon: Icons.language,
              title: l.language,
              onTap: () => showLanguageSheet(context),
            ),
          ],
        ),
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
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
