import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/theme_context.dart';
import '../../../../../core/util/image_picking.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_image_slot.dart';
import '../../../../../core/widgets/app_page.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../domain/listing_enums.dart';
import '../../../domain/listing_rules.dart';
import 'image_draft.dart';

/// Bước 2: ảnh. Bốn ô góc bắt buộc cộng ảnh thêm; mỗi ảnh tải riêng.
class ImagesStep extends StatefulWidget {
  const ImagesStep({
    super.key,
    required this.draft,
    required this.rules,
    required this.saving,
    required this.onNext,
  });

  final ImageDraft draft;
  final ListingRules rules;
  final bool saving;
  final VoidCallback onNext;

  @override
  State<ImagesStep> createState() => _ImagesStepState();
}

class _ImagesStepState extends State<ImagesStep> {
  final _picker = ImagePicker();

  Future<ImageSource?> _chooseSource() {
    final l = context.l10n;
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.chooseFromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.takePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(void Function(PickedImage image) onPicked) async {
    final l = context.l10n;
    final source = await _chooseSource();
    if (source == null || !mounted) return;
    try {
      final image = await pickImage(
        _picker,
        source,
        maxBytes: widget.rules.maxImageBytes,
      );
      if (image != null) onPicked(image);
    } on ImagePickException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, switch (e.failure) {
        ImagePickFailure.unsupported => l.errorAvatarUnsupported,
        ImagePickFailure.tooLarge => l.errorPhotoTooLarge(
          widget.rules.maxImageMegabytes,
        ),
        ImagePickFailure.unavailable => l.errorPickImage,
      }, type: AppSnackbarType.error);
    }
  }

  AppImageSlotStatus _status(ImageEntry? e) => switch (e?.status) {
    null => AppImageSlotStatus.empty,
    UploadStatus.uploading => AppImageSlotStatus.uploading,
    UploadStatus.done => AppImageSlotStatus.done,
    UploadStatus.failed => AppImageSlotStatus.failed,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final draft = widget.draft;
    final rules = widget.rules;

    return ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        final ready =
            draft.requiredComplete &&
            !draft.isUploading &&
            !draft.hasFailed &&
            draft.count >= rules.minImages;

        return AppPage(
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (draft.isUploading || draft.hasFailed)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    draft.isUploading
                        ? l.photosWaiting
                        : l.errorPhotosUploadPending,
                    style: context.text.bodySmall?.copyWith(
                      color: draft.hasFailed && !draft.isUploading
                          ? colors.error
                          : colors.textSecondary,
                    ),
                  ),
                ),
              AppButton(
                label: l.next,
                loading: widget.saving,
                onPressed: ready ? widget.onNext : null,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.photosHint(rules.minImages, rules.maxImages),
                style: context.text.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 3 / 4,
                children: [
                  for (var i = 0; i < ImageType.required.length; i++)
                    AppImageSlot(
                      label: ImageType.required[i].label(l),
                      required: true,
                      status: _status(draft.slots[i]),
                      bytes: draft.slots[i]?.bytes,
                      url: draft.slots[i]?.url,
                      onTap: () => _pick((img) => draft.setSlot(i, img)),
                      onRetry: draft.slots[i] == null
                          ? null
                          : () => draft.retry(draft.slots[i]!),
                      onRemove: () => draft.removeSlot(i),
                    ),
                ],
              ),
              if (rules.maxExtraImages > 0) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l.photosExtraTitle(draft.extras.length, rules.maxExtraImages),
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.xs,
                  crossAxisSpacing: AppSpacing.xs,
                  childAspectRatio: 3 / 4,
                  children: [
                    for (final e in draft.extras)
                      AppImageSlot(
                        label: l.imageExtra,
                        status: _status(e),
                        bytes: e.bytes,
                        url: e.url,
                        onTap: () {},
                        onRetry: () => draft.retry(e),
                        onRemove: () => draft.removeExtra(e),
                      ),
                    if (draft.extras.length < rules.maxExtraImages)
                      AppImageSlot(
                        label: l.imageExtra,
                        status: AppImageSlotStatus.empty,
                        onTap: () => _pick(draft.addExtra),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}
