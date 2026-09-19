import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_paged_list.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../categories/application/category_providers.dart';
import '../../categories/domain/category.dart';
import '../../listings/presentation/seller/wizard/category_picker.dart';
import '../../listings/presentation/widgets/listing_card.dart';
import '../application/inspection_providers.dart';
import '../domain/inspection.dart';

import 'package:flutter/services.dart';

/// Tab "Hàng đợi" của Inspector: tin chờ kiểm định, cũ nhất trước.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final filter = ref.watch(queueFilterProvider);
    final provider = inspectionQueueProvider(filter);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return AppPage(
      title: l.queueTitle,
      scrollable: false,
      child: AppPagedList<QueueItem>(
        value: state,
        onLoadMore: notifier.loadMore,
        onRefresh: notifier.reload,
        header: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: Icon(
                Icons.filter_list,
                size: 18,
                color: filter.isEmpty
                    ? context.colors.textSecondary
                    : context.colors.primary,
              ),
              label: Text(l.filterButton),
              backgroundColor: filter.isEmpty
                  ? null
                  : context.colors.primaryContainer,
              onPressed: () => _showFilter(context, ref, filter),
            ),
          ),
        ),
        empty: AppEmptyView(
          icon: Icons.inbox_outlined,
          title: l.emptyQueueTitle,
          message: l.emptyQueueMessage,
        ),
        itemBuilder: (context, item) => ListingCard(
          listing: item.listing,
          showStatus: false,
          footer: _Footer(item: item),
          onTap: () => context.push('/inspection/${item.listing.id}'),
        ),
      ),
    );
  }

  Future<void> _showFilter(
    BuildContext context,
    WidgetRef ref,
    QueueFilter current,
  ) async {
    final result = await showModalBottomSheet<QueueFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(initial: current),
    );
    if (result != null) ref.read(queueFilterProvider.notifier).set(result);
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.item});

  final QueueItem item;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Wrap(
      spacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (item.isOverdue)
          AppTag(
            label: l.overdueTag,
            tone: AppTagTone.error,
            icon: Icons.warning_amber_rounded,
          ),
        if (item.waitingHours != null)
          Text(
            l.waitingHours(item.waitingHours!.round()),
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.initial});

  final QueueFilter initial;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late final _from = TextEditingController(
    text: widget.initial.priceFrom?.toString(),
  );
  late final _to = TextEditingController(
    text: widget.initial.priceTo?.toString(),
  );
  late String? _categoryId = widget.initial.categoryId;

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tree = ref.watch(categoryTreeProvider).value ?? const [];
    final category = CategoryNode.find(tree, _categoryId);

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
              Text(l.filterTitle, style: context.text.titleLarge),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                borderRadius: AppRadius.mdAll,
                onTap: () async {
                  final picked = await showCategoryPicker(
                    context,
                    tree: tree,
                    selectedId: _categoryId,
                  );
                  if (picked != null) setState(() => _categoryId = picked.id);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l.fieldCategory,
                    suffixIcon: _categoryId == null
                        ? const Icon(Icons.arrow_drop_down)
                        : IconButton(
                            tooltip: l.clearFilter,
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => _categoryId = null),
                          ),
                  ),
                  child: Text(category?.name ?? l.categoryAll),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: l.priceFrom,
                      controller: _from,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      label: l.priceTo,
                      controller: _to,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l.applyFilter,
                onPressed: () => Navigator.pop(
                  context,
                  QueueFilter(
                    categoryId: _categoryId,
                    priceFrom: int.tryParse(_from.text),
                    priceTo: int.tryParse(_to.text),
                  ),
                ),
              ),
              AppButton(
                label: l.clearFilter,
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.pop(context, const QueueFilter()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
