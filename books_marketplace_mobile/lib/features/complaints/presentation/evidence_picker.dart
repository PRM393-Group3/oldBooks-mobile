import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/image_picking.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../data/complaint_repository.dart';

const maxEvidenceFiles = 10;
const _maxImageBytes = 10 * 1024 * 1024;
const _maxVideoBytes = 50 * 1024 * 1024;

const _videoTypes = {
  'mp4': 'video/mp4',
  'mov': 'video/quicktime',
  'webm': 'video/webm',
};

enum _Kind { photo, video }

/// Chọn một tệp bằng chứng từ thư viện (ảnh JPEG/PNG/WebP tối đa 10 MB, video
/// MP4/MOV/WebM tối đa 50 MB). Trả `null` nếu hủy hoặc tệp không hợp lệ (đã
/// báo lỗi cho người dùng).
Future<EvidenceFile?> pickEvidence(BuildContext context) async {
  final l = context.l10n;
  final kind = await showModalBottomSheet<_Kind>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_outlined),
            title: Text(l.cpPickPhoto),
            onTap: () => Navigator.of(sheet).pop(_Kind.photo),
          ),
          ListTile(
            leading: const Icon(Icons.videocam_outlined),
            title: Text(l.cpPickVideo),
            onTap: () => Navigator.of(sheet).pop(_Kind.video),
          ),
        ],
      ),
    ),
  );
  if (kind == null || !context.mounted) return null;

  final picker = ImagePicker();
  try {
    if (kind == _Kind.photo) {
      final image = await pickImage(
        picker,
        ImageSource.gallery,
        maxBytes: _maxImageBytes,
      );
      if (image == null) return null;
      return EvidenceFile(
        bytes: image.bytes,
        fileName:
            'evidence-${DateTime.now().millisecondsSinceEpoch}.${image.extension}',
        contentType: image.contentType,
      );
    }
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return null;
    final name = video.name;
    final dot = name.lastIndexOf('.');
    final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
    final type = _videoTypes[ext];
    if (type == null) {
      if (context.mounted) {
        AppSnackbar.show(
          context,
          l.cpEvidenceUnsupported,
          type: AppSnackbarType.error,
        );
      }
      return null;
    }
    if (await video.length() > _maxVideoBytes) {
      if (context.mounted) {
        AppSnackbar.show(
          context,
          l.cpEvidenceTooLarge,
          type: AppSnackbarType.error,
        );
      }
      return null;
    }
    return EvidenceFile(
      bytes: await video.readAsBytes(),
      fileName: 'evidence-${DateTime.now().millisecondsSinceEpoch}.$ext',
      contentType: type,
    );
  } on ImagePickException catch (e) {
    if (context.mounted) {
      AppSnackbar.show(context, switch (e.failure) {
        ImagePickFailure.unsupported => l.cpEvidenceUnsupported,
        ImagePickFailure.tooLarge => l.cpEvidenceTooLarge,
        ImagePickFailure.unavailable => l.errorPickImage,
      }, type: AppSnackbarType.error);
    }
    return null;
  }
}

/// Lưới tệp bằng chứng đã chọn kèm nút thêm. [files] do màn hình sở hữu.
class EvidenceGrid extends StatelessWidget {
  const EvidenceGrid({
    super.key,
    required this.files,
    required this.onAdd,
    required this.onRemove,
    this.enabled = true,
  });

  final List<EvidenceFile> files;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (var i = 0; i < files.length; i++)
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: files[i].isVideo
                      ? ColoredBox(
                          color: colors.surfaceMuted,
                          child: Icon(
                            Icons.play_circle_outline,
                            color: colors.textSecondary,
                            size: 32,
                          ),
                        )
                      : Image.memory(files[i].bytes, fit: BoxFit.cover),
                ),
                if (enabled)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (files.length < maxEvidenceFiles)
          SizedBox(
            width: 76,
            height: 76,
            child: InkWell(
              onTap: enabled ? onAdd : null,
              borderRadius: BorderRadius.circular(10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: Icon(
                  Icons.add_a_photo_outlined,
                  color: colors.textMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
