import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import '../../../../../core/validation/isbn.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_page.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../categories/domain/category.dart';
import '../../../domain/listing.dart';
import '../../../domain/listing_enums.dart';
import '../../../domain/listing_input.dart';
import '../../../domain/listing_rules.dart';
import 'category_picker.dart';

/// Bước 1: thông tin sách.
class BookInfoStep extends StatefulWidget {
  const BookInfoStep({
    super.key,
    required this.listing,
    required this.rules,
    required this.categories,
    required this.saving,
    required this.errors,
    required this.onSubmit,
    required this.onClearError,
  });

  final Listing? listing;
  final ListingRules rules;
  final List<CategoryNode> categories;
  final bool saving;

  /// Lỗi từ server theo tên trường (chữ thường).
  final Map<String, String> errors;
  final ValueChanged<BookInfoInput> onSubmit;
  final ValueChanged<String> onClearError;

  @override
  State<BookInfoStep> createState() => _BookInfoStepState();
}

class _BookInfoStepState extends State<BookInfoStep> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: _info?.title);
  late final _author = TextEditingController(text: _info?.author);
  late final _publisher = TextEditingController(text: _info?.publisher);
  late final _isbn = TextEditingController(text: _info?.isbn);
  late final _year = TextEditingController(
    text: _info?.publicationYear?.toString(),
  );
  late final _language = TextEditingController(text: _info?.language);
  late final _pages = TextEditingController(text: _info?.pageCount?.toString());
  late final _description = TextEditingController(text: _info?.description);
  late final _defects = TextEditingController(text: _info?.defectNotes);

  late CategoryNode? _category = CategoryNode.find(
    widget.categories,
    widget.listing?.category?.id,
  );
  late BookCondition? _condition = _info?.condition;
  late CoverType? _cover = _info?.coverType;
  bool _submitted = false;

  BookInfo? get _info => widget.listing?.bookInfo;

  @override
  void dispose() {
    for (final c in [
      _title,
      _author,
      _publisher,
      _isbn,
      _year,
      _language,
      _pages,
      _description,
      _defects,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _err(String key) => widget.errors[key.toLowerCase()];

  Future<void> _pickCategory() async {
    final picked = await showCategoryPicker(
      context,
      tree: widget.categories,
      selectedId: _category?.id,
    );
    if (picked != null) {
      setState(() => _category = picked);
      widget.onClearError('categoryid');
    }
  }

  void _next() {
    setState(() => _submitted = true);
    final valid = _formKey.currentState!.validate();
    if (!valid || _category == null || _condition == null) return;
    widget.onSubmit(
      BookInfoInput(
        title: _title.text,
        author: _author.text,
        categoryId: _category!.id,
        publisher: _publisher.text,
        isbn: _isbn.text.replaceAll(RegExp(r'[\s-]'), ''),
        publicationYear: int.tryParse(_year.text.trim()),
        language: _language.text,
        pageCount: int.tryParse(_pages.text.trim()),
        coverType: _cover,
        condition: _condition!,
        description: _description.text,
        defectNotes: _defects.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final rules = widget.rules;
    final maxYear = DateTime.now().year + 1;
    final enabled = !widget.saving;

    String? required(String? v, String field) => (v == null || v.trim().isEmpty)
        ? l.validationFieldRequired(field)
        : null;

    return AppPage(
      bottom: AppButton(
        label: l.next,
        loading: widget.saving,
        onPressed: _next,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.draftSavedHint,
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.fieldTitle,
              controller: _title,
              enabled: enabled,
              maxLength: 200,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => required(v, l.fieldTitle),
              errorText: _err('title'),
              onChanged: (_) => widget.onClearError('title'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.fieldAuthor,
              controller: _author,
              enabled: enabled,
              maxLength: 200,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: (v) => required(v, l.fieldAuthor),
              errorText: _err('author'),
              onChanged: (_) => widget.onClearError('author'),
            ),
            const SizedBox(height: AppSpacing.md),
            _CategoryField(
              label: l.fieldCategory,
              value: _category?.name,
              error: _submitted && _category == null
                  ? l.validationChooseCategory
                  : _err('categoryid'),
              onTap: enabled ? _pickCategory : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l.fieldCondition, style: context.text.labelMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l.fieldConditionHelper,
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final c in BookCondition.values)
              _ConditionTile(
                condition: c,
                selected: _condition == c,
                onTap: enabled
                    ? () {
                        setState(() => _condition = c);
                        widget.onClearError('condition');
                      }
                    : null,
              ),
            if ((_submitted && _condition == null) || _err('condition') != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs),
                child: Text(
                  _err('condition') ?? l.validationChooseCondition,
                  style: context.text.bodySmall?.copyWith(color: colors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.fieldDescription,
              controller: _description,
              enabled: enabled,
              maxLength: 5000,
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              minLines: 4,
              helperText: l.fieldDescriptionHelper(
                rules.minDescriptionLength,
                _description.text.trim().length,
              ),
              validator: (v) =>
                  (v?.trim().length ?? 0) < rules.minDescriptionLength
                  ? l.validationDescriptionMin(rules.minDescriptionLength)
                  : null,
              errorText: _err('description'),
              onChanged: (_) {
                widget.onClearError('description');
                setState(() {});
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.fieldDefects,
              controller: _defects,
              enabled: enabled,
              maxLength: 1000,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              minLines: 2,
              helperText: l.optionalHint,
              errorText: _err('defectnotes'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.fieldPublisher,
              controller: _publisher,
              enabled: enabled,
              maxLength: 200,
              textInputAction: TextInputAction.next,
              helperText: l.optionalHint,
              errorText: _err('publisher'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.fieldIsbn,
              controller: _isbn,
              enabled: enabled,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              helperText: l.optionalHint,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9Xx\- ]')),
              ],
              validator: (v) =>
                  (v == null || v.trim().isEmpty || isValidIsbn(v))
                  ? null
                  : l.validationIsbn,
              errorText: _err('isbn'),
              onChanged: (_) => widget.onClearError('isbn'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: l.fieldYear,
                    controller: _year,
                    enabled: enabled,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 4,
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null) {
                        return l.validationFieldRequired(l.fieldYear);
                      }
                      return (n < 1400 || n > maxYear)
                          ? l.validationYearRange(1400, maxYear)
                          : null;
                    },
                    errorText: _err('publicationyear'),
                    onChanged: (_) => widget.onClearError('publicationyear'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppTextField(
                    label: l.fieldPages,
                    controller: _pages,
                    enabled: enabled,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 5,
                    helperText: l.optionalHint,
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return null;
                      final n = int.tryParse(t);
                      return (n == null || n < 1 || n > 10000)
                          ? l.validationPagesRange
                          : null;
                    },
                    errorText: _err('pagecount'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.fieldLanguage,
              controller: _language,
              enabled: enabled,
              maxLength: 2,
              helperText: l.fieldLanguageHelper,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
              ],
              validator: (v) =>
                  RegExp(r'^[a-zA-Z]{2}$').hasMatch(v?.trim() ?? '')
                  ? null
                  : l.validationLanguage,
              errorText: _err('language'),
              onChanged: (_) => widget.onClearError('language'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l.fieldCover, style: context.text.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final c in CoverType.values)
                  ChoiceChip(
                    label: Text(c.label(l)),
                    selected: _cover == c,
                    onSelected: enabled
                        ? (sel) => setState(() => _cover = sel ? c : null)
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.label,
    required this.value,
    required this.error,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String? error;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: '$label: ${value ?? context.l10n.chooseCategory}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: error,
            suffixIcon: const Icon(Icons.arrow_drop_down),
            prefixIcon: Icon(
              Icons.category_outlined,
              color: colors.textSecondary,
            ),
          ),
          child: Text(
            value ?? context.l10n.chooseCategory,
            style: context.text.bodyMedium?.copyWith(
              color: value == null ? colors.textMuted : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConditionTile extends StatelessWidget {
  const _ConditionTile({
    required this.condition,
    required this.selected,
    required this.onTap,
  });

  final BookCondition condition;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? colors.primaryContainer : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
            side: BorderSide(
              color: selected ? colors.primary : colors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.mdAll,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? colors.primary : colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          condition.label(l),
                          style: context.text.titleMedium,
                        ),
                        Text(
                          condition.description(l),
                          style: context.text.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
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
