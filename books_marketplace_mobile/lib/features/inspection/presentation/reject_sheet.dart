import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/inspection.dart';

typedef RejectDecision = ({List<RejectReason> reasons, String note});

/// Bảng từ chối: chọn ít nhất 1 lý do và ghi chú tối thiểu [minNote] ký tự
/// (FR-INS-09). Trả `null` nếu người dùng hủy.
Future<RejectDecision?> showRejectSheet(
  BuildContext context, {
  required int minNote,
}) {
  return showModalBottomSheet<RejectDecision>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _RejectSheet(minNote: minNote),
  );
}

class _RejectSheet extends StatefulWidget {
  const _RejectSheet({required this.minNote});

  final int minNote;

  @override
  State<_RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<_RejectSheet> {
  final _note = TextEditingController();
  final _selected = <RejectReason>{};
  bool _submitted = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    if (_selected.isEmpty || _note.text.trim().length < widget.minNote) return;
    Navigator.of(context).pop((
      reasons: RejectReason.values.where(_selected.contains).toList(),
      note: _note.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final noteShort = _note.text.trim().length < widget.minNote;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.rejectTitle, style: context.text.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Text(l.rejectReasonsLabel, style: context.text.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final r in RejectReason.values)
                    FilterChip(
                      label: Text(r.label(l)),
                      selected: _selected.contains(r),
                      showCheckmark: true,
                      onSelected: (on) => setState(
                        () => on ? _selected.add(r) : _selected.remove(r),
                      ),
                    ),
                ],
              ),
              if (_submitted && _selected.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    l.validationRejectReasons,
                    style: context.text.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.rejectNoteLabel,
                controller: _note,
                maxLength: 1000,
                maxLines: 5,
                minLines: 3,
                keyboardType: TextInputType.multiline,
                helperText: l.rejectNoteHelper(widget.minNote),
                errorText: _submitted && noteShort
                    ? l.validationRejectNote(widget.minNote)
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l.reject,
                variant: AppButtonVariant.danger,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
