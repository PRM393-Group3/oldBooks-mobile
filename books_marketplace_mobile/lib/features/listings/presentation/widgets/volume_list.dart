import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/app_image_viewer.dart';

/// Một tập của bộ sách để hiển thị: số tập, tên (tùy chọn) và URL ảnh của tập.
class VolumeView {
  const VolumeView({
    required this.volumeNo,
    required this.thumbnailUrls,
    required this.urls,
    this.title,
  });

  final int volumeNo;
  final String? title;
  final List<String> thumbnailUrls;
  final List<String> urls;
}

/// Nhãn "Bộ N tập" cho thẻ danh sách; không hiện gì với sách lẻ.
class SetBadge extends StatelessWidget {
  const SetBadge({super.key, required this.volumeCount});

  final int volumeCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.successContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Text(
          context.l10n.setBadge(volumeCount),
          style: context.text.labelSmall?.copyWith(
            color: colors.onSuccessContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Danh sách tập của bộ sách kèm ảnh từng tập; chạm vào ảnh để xem toàn màn hình.
class VolumeList extends StatelessWidget {
  const VolumeList({super.key, required this.volumes});

  final List<VolumeView> volumes;

  @override
  Widget build(BuildContext context) {
    if (volumes.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.detailVolumes(volumes.length), style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          for (final v in volumes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text(
                      l.sellVolumeLabel(v.volumeNo),
                      style: context.text.labelLarge,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      v.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall,
                    ),
                  ),
                  for (var i = 0; i < v.thumbnailUrls.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: GestureDetector(
                        onTap: () => showImageViewer(
                          context,
                          urls: v.urls,
                          labels: [
                            for (final _ in v.urls)
                              l.sellVolumeLabel(v.volumeNo),
                          ],
                          initialIndex: i,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            v.thumbnailUrls[i],
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const SizedBox(width: 48, height: 48),
                          ),
                        ),
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
