import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import '../../../../../core/util/format.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_page.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../domain/listing.dart';
import '../../../domain/listing_enums.dart';
import '../../../domain/listing_input.dart';
import '../../../domain/listing_rules.dart';

/// Bước 3: chọn giá cố định hoặc đấu giá và nhập cấu hình.
class SaleMethodStep extends StatefulWidget {
  const SaleMethodStep({
    super.key,
    required this.listing,
    required this.rules,
    required this.saving,
    required this.errors,
    required this.onSubmit,
    required this.onClearError,
  });

  final Listing listing;
  final ListingRules rules;
  final bool saving;
  final Map<String, String> errors;
  final ValueChanged<SaleMethodInput> onSubmit;
  final ValueChanged<String> onClearError;

  @override
  State<SaleMethodStep> createState() => _SaleMethodStepState();
}

class _SaleMethodStepState extends State<SaleMethodStep> {
  final _formKey = GlobalKey<FormState>();

  late SaleMethod _method = widget.listing.saleMethod ?? SaleMethod.fixedPrice;

  late final _price = TextEditingController(
    text: widget.listing.fixedPrice?.price.toString(),
  );
  late final _quantity = TextEditingController(
    text: (widget.listing.fixedPrice?.quantity ?? 1).toString(),
  );
  late final _starting = TextEditingController(
    text: widget.listing.auction?.startingPrice.toString(),
  );
  late final _increment = TextEditingController(
    text: widget.listing.auction?.minBidIncrement.toString(),
  );

  late int _duration =
      widget.listing.auction?.durationDays ??
      widget.rules.auctionDurations.first;
  late AuctionStartMode _startMode =
      widget.listing.auction?.startMode ?? AuctionStartMode.onApproval;
  late DateTime? _scheduledAt = widget.listing.auction?.scheduledStartAt;

  /// Người dùng đã tự sửa bước giá thì không ghi đè bằng giá trị gợi ý nữa.
  late bool _incrementEdited = widget.listing.auction != null;
  bool _submitted = false;

  @override
  void dispose() {
    _price.dispose();
    _quantity.dispose();
    _starting.dispose();
    _increment.dispose();
    super.dispose();
  }

  String? _err(String key) => widget.errors[key.toLowerCase()];

