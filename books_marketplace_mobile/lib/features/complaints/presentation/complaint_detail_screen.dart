import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_image_viewer.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/countdown_text.dart';
import '../../orders/application/order_providers.dart';
import '../../wallet/application/wallet_providers.dart';
import '../application/complaint_providers.dart';
import '../data/complaint_repository.dart';
import '../domain/complaint_case.dart';
import 'complaint_text.dart';
import 'evidence_picker.dart';

/// Chi tiết khiếu nại: diễn biến (chat), hạn phản hồi/quyết định, kết quả và
/// các thao tác theo `actions` của server.
class ComplaintDetailScreen extends ConsumerWidget {
  const ComplaintDetailScreen({super.key, required this.complaintId});

  final String complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(complaintProvider(complaintId));
    return Scaffold(
      appBar: AppBar(title: Text(l.cpListTitle)),
      body: SafeArea(
        child: state.when(
          skipLoadingOnReload: true,
          loading: () => const AppLoadingView(),
          error: (e, _) => AppErrorView(
            error: e,
            onRetry: () => ref.invalidate(complaintProvider(complaintId)),
          ),
          data: (c) => _Body(complaint: c),
        ),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.complaint});

  final ComplaintCase complaint;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _busy = false;
  final _message = TextEditingController();
  final List<EvidenceFile> _files = [];

