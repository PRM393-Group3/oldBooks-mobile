import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'image_picking.dart';

const _maxPhotoBytes = 10 * 1024 * 1024;

enum PhotoSource { camera, gallery }

/// Lấy ảnh từ [PhotoSource]: máy ảnh chụp một ảnh, thư viện chọn được nhiều ảnh
/// (tối đa [limit]). Danh sách rỗng nếu hủy. Test ghi đè bằng ảnh có sẵn.
typedef PhotoPicker = Future<PickedBatch> Function(
  PhotoSource source,
  int limit,
);

final photoPickerProvider = Provider<PhotoPicker>((ref) {
  final picker = ImagePicker();
  return (source, limit) async {
    switch (source) {
      case PhotoSource.camera:
        final one = await pickImage(
          picker,
          ImageSource.camera,
          maxBytes: _maxPhotoBytes,
        );
        return one == null ? PickedBatch.empty : PickedBatch([one]);
      case PhotoSource.gallery:
        return pickImages(picker, limit: limit, maxBytes: _maxPhotoBytes);
    }
  };
});
