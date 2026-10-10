import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auction_orders/application/auction_order_providers.dart';
import '../../orders/application/order_providers.dart';
import '../application/complaint_providers.dart';
import '../data/complaint_repository.dart';
import '../domain/complaint_case.dart';
import 'complaint_text.dart';
import 'evidence_picker.dart';

/// Người mua mở khiếu nại: lý do, mô tả, 1 đến 10 tệp bằng chứng (tải lên kho
/// riêng tư rồi gửi `blobName`).
class OpenComplaintScreen extends ConsumerStatefulWidget {
  const OpenComplaintScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OpenComplaintScreen> createState() =>
      _OpenComplaintScreenState();
}

class _OpenComplaintScreenState extends ConsumerState<OpenComplaintScreen> {
  CaseReason _reason = CaseReason.notAsDescribed;
  final _description = TextEditingController();
  final List<EvidenceFile> _files = [];
  bool _busy = false;
  bool _tried = false;
  String? _progress;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  bool get _descriptionOk {
    final n = _description.text.trim().length;
    return n >= 10 && n <= 2000;
  }

  Future<void> _add() async {
    final file = await pickEvidence(context);
    if (file != null && mounted) setState(() => _files.add(file));
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l = context.l10n;
    if (!_descriptionOk || _files.isEmpty) {
      setState(() => _tried = true);
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(complaintRepositoryProvider);
      // Tệp đã tải lên giữ `blobName` nên bấm gửi lại sau lỗi không tải lại.
      final names = await repo.uploadEvidence(
        _files,
        onProgress: (done, total) {
          if (mounted) setState(() => _progress = l.cpUploading(done, total));
        },
      );
      if (mounted) setState(() => _progress = null);
      final complaint = await repo.open(
        orderId: widget.orderId,
        reason: _reason,
        description: _description.text,
        attachments: names,
      );
      refreshComplaints(ref);
      refreshOrders(ref, orderId: widget.orderId);
      ref.invalidate(auctionOrderProvider);
      if (!mounted) return;
      AppSnackbar.success(context, l.cpOpened);
      context.pushReplacement('/me/complaints/${complaint.id}');
    } on ApiError catch (e) {
      if (!mounted) return;
      // Đơn đã có khiếu nại / hết cửa sổ: tải lại đơn để nút đổi theo.
      if (e.needsReload || e.code == ApiErrorCode.complaintWindowClosed) {
        refreshOrders(ref, orderId: widget.orderId);
      }
      AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(l.cpOpenTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen + 4),
          children: [
            Text(
              l.cpOpenNote,
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l.cpReasonLabel, style: context.text.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final r in CaseReason.values)
                  ChoiceChip(
                    label: Text(caseReasonLabel(l, r)),
                    selected: _reason == r,
                    onSelected: _busy
                        ? null
                        : (_) => setState(() => _reason = r),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _description,
              enabled: !_busy,
              minLines: 4,
              maxLines: 8,
              maxLength: 2000,
              // Đợi IME ghép xong dấu tiếng Việt rồi mới cắt (mặc định Android
              // chặn ngay khi đang ghép, làm mất dấu ở sát giới hạn).
              maxLengthEnforcement:
                  MaxLengthEnforcement.truncateAfterCompositionEnds,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l.cpDescLabel,
                hintText: l.cpDescHint,
                errorText: _tried && !_descriptionOk ? l.cpDescInvalid : null,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.cpEvidence, style: context.text.labelMedium),
                Text(
                  l.cpEvidenceCount(_files.length),
                  style: context.text.labelSmall?.copyWith(
                    color: _files.isNotEmpty
                        ? colors.success
                        : colors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            EvidenceGrid(
              files: _files,
              enabled: !_busy,
              onAdd: _add,
              onRemove: (i) => setState(() => _files.removeAt(i)),
            ),
            if (_tried && _files.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  l.cpEvidenceRequired,
                  style: context.text.labelSmall?.copyWith(color: colors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            if (_progress != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  _progress!,
                  textAlign: TextAlign.center,
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            AppButton(label: l.cpSubmit, loading: _busy, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
