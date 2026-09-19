import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Ảnh hợp lệ để tải lên: đuôi và `Content-Type` phải khớp (backend kiểm tra).
class PickedImage {
  const PickedImage(this.bytes, this.extension, this.contentType);

  final Uint8List bytes;
  final String extension;
  final String contentType;

  static const _types = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  /// `null` nếu định dạng không được hỗ trợ.
  static PickedImage? tryCreate(Uint8List bytes, String fileName) {
    final dot = fileName.lastIndexOf('.');
    final ext = dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
    final type = _types[ext];
    return type == null ? null : PickedImage(bytes, ext, type);
  }
}

enum ImagePickFailure { unsupported, tooLarge, unavailable }

class ImagePickException implements Exception {
  const ImagePickException(this.failure);
  final ImagePickFailure failure;
}

/// Chọn ảnh, thu nhỏ (cạnh dài 1024px) và nén 85% ngay khi chọn. Trả `null`
/// nếu người dùng hủy; ném [ImagePickException] khi ảnh không dùng được.
Future<PickedImage?> pickImage(
  ImagePicker picker,
  ImageSource source, {
  required int maxBytes,
}) async {
  final XFile? file;
  try {
    file = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  } catch (_) {
    throw const ImagePickException(ImagePickFailure.unavailable);
  }
  if (file == null) return null;

  final bytes = await file.readAsBytes();
  final image = PickedImage.tryCreate(bytes, file.name);
  if (image == null) {
    throw const ImagePickException(ImagePickFailure.unsupported);
  }
  if (bytes.length > maxBytes) {
    throw const ImagePickException(ImagePickFailure.tooLarge);
  }
  return image;
}
