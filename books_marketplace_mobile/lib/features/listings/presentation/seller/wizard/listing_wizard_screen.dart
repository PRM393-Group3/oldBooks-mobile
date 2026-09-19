import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/api_error_l10n.dart';
import '../../../../../core/network/api_error.dart';
import '../../../../../core/network/network_providers.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_page.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../../../core/widgets/app_state_views.dart';
import '../../../../../core/widgets/app_step_progress.dart';
import '../../../../categories/application/category_providers.dart';
import '../../../application/listing_providers.dart';
import '../../../domain/listing.dart';
import '../../../domain/listing_enums.dart';
import '../../../domain/listing_input.dart';
import '../../../domain/listing_rules.dart';
import 'book_info_step.dart';
import 'image_draft.dart';
import 'images_step.dart';
import 'review_step.dart';
import 'sale_method_step.dart';
import 'wizard_fields.dart';

/// Wizard đăng bán 4 bước. Server là nguồn sự thật: mỗi bước lưu bằng PUT và
/// lấy `ListingDto` trả về làm state, nên quay lại hay mở lại đều đúng dữ liệu.
///
/// [listingId] `null` là tin mới; bản nháp chỉ được tạo khi lưu bước đầu.
class ListingWizardScreen extends ConsumerStatefulWidget {
  const ListingWizardScreen({super.key, this.listingId});

  final String? listingId;

  @override
  ConsumerState<ListingWizardScreen> createState() =>
      _ListingWizardScreenState();
}

class _ListingWizardScreenState extends ConsumerState<ListingWizardScreen> {
  int _step = 0;
  bool _saving = false;
  Map<String, String> _errors = const {};
  ImageDraft? _images;
  bool _initialized = false;

  @override
  void dispose() {
    _images?.dispose();
    super.dispose();
  }

  ListingDraft get _draft =>
      ref.read(listingDraftProvider(widget.listingId).notifier);

  void _init(Listing? listing, ListingRules rules) {
    if (_initialized) return;
    _initialized = true;
    final uploader = ref.read(blobUploaderProvider);
    _images = ImageDraft(
      maxExtras: rules.maxExtraImages,
      upload: (img) => uploader.upload(
        bytes: img.bytes,
        fileName: 'photo.${img.extension}',
        contentType: img.contentType,
      ),
    );
    if (listing != null) {
      _images!.loadFrom(listing.images);
      _step = _firstIncompleteStep(listing, rules);
    }
  }

