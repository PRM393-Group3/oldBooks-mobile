import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import '../../../../categories/domain/category.dart';

/// Chọn một nút bất kỳ trong cây danh mục (tối đa 3 cấp). Chạm dòng để chọn,
/// chạm mũi tên để mở nhóm con.
Future<CategoryNode?> showCategoryPicker(
  BuildContext context, {
  required List<CategoryNode> tree,
  String? selectedId,
}) {
  return showModalBottomSheet<CategoryNode>(
    context: context,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.categoryPickerTitle,
                style: context.text.titleLarge,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              children: [
                for (final n in tree)
                  _Node(node: n, depth: 0, selectedId: selectedId),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Node extends StatefulWidget {
  const _Node({
    required this.node,
    required this.depth,
    required this.selectedId,
  });

  final CategoryNode node;
  final int depth;
  final String? selectedId;

  @override
  State<_Node> createState() => _NodeState();
}

class _NodeState extends State<_Node> {
  late bool _open =
      CategoryNode.find(widget.node.children, widget.selectedId) != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final node = widget.node;
    final selected = node.id == widget.selectedId;
    final hasChildren = node.children.isNotEmpty;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(
            left: AppSpacing.md + widget.depth * AppSpacing.lg,
            right: AppSpacing.xs,
          ),
          title: Text(node.name),
          selected: selected,
          selectedColor: colors.primary,
          onTap: () => Navigator.of(context).pop(node),
          trailing: hasChildren
              ? IconButton(
                  tooltip: node.name,
                  icon: Icon(_open ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _open = !_open),
                )
              : (selected ? Icon(Icons.check, color: colors.primary) : null),
        ),
        if (hasChildren && _open)
          for (final c in node.children)
            _Node(
              node: c,
              depth: widget.depth + 1,
              selectedId: widget.selectedId,
            ),
      ],
    );
  }
}
