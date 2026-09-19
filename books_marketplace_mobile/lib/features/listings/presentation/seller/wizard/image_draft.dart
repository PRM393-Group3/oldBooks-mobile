import 'package:flutter/foundation.dart';

import '../../../../../core/util/async_pool.dart';
import '../../../../../core/util/image_picking.dart';
import '../../../domain/listing.dart';
import '../../../domain/listing_enums.dart';

enum UploadStatus { uploading, done, failed }

class ImageEntry {
  ImageEntry({
    required this.type,
    this.picked,
    this.blobName,
    this.url,
    this.status = UploadStatus.uploading,
  });

  final ImageType type;
  final PickedImage? picked;
  String? blobName;

  /// URL của ảnh đã có trên server (khi mở lại bản nháp).
  final String? url;
  UploadStatus status;

  Uint8List? get bytes => picked?.bytes;
}

/// Trạng thái ảnh của wizard: 4 ô góc bắt buộc và tối đa vài ảnh thêm.
///
/// Mỗi ảnh tải riêng (tối đa 2 ảnh cùng lúc), có thể thử lại từng ảnh, nên
/// một ảnh lỗi không làm mất các ảnh đã tải xong. Giữ trong State của wizard
/// để chuyển bước không làm mất tiến độ.
class ImageDraft extends ChangeNotifier {
  ImageDraft({required this.upload, required this.maxExtras});

  /// Tải ảnh lên Blob Storage, trả về `blobName`.
  final Future<String> Function(PickedImage image) upload;
  final int maxExtras;

  final _pool = AsyncPool(2);
  final List<ImageEntry?> slots = List.filled(ImageType.required.length, null);
  final List<ImageEntry> extras = [];
  bool _disposed = false;

  /// Nạp ảnh đã lưu trên server. Ảnh không suy được `blobName` bị bỏ qua để
  /// người dùng chọn lại, vì không gửi lại được danh sách ảnh nếu thiếu nó.
  void loadFrom(List<ListingImage> images) {
    for (final img in images) {
      final blob = img.blobName;
      if (blob == null) continue;
      final entry = ImageEntry(
        type: img.type,
        blobName: blob,
        url: img.url,
        status: UploadStatus.done,
      );
      final i = ImageType.required.indexOf(img.type);
      if (i >= 0 && slots[i] == null) {
        slots[i] = entry;
      } else if (extras.length < maxExtras) {
        extras.add(
          ImageEntry(
            type: ImageType.innerPage,
            blobName: blob,
            url: img.url,
            status: UploadStatus.done,
          ),
        );
      }
    }
  }

  Future<void> setSlot(int index, PickedImage image) {
    final entry = ImageEntry(type: ImageType.required[index], picked: image);
    slots[index] = entry;
    return _start(entry);
  }

  Future<void> addExtra(PickedImage image) {
    if (extras.length >= maxExtras) return Future.value();
    // Doc chưa có loại riêng cho ảnh thêm; tạm dùng InnerPage.
    final entry = ImageEntry(type: ImageType.innerPage, picked: image);
    extras.add(entry);
    return _start(entry);
  }

  Future<void> retry(ImageEntry entry) => _start(entry);

  void removeSlot(int index) {
    slots[index] = null;
    _notify();
  }

  void removeExtra(ImageEntry entry) {
    extras.remove(entry);
    _notify();
  }

  Future<void> _start(ImageEntry entry) async {
    entry.status = UploadStatus.uploading;
    _notify();
    try {
      entry.blobName = await _pool.run(() => upload(entry.picked!));
      entry.status = UploadStatus.done;
    } catch (_) {
      entry.status = UploadStatus.failed;
    }
    _notify();
  }

  int get count => slots.whereType<ImageEntry>().length + extras.length;

  bool get isUploading => [
    ...slots.whereType<ImageEntry>(),
    ...extras,
  ].any((e) => e.status == UploadStatus.uploading);

  bool get hasFailed => [
    ...slots.whereType<ImageEntry>(),
    ...extras,
  ].any((e) => e.status == UploadStatus.failed);

  /// Đủ 4 góc và đã tải xong.
  bool get requiredComplete =>
      slots.every((s) => s != null && s.status == UploadStatus.done);

  /// Body của `PUT images`: 4 góc trước, ảnh thêm sau (thứ tự là thứ tự hiển thị).
  List<({String blobName, ImageType type})> toRequest() => [
    for (final e in [...slots.whereType<ImageEntry>(), ...extras])
      if (e.blobName != null) (blobName: e.blobName!, type: e.type),
  ];

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