  void _suggestIncrement() {
    if (_incrementEdited) return;
    final start = int.tryParse(_starting.text);
    _increment.text = start == null
        ? ''
        : widget.rules.minBidIncrementFor(start).toString();
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt?.toLocal() ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt?.toLocal() ?? now),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _next() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    if (_method == SaleMethod.fixedPrice) {
      widget.onSubmit(
        FixedPriceInput(
          price: int.parse(_price.text),
          quantity: int.parse(_quantity.text),
        ),
      );
      return;
    }
    if (_startMode == AuctionStartMode.scheduled &&
        (_scheduledAt == null || !_scheduledAt!.isAfter(DateTime.now()))) {
      return;
    }
    widget.onSubmit(
      AuctionInput(
        startingPrice: int.parse(_starting.text),
        minBidIncrement: int.parse(_increment.text),
        durationDays: _duration,
        startMode: _startMode,
        scheduledStartAt: _startMode == AuctionStartMode.scheduled
            ? _scheduledAt
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final rules = widget.rules;
    final locale = Localizations.localeOf(context).toString();
    final enabled = !widget.saving;
    final digits = [FilteringTextInputFormatter.digitsOnly];

    String? priceCheck(String? v) {
      final n = int.tryParse(v ?? '');
      if (n == null) return l.validationFieldRequired(l.fieldPrice);
      return (n < rules.minPrice || n > rules.maxPrice)
          ? l.validationPriceRange(
              formatVnd(rules.minPrice, locale),
              formatVnd(rules.maxPrice, locale),
            )
          : null;
    }

    final scheduleError = _submitted && _startMode == AuctionStartMode.scheduled
        ? (_scheduledAt == null
              ? l.validationScheduleRequired
              : (!_scheduledAt!.isAfter(DateTime.now())
                    ? l.validationScheduleFuture
                    : null))
        : null;

    final changed =
        widget.listing.saleMethod != null &&
        widget.listing.saleMethod != _method;

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
            Text(l.saleMethodLabel, style: context.text.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<SaleMethod>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: SaleMethod.fixedPrice,
                  label: Text(SaleMethod.fixedPrice.label(l)),
                  icon: const Icon(Icons.sell_outlined),
                ),
                ButtonSegment(
                  value: SaleMethod.auction,
                  label: Text(SaleMethod.auction.label(l)),
                  icon: const Icon(Icons.gavel),
                ),
              ],
              selected: {_method},
              onSelectionChanged: enabled
                  ? (s) => setState(() => _method = s.first)
                  : null,
            ),
            if (changed) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.changeMethodMessage,
                style: context.text.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (_method == SaleMethod.fixedPrice) ...[
              AppTextField(
                label: l.fieldPrice,
                controller: _price,
                enabled: enabled,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                maxLength: 9,
                prefixIcon: Icons.payments_outlined,
                validator: priceCheck,
                errorText: _err('price'),
                onChanged: (_) => widget.onClearError('price'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.fieldQuantity,
                controller: _quantity,
                enabled: enabled,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                maxLength: 2,
                prefixIcon: Icons.numbers,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return (n == null ||
                          n < rules.minQuantity ||
                          n > rules.maxQuantity)
                      ? l.validationQuantityRange(
                          rules.minQuantity,
                          rules.maxQuantity,
                        )
                      : null;
                },
                errorText: _err('quantity'),
              ),
            ] else ...[
              AppTextField(
                label: l.fieldStartingPrice,
                controller: _starting,
                enabled: enabled,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                maxLength: 9,
                prefixIcon: Icons.payments_outlined,
                validator: priceCheck,
                errorText: _err('startingprice'),
                onChanged: (_) {
                  widget.onClearError('startingprice');
                  _suggestIncrement();
                  setState(() {});
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.fieldMinIncrement,
                controller: _increment,
                enabled: enabled,
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                maxLength: 9,
                prefixIcon: Icons.trending_up,
                helperText: int.tryParse(_starting.text) == null
                    ? null
                    : l.minIncrementHelper(
                        formatVnd(
                          rules.minBidIncrementFor(int.parse(_starting.text)),
                          locale,
                        ),
                      ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  final start = int.tryParse(_starting.text);
                  if (n == null) {
                    return l.validationFieldRequired(l.fieldMinIncrement);
                  }
                  if (start == null) return null;
                  final min = rules.minBidIncrementFor(start);
                  return n < min
                      ? l.validationMinIncrement(formatVnd(min, locale))
                      : null;
                },
                errorText: _err('minbidincrement'),
                onChanged: (_) {
                  _incrementEdited = true;
                  widget.onClearError('minbidincrement');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l.fieldDuration, style: context.text.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  for (final d in rules.auctionDurations)
                    ChoiceChip(
                      label: Text(l.durationDays(d)),
                      selected: _duration == d,
                      onSelected: enabled
                          ? (_) => setState(() => _duration = d)
                          : null,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l.fieldStartMode, style: context.text.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  for (final m in AuctionStartMode.values)
                    ChoiceChip(
                      label: Text(m.label(l)),
                      selected: _startMode == m,
                      onSelected: enabled
                          ? (_) => setState(() => _startMode = m)
                          : null,
                    ),
                ],
              ),
              if (_startMode == AuctionStartMode.scheduled) ...[
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  onTap: enabled ? _pickSchedule : null,
                  borderRadius: AppRadius.mdAll,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l.fieldScheduledAt,
                      errorText: scheduleError ?? _err('scheduledstartat'),
                      prefixIcon: Icon(
                        Icons.event_outlined,
                        color: colors.textSecondary,
                      ),
                    ),
                    child: Text(
                      _scheduledAt == null
                          ? l.pickDateTime
                          : formatDateTime(_scheduledAt!.toUtc(), locale),
                      style: context.text.bodyMedium?.copyWith(
                        color: _scheduledAt == null
                            ? colors.textMuted
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
