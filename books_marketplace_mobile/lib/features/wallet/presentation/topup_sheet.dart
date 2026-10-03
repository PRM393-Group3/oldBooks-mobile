import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/api_error_l10n.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/util/idempotency.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../notifications/application/notification_providers.dart';
import '../application/wallet_limits.dart';
import '../application/wallet_providers.dart';
import '../domain/wallet_models.dart';

/// Nạp tiền thật: tạo yêu cầu, mở trang thanh toán của cổng, rồi poll trạng thái
/// tới khi có kết quả. Số dư cập nhật khi `PAID`.
Future<void> showWalletTopupSheet(BuildContext context, {int? initialAmount}) {
  return showAppSheet<void>(
    context,
    builder: (_) => _TopupFlow(initialAmount: initialAmount),
  );
}

enum _Step { amount, waiting }

class _TopupFlow extends ConsumerStatefulWidget {
  const _TopupFlow({this.initialAmount});

  final int? initialAmount;

  @override
  ConsumerState<_TopupFlow> createState() => _TopupFlowState();
}

class _TopupFlowState extends ConsumerState<_TopupFlow>
    with WidgetsBindingObserver {
  /// Poll mỗi 2 giây, tối đa khoảng 1 phút; quá thời gian vẫn `PENDING` thì báo
  /// "đang xác nhận" (IPN của cổng có thể đến trễ, tiền vẫn được cộng).
  static const _pollEvery = Duration(seconds: 2);
  static const _pollFor = Duration(minutes: 1);

  final _controller = TextEditingController();
  _Step _step = _Step.amount;
  Topup? _topup;
  bool _busy = false;
  String? _amountError;

  /// Một key cho mỗi lần bấm "Nạp": giữ nguyên khi gửi lại do mạng lỗi, chỉ đổi
  /// khi số tiền đổi hoặc yêu cầu đã tạo xong.
  String? _key;
  int? _keyAmount;
  Timer? _timer;
  DateTime? _pollStart;
  bool _gaveUp = false;
  String? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final initial = widget.initialAmount;
    if (initial != null) _controller.text = '$initial';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _step == _Step.waiting) {
      _check();
    }
  }

  int get _amount => int.tryParse(_controller.text) ?? 0;

  Future<void> _create() async {
    if (_busy) return;
    final l = context.l10n;
    final limits = ref.read(walletLimitsProvider);
    final locale = Localizations.localeOf(context).toString();
    final amount = _amount;
    if (amount < limits.topupMin || amount > limits.topupMax) {
      setState(() {
        _amountError = l.topupAmountOut(
          formatVnd(limits.topupMin, locale),
          formatVnd(limits.topupMax, locale),
        );
      });
      return;
    }
    if (_keyAmount != amount) {
      _key = null;
      _keyAmount = amount;
    }
    final key = _key ??= newIdempotencyKey();
    setState(() {
      _busy = true;
      _amountError = null;
    });
    try {
      final topup = await ref
          .read(walletRepositoryProvider)
          .createTopup(
            amount: amount,
            idempotencyKey: key,
            provider: _provider,
          );
      _key = null;
      if (!mounted) return;
      setState(() {
        _topup = topup;
        _step = _Step.waiting;
      });
      _startPolling();
      unawaited(_openPayPage());
    } on ApiError catch (e) {
      if (!mounted) return;
      if (e.code == ApiErrorCode.topupOutOfRange ||
          e.fieldErrors.containsKey('amount')) {
        setState(() => _amountError = e.localized(l));
      } else if (e.code == ApiErrorCode.paymentProviderUnknown ||
          e.code == ApiErrorCode.paymentGatewayUnavailable) {
        // Cổng vừa bị tắt hoặc đổi: tải lại danh sách cổng rồi cho chọn lại.
        _provider = null;
        ref.invalidate(paymentMethodsProvider);
        AppSnackbar.apiError(context, e);
      } else {
        AppSnackbar.apiError(context, e);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _pollStart = DateTime.now();
    _gaveUp = false;
    _timer = Timer.periodic(_pollEvery, (_) => _check(silent: true));
  }

  Future<void> _openPayPage() async {
    final url = _topup?.payUrl;
    if (url == null) return;
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!opened && mounted) {
      AppSnackbar.show(
        context,
        context.l10n.topupCannotOpen,
        type: AppSnackbarType.error,
      );
    }
  }

  /// Hỏi lại trạng thái yêu cầu; `PENDING` thì chờ tiếp tới `expiresAt`.
  Future<void> _check({bool silent = false}) async {
    final current = _topup;
    if (current == null || _busy) return;
    try {
      final fresh = await ref.read(walletRepositoryProvider).topup(current.id);
      if (!mounted) return;
      setState(() => _topup = fresh);
      if (fresh.status == TopupStatus.pending) {
        final start = _pollStart;
        if (start != null && DateTime.now().difference(start) > _pollFor) {
          _timer?.cancel();
          if (mounted) setState(() => _gaveUp = true);
        }
        return;
      }
      _timer?.cancel();
      if (fresh.status == TopupStatus.paid) _onPaid();
    } on ApiError catch (e) {
      if (!silent && mounted) AppSnackbar.apiError(context, e);
    }
  }

  void _onPaid() {
    ref.read(walletProvider.notifier).refresh();
    ref.invalidate(walletTransactionsProvider);
    ref.invalidate(topupsProvider);
    ref.invalidate(unreadCountProvider);
  }

  Future<void> _devPay() async {
    final id = _topup?.id;
    if (id == null) return;
    try {
      await ref.read(walletRepositoryProvider).devPayTopup(id, success: true);
      await _check();
    } on ApiError catch (e) {
      if (mounted) AppSnackbar.apiError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) =>
      _step == _Step.amount ? _amountStep(context) : _waitingStep(context);

  Widget _amountStep(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final limits = ref.watch(walletLimitsProvider);
    final methods = ref.watch(paymentMethodsProvider);
    final choices = [
      for (final v in const [100000, 200000, 500000, 1000000])
        if (v >= limits.topupMin && v <= limits.topupMax) v,
    ];

    // Mảng rỗng: admin chưa bật cổng nào, chưa nạp được.
    final noGateway = methods.value?.isEmpty ?? false;
    final gateways = methods.value ?? const <PaymentMethod>[];
    if (_provider == null && gateways.isNotEmpty) {
      _provider =
          (gateways.where((g) => g.isDefault).firstOrNull ?? gateways.first)
              .provider;
    }

    if (noGateway) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(l.topupSheetTitle),
          const SizedBox(height: AppSpacing.md),
          Text(l.topupNoGateway, style: context.text.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l.sheetClose,
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(l.topupSheetTitle),
        const SizedBox(height: AppSpacing.md),
        if (gateways.length > 1) ...[
          Text(l.topupPickGateway, style: context.text.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final g in gateways)
                ChoiceChip(
                  label: Text(g.displayName),
                  selected: _provider == g.provider,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() => _provider = g.provider),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final v in choices)
              ChoiceChip(
                label: Text(formatVnd(v, locale)),
                selected: _amount == v,
                onSelected: _busy
                    ? null
                    : (_) => setState(() {
                        _controller.text = '$v';
                        _amountError = null;
                      }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          enabled: !_busy,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() => _amountError = null),
          decoration: InputDecoration(
            labelText: l.topupAmountLabel,
            helperText: l.topupAmountRange(
              formatVnd(limits.topupMin, locale),
              formatVnd(limits.topupMax, locale),
            ),
            errorText: _amountError,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l.topupSheetNote,
          style: context.text.labelSmall?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(label: l.topupCreate, loading: _busy, onPressed: _create),
      ],
    );
  }

  Widget _waitingStep(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final topup = _topup!;
    final expires = topup.expiresAt;

    final (String message, bool canRetry) = switch (topup.status) {
      TopupStatus.paid => (l.topupPaid(formatVnd(topup.amount, locale)), false),
      TopupStatus.expired => (l.topupExpired, true),
      TopupStatus.failed => (l.topupFailed, false),
      _ => (_gaveUp ? l.topupConfirming : l.topupWaiting, true),
    };
    final pending = topup.status == TopupStatus.pending && !_gaveUp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(formatVnd(topup.amount, locale)),
        const SizedBox(height: AppSpacing.md),
        if (pending) const Center(child: CircularProgressIndicator()),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.text.titleMedium?.copyWith(
            color: topup.status == TopupStatus.paid
                ? colors.success
                : topup.status == TopupStatus.failed
                ? colors.error
                : null,
          ),
        ),
        if (pending && expires != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.topupWaitingNote(formatDateTime(expires, locale)),
            textAlign: TextAlign.center,
            style: context.text.labelSmall?.copyWith(color: colors.textMuted),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        if (pending) AppButton(label: l.topupOpenPay, onPressed: _openPayPage),
        if (canRetry) ...[
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: l.topupCheckAgain,
            variant: AppButtonVariant.secondary,
            onPressed: () {
              if (_gaveUp) _startPolling();
              _check();
            },
          ),
        ],
        // Cổng sandbox của backend dev: payUrl không mở được trang thật.
        if (kDebugMode && pending) ...[
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: l.topupDevPay,
            variant: AppButtonVariant.text,
            onPressed: _devPay,
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: l.sheetClose,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Báo thiếu số dư (khi đặt hàng) và gợi ý nạp đúng phần còn thiếu, làm tròn lên
/// bội của 10.000 đ để vừa khoảng nạp tối thiểu.
Future<void> showWalletInsufficientSheet(
  BuildContext context, {
  required int required,
  required int available,
}) {
  final needed = required - available;
  final topup = (needed + 9999) ~/ 10000 * 10000;
  return showAppSheet<void>(
    context,
    builder: (sheet) {
      final l = context.l10n;
      final locale = Localizations.localeOf(context).toString();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetTitle(l.insufficientTitle),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.insufficientBody(
              formatVnd(needed, locale),
              formatVnd(available, locale),
            ),
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l.insufficientTopup(formatVnd(topup, locale)),
            onPressed: () {
              Navigator.of(sheet).pop();
              showWalletTopupSheet(context, initialAmount: topup);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: l.sheetClose,
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(sheet).pop(),
          ),
        ],
      );
    },
  );
}
