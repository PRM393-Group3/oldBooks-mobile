import '../../listings/data/listing_repository.dart';
import '../../listings/domain/listing.dart';
import '../../listings/domain/listing_query.dart';

/// Một ô ảnh trong form: ảnh đã có trên server (`blobName`) hoặc ảnh mới chọn.
class PhotoSlot {
  PhotoSlot.existing({required String this.blobName, required this.previewUrl})
    : photo = null;
  PhotoSlot.fresh(NewPhoto this.photo) : blobName = null, previewUrl = null;

  /// Đã có trên server; khi tải lên xong, ảnh mới cũng được gán `blobName`.
  String? blobName;
  final String? previewUrl;
  final NewPhoto? photo;

  bool get isUploaded => blobName != null;
}

/// Tiến trình đăng bán, để hiển thị và để chạy lại từ bước dở khi lỗi.
enum PublishStage { creating, uploading, submitting }

/// Trạng thái có thể chạy lại. Nếu một bước lỗi, giữ nguyên đối tượng này và gọi
/// [ListingPublisher.run] lần nữa: tin đã tạo và ảnh đã tải lên không làm lại.
class PublishProgress {
  PublishProgress({this.listingId});

  String? listingId;
  bool fieldsSaved = false;
  bool photosSaved = false;
}

/// Đăng bán một tin giá cố định theo 3 bước của backend: tạo/sửa tin, tải từng
/// ảnh rồi đặt lại danh sách ảnh, gửi duyệt. Mỗi bước hoàn tất được ghi vào
/// [PublishProgress] nên lỗi giữa chừng (mất mạng...) có thể thử lại mà không tạo
/// tin trùng hay tải lại ảnh.
class ListingPublisher {
  ListingPublisher(this._repo);

  final ListingRepository _repo;

  /// [photos] theo thứ tự hiển thị, ảnh đầu là ảnh bìa. [photosChanged] bỏ qua
  /// `PUT /photos` khi sửa tin mà không đụng tới ảnh.
  Future<Listing> run({
    required PublishProgress progress,
    required ListingDraftInput input,
    required List<PhotoSlot> photos,
    required bool submit,
    bool photosChanged = true,
    void Function(PublishStage stage, int done, int total)? onStage,
  }) async {
    Listing? listing;

    if (!progress.fieldsSaved) {
      onStage?.call(PublishStage.creating, 0, 0);
      final id = progress.listingId;
      listing = id == null
          ? await _repo.create(input)
          : await _repo.update(id, input);
      progress.listingId = listing.id;
      progress.fieldsSaved = true;
    }
    final id = progress.listingId!;

    if (photosChanged && !progress.photosSaved) {
      final pending = [
        for (final p in photos)
          if (!p.isUploaded) p,
      ];
      var done = 0;
      onStage?.call(PublishStage.uploading, done, pending.length);
      // Mỗi ảnh một lần xin URL, tải xong ghi nhận ngay để lần thử lại bỏ qua.
      for (final slot in pending) {
        final names = await _repo.uploadPhotos(id, [slot.photo!]);
        slot.blobName = names.single;
        onStage?.call(PublishStage.uploading, ++done, pending.length);
      }
      await _repo.setPhotos(id, [for (final p in photos) p.blobName!]);
      progress.photosSaved = true;
    }

    if (submit) {
      onStage?.call(PublishStage.submitting, 0, 0);
      return _repo.submit(id);
    }
    return listing ?? _repo.get(id);
  }
}
