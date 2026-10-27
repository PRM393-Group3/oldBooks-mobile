import 'package:flutter/foundation.dart';
import 'package:flutter_litert/flutter_litert.dart';

import 'face_image.dart';
import 'face_math.dart';

/// Nhúng một khuôn mặt thành vector để so sánh. Tách thành interface để thay
/// model hoặc giả lập khi test; không có model thì [FaceMatchService] trả
/// `null` và hồ sơ vẫn gửi được.
abstract class FaceEmbedder {
  /// Nhãn phiên bản model, gửi trong `clientInfo.modelVersion`.
  String get modelVersion;

  /// [rgb] là `112*112*3` byte RGB của mặt đã cắt. `null` nếu model không chạy
  /// được.
  Future<List<double>?> embed(Uint8List rgb);

  void dispose();
}

/// MobileFaceNet (sirius-ai/MobileFaceNet_TF, Apache-2.0) đã đổi sang TFLite,
/// float32, vào 1x112x112x3 RGB chuẩn hóa `(p - 127.5) / 128`, ra 128 chiều
/// đã chuẩn hóa L2. Nguồn, cách đổi và checksum nằm ở
/// `assets/kyc/MODEL_LICENSE.txt`. Chỉ là gợi ý cho admin, không dùng để quyết
/// định.
class TfliteFaceEmbedder implements FaceEmbedder {
  static const asset = 'assets/kyc/mobilefacenet.tflite';
  static const _dims = 128;

  Interpreter? _interpreter;
  bool _failed = false;

  @override
  String get modelVersion => 'mobilefacenet-sirius-v1';

  Future<Interpreter?> _load() async {
    if (_failed) return null;
    try {
      return _interpreter ??= await Interpreter.fromAsset(asset);
    } catch (e) {
      debugPrint('[KYC] không nạp được model nhúng mặt: ${e.runtimeType}');
      _failed = true;
      return null;
    }
  }

  @override
  Future<List<double>?> embed(Uint8List rgb) async {
    if (rgb.length != faceInputSize * faceInputSize * 3) return null;
    final interpreter = await _load();
    if (interpreter == null) return null;
    try {
      final input = Float32List(rgb.length);
      for (var i = 0; i < rgb.length; i++) {
        input[i] = (rgb[i] - 127.5) / 128.0;
      }
      final output = Float32List(_dims);
      interpreter.run(input, output);
      return l2Normalize(output.toList());
    } catch (e) {
      debugPrint('[KYC] model nhúng mặt lỗi: ${e.runtimeType}');
      return null;
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
