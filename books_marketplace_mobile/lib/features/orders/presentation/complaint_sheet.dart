import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/image_picking.dart';
import '../../../core/util/photo_picker.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../sim/application/sim_providers.dart';
import '../../sim/presentation/sim_text.dart';
import '../domain/order.dart';

const _maxEvidence = 10;

/// Mở khiếu nại cho đơn [orderId]: chọn lý do, mô tả và ít nhất một ảnh bằng
/// chứng. Bằng chứng giữ cục bộ vì khiếu nại là mô phỏng.
Future<void> showComplaintSheet(BuildContext context, String orderId) {
  return showAppSheet<void>(
    context,
    builder: (_) => _ComplaintBody(orderId: orderId),
  );
}

class _ComplaintBody extends ConsumerStatefulWidget {
  const _ComplaintBody({required this.orderId});

  final String orderId;

  @override
  ConsumerState<_ComplaintBody> createState() => _ComplaintBodyState();
}

class _ComplaintBodyState extends ConsumerState<_ComplaintBody> {
  ComplaintReason? _reason;
  final _text = TextEditingController();
  final List<Uint8List> _photos = [];

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    if (_photos.length >= _maxEvidence) return;
    try {
      final image = await ref.read(photoPickerProvider)();
      if (image != null && mounted) {
        setState(() => _photos.add(image.bytes));
      }
    } on ImagePickException {
      if (mounted) {
        AppSnackbar.show(
          context,
          context.l10n.complaintNeedReasonAndPhoto,
          type: AppSnackbarType.error,
        );
      }
    }
  }

  void _submit() {
    if (_reason == null || _photos.isEmpty) {
      AppSnackbar.show(
        context,
        context.l10n.complaintNeedReasonAndPhoto,
        type: AppSnackbarType.error,
      );
      return;
    }
    ref.read(simProvider.notifier).openComplaint(widget.orderId, _reason!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(l.complaintSheetTitle),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          l.complaintSheetNote,
          style: context.text.labelSmall?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final r in ComplaintReason.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _ReasonTile(
              label: complaintReasonLabel(l, r),
              selected: _reason == r,
              onTap: () => setState(() => _reason = r),
            ),
          ),
        const SizedBox(height: AppSpacing.xxs),
        TextField(
          controller: _text,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(hintText: l.complaintDescribeHint),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_photos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _photos[i],
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        OutlinedButton(
          onPressed: _photos.length < _maxEvidence ? _addPhoto : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textSecondary,
            side: BorderSide(color: colors.border),
          ),
          child: Text(l.complaintAddEvidence(_photos.length)),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l.complaintSubmit,
          variant: AppButtonVariant.danger,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.background : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smAll,
          side: BorderSide(
            color: selected ? colors.textPrimary : colors.divider,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 46),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: context.text.bodyMedium)),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? colors.textPrimary : colors.border,
                        width: selected ? 5 : 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
