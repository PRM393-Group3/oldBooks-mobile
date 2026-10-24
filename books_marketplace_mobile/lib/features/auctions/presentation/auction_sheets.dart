import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/util/server_clock.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../wallet/application/wallet_providers.dart';
import '../domain/auction.dart';

/// Dòng nhãn và số tiền trong các sheet xác nhận.
class SheetMoneyRow extends StatelessWidget {
  const SheetMoneyRow(
    this.label,
    this.value, {
    super.key,
    this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: bold ? null : colors.textSecondary,
              fontWeight: bold ? FontWeight.w700 : null,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: context.text.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes(this.lines);

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.smAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final t in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  t,
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Số dư khả dụng hiện tại, tô xanh/đỏ theo việc có đủ [needed] không.
class _BalanceRow extends ConsumerWidget {
  const _BalanceRow({required this.needed});

  final int needed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final balance = ref.watch(walletProvider).value?.available;
    if (balance == null) return const SizedBox.shrink();
    return SheetMoneyRow(
      l.regBalance,
      formatVnd(balance, locale),
      color: balance >= needed ? colors.success : colors.error,
    );
  }
}

/// Đăng ký tham gia: ghi rõ phí + cọc bị giữ và điều kiện hoàn. Trả `true`
/// khi người dùng xác nhận.
Future<bool> confirmRegister(BuildContext context, Auction auction) async {
  final ok = await showAppSheet<bool>(
    context,
    builder: (sheet) {
      final l = context.l10n;
      final colors = context.colors;
      final locale = Localizations.localeOf(context).toString();
      final closes = auction.registrationClosesAt;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(l.regSheetTitle),
          const SizedBox(height: 4),
          Text(
            auction.title,
            style: context.text.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SheetMoneyRow(l.regFee, formatVnd(auction.participationFee, locale)),
          const SizedBox(height: 10),
          SheetMoneyRow(l.regDeposit, formatVnd(auction.deposit, locale)),
          const Divider(height: 24),
          SheetMoneyRow(
            l.regHold,
            formatVnd(auction.registrationHold, locale),
            bold: true,
          ),
          const SizedBox(height: 10),
          _BalanceRow(needed: auction.registrationHold),
          const SizedBox(height: AppSpacing.sm),
          _Notes([
            l.regNote1,
            l.regNote2,
            if (closes != null) l.regNote3(formatShortDateTime(closes)),
          ]),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l.regConfirm(formatVnd(auction.registrationHold, locale)),
            onPressed: () => Navigator.of(sheet).pop(true),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}

/// Xác nhận một lượt trả giá: nêu số tiền sẽ bị tạm giữ.
Future<bool> confirmBid(BuildContext context, Auction auction, int amount) {
  final l = context.l10n;
  final locale = Localizations.localeOf(context).toString();
  final price = formatVnd(amount, locale);
  return _confirmMoneySheet(
    context,
    title: l.bidConfirmTitle(price),
    hold: amount,
    notes: [l.bidConfirmHold(price), l.bidConfirmOutbid, l.aucSubLive],
    confirmLabel: l.aucBid,
  );
}

/// Xác nhận mua ngay.
Future<bool> confirmBuyNow(BuildContext context, Auction auction) {
  final l = context.l10n;
  final locale = Localizations.localeOf(context).toString();
  final price = formatVnd(auction.buyNowPrice ?? 0, locale);
  return _confirmMoneySheet(
    context,
    title: l.buyNowTitle(price),
    hold: auction.buyNowPrice ?? 0,
    notes: [l.buyNowNote1(price), l.buyNowNote2, l.buyNowNote3],
    confirmLabel: l.buyNowConfirm,
  );
}

Future<bool> _confirmMoneySheet(
  BuildContext context, {
  required String title,
  required int hold,
  required List<String> notes,
  required String confirmLabel,
}) async {
  final ok = await showAppSheet<bool>(
    context,
    builder: (sheet) {
      final l = context.l10n;
      final colors = context.colors;
      final locale = Localizations.localeOf(context).toString();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(title),
          const SizedBox(height: AppSpacing.sm),
          SheetMoneyRow(l.aucWillHold, formatVnd(hold, locale), bold: true),
          const SizedBox(height: 10),
          _BalanceRow(needed: hold),
          const SizedBox(height: AppSpacing.sm),
          _Notes(notes),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.auction,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            ),
            onPressed: () => Navigator.of(sheet).pop(true),
            child: Text(confirmLabel),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: l.sheetLater,
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(sheet).pop(false),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}

/// Kết quả người bán chọn ở [pickFallback].
typedef FallbackPick = ({FallbackChoice choice, DateTime? startAt, int? price});

/// Người bán chọn phương án khi không đủ người hoặc không có lượt.
Future<FallbackPick?> pickFallback(BuildContext context, Auction auction) {
  return showAppSheet<FallbackPick>(
    context,
    builder: (_) => _FallbackSheet(auction: auction),
  );
}

class _FallbackSheet extends StatefulWidget {
  const _FallbackSheet({required this.auction});

  final Auction auction;

  @override
  State<_FallbackSheet> createState() => _FallbackSheetState();
}

class _FallbackSheetState extends State<_FallbackSheet> {
  late FallbackChoice _choice = widget.auction.owner!.rescheduleRemaining > 0
      ? FallbackChoice.reschedule
      : FallbackChoice.convertToSale;
  DateTime? _startAt;
  final _price = TextEditingController();
  bool _tried = false;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  /// Giờ sớm nhất gợi ý khi dời lịch: mở đăng ký tối thiểu 3 ngày + đóng trước
  /// 24 giờ (server kiểm tra lại, sai thì trả `AUCTION_START_TOO_SOON`).
  DateTime get _earliest =>
      ServerClock.now().add(const Duration(days: 4, hours: 1));

  Future<void> _pickDate() async {
    final first = _earliest.toLocal();
    final date = await showDatePicker(
      context: context,
      initialDate: _startAt?.toLocal() ?? first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _startAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ).toUtc();
    });
  }

  void _submit() {
    final price = int.tryParse(_price.text);
    final valid = switch (_choice) {
      FallbackChoice.reschedule => _startAt != null,
      FallbackChoice.convertToSale => price != null && price >= 1000,
      FallbackChoice.returnBook => true,
    };
    if (!valid) {
      setState(() => _tried = true);
      return;
    }
    Navigator.of(context).pop((
      choice: _choice,
      startAt: _choice == FallbackChoice.reschedule ? _startAt : null,
      price: _choice == FallbackChoice.convertToSale ? price : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final owner = widget.auction.owner!;
    final options = [
      if (owner.rescheduleRemaining > 0)
        (
          FallbackChoice.reschedule,
          l.fbReschedule,
          l.fbRescheduleSub(owner.rescheduleRemaining),
        ),
      (FallbackChoice.convertToSale, l.fbConvert, l.fbConvertSub),
      (FallbackChoice.returnBook, l.fbReturn, l.fbReturnSub),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(l.fbTitle),
        const SizedBox(height: AppSpacing.xs),
        RadioGroup<FallbackChoice>(
          groupValue: _choice,
          onChanged: (v) => setState(() => _choice = v ?? _choice),
          child: Column(
            children: [
              for (final (value, title, sub) in options)
                RadioListTile<FallbackChoice>(
                  value: value,
                  contentPadding: EdgeInsets.zero,
                  title: Text(title),
                  subtitle: Text(sub),
                ),
            ],
          ),
        ),
        if (_choice == FallbackChoice.reschedule) ...[
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event_outlined),
            label: Text(
              _startAt == null
                  ? l.fbPickStart
                  : formatDateTime(_startAt!, locale),
            ),
          ),
          if (_tried && _startAt == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l.fbPickStart,
                style: context.text.labelSmall?.copyWith(color: colors.error),
              ),
            ),
        ],
        if (_choice == FallbackChoice.convertToSale)
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l.fbPrice,
              errorText: _tried && (int.tryParse(_price.text) ?? 0) < 1000
                  ? l.fbPriceInvalid
                  : null,
            ),
          ),
        if (_choice == FallbackChoice.returnBook)
          Text(
            l.fbReturnNote,
            style: context.text.labelSmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        AppButton(label: l.fbConfirm, onPressed: _submit),
      ],
    );
  }
}
