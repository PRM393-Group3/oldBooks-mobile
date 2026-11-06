import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/config_providers.dart';
import '../../../core/config/public_config.dart';
import '../../../core/l10n/api_error_l10n.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/idempotency.dart';
import '../../../core/util/image_picking.dart';
import '../../../core/widgets/app_banner.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_step_progress.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/photo_source_sheet.dart';
import '../application/kyc_providers.dart';
import '../data/kyc_repository.dart';
import '../domain/kyc_models.dart';
import '../domain/kyc_rules.dart';
import '../face/face_match_service.dart';
import 'cccd_ai_sheet.dart';
import 'liveness_capture_screen.dart';

/// Luồng gửi hồ sơ eKYC: đồng ý -> giấy tờ -> selfie liveness -> xem lại và gửi.
/// Mọi AI chạy trên máy; admin là người quyết định.
class KycFlowScreen extends ConsumerStatefulWidget {
  const KycFlowScreen({super.key});

  @override
  ConsumerState<KycFlowScreen> createState() => _KycFlowScreenState();
}

class _KycFlowScreenState extends ConsumerState<KycFlowScreen> {
  int _step = 0;
  bool _consent = false;

  Uint8List? _front;
  Uint8List? _back;
  final _name = TextEditingController();
  final _idNumber = TextEditingController();
  final _dob = TextEditingController();
  bool _usedAi = false;
  bool _showFieldErrors = false;
  Map<String, String> _serverFieldErrors = const {};

  LivenessResult? _liveness;
  FaceMatchResult? _match;
  Future<FaceMatchResult>? _matching;

  bool _submitting = false;
  String _progress = '';
  String? _error;
  final _idem = IdempotentAction();
  List<KycImage>? _uploads;

  @override
  void dispose() {
    _name.dispose();
    _idNumber.dispose();
    _dob.dispose();
    super.dispose();
  }

  int get _minAge =>
      ref.read(publicConfigProvider).intOf(PublicConfig.kycMinAge) ??
      kycDefaultMinAge;

  KycFieldsCheck get _check => checkKycFields(
    fullName: _name.text,
    idNumber: _idNumber.text,
    dob: _dob.text,
    minAge: _minAge,
  );

  bool get _documentsReady => _front != null && _back != null && _check.ok;

  Future<Uint8List?> _pick() async {
    final source = await showPhotoSourceSheet(context, multiple: false);
    if (source == null || !mounted) return null;
    try {
      return await ref.read(kycPhotoPickerProvider)(source);
    } on ImagePickException catch (e) {
      if (mounted) {
        final l = context.l10n;
        AppSnackbar.show(context, switch (e.failure) {
          ImagePickFailure.unsupported => l.cpEvidenceUnsupported,
          ImagePickFailure.tooLarge => l.cpEvidenceTooLarge,
          ImagePickFailure.unavailable => l.errorPickImage,
        }, type: AppSnackbarType.error);
      }
      return null;
    }
  }

  Future<void> _pickFront() async {
    final bytes = await _pick();
    if (bytes == null || !mounted) return;
    setState(() {
      _front = bytes;
      _match = null;
      _matching = null;
      _uploads = null;
    });
    // Ảnh mặt trước vừa có: mời đọc tự động bằng AI.
    await _runOcr();
  }

  Future<void> _pickBack() async {
    final bytes = await _pick();
    if (bytes == null || !mounted) return;
    setState(() {
      _back = bytes;
      _uploads = null;
    });
  }

  Future<void> _runOcr() async {
    final front = _front;
    if (front == null) return;
    final fields = await showCccdAiSheet(context, front);
    if (fields == null || !mounted) return;
    setState(() {
      _usedAi = true;
      if (fields.fullName != null) _name.text = fields.fullName!;
      if (fields.idNumber != null) _idNumber.text = fields.idNumber!;
      if (fields.dateOfBirth != null) {
        _dob.text = formatVnDate(fields.dateOfBirth!);
      }
      _serverFieldErrors = const {};
    });
  }

