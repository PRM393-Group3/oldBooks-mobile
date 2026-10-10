import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(apiClientProvider)),
);

/// Cây danh mục. Ít đổi nên giữ trong bộ nhớ suốt phiên.
final categoryTreeProvider = FutureProvider<List<CategoryNode>>(
  (ref) => ref.watch(categoryRepositoryProvider).tree(),
);
