import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import 'face_embedder.dart';
import 'face_image.dart';
import 'face_math.dart';

/// Tìm khuôn mặt lớn nhất trong một ảnh JPEG đã xoay thẳng đứng.
abstract class FaceFinder {
  Future<PixelBox?> largestFace(Uint8List jpeg);
}

/// ML Kit đọc ảnh từ tệp tạm; tệp xóa ngay sau khi nhận diện.
class MlKitFaceFinder implements FaceFinder {
  @override
  Future<PixelBox?> largestFace(Uint8List jpeg) async {
    // Thiếu ML Kit (nền tảng không hỗ trợ, plugin lỗi, không có Google Play
    // services...) thì coi như không thấy mặt: điểm khớp mặt sẽ là null.
    File? file;
    FaceDetector? detector;
    try {
      final dir = await getTemporaryDirectory();
      file = File(
        '${dir.path}/kyc_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(jpeg, flush: true);
      detector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          // Mặt trên CCCD nhỏ (khoảng 15-20% bề ngang ảnh).
          minFaceSize: 0.05,
        ),
      );
      final faces = await detector.processImage(
        InputImage.fromFilePath(file.path),
      );
      if (faces.isEmpty) return null;
      faces.sort(
        (a, b) => (b.boundingBox.width * b.boundingBox.height).compareTo(
          a.boundingBox.width * a.boundingBox.height,
        ),
      );
      final r = faces.first.boundingBox;
      return PixelBox(r.left, r.top, r.width, r.height);
    } catch (e) {
      debugPrint('[KYC] không nhận diện được mặt: ${e.runtimeType}');
      return null;
    } finally {
      try {
        await detector?.close();
      } catch (_) {}
      try {
        await file?.delete();
      } catch (_) {}
    }
  }
}

class FaceMatchResult {
  const FaceMatchResult(this.score, this.modelVersion);

  /// 0..1, `null` khi thiếu mặt ở một trong hai ảnh hoặc model không chạy.
  final double? score;
  final String modelVersion;
}

/// So khớp mặt trên CCCD với selfie. Mọi lỗi đều thành `score == null`: kết quả
/// chỉ là gợi ý cho admin, không được chặn việc gửi hồ sơ.
class FaceMatchService {
  FaceMatchService(this._finder, this._embedder);

  final FaceFinder _finder;
  final FaceEmbedder _embedder;

  static const _margin = 0.15;

  Future<FaceMatchResult> match({
    required Uint8List cccdFront,
    required Uint8List selfie,
  }) async {
    final version = _embedder.modelVersion;
    try {
      final a = await _embed(cccdFront);
      final b = await _embed(selfie);
      if (a == null || b == null) return FaceMatchResult(null, version);
      return FaceMatchResult(faceMatchScore(a, b), version);
    } catch (e) {
      debugPrint('[KYC] so khớp mặt lỗi: ${e.runtimeType}');
      return FaceMatchResult(null, version);
    }
  }

  Future<List<double>?> _embed(Uint8List jpeg) async {
    final box = await _finder.largestFace(jpeg);
    if (box == null) return null;
    final rgb = await compute(cropFaceRgb, (
      bytes: jpeg,
      box: box,
      margin: _margin,
    ));
    if (rgb == null) return null;
    return _embedder.embed(rgb);
  }

  void dispose() => _embedder.dispose();
}
