/// Đọc JSON phòng thủ: trường thiếu hoặc sai kiểu cho ra `null`, không ném lỗi.
/// Dùng cho các DTO doc backend chưa mô tả đủ hình dạng.
String? readString(Map<dynamic, dynamic> j, String key) {
  final v = j[key];
  return v is String && v.isNotEmpty ? v : null;
}

int? readInt(Map<dynamic, dynamic> j, String key) {
  final v = j[key];
  return v is num ? v.toInt() : null;
}

double? readDouble(Map<dynamic, dynamic> j, String key) {
  final v = j[key];
  return v is num ? v.toDouble() : null;
}

bool? readBool(Map<dynamic, dynamic> j, String key) {
  final v = j[key];
  return v is bool ? v : null;
}

DateTime? readDate(Map<dynamic, dynamic> j, String key) {
  final v = j[key];
  return v is String ? DateTime.tryParse(v) : null;
}

Map<dynamic, dynamic>? readMap(Map<dynamic, dynamic> j, String key) {
  final v = j[key];
  return v is Map ? v : null;
}

List<dynamic> readList(Map<dynamic, dynamic> j, String key) {
  final v = j[key];
  return v is List ? v : const [];
}
