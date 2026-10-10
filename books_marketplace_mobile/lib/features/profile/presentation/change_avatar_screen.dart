import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/util/image_picking.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../application/profile_controller.dart';

/// Giới hạn dung lượng avatar do backend quy định.
const _avatarMaxBytes = 5 * 1024 * 1024;

class ChangeAvatarScreen extends ConsumerStatefulWidget {
  const ChangeAvatarScreen({super.key});

  @override
  ConsumerState<ChangeAvatarScreen> createState() => _ChangeAvatarScreenState();
}

class _ChangeAvatarScreenState extends ConsumerState<ChangeAvatarScreen> {
  final _picker = ImagePicker();

  PickedImage? _picked;
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    final l = context.l10n;
    try {
      final image = await pickImage(_picker, source, maxBytes: _avatarMaxBytes);
      if (image == null || !mounted) return;
      setState(() => _picked = image);
    } on ImagePickException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, switch (e.failure) {
        ImagePickFailure.unsupported => l.errorAvatarUnsupported,
        ImagePickFailure.tooLarge => l.errorAvatarTooLarge,
        ImagePickFailure.unavailable => l.errorPickImage,
      }, type: AppSnackbarType.error);
    }
  }

  Future<void> _save() async {
    final image = _picked;
    if (_busy || image == null) return;
    final l = context.l10n;
    setState(() => _busy = true);
    try {
      await ref
          .read(profileControllerProvider.notifier)
          .changeAvatar(
            bytes: image.bytes,
            fileName: 'avatar.${image.extension}',
            contentType: image.contentType,
          );
      if (!mounted) return;
      AppSnackbar.success(context, l.avatarUpdated);
      context.pop();
    } on ApiError catch (e) {
      if (mounted) AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.removeAvatarConfirmTitle,
      message: l.removeAvatarConfirmMessage,
      confirmLabel: l.removeAvatar,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(profileControllerProvider.notifier).removeAvatar();
      if (!mounted) return;
      AppSnackbar.success(context, l.avatarRemoved);
      context.pop();
    } on ApiError catch (e) {
      if (mounted) AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final profile = ref.watch(profileControllerProvider).requireValue;
    final hasAvatar = profile.avatarUrl != null;

    return AppPage(
      title: l.changeAvatar,
      bottom: AppButton(
        label: l.saveAvatar,
        loading: _busy,
        onPressed: _picked == null ? null : _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: AppAvatar(
              name: profile.fullName,
              imageUrl: profile.avatarUrl,
              localImage: _picked == null ? null : MemoryImage(_picked!.bytes),
              size: 200,
              semanticLabel: l.avatarPreviewLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l.avatarHint,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l.chooseFromGallery,
            icon: Icons.photo_library_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: _busy ? null : () => _pick(ImageSource.gallery),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l.takePhoto,
            icon: Icons.photo_camera_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: _busy ? null : () => _pick(ImageSource.camera),
          ),
          if (hasAvatar && _picked == null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l.removeAvatar,
              icon: Icons.delete_outline,
              variant: AppButtonVariant.text,
              onPressed: _busy ? null : _remove,
            ),
          ],
        ],
      ),
    );
  }
}
