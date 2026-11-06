import 'dart:math';
import 'dart:typed_data';

import 'package:books_marketplace_mobile/features/kyc/face/face_embedder.dart';
import 'package:books_marketplace_mobile/features/kyc/face/face_image.dart';
import 'package:books_marketplace_mobile/features/kyc/face/face_match_service.dart';
import 'package:books_marketplace_mobile/features/kyc/face/face_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

class _FakeFinder implements FaceFinder {
  _FakeFinder(this.box);
  final PixelBox? box;
  @override
  Future<PixelBox?> largestFace(Uint8List jpeg) async => box;
}

class _FakeEmbedder implements FaceEmbedder {
  _FakeEmbedder(this.vectors);
  final List<List<double>?> vectors;
  var _i = 0;
  @override
  String get modelVersion => 'fake-v1';
  @override
  Future<List<double>?> embed(Uint8List rgb) async => vectors[_i++];
  @override
  void dispose() {}
}

Uint8List _jpeg(int w, int h) {
  final im = img.Image(width: w, height: h);
  img.fill(im, color: img.ColorRgb8(200, 100, 50));
  return Uint8List.fromList(img.encodeJpg(im));
}

void main() {
  group('face_math', () {
    test('cosine: giống nhau, vuông góc, ngược chiều', () {
      expect(cosineSimilarity([1, 2, 3], [2, 4, 6]), closeTo(1, 1e-9));
      expect(cosineSimilarity([1, 0], [0, 1]), closeTo(0, 1e-9));
      expect(cosineSimilarity([1, 0], [-1, 0]), closeTo(-1, 1e-9));
    });
    test('cosine: đầu vào không hợp lệ trả null', () {
      expect(cosineSimilarity([], []), isNull);
      expect(cosineSimilarity([1], [1, 2]), isNull);
      expect(cosineSimilarity([0, 0], [1, 1]), isNull);
    });
    test('l2Normalize ra độ dài 1; vector 0 giữ nguyên', () {
      final n = l2Normalize([3, 4]);
      expect(n[0], closeTo(0.6, 1e-9));
      expect(n[1], closeTo(0.8, 1e-9));
      expect(sqrt(n.fold<double>(0, (a, b) => a + b * b)), closeTo(1, 1e-9));
      expect(l2Normalize([0, 0]), [0, 0]);
    });
    test('faceMatchScore kẹp về 0..1 và làm tròn', () {
      expect(faceMatchScore([1, 0], [1, 0]), 1.0);
      expect(faceMatchScore([1, 0], [-1, 0]), 0.0);
      expect(faceMatchScore([1, 0], [0, 1]), 0.0);
      expect(faceMatchScore([1, 1], [1, 0]), closeTo(0.7071, 1e-4));
      expect(faceMatchScore([], []), isNull);
    });
  });

  group('cropFaceRgb', () {
    test('ra đúng 112x112x3 byte RGB, giữ màu', () {
      final out = cropFaceRgb((
        bytes: _jpeg(400, 300),
        box: const PixelBox(100, 50, 120, 140),
        margin: 0.15,
      ))!;
      expect(out.length, faceInputSize * faceInputSize * 3);
      // JPEG nén có sai số nhỏ.
      expect(out[0], closeTo(200, 6));
      expect(out[1], closeTo(100, 6));
      expect(out[2], closeTo(50, 6));
    });
    test('hộp sát mép hoặc vượt ảnh vẫn cắt được', () {
      final out = cropFaceRgb((
        bytes: _jpeg(200, 200),
        box: const PixelBox(150, 150, 120, 120),
        margin: 0.2,
      ));
      expect(out?.length, faceInputSize * faceInputSize * 3);
    });
    test('ảnh hỏng hoặc hộp rỗng trả null', () {
      expect(
        cropFaceRgb((
          bytes: Uint8List.fromList([1, 2, 3]),
          box: const PixelBox(0, 0, 10, 10),
          margin: 0.1,
        )),
        isNull,
      );
      expect(
        cropFaceRgb((
          bytes: _jpeg(50, 50),
          box: const PixelBox(0, 0, 0, 0),
          margin: 0.1,
        )),
        isNull,
      );
    });
  });

  group('normalizeJpeg', () {
    test('thu nhỏ cạnh dài và giữ tỉ lệ', () {
      final out = normalizeJpeg((
        bytes: _jpeg(3200, 1600),
        maxSide: 1600,
        quality: 85,
      ))!;
      final size = imageSize(out)!;
      expect(size.width, 1600);
      expect(size.height, 800);
    });
    test('ảnh không giải mã được trả null', () {
      expect(
        normalizeJpeg((
          bytes: Uint8List.fromList([0, 1, 2]),
          maxSide: 100,
          quality: 80,
        )),
        isNull,
      );
    });
  });

  group('FaceMatchService', () {
    final jpeg = _jpeg(300, 300);
    const box = PixelBox(100, 100, 100, 100);

    test('hai mặt giống nhau cho điểm 1', () async {
      final s = FaceMatchService(
        _FakeFinder(box),
        _FakeEmbedder([
          [1, 0],
          [1, 0],
        ]),
      );
      final r = await s.match(cccdFront: jpeg, selfie: jpeg);
      expect(r.score, 1.0);
      expect(r.modelVersion, 'fake-v1');
    });
    test('không thấy mặt thì điểm null', () async {
      final s = FaceMatchService(_FakeFinder(null), _FakeEmbedder([]));
      expect((await s.match(cccdFront: jpeg, selfie: jpeg)).score, isNull);
    });
    test('model không chạy được thì điểm null', () async {
      final s = FaceMatchService(_FakeFinder(box), _FakeEmbedder([null, null]));
      expect((await s.match(cccdFront: jpeg, selfie: jpeg)).score, isNull);
    });
  });
}
