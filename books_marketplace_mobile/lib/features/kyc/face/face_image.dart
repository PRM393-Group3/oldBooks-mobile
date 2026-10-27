import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Cạnh vuông đầu vào của model nhúng mặt.
const faceInputSize = 112;

/// Hộp mặt theo điểm ảnh của ảnh đã xoay thẳng đứng.
class PixelBox {
  const PixelBox(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;
}

/// Đưa ảnh về dạng dùng chung cho các bước sau: xoay đúng chiều theo EXIF, thu
/// nhỏ cạnh dài về [maxSide], mã hóa lại JPEG (xóa luôn EXIF, gồm cả vị trí).
/// Trả `null` nếu không giải mã được. Hàm cấp cao nhất để chạy bằng `compute`.
Uint8List? normalizeJpeg(({Uint8List bytes, int maxSide, int quality}) a) {
  final decoded = img.decodeImage(a.bytes);
  if (decoded == null) return null;
  var image = img.bakeOrientation(decoded);
  final longest = max(image.width, image.height);
  if (longest > a.maxSide) {
    image = img.copyResize(
      image,
      width: image.width >= image.height ? a.maxSide : null,
      height: image.height > image.width ? a.maxSide : null,
      interpolation: img.Interpolation.average,
    );
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: a.quality));
}

/// Kích thước ảnh sau khi giải mã (đã xoay), `null` nếu hỏng.
({int width, int height})? imageSize(Uint8List bytes) {
  final d = img.decodeImage(bytes);
  return d == null ? null : (width: d.width, height: d.height);
}

/// Cắt mặt quanh [box] (nới [margin] mỗi phía, theo tỉ lệ cạnh lớn, ra hình
/// vuông), thu về 112x112 và trả `112*112*3` byte RGB. Phần vượt khỏi ảnh được
/// kẹp lại. `null` nếu ảnh hỏng hoặc hộp rỗng.
Uint8List? cropFaceRgb(({Uint8List bytes, PixelBox box, double margin}) a) {
  final decoded = img.decodeImage(a.bytes);
  if (decoded == null || a.box.width <= 0 || a.box.height <= 0) return null;
  final image = img.bakeOrientation(decoded);

  final side = max(a.box.width, a.box.height) * (1 + 2 * a.margin);
  final cx = a.box.left + a.box.width / 2;
  final cy = a.box.top + a.box.height / 2;
  var x = (cx - side / 2).round();
  var y = (cy - side / 2).round();
  var s = side.round();
  // Kẹp trong ảnh: thu hộp vuông nếu vượt biên.
  s = min(s, min(image.width, image.height));
  x = x.clamp(0, image.width - s);
  y = y.clamp(0, image.height - s);
  if (s <= 0) return null;

  final crop = img.copyCrop(image, x: x, y: y, width: s, height: s);
  final small = img.copyResize(
    crop,
    width: faceInputSize,
    height: faceInputSize,
    interpolation: img.Interpolation.average,
  );
  final out = Uint8List(faceInputSize * faceInputSize * 3);
  var i = 0;
  for (final p in small) {
    out[i++] = p.r.toInt();
    out[i++] = p.g.toInt();
    out[i++] = p.b.toInt();
  }
  return out;
}
