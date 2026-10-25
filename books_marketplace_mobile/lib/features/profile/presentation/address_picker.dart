import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_sheet.dart';
import '../domain/address.dart';

/// Chọn một địa chỉ trong sổ địa chỉ. Trả `id` đã chọn, `null` nếu đóng sheet
/// hoặc người dùng đi thêm địa chỉ mới.
Future<String?> pickAddress(
  BuildContext context,
  List<Address> addresses, {
  String? selectedId,
}) {
  return showAppSheet<String>(
    context,
    builder: (sheet) {
      final l = context.l10n;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(l.ckPickAddress),
          RadioGroup<String>(
            groupValue: selectedId,
            onChanged: (v) => Navigator.of(sheet).pop(v),
            child: Column(
              children: [
                for (final a in addresses)
                  RadioListTile<String>(
                    value: a.id,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${a.recipient} · ${a.phone}'),
                    subtitle: Text(a.fullLine),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(sheet).pop();
              context.push('/me/addresses');
            },
            child: Text(l.ckAddAddress),
          ),
        ],
      );
    },
  );
}
