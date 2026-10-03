
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../../../core/util/image_picking.dart';
import '../../../core/util/photo_picker.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../sim/application/sim_providers.dart';
import '../../sim/domain/rules.dart';
import '../application/my_listings_provider.dart';
import '../domain/sell_rules.dart';
import 'sell_text.dart';

/// Tab Đăng bán: một biểu mẫu cho bán giá cố định và đấu giá, kèm ô "Dự tính".
class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});

  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  SellForm _form = const SellForm();
  final List<Uint8List> _photos = [];
  bool _tried = false;

  final _title = TextEditingController();
  final _author = TextEditingController();
  final _price = TextEditingController();
  final _start = TextEditingController();
  final _step = TextEditingController();
  final _buyNow = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    for (final c in [_title, _author, _price, _start, _step, _buyNow, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  void _update(SellForm Function(SellForm f) change) =>
      setState(() => _form = change(_form));

  int _num(TextEditingController c) => int.tryParse(c.text) ?? 0;

  /// Đồng bộ các ô nhập vào form (gọi mỗi lần chữ đổi).
  void _sync() => _update(
    (f) => f.copyWith(
      title: _title.text,
      author: _author.text,
      description: _desc.text,
      price: _num(_price),
      startingPrice: _num(_start),
      step: _num(_step),
      buyNow: _num(_buyNow),
      photos: _photos.length,
    ),
  );

  Future<void> _addPhoto() async {
    if (_photos.length >= maxSellPhotos) return;
    try {
      final image = await ref.read(photoPickerProvider)();
      if (image != null && mounted) {
        _photos.add(image.bytes);
        _sync();
      }
    } on ImagePickException {
      if (mounted) {
        AppSnackbar.show(
          context,
          context.l10n.sellErrPhotos(_photos.length),
          type: AppSnackbarType.error,
        );
      }
    }
  }

  void _removePhoto(int i) {
    _photos.removeAt(i);
    _sync();
  }

  String _newCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = ref.read(randomProvider);
    return 'OB-IN-${List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join()}';
  }

  Future<void> _submit() async {
    _sync();
    final errors = validateSell(_form);
    if (errors.isNotEmpty) {
      setState(() => _tried = true);
      return;
    }
    final form = _form;
    final code = ref
        .read(myListingsProvider.notifier)
        .add(form, _photos.isEmpty ? null : _photos.first, _newCode);
    setState(() {
      _form = SellForm(mode: form.mode);
      _photos.clear();
      _tried = false;
      for (final c in [
        _title,
        _author,
        _price,
        _start,
        _step,
        _buyNow,
        _desc,
      ]) {
        c.clear();
      }
    });
    await _showDone(form, code);
  }

  Future<void> _showDone(SellForm form, String? code) {
    final router = GoRouter.of(context);
    return showAppSheet<void>(
      context,
      builder: (sheet) {
        final l = context.l10n;
        final colors = context.colors;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 26,
                backgroundColor: colors.warningContainer,
                child: Icon(Icons.check, color: colors.warning, size: 26),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSheetTitle(
              form.isAuction ? l.sellDoneAuctionTitle : l.sellDoneSaleTitle,
              center: true,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              form.isAuction
                  ? l.sellDoneAuctionBody
                  : l.sellDoneSaleBody(form.title.trim()),
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.55,
              ),
            ),
            if (code != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                color: colors.background,
                child: Column(
                  children: [
                    Text(
                      l.sellDoneCode,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      code,
                      style: TextStyle(
                        fontFamily: AppTypography.monoFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.3,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.sellDoneWarehouse,
                      textAlign: TextAlign.center,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l.sellDoneView,
              onPressed: () {
                Navigator.of(sheet).pop();
                router.push('/me/listings');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final f = _form;
    final errors = validateSell(f);
    final now = ref.watch(clockProvider)();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen + 4,
            AppSpacing.xs,
            AppSpacing.screen + 4,
            AppSpacing.xl,
          ),
          children: [
            Text(
              l.sellTitle,
              style: context.text.headlineMedium?.copyWith(
                fontSize: 30,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ModeToggle(
              mode: f.mode,
              onChanged: (m) => _update((x) => x.copyWith(mode: m)),
            ),
            if (f.isAuction) ...[
              const SizedBox(height: AppSpacing.md),
              AppCard(
                color: colors.warningContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Text(
                  l.sellAuctionNote,
                  style: context.text.labelSmall?.copyWith(
                    color: colors.onWarningContainer,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _PhotoGrid(
              photos: _photos,
              onAdd: _addPhoto,
              onRemove: _removePhoto,
            ),
            _Field(
              label: l.sellFieldTitle,
              controller: _title,
              hint: l.sellFieldTitleHint,
              onChanged: (_) => _sync(),
            ),
            _Field(
              label: l.sellFieldAuthor,
              controller: _author,
              hint: l.sellFieldAuthorHint,
              onChanged: (_) => _sync(),
            ),
            _Label(l.sellFieldCategory),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final k in sellCategoryKeys)
                  ChoiceChip(
                    label: Text(sellCategoryLabel(l, k)),
                    selected: f.categoryKey == k,
                    onSelected: (_) =>
                        _update((x) => x.copyWith(categoryKey: k)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Label(l.sellFieldCondition),
            Row(
              children: [
                for (final c in SellCondition.values)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _ConditionTile(
                        label: sellConditionLabel(l, c),
                        code: c.code,
                        selected: f.condition == c,
                        onTap: () => _update((x) => x.copyWith(condition: c)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (!f.isAuction)
              _Field(
                label: l.sellFieldPrice,
                controller: _price,
                hint: l.sellFieldPriceHint,
                numeric: true,
                onChanged: (_) => _sync(),
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Field(
                      label: l.sellFieldStart,
                      controller: _start,
                      hint: l.sellFieldStartHint,
                      numeric: true,
                      onChanged: (_) => _sync(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      label: l.sellFieldStep,
                      controller: _step,
                      hint: f.startingPrice >= minStartingPrice
                          ? '${formatVnd(stepRange(f.startingPrice).lo, locale)} – ${formatVnd(stepRange(f.startingPrice).hi, locale)}'
                          : l.sellStepHintEmpty,
                      numeric: true,
                      onChanged: (_) => _sync(),
                    ),
                  ),
                ],
              ),
              _Field(
                label: '${l.sellFieldBuyNow} ${l.sellFieldBuyNowOptional}',
                controller: _buyNow,
                hint: f.startingPrice > 0
                    ? l.sellBuyNowHint(
                        formatVnd(minBuyNow(f.startingPrice), locale),
                      )
                    : l.sellBuyNowHintEmpty,
                numeric: true,
                onChanged: (_) => _sync(),
              ),
              _Label(l.sellDuration),
              _Durations(
                selected: f.durationMinutes,
                onChanged: (m) =>
                    _update((x) => x.copyWith(durationMinutes: m)),
              ),
              const SizedBox(height: 6),
              Text(
                l.sellEarliestStart(
                  formatShortDateTime(earliestAuctionStart(now)),
                ),
                style: context.text.labelSmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _Field(
              label: l.sellFieldDesc,
              controller: _desc,
              hint: l.sellFieldDescHint,
              lines: 3,
              onChanged: (_) => _sync(),
            ),
            _PreviewCard(form: f, locale: locale),
            if (_tried && errors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              for (final e in errors)
                Text(
                  '• ${sellErrorText(l, locale, e, f)}',
                  style: context.text.labelSmall?.copyWith(
                    color: colors.error,
                    height: 1.6,
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: f.isAuction ? l.sellSubmitAuction : l.sellSubmitSale,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: context.text.labelMedium),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.numeric = false,
    this.lines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool numeric;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label),
          TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: lines,
            maxLines: lines,
            keyboardType: numeric
                ? TextInputType.number
                : (lines > 1 ? TextInputType.multiline : TextInputType.text),
            inputFormatters: numeric
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintMaxLines: 1,
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: BorderSide(color: context.colors.divider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final SellMode mode;
  final ValueChanged<SellMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    Widget seg(SellMode m, String label) {
      final selected = mode == m;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          child: Material(
            color: selected ? colors.surface : Colors.transparent,
            elevation: selected ? 1 : 0,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => onChanged(m),
              child: SizedBox(
                height: 44,
                child: Center(
                  child: Text(
                    label,
                    style: context.text.labelMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.smAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            seg(SellMode.fixedPrice, l.sellModeFixed),
            seg(SellMode.auction, l.sellModeAuction),
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<Uint8List> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final slots = (photos.length + 1).clamp(4, maxSellPhotos);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.sellPhotos, style: context.text.labelMedium),
              Text(
                l.sellPhotoCount(photos.length),
                style: context.text.labelSmall?.copyWith(
                  color: photos.length >= minSellPhotos
                      ? colors.success
                      : colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (var i = 0; i < slots; i++)
                if (i < photos.length)
                  Semantics(
                    button: true,
                    label: '${l.sellPhotos} ${i + 1}',
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(photos[i], fit: BoxFit.cover),
                            const Positioned(
                              top: 4,
                              right: 4,
                              child: CircleAvatar(
                                radius: 9,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  _AddSlot(
                    label: i == photos.length ? l.sellPhotoAdd : '',
                    onTap: onAdd,
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddSlot extends StatelessWidget {
  const _AddSlot({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: label.isEmpty ? null : label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border.withValues(alpha: 0.6)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.monoFamily,
                fontSize: 10,
                color: colors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConditionTile extends StatelessWidget {
  const _ConditionTile({
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = selected ? colors.background : colors.textPrimary;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.textPrimary : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smAll,
          side: BorderSide(
            color: selected ? colors.textPrimary : colors.divider,
          ),
        ),
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(
                    color: fg,
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  code,
                  style: TextStyle(
                    fontFamily: AppTypography.monoFamily,
                    fontSize: 9.5,
                    color: fg.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Durations extends StatelessWidget {
  const _Durations({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      (60, l.sellDuration1h),
      (1440, l.sellDuration1d),
      (4320, l.sellDuration3d),
      (10080, l.sellDuration7d),
    ];
    return Row(
      children: [
        for (final (minutes, label) in options)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(label, textAlign: TextAlign.center),
                ),
                selected: selected == minutes,
                onSelected: (_) => onChanged(minutes),
              ),
            ),
          ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.form, required this.locale});

  final SellForm form;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    String money(int v, {bool minus = false}) =>
        v == 0 ? '—' : '${minus ? '−' : ''}${formatVnd(v, locale)}';

    final rows = form.isAuction
        ? [
            (
              l.sellPreviewPlayerFee,
              form.startingPrice == 0
                  ? '—'
                  : formatVnd(
                      auctionRegistrationFee(form.startingPrice),
                      locale,
                    ),
              false,
            ),
            (
              l.sellPreviewPlayerDeposit,
              money(form.startingPrice ~/ 10),
              false,
            ),
            (
              l.sellPreviewCommission,
              money(auctionCommission(form.startingPrice), minus: true),
              false,
            ),
            (
              l.sellPreviewReceiveAtStart,
              form.startingPrice == 0
                  ? '—'
                  : formatVnd(
                      form.startingPrice -
                          auctionCommission(form.startingPrice),
                      locale,
                    ),
              true,
            ),
          ]
        : [
            (l.sellPreviewPrice, money(form.price), false),
            (
              l.sellPreviewFee,
              money(sellerFee(form.price), minus: true),
              false,
            ),
            (
              l.sellPreviewReceive,
              form.price == 0
                  ? '—'
                  : formatVnd(form.price - sellerFee(form.price), locale),
              true,
            ),
            (
              l.sellPreviewShip,
              formatVnd(shippingFeeFixedPrice, locale),
              false,
            ),
          ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.sellPreviewTitle.toUpperCase(),
            style: AppTypography.overline.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 9),
          for (final (label, value, bold) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    style: context.text.bodySmall?.copyWith(
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
