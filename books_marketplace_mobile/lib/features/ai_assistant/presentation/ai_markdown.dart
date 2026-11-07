import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/theme_context.dart';

/// Chỉ mở liên kết web/mail/điện thoại; chặn scheme khác (intent:, javascript:...).
bool isSafeAiLink(String? href) {
  final uri = href == null ? null : Uri.tryParse(href.trim());
  if (uri == null) return false;
  return const {'http', 'https', 'mailto', 'tel'}.contains(uri.scheme);
}

/// Tin trả lời của AI dạng markdown. Không render HTML thô (gói này hiển thị
/// thẻ HTML như chữ thường), bỏ qua ảnh, liên kết mở ngoài app, chữ chọn được.
class AiMarkdown extends StatelessWidget {
  const AiMarkdown(this.data, {super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = context.text.bodyMedium ?? const TextStyle();
    final sheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: base,
      a: base.copyWith(
        color: colors.primary,
        decoration: TextDecoration.underline,
      ),
      strong: base.copyWith(fontWeight: FontWeight.w700),
      em: base.copyWith(fontStyle: FontStyle.italic),
      h1: context.text.titleLarge,
      h2: context.text.titleMedium,
      h3: context.text.titleSmall,
      listBullet: base,
      code: base.copyWith(
        fontFamily: 'monospace',
        fontSize: (base.fontSize ?? 14) - 1,
        backgroundColor: colors.border.withValues(alpha: 0.4),
      ),
      codeblockDecoration: BoxDecoration(
        color: colors.border.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.border, width: 3)),
      ),
      blockSpacing: 6,
    );
    return RepaintBoundary(
      child: MarkdownBody(
        data: data,
        selectable: true,
        styleSheet: sheet,
        softLineBreak: true,
        imageBuilder: (uri, title, alt) => const SizedBox.shrink(),
        onTapLink: (text, href, title) {
          if (!isSafeAiLink(href)) return;
          launchUrl(
            Uri.parse(href!.trim()),
            mode: LaunchMode.externalApplication,
          );
        },
      ),
    );
  }
}