  Future<void> _runLiveness() async {
    final l = context.l10n;
    final result = await ref.read(livenessRunnerProvider)(context);
    if (result == null || !mounted) return;
    setState(() {
      _liveness = result;
      _match = null;
      _matching = null;
      _uploads = null;
    });
    _startMatching();
    if (!mounted) return;
    AppSnackbar.show(context, l.kycLivenessDone, type: AppSnackbarType.success);
  }

  /// So khớp mặt chạy nền ngay sau khi có selfie để lúc gửi không phải chờ.
  Future<FaceMatchResult>? _startMatching() {
    final front = _front;
    final selfie = _liveness?.selfie;
    if (front == null || selfie == null) return null;
    final future = ref
        .read(faceMatchServiceProvider)
        .match(cccdFront: front, selfie: selfie)
        .then((r) {
          if (mounted) _match = r;
          return r;
        });
    return _matching = future;
  }

  void _next() {
    final l = context.l10n;
    if (_step == 1) {
      setState(() => _showFieldErrors = true);
      if (!_documentsReady) {
        if (_front == null || _back == null) {
          AppSnackbar.show(
            context,
            l.kycNeedBothImages,
            type: AppSnackbarType.error,
          );
        }
        return;
      }
    }
    setState(() {
      _step++;
      _error = null;
    });
  }

