import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../domain/listing_enums.dart';
import '../../domain/listing_query.dart';

/// Bộ lọc tìm kiếm: tình trạng, khoảng giá, sắp xếp. Trả về điều kiện mới (giữ
/// nguyên từ khóa và danh mục), hoặc `null` nếu đóng mà không áp dụng.
Future<ListingQuery?> showListingFilterSheet(
  BuildContext context,
  ListingQuery current,
) => showAppSheet<ListingQuery>(
  context,
  builder: (sheet) => _FilterBody(current: current),
);

class _FilterBody extends StatefulWidget {
  const _FilterBody({required this.current});

  final ListingQuery current;

  @override
  State<_FilterBody> createState() => _FilterBodyState();
}

class _FilterBodyState extends State<_FilterBody> {
  late BookCondition? _condition = widget.current.condition;
  late ListingSort _sort = widget.current.sort;
  late final _min = TextEditingController(
    text: widget.current.minPrice?.toString() ?? '',
  );
  late final _max = TextEditingController(
    text: widget.current.maxPrice?.toString() ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _apply() {
    final min = int.tryParse(_min.text);
    final max = int.tryParse(_max.text);
    if (min != null && max != null && min > max) {
      setState(() => _error = context.l10n.filterPriceInvalid);
      return;
    }
    Navigator.of(context).pop(
      widget.current.copyWith(
        condition: () => _condition,
        minPrice: () => min,
        maxPrice: () => max,
        sort: _sort,
      ),
    );
  }

  void _reset() => setState(() {
    _condition = null;
    _sort = ListingSort.newest;
    _min.clear();
    _max.clear();
    _error = null;
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    String sortLabel(ListingSort s) => switch (s) {
      ListingSort.newest => l.sortNewest,
      ListingSort.priceAsc => l.sortPriceAsc,
      ListingSort.priceDesc => l.sortPriceDesc,
    };

    Widget title(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Text(text, style: context.text.labelMedium),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(l.filterTitle),
        title(l.filterCondition),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            ChoiceChip(
              label: Text(l.filterAll),
              selected: _condition == null,
              onSelected: (_) => setState(() => _condition = null),
            ),
            for (final c in BookCondition.values)
              ChoiceChip(
                label: Text(c.label(l)),
                selected: _condition == c,
                onSelected: (_) => setState(() => _condition = c),
              ),
          ],
        ),
        title(l.filterPrice),
        Row(
          children: [
            Expanded(child: _priceField(_min, l.filterMin)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _priceField(_max, l.filterMax)),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _error!,
              style: context.text.labelSmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        title(l.filterSort),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final s in ListingSort.values)
              ChoiceChip(
                label: Text(sortLabel(s)),
                selected: _sort == s,
                onSelected: (_) => setState(() => _sort = s),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(label: l.filterApply, onPressed: _apply),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: l.filterReset,
          variant: AppButtonVariant.text,
          onPressed: _reset,
        ),
      ],
    );
  }

  Widget _priceField(TextEditingController c, String label) => TextField(
    controller: c,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    onChanged: (_) => setState(() => _error = null),
    decoration: InputDecoration(labelText: label),
  );
}
