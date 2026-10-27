import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_section.dart';
import '../application/kyc_providers.dart';
import '../domain/kyc_rules.dart';
import 'kyc_text.dart';

/// Hàng "Xác minh tài khoản" trên màn hồ sơ: hiện trạng thái hiện tại và mở
/// màn hình eKYC.
class KycProfileTile extends ConsumerWidget {
  const KycProfileTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final phase = ref.watch(kycStateProvider).whenData(kycUiPhase).value;
    return AppSection(
      children: [
        AppMenuTile(
          icon: phase == null
              ? Icons.verified_user_outlined
              : kycPhaseIcon(phase),
          title: l.kycTitle,
          subtitle: phase == null
              ? l.kycSubNone
              : '${kycPhaseLabel(l, phase)} · ${kycPhaseSubtitle(l, phase)}',
          onTap: () async {
            await context.push('/me/kyc');
            ref.invalidate(kycStateProvider);
          },
        ),
      ],
    );
  }
}
