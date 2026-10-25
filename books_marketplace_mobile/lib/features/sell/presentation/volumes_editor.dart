import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../application/listing_publisher.dart';
import '../domain/sell_rules.dart';

/// Danh sách tập của bộ sách trong form đăng bán/đấu giá: mỗi tập có số tập,
/// tên (tùy chọn) và 1 đến [SellRules.photosPerVolumeMax] ảnh riêng.
class VolumesEditor extends StatelessWidget {
  const VolumesEditor({
    super.key,
    required this.volumes,
    required this.rules,
    required this.enabled,
    required this.onAddVolume,
    required this.onRemoveVolume,
    required this.onTitleChanged,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  final List<VolumeSlot> volumes;
  final SellRules rules;
  final bool enabled;
  final VoidCallback onAddVolume;
  final ValueChanged<int> onRemoveVolume;
  final void Function(int volume, String title) onTitleChanged;
  final ValueChanged<int> onAddPhoto;
  final void Function(int volume, int photo) onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.sellVolumesTitle(volumes.length),
                style: context.text.labelMedium,
              ),
              Text(
                '${rules.setMinVolumes}–${rules.setMaxVolumes}',
                style: context.text.labelSmall?.copyWith(
                  color:
                      volumes.length >= rules.setMinVolumes &&
                          volumes.length <= rules.setMaxVolumes
                      ? colors.success
                      : colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < volumes.length; i++)
            _VolumeCard(
              key: ObjectKey(volumes[i]),
              volume: volumes[i],
              maxPhotos: rules.photosPerVolumeMax,
              enabled: enabled,
              onRemove: () => onRemoveVolume(i),
              onTitleChanged: (t) => onTitleChanged(i, t),
              onAddPhoto: () => onAddPhoto(i),
              onRemovePhoto: (p) => onRemovePhoto(i, p),
            ),
          OutlinedButton.icon(
            onPressed: enabled && volumes.length < rules.setMaxVolumes
                ? onAddVolume
                : null,
            icon: const Icon(Icons.add),
            label: Text(l.sellAddVolume),
          ),
        ],
      ),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  const _VolumeCard({
    super.key,
    required this.volume,
    required this.maxPhotos,
    required this.enabled,
    required this.onRemove,
    required this.onTitleChanged,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  final VolumeSlot volume;
  final int maxPhotos;
  final bool enabled;
  final VoidCallback onRemove;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final photos = volume.photos;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  l.sellVolumeLabel(volume.volumeNo),
                  style: context.text.titleSmall,
                ),
                const Spacer(),
                Text(
                  l.sellVolumePhotoCount(photos.length, maxPhotos),
                  style: context.text.labelSmall?.copyWith(
                    color: photos.isNotEmpty
                        ? colors.success
                        : colors.textMuted,
                  ),
                ),
                IconButton(
                  tooltip: l.sellVolumeRemove,
                  onPressed: enabled ? onRemove : null,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            TextFormField(
              initialValue: volume.title,
              enabled: enabled,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: l.sellVolumeNameHint,
                counterText: '',
              ),
              onChanged: onTitleChanged,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var p = 0; p < photos.length; p++)
                  _Thumb(
                    slot: photos[p],
                    onRemove: enabled ? () => onRemovePhoto(p) : null,
                  ),
                if (photos.length < maxPhotos)
                  InkWell(
                    onTap: enabled ? onAddPhoto : null,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.textMuted),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.slot, required this.onRemove});

  final PhotoSlot slot;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            fit: StackFit.expand,
            children: [
              slot.photo != null
                  ? Image.memory(slot.photo!.bytes, fit: BoxFit.cover)
                  : Image.network(
                      slot.previewUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_outlined),
                    ),
              const Positioned(
                top: 2,
                right: 2,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
