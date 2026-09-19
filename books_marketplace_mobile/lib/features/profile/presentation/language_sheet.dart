import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/theme_context.dart';

/// Bảng chọn ngôn ngữ: theo hệ thống, Tiếng Việt, English.
Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final current = ref.watch(localeControllerProvider);
    final controller = ref.read(localeControllerProvider.notifier);

    Widget option(String label, Locale? locale) {
      final selected = current?.languageCode == locale?.languageCode;
      return ListTile(
        title: Text(label),
        trailing: selected
            ? Icon(Icons.check, color: context.colors.primary)
            : null,
        selected: selected,
        selectedColor: context.colors.primary,
        onTap: () {
          controller.select(locale);
          Navigator.of(context).pop();
        },
      );
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          option(l.languageSystem, null),
          option(l.languageVi, const Locale('vi')),
          option(l.languageEn, const Locale('en')),
        ],
      ),
    );
  }
}
