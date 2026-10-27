import 'dart:math';

/// Chuẩn hóa L2. Vector toàn 0 trả về nguyên vector.
List<double> l2Normalize(List<double> v) {
  var sum = 0.0;
  for (final x in v) {
    sum += x * x;
  }
  final norm = sqrt(sum);
  if (norm == 0) return List.of(v);
  return [for (final x in v) x / norm];
}

/// Cosine similarity trong -1..1. Hai vector phải cùng độ dài, khác rỗng và
/// khác 0; ngược lại trả `null`.
double? cosineSimilarity(List<double> a, List<double> b) {
  if (a.isEmpty || a.length != b.length) return null;
  var dot = 0.0, na = 0.0, nb = 0.0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  if (na == 0 || nb == 0) return null;
  return dot / (sqrt(na) * sqrt(nb));
}

/// Điểm khớp mặt 0..1 gửi cho admin: cosine, âm thì coi như 0, làm tròn 4 chữ
/// số thập phân. Chỉ là gợi ý.
double? faceMatchScore(List<double> a, List<double> b) {
  final c = cosineSimilarity(a, b);
  if (c == null) return null;
  return (c.clamp(0.0, 1.0) * 10000).round() / 10000;
}
