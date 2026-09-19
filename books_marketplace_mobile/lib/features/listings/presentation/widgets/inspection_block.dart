import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/util/format.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../inspection/domain/inspection.dart';
import '../../domain/listing.dart';

/// Khối kết quả kiểm định: ngang hàng với giá và ảnh, không phải nhãn phụ
/// (SRS FR-CAT-04).
class InspectionBlock extends StatelessWidget {
  const InspectionBlock({super.key, required this.inspection});

  final InspectionSummary inspection;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final approved = inspection.isApproved;
    final bg = approved ? colors.successContainer : colors.errorContainer;
    final fg = approved ? colors.onSuccessContainer : colors.onErrorContainer;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.lgAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                approved ? Icons.verified_outlined : Icons.report_outlined,
                color: fg,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l.inspectionResult,
                  style: context.text.titleMedium?.copyWith(color: fg),
                ),
              ),
              AppTag(
                label: approved ? l.inspectionApproved : l.inspectionRejected,
                tone: approved ? AppTagTone.success : AppTagTone.error,
              ),
            ],
          ),
          if (inspection.decidedAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.inspectedOn(formatDateTime(inspection.decidedAt!, locale)),
              style: context.text.bodySmall?.copyWith(color: fg),
            ),
          ],
          if (inspection.reasonCodes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.reasonsLabel,
              style: context.text.labelMedium?.copyWith(color: fg),
            ),
            const SizedBox(height: AppSpacing.xxs),
            for (final code in inspection.reasonCodes)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '• ${RejectReason.labelOf(code, l)}',
                  style: context.text.bodyMedium?.copyWith(color: fg),
                ),
              ),
          ],
          if (inspection.note != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.inspectorNote,
              style: context.text.labelMedium?.copyWith(color: fg),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              inspection.note!,
              style: context.text.bodyMedium?.copyWith(color: fg),
            ),
          ],
        ],
      ),
    );
  }
}
