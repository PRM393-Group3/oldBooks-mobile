import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/app_tag.dart';
import '../domain/kyc_rules.dart';

/// Nhãn ngắn của trạng thái, dùng ở thẻ hồ sơ và màn trạng thái.
String kycPhaseLabel(AppLocalizations l, KycUiPhase p) => switch (p) {
  KycUiPhase.notStarted => l.kycPhaseNone,
  KycUiPhase.pending => l.kycPhasePending,
  KycUiPhase.verified => l.kycPhaseVerified,
  KycUiPhase.rejectedCanRetry || KycUiPhase.blocked => l.kycPhaseRejected,
  KycUiPhase.revoked => l.kycPhaseRevoked,
};

AppTagTone kycPhaseTone(KycUiPhase p) => switch (p) {
  KycUiPhase.notStarted => AppTagTone.neutral,
  KycUiPhase.pending => AppTagTone.warning,
  KycUiPhase.verified => AppTagTone.success,
  KycUiPhase.rejectedCanRetry ||
  KycUiPhase.blocked ||
  KycUiPhase.revoked => AppTagTone.error,
};

IconData kycPhaseIcon(KycUiPhase p) => switch (p) {
  KycUiPhase.notStarted => Icons.verified_user_outlined,
  KycUiPhase.pending => Icons.hourglass_top,
  KycUiPhase.verified => Icons.verified,
  KycUiPhase.rejectedCanRetry || KycUiPhase.blocked => Icons.gpp_bad_outlined,
  KycUiPhase.revoked => Icons.remove_moderator_outlined,
};

/// Dòng phụ ở thẻ hồ sơ.
String kycPhaseSubtitle(AppLocalizations l, KycUiPhase p) => switch (p) {
  KycUiPhase.notStarted => l.kycSubNone,
  KycUiPhase.pending => l.kycSubPending,
  KycUiPhase.verified => l.kycSubVerified,
  KycUiPhase.rejectedCanRetry => l.kycSubRejected,
  KycUiPhase.blocked => l.kycSubBlocked,
  KycUiPhase.revoked => l.kycSubRevoked,
};

/// "Thử lại sau HH:mm dd/MM/yyyy" theo giờ máy.
String kycRetryAfterText(AppLocalizations l, DateTime at, String locale) =>
    l.kycRetryAfter(DateFormat.yMd(locale).add_Hm().format(at.toLocal()));
