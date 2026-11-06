import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/util/image_picking.dart';
import '../../../core/util/photo_picker.dart';
import '../../auth/application/auth_controller.dart';
import '../data/kyc_repository.dart';
import '../domain/kyc_models.dart';
import '../face/face_embedder.dart';
import '../face/face_image.dart';
import '../face/face_match_service.dart';

final kycRepositoryProvider = Provider<KycRepository>(
  (ref) => KycRepository(
    ref.watch(apiClientProvider),
    ref.watch(blobUploaderProvider),
  ),
);

/// Trạng thái xác minh của người dùng. Đóng khi rời màn hình để lần mở sau luôn
/// lấy mới; sau khi gửi hồ sơ gọi `ref.invalidate` để tải lại.
final kycStateProvider = FutureProvider.autoDispose<KycState>((ref) {
  final authed = ref.watch(
    authControllerProvider.select((s) => s == AuthStatus.authenticated),
  );
  if (!authed) return Future.value(const KycState(status: KycStatus.none));
  return ref.watch(kycRepositoryProvider).getState();
});

/// So khớp mặt CCCD với selfie. Tạo mới mỗi lần dùng để giải phóng model.
final faceMatchServiceProvider = Provider.autoDispose<FaceMatchService>((ref) {
  final service = FaceMatchService(MlKitFaceFinder(), TfliteFaceEmbedder());
  ref.onDispose(service.dispose);
  return service;
});

/// Lấy một ảnh giấy tờ từ máy ảnh hoặc thư viện, đã xoay thẳng, thu nhỏ cạnh
/// dài 1600px, mã hóa lại JPEG (xóa EXIF). `null` nếu hủy; ném
/// [ImagePickException] nếu ảnh không dùng được. Test ghi đè bằng ảnh có sẵn.
typedef KycPhotoPicker = Future<Uint8List?> Function(PhotoSource source);

const kycDocumentMaxSide = 1600;
const kycDocumentQuality = 88;
const _kycMaxPickBytes = 15 * 1024 * 1024;

final kycPhotoPickerProvider = Provider<KycPhotoPicker>((ref) {
  final picker = ImagePicker();
  return (source) async {
    final XFile? file;
    try {
      file = await picker.pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 92,
      );
    } catch (_) {
      throw const ImagePickException(ImagePickFailure.unavailable);
    }
    if (file == null) return null;
    final raw = await file.readAsBytes();
    if (raw.length > _kycMaxPickBytes) {
      throw const ImagePickException(ImagePickFailure.tooLarge);
    }
    final jpeg = await compute(normalizeJpeg, (
      bytes: raw,
      maxSide: kycDocumentMaxSide,
      quality: kycDocumentQuality,
    ));
    if (jpeg == null) {
      throw const ImagePickException(ImagePickFailure.unsupported);
    }
    return jpeg;
  };
});
