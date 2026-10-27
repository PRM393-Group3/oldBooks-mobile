import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

/// Dấu tích xanh "Đã xác minh" cạnh tên người dùng. Chỉ hiện khi admin đã duyệt
/// eKYC. Có tooltip và nhãn cho trình đọc màn hình.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.verifiedBadgeLabel;
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        image: true,
        excludeSemantics: true,
        child: Icon(Icons.verified, size: size, color: context.colors.info),
      ),
    );
  }
}

/// Tên kèm dấu tích khi [verified]; tên dài thì cắt chữ chứ không đẩy dấu tích
/// ra khỏi hàng.
class NameWithBadge extends StatelessWidget {
  const NameWithBadge(
    this.name, {
    super.key,
    required this.verified,
    this.style,
    this.textAlign,
    this.badgeSize = 18,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  final String name;
  final bool verified;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double badgeSize;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (!verified) return Text(name, style: style, textAlign: textAlign);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Flexible(
          child: Text(
            name,
            style: style,
            textAlign: textAlign,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        VerifiedBadge(size: badgeSize),
      ],
    );
  }
}
