import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../../../core/util/image_picking.dart';
import '../../../core/util/photo_picker.dart';
import '../../../core/util/server_clock.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../categories/application/category_providers.dart';
import '../../listings/application/listing_providers.dart';
import '../../listings/data/listing_repository.dart';
import '../../listings/domain/listing.dart';
import '../../listings/domain/listing_enums.dart';
import '../../listings/domain/listing_query.dart';
import '../../auctions/application/auction_providers.dart';
import '../../auctions/domain/auction.dart';
import '../application/listing_publisher.dart';
import '../application/my_listings_provider.dart';
import '../application/sell_rules_provider.dart';
import '../domain/sell_rules.dart';
import 'sell_text.dart';

/// Tab Đăng bán: một biểu mẫu cho bán giá cố định và đấu giá, kèm ô "Dự tính".
///
/// Bán giá cố định đi qua backend thật (tạo tin, tải ảnh, đặt danh sách ảnh,
/// gửi duyệt). Truyền [editing] để sửa một tin đã có (nháp, cần sửa, đã gỡ hoặc
/// đang bán). Đấu giá: tải từng ảnh lên kho công khai rồi `POST /auctions`,
/// server trả mã nhập kho.
class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key, this.editing});

  final Listing? editing;

  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  SellForm _form = const SellForm();
  final List<PhotoSlot> _photos = [];
  bool _tried = false;

  /// Giờ bắt đầu mong muốn của phiên (UTC); `null` là giờ sớm nhất cho phép.
  DateTime? _auctionStart;

  /// Đang gọi backend; chặn bấm lặp.
  bool _busy = false;
  String? _stageText;

  /// Giữ tiến trình để lỗi giữa chừng chạy lại không tạo tin trùng/tải lại ảnh.
  late PublishProgress _progress = PublishProgress(
    listingId: widget.editing?.id,
  );

  final _title = TextEditingController();
  final _author = TextEditingController();
  final _price = TextEditingController();
  final _start = TextEditingController();
  final _step = TextEditingController();
  final _buyNow = TextEditingController();
  final _desc = TextEditingController();
  final _publisher = TextEditingController();
  final _year = TextEditingController();
  final _isbn = TextEditingController();
  final _defects = TextEditingController();

  List<TextEditingController> get _controllers => [
    _title,
    _author,
    _price,
    _start,
    _step,
    _buyNow,
    _desc,
    _publisher,
    _year,
    _isbn,
    _defects,
  ];

  bool get _editing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e == null) return;
    final b = e.bookInfo;
    _title.text = b.title ?? '';
    _author.text = b.author ?? '';
    _price.text = '${e.price ?? ''}';
    _desc.text = b.description ?? '';
    _publisher.text = b.publisher ?? '';
    _year.text = b.publicationYear?.toString() ?? '';
    _isbn.text = b.isbn ?? '';
    _defects.text = b.defectNotes ?? '';
    for (final p in e.images) {
      final name = p.blobName;
      if (name != null) {
        _photos.add(
          PhotoSlot.existing(
            blobName: name,
            previewUrl: p.thumbnailUrl ?? p.url,
          ),
        );
      }
    }
    _form = SellForm(
      photos: _photos.length,
      title: _title.text,
      author: _author.text,
      categoryId: e.category?.id,
      condition: SellCondition.values.firstWhere(
        (c) => c.condition == b.condition,
        orElse: () => SellCondition.good,
      ),
      price: e.price ?? 0,
      description: _desc.text,
      publisher: _publisher.text,
      publishYear: _year.text,
      isbn: _isbn.text,
      defectNotes: _defects.text,
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
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
      publisher: _publisher.text,
      publishYear: _year.text,
      isbn: _isbn.text,
      defectNotes: _defects.text,
    ),
  );

  Future<void> _addPhoto() async {
    if (_busy) return;
    if (_photos.length >= maxSellPhotos) {
      AppSnackbar.show(
        context,
        context.l10n.sellPhotoLimit(maxSellPhotos),
        type: AppSnackbarType.error,
      );
      return;
    }
    try {
      final image = await ref.read(photoPickerProvider)();
      if (image != null && mounted) {
        _photos.add(
          PhotoSlot.fresh(
            NewPhoto(
              bytes: image.bytes,
              fileName: 'photo-${_photos.length + 1}.${image.extension}',
              contentType: image.contentType,
            ),
          ),
        );
        _photosChanged = true;
        _progress.photosSaved = false;
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

  /// Đã thêm/xóa/đổi thứ tự ảnh so với lúc mở (để biết có cần `PUT /photos`).
  bool _photosChanged = false;

  void _removePhoto(int i) {
    _photos.removeAt(i);
    _photosChanged = true;
    _progress.photosSaved = false;
    _sync();
  }

  void _makeCover(int i) {
    _photos.insert(0, _photos.removeAt(i));
    _photosChanged = true;
    _progress.photosSaved = false;
    _sync();
  }

  Future<void> _photoActions(int i) async {
    final l = context.l10n;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (i != 0)
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: Text(l.photoMakeCover),
                onTap: () => Navigator.of(sheet).pop('cover'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l.removeAvatar),
              onTap: () => Navigator.of(sheet).pop('remove'),
            ),
          ],
        ),
      ),
    );
    if (action == 'cover') _makeCover(i);
    if (action == 'remove') _removePhoto(i);
  }

  /// Trường gửi lên server. Khi sửa, trường tùy chọn để trống gửi `""` để xóa
  /// giá trị cũ; khi tạo thì không gửi.
  ListingDraftInput _input(SellForm f) {
    String? opt(String v) {
      final t = v.trim();
      return t.isEmpty ? (_editing ? '' : null) : t;
    }

    return ListingDraftInput(
      title: f.title,
      author: f.author,
      categoryId: f.categoryId,
      condition: f.condition.condition,
      price: f.price,
      description: f.description,
      publisher: opt(f.publisher),
      publishYear: int.tryParse(f.publishYear.trim()),
      isbn: opt(f.isbn),
      defectNotes: opt(f.defectNotes),
    );
  }

  /// Sửa tin ĐANG BÁN: chỉ giá và mô tả có hiệu lực ngay, đổi phần khác hoặc
  /// ảnh đưa tin về chờ duyệt. Dùng để cảnh báo trước khi lưu.
  bool _needsReReview(SellForm f) {
    final e = widget.editing;
    if (e == null || e.status != ListingStatus.published) return false;
    final b = e.bookInfo;
    String t(String? v) => (v ?? '').trim();
    return _photosChanged ||
        t(b.title) != f.title.trim() ||
        t(b.author) != f.author.trim() ||
        e.category?.id != f.categoryId ||
        b.condition != f.condition.condition ||
        t(b.publisher) != f.publisher.trim() ||
        (b.publicationYear?.toString() ?? '') != f.publishYear.trim() ||
        t(b.isbn) != f.isbn.trim() ||
        t(b.defectNotes) != f.defectNotes.trim();
  }

  Future<void> _submit() async {
    if (_busy) return;
    _sync();
    final rules = ref.read(sellRulesProvider);
    final errors = validateSell(_form, rules: rules);
    if (errors.isNotEmpty) {
      setState(() => _tried = true);
      return;
    }
    final form = _form;
    if (form.isAuction) return _submitAuction(form);
    await _submitFixed(form);
  }

  /// Giờ bắt đầu gửi lên server: giờ người dùng chọn, không sớm hơn mốc tối
  /// thiểu của app. Server kiểm tra lại theo cấu hình.
  DateTime _startFor(DateTime now) {
    final earliest = earliestAuctionStart(now);
    final chosen = _auctionStart;
    return chosen == null || chosen.isBefore(earliest) ? earliest : chosen;
  }

  Future<void> _pickAuctionStart() async {
    final now = ServerClock.now();
    final initial = _startFor(now).toLocal();
    final first = earliestAuctionStart(now).toLocal();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: first.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    setState(() {
      _auctionStart = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ).toUtc();
    });
  }

  Future<void> _submitAuction(SellForm form) async {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(auctionRepositoryProvider);
    setState(() => _busy = true);
    try {
      // Ảnh đã tải giữ `blobName` nên bấm lại sau lỗi không tải lại.
      final pending = [
        for (final p in _photos)
          if (!p.isUploaded) p,
      ];
      var done = 0;
      for (final slot in pending) {
        setState(() => _stageText = l.sellProgressUpload(done, pending.length));
        slot.blobName = await repo.uploadPhoto(slot.photo!);
        done++;
      }
      setState(() => _stageText = l.sellProgressCreate);
      String? opt(String v) => v.trim().isEmpty ? null : v.trim();
      final auction = await repo.create(
        CreateAuctionInput(
          title: form.title,
          author: form.author,
          categoryId: form.categoryId!,
          condition: form.condition.condition.api,
          description: form.description,
          startPrice: form.startingPrice,
          bidStep: form.step,
          buyNowPrice: form.buyNow > 0 ? form.buyNow : null,
          durationMinutes: form.durationMinutes,
          desiredStartAt: _startFor(ServerClock.now()),
          photos: [for (final p in _photos) p.blobName!],
          publisher: opt(form.publisher),
          publishYear: int.tryParse(form.publishYear.trim()),
          isbn: opt(form.isbn),
          defectNotes: opt(form.defectNotes),
        ),
      );
      refreshAuctionLists(ref);
      if (!mounted) return;
      _resetForm(form.mode);
      setState(() {
        _auctionStart = null;
        _busy = false;
        _stageText = null;
      });
      await _showDone(form, auction.owner?.inboundCode, auctionId: auction.id);
    } on ApiError catch (e) {
      if (!mounted) return;
      if (e.code == ApiErrorCode.auctionStartTooSoon) {
        // `details[0].message` là giờ sớm nhất server cho phép.
        final earliest = e.detailMessages.isEmpty
            ? null
            : DateTime.tryParse(e.detailMessages.first);
        if (earliest != null) {
          setState(() => _auctionStart = earliest.toUtc());
          AppSnackbar.show(
            context,
            l.sellStartTooSoon(formatDateTime(earliest, locale)),
            type: AppSnackbarType.error,
          );
          return;
        }
      }
      AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _stageText = null;
        });
      }
    }
  }

  Future<void> _submitFixed(SellForm form) async {
    final l = context.l10n;
    final existing = widget.editing;

    if (_needsReReview(form)) {
      final ok = await showConfirmDialog(
        context,
        title: l.sellEditWarnTitle,
        message: l.sellEditWarnBody,
        confirmLabel: l.sellEditWarnConfirm,
      );
      if (!ok || !mounted) return;
    }

    // Tin đang bán: lưu thẳng, không gửi duyệt lại (server tự đưa về chờ duyệt
    // nếu đổi phần chính). Tin khác: gửi duyệt sau khi lưu.
    final submit = existing == null || existing.status.canSubmit;
    final photosChanged = existing == null || _photosChanged;

    setState(() {
      _busy = true;
      _stageText = l.sellProgressCreate;
    });
    try {
      final listing =
          await ListingPublisher(ref.read(listingRepositoryProvider)).run(
            progress: _progress,
            input: _input(form),
            photos: _photos,
            submit: submit,
            photosChanged: photosChanged,
            onStage: (stage, done, total) {
              if (!mounted) return;
              setState(() {
                _stageText = switch (stage) {
                  PublishStage.creating => l.sellProgressCreate,
                  PublishStage.uploading => l.sellProgressUpload(done, total),
                  PublishStage.submitting => l.sellProgressSubmit,
                };
              });
            },
          );
      refreshMyListings(ref);
      ref.invalidate(listingDetailProvider(listing.id));
      if (!mounted) return;
      if (_editing) {
        AppSnackbar.success(context, submit ? l.mlSubmitted : l.sellSaved);
        context.pop();
      } else {
        _resetForm(form.mode);
        // Tắt trạng thái bận trước khi mở sheet (sheet chờ người dùng đóng).
        setState(() {
          _busy = false;
          _stageText = null;
        });
        await _showDone(form, null);
      }
    } on ApiError catch (e) {
      if (!mounted) return;
      // Lỗi trạng thái hoặc sửa đồng thời: tin đã đổi, tải lại để khỏi ghi đè.
      if (e.needsReload || e.code == ApiErrorCode.listingConcurrentUpdate) {
        ref.invalidate(listingDetailProvider(_progress.listingId ?? ''));
      }
      AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _stageText = null;
        });
      }
    }
  }

  void _resetForm(SellMode mode) {
    setState(() {
      _form = SellForm(mode: mode);
      _photos.clear();
      _photosChanged = false;
      _progress = PublishProgress();
      _tried = false;
      for (final c in _controllers) {
        c.clear();
      }
    });
  }

  Future<void> _showDone(SellForm form, String? code, {String? auctionId}) {
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
              label: auctionId != null ? l.sellDoneViewAuction : l.sellDoneView,
              onPressed: () {
                Navigator.of(sheet).pop();
                router.push(
                  auctionId != null ? '/auctions/$auctionId' : '/me/listings',
                );
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
    final rules = ref.watch(sellRulesProvider);
    final errors = validateSell(f, rules: rules);
    final now = ref.watch(clockProvider)();

    final categories = ref.watch(categoryTreeProvider).value ?? const [];
    final existingStatus = widget.editing?.status;

    return Scaffold(
      appBar: _editing ? AppBar(title: Text(l.sellEditTitle)) : null,
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
            if (!_editing) ...[
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
            ],
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
              minPhotos: rules.minPhotos,
              onAdd: _addPhoto,
              onTapPhoto: _photoActions,
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
                for (final c in categories)
                  ChoiceChip(
                    label: Text(c.name),
                    selected: f.categoryId == c.id,
                    onSelected: (_) =>
                        _update((x) => x.copyWith(categoryId: () => c.id)),
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
                          ? '${formatVnd(rules.stepRange(f.startingPrice).lo, locale)} – ${formatVnd(rules.stepRange(f.startingPrice).hi, locale)}'
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
                        formatVnd(rules.minBuyNow(f.startingPrice), locale),
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
              const SizedBox(height: AppSpacing.sm),
              _Label(l.sellStartAt),
              OutlinedButton.icon(
                onPressed: _busy ? null : _pickAuctionStart,
                icon: const Icon(Icons.event_outlined),
                label: Text(formatDateTime(_startFor(now), locale)),
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
            ...[
              _Field(
                label: l.sellFieldPublisher,
                controller: _publisher,
                hint: '',
                onChanged: (_) => _sync(),
              ),
              _Field(
                label: l.sellFieldYear,
                controller: _year,
                hint: '',
                numeric: true,
                onChanged: (_) => _sync(),
              ),
              _Field(
                label: l.sellFieldIsbn,
                controller: _isbn,
                hint: '978-0-671-02703-2',
                onChanged: (_) => _sync(),
              ),
              _Field(
                label: l.sellFieldDefects,
                controller: _defects,
                hint: '',
                lines: 2,
                onChanged: (_) => _sync(),
              ),
            ],
            _PreviewCard(form: f, locale: locale, rules: rules),
            if (_tried && errors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              for (final e in errors)
                Text(
                  '• ${sellErrorText(l, locale, e, f, rules: rules)}',
                  style: context.text.labelSmall?.copyWith(
                    color: colors.error,
                    height: 1.6,
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (_stageText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  _stageText!,
                  textAlign: TextAlign.center,
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
            AppButton(
              label: f.isAuction
                  ? l.sellSubmitAuction
                  : _editing
                  ? (existingStatus != null && existingStatus.canSubmit
                        ? l.sellEditSaveSubmit
                        : l.sellEditSave)
                  : l.sellSubmitSale,
              loading: _busy,
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
    required this.minPhotos,
    required this.onAdd,
    required this.onTapPhoto,
  });

  final List<PhotoSlot> photos;
  final int minPhotos;
  final VoidCallback onAdd;
  final ValueChanged<int> onTapPhoto;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final slots = (photos.length + 1).clamp(minPhotos, maxSellPhotos);

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
                  color: photos.length >= minPhotos
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
                      onTap: () => onTapPhoto(i),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            photos[i].photo != null
                                ? Image.memory(
                                    photos[i].photo!.bytes,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    photos[i].previewUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.image_outlined),
                                  ),
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
      (5, l.sellDuration5m),
      (15, l.sellDuration15m),
      (60, l.sellDuration1h),
      (1440, l.sellDuration1d),
      (4320, l.sellDuration3d),
      (10080, l.sellDuration7d),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (minutes, label) in options)
          ChoiceChip(
            label: Text(label),
            selected: selected == minutes,
            onSelected: (_) => onChanged(minutes),
          ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.form,
    required this.locale,
    required this.rules,
  });

  final SellForm form;
  final String locale;
  final SellRules rules;

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
                      rules.participationFee(form.startingPrice),
                      locale,
                    ),
              false,
            ),
            (
              l.sellPreviewPlayerDeposit,
              money(rules.deposit(form.startingPrice)),
              false,
            ),
            (
              l.sellPreviewCommission,
              money(rules.auctionCommission(form.startingPrice), minus: true),
              false,
            ),
            (
              l.sellPreviewReceiveAtStart,
              form.startingPrice == 0
                  ? '—'
                  : formatVnd(
                      form.startingPrice -
                          rules.auctionCommission(form.startingPrice),
                      locale,
                    ),
              true,
            ),
          ]
        : [
            (l.sellPreviewPrice, money(form.price), false),
            (
              l.sellPreviewFee,
              money(rules.sellerFee(form.price), minus: true),
              false,
            ),
            (
              l.sellPreviewReceive,
              form.price == 0
                  ? '—'
                  : formatVnd(form.price - rules.sellerFee(form.price), locale),
              true,
            ),
            (l.sellPreviewShip, formatVnd(rules.shippingSale, locale), false),
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
