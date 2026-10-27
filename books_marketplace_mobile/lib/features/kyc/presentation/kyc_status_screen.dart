import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../profile/application/profile_controller.dart';
import '../application/kyc_providers.dart';
import '../domain/kyc_models.dart';
import '../domain/kyc_rules.dart';
import 'kyc_text.dart';

/// Trạng thái xác minh và kết quả hồ sơ gần nhất. Cũng là màn hình đích sau khi
/// gửi hồ sơ và khi bấm thông báo `KYC_APPROVED`/`KYC_REJECTED`.
class KycStatusScreen extends ConsumerWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(kycStateProvider);

    // Đã duyệt/thu hồi ở nơi khác thì hồ sơ (dấu tích) cần tải lại.
    ref.listen(kycStateProvider, (prev, next) {
      final verified = next.value?.isVerified;
      final profile = ref.read(profileControllerProvider).value;
      if (verified != null &&
          profile != null &&
          profile.isVerified != verified) {
        ref.read(profileControllerProvider.notifier).reload().ignore();
      }
    });

    return state.when(
      skipLoadingOnReload: true,
      loading: () => AppPage(
        title: l.kycTitle,
        scrollable: false,
        child: const AppLoadingView(),
      ),
      error: (e, _) => AppPage(
        title: l.kycTitle,
        scrollable: false,
        child: AppErrorView(
          error: e,
          onRetry: () => ref.invalidate(kycStateProvider),
        ),
      ),
      data: (s) => AppPage(
        title: l.kycTitle,
        onRefresh: () async {
          ref.invalidate(kycStateProvider);
          await ref.read(kycStateProvider.future);
        },
        bottom: _Actions(state: s),
        child: _Body(state: s),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final KycState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final phase = kycUiPhase(state);
    final latest = state.latest;
    final fmt = DateFormat.yMd(locale).add_Hm();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Icon(
            kycPhaseIcon(phase),
            size: 72,
            color: switch (phase) {
              KycUiPhase.verified => colors.info,
              KycUiPhase.pending => colors.warning,
              KycUiPhase.notStarted => colors.textMuted,
              _ => colors.error,
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: AppTag(
            label: kycPhaseLabel(l, phase),
            tone: kycPhaseTone(phase),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          switch (phase) {
            KycUiPhase.notStarted => l.kycStatusNoneBody,
            KycUiPhase.pending => l.kycStatusPendingBody,
            KycUiPhase.verified => l.kycStatusVerifiedBody,
            KycUiPhase.rejectedCanRetry ||
            KycUiPhase.blocked => l.kycStatusRejectedBody,
            KycUiPhase.revoked => l.kycStatusRevokedBody,
          },
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        if (state.verifiedAt != null && phase == KycUiPhase.verified) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.kycVerifiedAt(fmt.format(state.verifiedAt!.toLocal())),
            textAlign: TextAlign.center,
            style: context.text.labelMedium?.copyWith(color: colors.textMuted),
          ),
        ],
        if ((state.status == KycStatus.rejected ||
                state.status == KycStatus.revoked) &&
            (latest?.rejectReason ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          AppBanner(
            tone: AppTagTone.error,
            icon: Icons.report_gmailerrorred_outlined,
            message: l.kycRejectReason(latest!.rejectReason!),
          ),
        ],
        if (!state.canSubmit &&
            state.retryAfter != null &&
            state.status != KycStatus.pendingReview &&
            state.status != KycStatus.approved) ...[
          const SizedBox(height: AppSpacing.sm),
          AppBanner(
            tone: AppTagTone.warning,
            icon: Icons.schedule,
            message: kycRetryAfterText(l, state.retryAfter!, locale),
          ),
        ],
        if (latest != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(l.kycLatestTitle, style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          _InfoRow(l.kycFieldName, latest.fullName),
          _InfoRow(l.kycFieldId, latest.idNumberMasked),
          if (latest.dateOfBirth != null)
            _InfoRow(l.kycFieldDob, _dob(latest.dateOfBirth!)),
          if (latest.submittedAt != null)
            _InfoRow(
              l.kycSubmittedAt,
              fmt.format(latest.submittedAt!.toLocal()),
            ),
          if (latest.reviewedAt != null)
            _InfoRow(l.kycReviewedAt, fmt.format(latest.reviewedAt!.toLocal())),
        ],
      ],
    );
  }

  /// `yyyy-MM-dd` -> `dd/MM/yyyy`; giữ nguyên nếu lạ.
  String _dob(String api) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(api);
    return m == null ? api : '${m.group(3)}/${m.group(2)}/${m.group(1)}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: context.text.bodyMedium)),
        ],
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.state});

  final KycState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final phase = kycUiPhase(state);
    final label = switch (phase) {
      KycUiPhase.notStarted => l.kycStart,
      KycUiPhase.rejectedCanRetry || KycUiPhase.revoked => l.kycRetry,
      _ => null,
    };
    if (label == null) return const SizedBox.shrink();
    return Padding(
      padding: AppSpacing.screenPadding,
      child: AppButton(
        label: label,
        large: true,
        onPressed: () async {
          await context.push('/me/kyc/verify');
          ref.invalidate(kycStateProvider);
        },
      ),
    );
  }
}
