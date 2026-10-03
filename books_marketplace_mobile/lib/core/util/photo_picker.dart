import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'image_picking.dart';

const _maxPhotoBytes = 10 * 1024 * 1024;

/// Chọn một ảnh từ thư viện; `null` nếu hủy. Test ghi đè bằng ảnh có sẵn.
final photoPickerProvider = Provider<Future<PickedImage?> Function()>((ref) {
  final picker = ImagePicker();
  return () => pickImage(picker, ImageSource.gallery, maxBytes: _maxPhotoBytes);
});