  ComplaintCase get c => widget.complaint;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  /// Chạy một thao tác ghi; thành công thì tải lại khiếu nại, đơn và ví (tiền có
  /// thể đã được thực hiện).
  Future<bool> _run(Future<Object?> Function() action, String? success) async {
    if (_busy) return false;
    setState(() => _busy = true);
    try {
      await action();
      refreshComplaints(ref, id: c.id);
      if (c.order != null) refreshOrders(ref, orderId: c.order!.id);
      ref.read(walletProvider.notifier).refresh();
      ref.invalidate(walletTransactionsProvider);
      if (mounted && success != null) AppSnackbar.success(context, success);
      return true;
    } on ApiError catch (e) {
      // Sai trạng thái (đã quá hạn, bên kia vừa thao tác): tải lại.
      if (e.needsReload) refreshComplaints(ref, id: c.id);
      if (mounted) AppSnackbar.apiError(context, e);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _respond() async {
    final l = context.l10n;
    final price = c.order?.price ?? 0;
    final result = await showAppSheet<_SellerInput>(
      context,
      builder: (sheet) => _RespondForm(sheetContext: sheet, price: price),
    );
    if (result == null || !mounted) return;
    await _run(() async {
      final repo = ref.read(complaintRepositoryProvider);
      final names = await repo.uploadEvidence(result.files);
      return repo.sellerResponse(
        c.id,
        action: result.action,
        amount: result.amount,
        reason: result.reason,
        attachments: names,
      );
    }, l.cpResponded);
  }

  Future<void> _decide(bool accept) async {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final resp = c.sellerResponse;
    final String message;
    if (accept) {
      message = switch (resp?.action) {
        SellerAction.acceptRefund => l.cpAcceptFull,
        SellerAction.proposePartial => l.cpAcceptPartial(
          formatVnd(resp?.amount ?? 0, locale),
        ),
        _ => l.cpAcceptReject,
      };
    } else {
      message = l.cpDisagreeBody;
    }
    final ok = await showConfirmDialog(
      context,
      title: accept ? l.cpAcceptTitle : l.cpDisagreeTitle,
      message: message,
      confirmLabel: accept ? l.cpAccept : l.cpDisagree,
      // Đồng ý với lời từ chối = rút khiếu nại: nhấn mạnh là thao tác nặng.
      destructive: accept && resp?.action == SellerAction.reject,
    );
    if (!ok || !mounted) return;
    await _run(
      () => ref
          .read(complaintRepositoryProvider)
          .buyerDecision(c.id, accept: accept),
      l.cpDecided,
    );
  }

  Future<void> _send() async {
    final l = context.l10n;
    if (_message.text.trim().isEmpty && _files.isEmpty) {
      AppSnackbar.show(context, l.cpMessageNeed, type: AppSnackbarType.error);
      return;
    }
    final ok = await _run(() async {
      final repo = ref.read(complaintRepositoryProvider);
      final names = await repo.uploadEvidence(_files);
      return repo.message(c.id, body: _message.text, attachments: names);
    }, null);
    if (ok && mounted) {
      setState(() {
        _message.clear();
        _files.clear();
      });
    }
  }

  Future<void> _addFile() async {
    final file = await pickEvidence(context);
    if (file != null && mounted) setState(() => _files.add(file));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final a = c.actions;
    String daysHours(int d, int h) => '$d ngày $h giờ';

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(complaintProvider(c.id));
              await ref.read(complaintProvider(c.id).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screen + 4),
              children: [
                // Đầu: trạng thái, lý do, đơn
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppTag(
                            label: caseStatusLabel(l, c.status),
                            tone: caseStatusTone(c.status),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          if (c.reason != null)
                            Text(
                              caseReasonLabel(l, c.reason!),
                              style: context.text.labelMedium,
                            ),
                        ],
                      ),
                      if (c.order != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          c.order!.bookTitle,
                          style: context.text.titleMedium,
                        ),
                        Text(
                          '${l.soTotal}: ${formatVnd(c.order!.totalAmount, locale)}',
                          style: context.text.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push('/me/orders/${c.order!.id}'),
                          child: Text(l.cpOpenOrder),
                        ),
                      ],
                      if (c.description != null)
                        Text(c.description!, style: context.text.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Đếm ngược theo trạng thái
                if (c.status == CaseStatus.open && c.sellerDeadlineAt != null)
                  _Deadline(
                    target: c.sellerDeadlineAt!,
                    daysHours: daysHours,
                    textFor: l.cpSellerDeadline,
                  ),
                if (c.status == CaseStatus.sellerResponded &&
                    c.buyerDeadlineAt != null)
                  _Deadline(
                    target: c.buyerDeadlineAt!,
                    daysHours: daysHours,
                    textFor: l.cpBuyerDeadline,
                  ),
                if (!c.status.isFinal)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      escalationText(l, c.escalationCause) ?? l.cpLockedNote,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),

                // Kết quả
                if (c.resolution != null)
                  _ResolutionBox(resolution: c.resolution!, isBuyer: c.isBuyer),

                // Diễn biến
                for (final e in c.entries) _EntryTile(entry: e),
              ],
            ),
          ),
        ),

        // Thao tác
        _ActionArea(
          children: [
            if (a.canRespond)
              AppButton(
                label: l.cpRespond,
                loading: _busy,
                onPressed: _respond,
              ),
            if (a.canDecide) ...[
              AppButton(
                label: l.cpAccept,
                loading: _busy,
                onPressed: () => _decide(true),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: l.cpDisagree,
                variant: AppButtonVariant.secondary,
                onPressed: _busy ? null : () => _decide(false),
              ),
            ],
          ],
        ),
        _Composer(
          enabled: a.canMessage && !_busy,
          closed: !a.canMessage,
          controller: _message,
          files: _files,
          onAdd: _addFile,
          onRemove: (i) => setState(() => _files.removeAt(i)),
          onSend: _send,
        ),
      ],
    );
  }
}

class _ActionArea extends StatelessWidget {
  const _ActionArea({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen + 4,
        AppSpacing.xs,
        AppSpacing.screen + 4,
        AppSpacing.xs,
      ),
      child: Column(children: children),
    );
  }
}

class _Deadline extends StatelessWidget {
  const _Deadline({
    required this.target,
    required this.daysHours,
    required this.textFor,
  });

