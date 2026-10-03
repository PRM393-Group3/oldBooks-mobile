import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Đồng hồ của ứng dụng. Test ghi đè để không phụ thuộc giờ thật.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