  /// Bản nháp mở lại thì vào đúng bước còn thiếu. Tin bị từ chối quay về bước
  /// nhập thông tin để soát lại (FR-INS-12).
  int _firstIncompleteStep(Listing listing, ListingRules rules) {
    if (listing.status == ListingStatus.rejected) return WizardStep.book;
    final b = listing.bookInfo;
    final bookOk =
        b.title != null &&
        b.author != null &&
        listing.category != null &&
        b.publicationYear != null &&
        b.language != null &&
        b.condition != null &&
        (b.description?.length ?? 0) >= rules.minDescriptionLength;
    if (!bookOk) return WizardStep.book;

    final types = listing.images.map((i) => i.type).toSet();
    final photosOk =
        listing.images.length >= rules.minImages &&
        ImageType.required.every(types.contains);
    if (!photosOk) return WizardStep.photos;
    if (listing.saleMethod == null) return WizardStep.sale;
    return WizardStep.review;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _errors = const {};
    });
    try {
      await action();
    } on ApiError catch (e) {
      _handleError(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _handleError(ApiError e) {
    if (!mounted) return;
    final l = context.l10n;
    if (e.code == ApiErrorCode.listingIncomplete) {
      _showIncomplete(e);
      return;
    }
    if (e.fieldErrors.isNotEmpty) {
      setState(() => _errors = fieldKeys(e.localizedFieldErrors(l)));
    }
    if (e.needsReload) _draft.reload();
    AppSnackbar.apiError(context, e);
  }

  void _clearError(String field) {
    final key = field.toLowerCase();
    if (_errors.containsKey(key)) {
      setState(() => _errors = {..._errors}..remove(key));
    }
  }

  void _go(int step) => setState(() {
    _step = step;
    _errors = const {};
  });

  Future<void> _showIncomplete(ApiError e) {
    final l = context.l10n;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.incompleteTitle, style: context.text.titleLarge),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l.incompleteMessage,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (e.fieldErrors.isEmpty)
                      ListTile(
                        leading: const Icon(Icons.error_outline),
                        title: Text(e.localized(l)),
                      ),
                    for (final field in e.fieldErrors.keys)
                      ListTile(
                        leading: Icon(
                          Icons.error_outline,
                          color: context.colors.error,
                        ),
                        title: Text(labelForField(l, field)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(ctx);
                          _go(stepForField(field));
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBook(BookInfoInput input) => _run(() async {
    await _draft.saveBookInfo(input);
    _go(WizardStep.photos);
  });

  Future<void> _saveImages() => _run(() async {
    await _draft.saveImages(_images!.toRequest());
    _go(WizardStep.sale);
  });

  Future<void> _saveSale(SaleMethodInput input) => _run(() async {
    await _draft.saveSaleMethod(input);
    _go(WizardStep.review);
  });

  Future<void> _submit() async {
    // `_run` bao quanh đúng lời gọi mạng: nút không được quay vô hạn phía
    // sau hộp thoại thành công trong lúc chờ người dùng bấm "Xong".
    SubmitResult? result;
    await _run(() async => result = await _draft.submit());
    if (result == null || !mounted) return;
    final l = context.l10n;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          color: ctx.colors.success,
          size: 40,
        ),
        title: Text(l.submitSuccessTitle),
        content: Text(l.submitSuccessMessage(result!.estimatedProcessingHours)),
        actions: [
          AppButton(
            label: l.done,
            expanded: false,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final draftState = ref.watch(listingDraftProvider(widget.listingId));
    final rulesState = ref.watch(listingRulesProvider);
    final catsState = ref.watch(categoryTreeProvider);

    final title = widget.listingId == null
        ? l.wizardTitleNew
        : l.wizardTitleEdit;
    Widget frame(Widget body) =>
        AppPage(title: title, scrollable: false, child: body);

    final error = draftState.error ?? rulesState.error ?? catsState.error;
    if (error != null) {
      return frame(
        AppErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(listingDraftProvider(widget.listingId));
            ref.invalidate(listingRulesProvider);
            ref.invalidate(categoryTreeProvider);
          },
        ),
      );
    }
    if (!draftState.hasValue || !rulesState.hasValue || !catsState.hasValue) {
      return frame(const AppLoadingView());
    }

    final listing = draftState.value;
    final rules = rulesState.value!;
    final categories = catsState.value!;
    _init(listing, rules);

    final labels = [
      l.wizardStepBook,
      l.wizardStepPhotos,
      l.wizardStepSale,
      l.wizardStepReview,
    ];

    // Các bước sau chỉ mở khi đã có bản nháp trên server.
    final step = listing == null ? WizardStep.book : _step;

    final Widget body = switch (step) {
      WizardStep.book => BookInfoStep(
        key: ValueKey('book-${listing?.id}'),
        listing: listing,
        rules: rules,
        categories: categories,
        saving: _saving,
        errors: _errors,
        onSubmit: _saveBook,
        onClearError: _clearError,
      ),
      WizardStep.photos => ImagesStep(
        draft: _images!,
        rules: rules,
        saving: _saving,
        onNext: _saveImages,
      ),
      WizardStep.sale => SaleMethodStep(
        key: ValueKey('sale-${listing!.updatedAt}'),
        listing: listing,
        rules: rules,
        saving: _saving,
        errors: _errors,
        onSubmit: _saveSale,
        onClearError: _clearError,
      ),
      _ => ReviewStep(
        listing: listing!,
        saving: _saving,
        onEdit: _go,
        onSubmit: _submit,
      ),
    };

    return PopScope(
      canPop: step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(step - 1);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: BackButton(
            onPressed: () => step == 0 ? context.pop() : _go(step - 1),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              AppStepProgress(current: step, labels: labels),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
