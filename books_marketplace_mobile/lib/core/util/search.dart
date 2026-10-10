const _from =
    'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
const _to =
    'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

/// Chữ thường và bỏ dấu tiếng Việt, để tìm "nha gia kim" ra "Nhà giả kim".
String normalizeSearch(String input) {
  final lower = input.toLowerCase().trim();
  final out = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    final at = _from.indexOf(ch);
    out.write(at < 0 ? ch : _to[at]);
  }
  return out.toString();
}