  void _goBack() {
    if (_step == 0) {
      context.pop();
    } else {
      setState(() {
        _step--;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final front = _front, back = _back, live = _liveness;
    final dob = parseVnDate(_dob.text);
    if (front == null || back == null || live == null || dob == null) return;
    setState(() {
      _submitting = true;
      _error = null;
      _progress = l.kycSubmitPreparing;
    });
    try {
      // Mặt chưa so khớp xong (hoặc ảnh đã đổi) thì chờ; lỗi cũng không chặn gửi.
      final match = _match ?? await (_matching ?? _startMatching());

      _uploads ??= [
        KycImage(front, fileName: 'cccd-front.jpg'),
        KycImage(back, fileName: 'cccd-back.jpg'),
        KycImage(live.selfie, fileName: 'selfie.jpg'),
        for (var i = 0; i < live.frames.length; i++)
          KycImage(live.frames[i], fileName: 'liveness-$i.jpg'),
      ];
      final repo = ref.read(kycRepositoryProvider);
      final names = await repo.uploadImages(
        _uploads!,
        onProgress: (done, total) {
          if (mounted) {
            setState(() => _progress = l.kycSubmitUploading(done, total));
          }
        },
      );
      if (mounted) setState(() => _progress = l.kycSubmitSending);

      await repo.submit(
        KycSubmitRequest(
          fullName: _name.text,
          idNumber: _idNumber.text.trim(),
          dateOfBirth: toApiDate(dob),
          frontBlobName: names[0],
          backBlobName: names[1],
          selfieBlobName: names[2],
          livenessBlobNames: names.sublist(3),
          clientInfo: KycClientInfo(
            faceMatchScore: match?.score,
            ocrSource: _usedAi ? OcrSource.ai : OcrSource.manual,
            modelVersion: _modelVersion(match),
            livenessChallenges: live.challenges,
          ),
        ),
        idempotencyKey: _idem.key,
      );
      _idem.settle();
      ref.invalidate(kycStateProvider);
      if (!mounted) return;
      AppSnackbar.show(context, l.kycSubmitted, type: AppSnackbarType.success);
      context.pop();
    } on ApiError catch (e) {
      _idem.settle(e);
      if (!mounted) return;
      _onSubmitError(e);
    } catch (_) {
      _idem.settle();
      if (mounted) setState(() => _error = context.l10n.errorUnknown);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _modelVersion(FaceMatchResult? match) {
    final parts = [
      if (_usedAi) 'gemma-4-e2b-it',
      if (match?.score != null) match!.modelVersion,
    ];
    return parts.isEmpty ? null : parts.join('+');
  }

  void _onSubmitError(ApiError e) {
    final l = context.l10n;
    // Hồ sơ đã có/đã duyệt: quay về màn trạng thái để thấy kết quả thật.
    if (e.code == ApiErrorCode.kycPendingExists ||
        e.code == ApiErrorCode.kycAlreadyVerified) {
      ref.invalidate(kycStateProvider);
      AppSnackbar.show(context, e.localized(l), type: AppSnackbarType.error);
      context.pop();
      return;
    }
    final fieldKeys = {'fullName', 'idNumber', 'dateOfBirth'};
    final fieldErrors = {
      for (final f in e.fieldErrors.entries)
        if (fieldKeys.contains(f.key)) f.key: f.value,
    };
    setState(() {
      _error = e.localized(l);
      if (fieldErrors.isNotEmpty || e.code == ApiErrorCode.kycIdDuplicate) {
        // Trường nhập sai: đưa người dùng về đúng chỗ để sửa.
        _serverFieldErrors = e.code == ApiErrorCode.kycIdDuplicate
            ? {'idNumber': e.localized(l)}
            : fieldErrors;
        _showFieldErrors = true;
        _step = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final labels = [
      l.kycStepConsent,
      l.kycStepDocuments,
      l.kycStepSelfie,
      l.kycStepReview,
    ];

    final body = switch (_step) {
      0 => _consentStep(context),
      1 => _documentsStep(context),
      2 => _selfieStep(context),
      _ => _reviewStep(context),
    };

    final canNext = switch (_step) {
      0 => _consent,
      1 => true,
      2 => _liveness != null,
      _ => !_submitting,
    };

    return PopScope(
      canPop: _step == 0 && !_submitting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_submitting) _goBack();
      },
      child: AppPage(
        title: l.kycTitle,
        bottom: Padding(
          padding: AppSpacing.screenPadding,
          child: Row(
            children: [
              if (_step > 0) ...[
                Expanded(
                  child: AppButton(
                    label: l.back,
                    variant: AppButtonVariant.secondary,
                    large: true,
                    onPressed: _submitting ? null : _goBack,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                flex: 2,
                child: AppButton(
                  label: _step == 3 ? l.kycSubmit : l.next,
                  large: true,
                  loading: _submitting,
                  onPressed: canNext ? (_step == 3 ? _submit : _next) : null,
                ),
              ),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppStepProgress(current: _step, labels: labels),
            const SizedBox(height: AppSpacing.sm),
            body,
          ],
        ),
      ),
    );
  }

  // ---- Bước 0: đồng ý ----

  Widget _consentStep(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    Widget bullet(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: context.text.bodyMedium)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.kycIntroTitle, style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l.kycIntroBody,
          style: context.text.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        bullet(Icons.badge_outlined, l.kycIntroStepDocuments),
        bullet(Icons.face_retouching_natural, l.kycIntroStepSelfie),
        bullet(Icons.fact_check_outlined, l.kycIntroStepReview),
        bullet(Icons.verified, l.kycIntroBenefit),
        const SizedBox(height: AppSpacing.sm),
        AppBanner(
          tone: AppTagTone.info,
          icon: Icons.lock_outline,
          message: l.kycIntroPrivacy,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCheckbox(
              value: _consent,
              onChanged: () => setState(() => _consent = !_consent),
              semanticLabel: l.kycConsentLabel,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _consent = !_consent),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    l.kycConsentLabel,
                    style: context.text.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---- Bước 1: giấy tờ ----

  Widget _documentsStep(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final check = _check;
    final show = _showFieldErrors;

    String? nameError = _serverFieldErrors['fullName'] != null
        ? l.errorFieldInvalid
        : (show && check.nameInvalid ? l.kycErrName : null);
    String? idError =
        _serverFieldErrors['idNumber'] ??
        (show && check.idInvalid ? l.kycErrIdNumber : null);
    String? dobError = _serverFieldErrors['dateOfBirth'] != null
        ? l.errorFieldInvalid
        : (show && check.dob != null
              ? (check.dob == KycDobProblem.underage
                    ? l.kycErrUnderageLocal(_minAge)
                    : l.kycErrDob)
              : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.kycDocumentsHint, style: context.text.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        _DocSlot(label: l.kycFront, bytes: _front, onTap: _pickFront),
        const SizedBox(height: AppSpacing.sm),
        _DocSlot(label: l.kycBack, bytes: _back, onTap: _pickBack),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(l.kycInfoTitle, style: context.text.titleSmall),
            ),
            if (_front != null)
              AppButton(
                label: l.kycReadWithAi,
                icon: Icons.auto_awesome,
                variant: AppButtonVariant.secondary,
                expanded: false,
                onPressed: _runOcr,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          l.kycInfoHint,
          style: context.text.bodySmall?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: l.kycFieldName,
          controller: _name,
          errorText: nameError,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() => _serverFieldErrors = const {}),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: l.kycFieldId,
          controller: _idNumber,
          errorText: idError,
          keyboardType: TextInputType.number,
          maxLength: 12,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() => _serverFieldErrors = const {}),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: l.kycFieldDob,
          hintText: l.kycDobHint,
          controller: _dob,
          errorText: dobError,
          keyboardType: TextInputType.datetime,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
          ],
          onChanged: (_) => setState(() => _serverFieldErrors = const {}),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppBanner(
            tone: AppTagTone.error,
            icon: Icons.error_outline,
            message: _error!,
          ),
        ],
      ],
    );
  }

  // ---- Bước 2: selfie ----

  Widget _selfieStep(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final live = _liveness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.kycSelfieTitle, style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l.kycSelfieBody,
          style: context.text.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        if (live != null) ...[
          Center(
            child: ClipOval(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Image.memory(live.selfie, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: AppTag(
              label: l.kycLivenessDone,
              tone: AppTagTone.success,
              icon: Icons.check,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppButton(
          label: live == null ? l.kycSelfieStart : l.kycSelfieRetake,
          icon: Icons.face_retouching_natural,
          variant: live == null
              ? AppButtonVariant.primary
              : AppButtonVariant.secondary,
          onPressed: _runLiveness,
        ),
      ],
    );
  }

  // ---- Bước 3: xem lại ----

  Widget _reviewStep(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final live = _liveness;
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.text.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
    Widget thumb(Uint8List? b) => Expanded(
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: AspectRatio(
          aspectRatio: 1.5,
          child: b == null
              ? const SizedBox.shrink()
              : Image.memory(b, fit: BoxFit.cover),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.kycReviewTitle, style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l.kycReviewBody,
          style: context.text.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            thumb(_front),
            const SizedBox(width: AppSpacing.xs),
            thumb(_back),
            const SizedBox(width: AppSpacing.xs),
            thumb(live?.selfie),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        row(l.kycFieldName, _name.text.trim()),
        row(l.kycFieldId, _idNumber.text.trim()),
        row(l.kycFieldDob, _dob.text.trim()),
        const SizedBox(height: AppSpacing.sm),
        AppBanner(
          tone: AppTagTone.info,
          icon: Icons.info_outline,
          message: l.kycReviewNote,
        ),
        if (_submitting) ...[
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            _progress,
            textAlign: TextAlign.center,
            style: context.text.bodySmall,
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppBanner(
            tone: AppTagTone.error,
            icon: Icons.error_outline,
            message: _error!,
          ),
        ],
      ],
    );
  }
}

/// Ô ảnh giấy tờ (ngang, tỉ lệ thẻ CCCD).
class _DocSlot extends StatelessWidget {
  const _DocSlot({
    required this.label,
    required this.bytes,
    required this.onTap,
  });

  final String label;
  final Uint8List? bytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return Semantics(
      label: bytes == null ? '$label, ${l.photoSlotEmpty}' : label,
      button: true,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1.586,
        child: Material(
          color: colors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgAll,
            side: BorderSide(color: colors.border),
          ),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (bytes != null)
                  Image.memory(bytes!, fit: BoxFit.cover)
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: colors.primary,
                        size: 32,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        l.addPhoto,
                        style: context.text.labelMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      label,
                      style: context.text.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
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
