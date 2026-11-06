import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../domain/ai_answers.dart';
import '../domain/ai_models.dart';

/// Đơn vị tiền do agent gửi.
bool _isMoneyUnit(String? unit) {
  final u = unit?.trim().toLowerCase();
  return u == 'đ' || u == '₫' || u == 'vnd' || u == 'vnđ';
}

/// Thẻ câu hỏi dưới tin AI cuối. [onSubmit] nhận đáp án và bản tóm tắt dễ đọc
/// (hiện làm tin của người dùng). [enabled] false khi đang gửi.
class AiQuestionCard extends StatefulWidget {
  const AiQuestionCard({
    super.key,
    required this.pending,
    required this.onSubmit,
    required this.onDismiss,
    this.enabled = true,
  });

  final AiPendingQuestion pending;
  final bool enabled;
  final void Function(List<AiAnswer> answers, String summary) onSubmit;
  final VoidCallback onDismiss;

  @override
  State<AiQuestionCard> createState() => _AiQuestionCardState();
}

class _AiQuestionCardState extends State<AiQuestionCard> {
  final Map<String, AiAnswerDraft> _drafts = {};
  final Map<String, TextEditingController> _controllers = {};

  List<AiQuestion> get _questions => widget.pending.questions;

  bool get _autoSend =>
      _questions.length == 1 &&
      _questions.first.kind == AiQuestionKind.singleChoice &&
      !_questions.first.allowOther;

  AiAnswerDraft _draft(AiQuestion q) => _drafts[q.id] ?? const AiAnswerDraft();

  TextEditingController _ctrl(String key) =>
      _controllers.putIfAbsent(key, TextEditingController.new);

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _update(AiQuestion q, AiAnswerDraft d) =>
      setState(() => _drafts[q.id] = d);

  void _submit() {
    final answers = buildAiAnswers(_questions, _drafts);
    if (answers == null || !widget.enabled) return;
    final summary = summarizeAiAnswers(
      _questions,
      answers,
      formatValue: (q, v) {
        if (q.kind != AiQuestionKind.number) return v;
        final n = formatAiNumberInput(v);
        return q.unit == null ? n : '$n ${q.unit}';
      },
    );
    widget.onSubmit(answers, summary);
  }

  void _pickSingle(AiQuestion q, AiQuestionOption o) {
    _update(q, AiAnswerDraft(picked: {o.value}));
    if (_autoSend) _submit();
  }

  void _toggleMulti(AiQuestion q, AiQuestionOption o, bool on) {
    final d = _draft(q);
    final picked = {...d.picked};
    on ? picked.add(o.value) : picked.remove(o.value);
    _update(q, d.copyWith(picked: picked));
  }

  void _toggleOther(AiQuestion q, bool on) {
    final d = _draft(q);
    if (q.kind == AiQuestionKind.singleChoice) {
      _update(
        q,
        AiAnswerDraft(
          picked: const {},
          otherSelected: on,
          otherText: d.otherText,
        ),
      );
    } else {
      _update(q, d.copyWith(otherSelected: on));
    }
  }

  Widget _buildQuestion(AiQuestion q) {
    final l = context.l10n;
    final d = _draft(q);
    final enabled = widget.enabled;
    final body = switch (q.kind) {
      AiQuestionKind.singleChoice || AiQuestionKind.multiChoice => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final o in q.options)
                if (q.kind == AiQuestionKind.singleChoice)
                  ChoiceChip(
                    label: Text(o.label),
                    selected: !d.otherSelected && d.picked.contains(o.value),
                    onSelected: enabled ? (_) => _pickSingle(q, o) : null,
                  )
                else
                  FilterChip(
                    label: Text(o.label),
                    selected: d.picked.contains(o.value),
                    onSelected: enabled ? (v) => _toggleMulti(q, o, v) : null,
                  ),
              if (q.allowOther)
                if (q.kind == AiQuestionKind.singleChoice)
                  ChoiceChip(
                    label: Text(l.aiQuestionOther),
                    selected: d.otherSelected,
                    onSelected: enabled ? (v) => _toggleOther(q, v) : null,
                  )
                else
                  FilterChip(
                    label: Text(l.aiQuestionOther),
                    selected: d.otherSelected,
                    onSelected: enabled ? (v) => _toggleOther(q, v) : null,
                  ),
            ],
          ),
          if (q.allowOther && d.otherSelected)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: TextField(
                key: Key('ai-other-${q.id}'),
                controller: _ctrl('${q.id}#other'),
                enabled: enabled,
                decoration: InputDecoration(
                  hintText: l.aiQuestionOtherHint,
                  isDense: true,
                ),
                onChanged: (v) => _update(q, d.copyWith(otherText: v)),
              ),
            ),
        ],
      ),
      AiQuestionKind.text => TextField(
        key: Key('ai-text-${q.id}'),
        controller: _ctrl(q.id),
        enabled: enabled,
        minLines: 1,
        maxLines: 3,
        decoration: InputDecoration(hintText: q.placeholder, isDense: true),
        onChanged: (v) => _update(q, d.copyWith(text: v)),
      ),
      AiQuestionKind.number => TextField(
        key: Key('ai-number-${q.id}'),
        controller: _ctrl(q.id),
        enabled: enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]')),
          if (_isMoneyUnit(q.unit)) _ThousandsFormatter(),
        ],
        decoration: InputDecoration(
          hintText: q.placeholder,
          suffixText: q.unit,
          isDense: true,
        ),
        onChanged: (v) => _update(q, d.copyWith(text: v)),
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.prompt, style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          body,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final ready = buildAiAnswers(_questions, _drafts) != null;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.92,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final q in _questions) _buildQuestion(q),
          Row(
            children: [
              TextButton(
                onPressed: widget.enabled ? widget.onDismiss : null,
                child: Text(l.aiQuestionTypeMyself),
              ),
              const Spacer(),
              if (!_autoSend)
                FilledButton(
                  onPressed: ready && widget.enabled ? _submit : null,
                  child: Text(l.aiQuestionSend),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gõ số tiền thì tự chèn dấu chấm nghìn, con trỏ luôn ở cuối.
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = formatAiNumberInput(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
