/// Kiểm tra ISBN-10 hoặc ISBN-13 (có checksum). Bỏ dấu gạch và khoảng trắng.
bool isValidIsbn(String input) {
  final s = input.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
  if (s.length == 10) return _isbn10(s);
  if (s.length == 13) return _isbn13(s);
  return false;
}

bool _isbn10(String s) {
  var sum = 0;
  for (var i = 0; i < 10; i++) {
    final c = s[i];
    final int v;
    if (c == 'X' && i == 9) {
      v = 10;
    } else if (RegExp(r'\d').hasMatch(c)) {
      v = int.parse(c);
    } else {
      return false;
    }
    sum += v * (10 - i);
  }
  return sum % 11 == 0;
}

bool _isbn13(String s) {
  if (!RegExp(r'^\d{13}$').hasMatch(s)) return false;
  var sum = 0;
  for (var i = 0; i < 13; i++) {
    sum += int.parse(s[i]) * (i.isEven ? 1 : 3);
  }
  return sum % 10 == 0;
}