  final DateTime target;
  final String Function(int, int) daysHours;
  final String Function(String) textFor;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Countdown(
        target: target,
        daysHours: daysHours,
        builder: (context, remaining, expired) => DecoratedBox(
          decoration: BoxDecoration(
            color: expired ? colors.errorContainer : colors.warningContainer,
            borderRadius: AppRadius.mdAll,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              expired
                  ? '${textFor(l.soOverdue)}. ${l.cpDeadlineNote}'
                  : textFor(remaining),
              style: context.text.labelMedium?.copyWith(
                color: expired
                    ? colors.onErrorContainer
                    : colors.onWarningContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResolutionBox extends StatelessWidget {
  const _ResolutionBox({required this.resolution, required this.isBuyer});

  final CaseResolution resolution;
  final bool isBuyer;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final outcome = switch (resolution.outcome) {
      CaseOutcome.fullRefund => l.cpOutFull,
      CaseOutcome.partialRefund => l.cpOutPartial(
        formatVnd(resolution.refundAmount ?? 0, locale),
      ),
      CaseOutcome.releaseToSeller => l.cpOutRelease,
      null => '',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.successContainer,
          borderRadius: AppRadius.mdAll,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.cpResolution,
                style: context.text.labelSmall?.copyWith(
                  color: colors.onSuccessContainer,
                ),
              ),
              Text(
                outcome,
                style: context.text.titleMedium?.copyWith(
                  color: colors.onSuccessContainer,
                ),
              ),
              Text(
                resolution.byAdmin ? l.cpByAdmin : l.cpByAgreement,
                style: context.text.labelSmall?.copyWith(
                  color: colors.onSuccessContainer,
                ),
              ),
              if (resolution.reason != null)
                Text(
                  resolution.reason!,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSuccessContainer,
                  ),
                ),
              // Admin yêu cầu gửi trả sách: nổi bật cho người mua.
              if (resolution.returnRequired && isBuyer)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    l.cpReturnRequired,
                    style: context.text.labelMedium?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final CaseEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final title = caseEntryTitle(l, entry.kind);
    final author = [
      caseAuthorLabel(l, entry.authorRole),
      if (entry.authorName != null && entry.authorName!.isNotEmpty)
        entry.authorName!,
    ].where((e) => e.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        color: entry.kind == CaseEntryKind.message ? null : colors.surfaceMuted,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title ?? author, style: context.text.labelLarge),
                ),
                if (entry.createdAt != null)
                  Text(
                    formatDateTime(entry.createdAt!, locale),
                    style: context.text.labelSmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
              ],
            ),
            if (title != null && author.isNotEmpty)
              Text(
                author,
                style: context.text.labelSmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            if (entry.amount != null)
              Text(
                l.cpRefundAmount(formatVnd(entry.amount!, locale)),
                style: context.text.labelMedium?.copyWith(
                  color: colors.success,
                ),
              ),
            if (entry.body != null) ...[
              const SizedBox(height: 4),
              Text(entry.body!, style: context.text.bodyMedium),
            ],
            if (entry.attachments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              _Attachments(items: entry.attachments),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tệp bằng chứng: ảnh mở trình xem toàn màn hình, video mở bằng trình phát của
/// hệ thống. URL có chữ ký hết hạn sau 15 phút nên không lưu lâu.
class _Attachments extends StatelessWidget {
  const _Attachments({required this.items});

  final List<CaseAttachment> items;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final images = [
      for (final a in items)
        if (!a.isVideo) a,
    ];
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final a in items)
          GestureDetector(
            onTap: () async {
              if (a.isVideo) {
                final ok = await launchUrl(
                  Uri.parse(a.url),
                  mode: LaunchMode.externalApplication,
                );
                if (!ok && context.mounted) {
                  AppSnackbar.show(
                    context,
                    l.topupCannotOpen,
                    type: AppSnackbarType.error,
                  );
                }
              } else {
                showImageViewer(
                  context,
                  urls: [for (final i in images) i.url],
                  labels: [for (var n = 0; n < images.length; n++) '${n + 1}'],
                  initialIndex: images.indexOf(a),
                );
              }
            },
            child: SizedBox(
              width: 72,
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: a.isVideo
                    ? ColoredBox(
                        color: colors.surface,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              color: colors.textSecondary,
                              size: 28,
                            ),
                            Text(l.cpOpenVideo, style: context.text.labelSmall),
                          ],
                        ),
                      )
                    : Image.network(
                        a.url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.broken_image_outlined,
                          color: colors.textMuted,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.enabled,
    required this.closed,
    required this.controller,
    required this.files,
    required this.onAdd,
    required this.onRemove,
    required this.onSend,
  });

  final bool enabled;
  final bool closed;
  final TextEditingController controller;
  final List<EvidenceFile> files;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    // Khóa ô nhập khi `canMessage = false` (khiếu nại đã đóng).
    if (closed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        color: colors.surfaceMuted,
        child: Text(
          l.cpMessageClosed,
          textAlign: TextAlign.center,
          style: context.text.labelSmall?.copyWith(color: colors.textMuted),
        ),
      );
    }
    return Material(
      color: colors.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (files.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: EvidenceGrid(
                      files: files,
                      enabled: enabled,
                      onAdd: onAdd,
                      onRemove: onRemove,
                    ),
                  ),
                ),
              Row(
                children: [
                  IconButton(
                    tooltip: l.cpAddEvidence,
                    onPressed: enabled && files.length < maxEvidenceFiles
                        ? onAdd
                        : null,
                    icon: const Icon(Icons.attach_file),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: enabled,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l.cpMessageHint,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l.cpSend,
                    onPressed: enabled ? onSend : null,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerInput {
  const _SellerInput({
    required this.action,
    required this.files,
    this.amount,
    this.reason,
  });

  final SellerAction action;
  final int? amount;
  final String? reason;
  final List<EvidenceFile> files;
}

/// Phản hồi của người bán: đồng ý hoàn, đề xuất hoàn một phần (số tiền 1 đến
/// `giá − 1`) hoặc từ chối (lý do từ 10 ký tự, nên kèm ảnh).
class _RespondForm extends StatefulWidget {
  const _RespondForm({required this.sheetContext, required this.price});

  final BuildContext sheetContext;
  final int price;

  @override
  State<_RespondForm> createState() => _RespondFormState();
}

class _RespondFormState extends State<_RespondForm> {
  SellerAction _action = SellerAction.acceptRefund;
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  final List<EvidenceFile> _files = [];
  bool _tried = false;

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  int get _maxAmount => widget.price - 1;

  bool get _valid {
    switch (_action) {
      case SellerAction.acceptRefund:
        return true;
      case SellerAction.proposePartial:
        final v = int.tryParse(_amount.text);
        return v != null && v >= 1 && v <= _maxAmount;
      case SellerAction.reject:
        return _reason.text.trim().length >= 10;
    }
  }

  Future<void> _add() async {
    final f = await pickEvidence(context);
    if (f != null && mounted) setState(() => _files.add(f));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(l.cpRespondTitle),
        const SizedBox(height: AppSpacing.sm),
        RadioGroup<SellerAction>(
          groupValue: _action,
          onChanged: (v) => setState(() => _action = v ?? _action),
          child: Column(
            children: [
              RadioListTile<SellerAction>(
                value: SellerAction.acceptRefund,
                contentPadding: EdgeInsets.zero,
                title: Text(l.cpActAccept),
              ),
              RadioListTile<SellerAction>(
                value: SellerAction.proposePartial,
                contentPadding: EdgeInsets.zero,
                title: Text(l.cpActPartial),
              ),
              RadioListTile<SellerAction>(
                value: SellerAction.reject,
                contentPadding: EdgeInsets.zero,
                title: Text(l.cpActReject),
              ),
            ],
          ),
        ),
        if (_action == SellerAction.proposePartial)
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l.cpAmountLabel,
              errorText: _tried && !_valid
                  ? l.cpAmountInvalid(formatVnd(_maxAmount, locale))
                  : null,
            ),
          ),
        if (_action == SellerAction.reject) ...[
          TextField(
            controller: _reason,
            minLines: 2,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l.cpRejectReason,
              errorText: _tried && !_valid ? l.cpReasonInvalid : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          EvidenceGrid(
            files: _files,
            onAdd: _add,
            onRemove: (i) => setState(() => _files.removeAt(i)),
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        Text(
          l.cpRespondNote,
          style: context.text.labelSmall?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l.cpRespondSubmit,
          onPressed: () {
            if (!_valid) {
              setState(() => _tried = true);
              return;
            }
            Navigator.of(widget.sheetContext).pop(
              _SellerInput(
                action: _action,
                amount: _action == SellerAction.proposePartial
                    ? int.parse(_amount.text)
                    : null,
                reason: _action == SellerAction.reject ? _reason.text : null,
                files: _action == SellerAction.reject ? _files : const [],
              ),
            );
          },
        ),
      ],
    );
  }
}
