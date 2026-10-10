import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../data/complaint_repository.dart';
import '../domain/complaint_case.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>(
  (ref) => ComplaintRepository(
    ref.watch(apiClientProvider),
    ref.watch(blobUploaderProvider),
  ),
);

/// Chi tiết khiếu nại. URL tệp hết hạn sau 15 phút nên tải lại khi cần.
final complaintProvider = FutureProvider.autoDispose
    .family<ComplaintCase, String>(
      (ref, id) => ref.watch(complaintRepositoryProvider).get(id),
    );

class ComplaintsNotifier extends PagedNotifier<ComplaintCase> {
  ComplaintsNotifier(this.role);

  /// `BUYER` hoặc `SELLER`.
  final String role;

  @override
  Future<PagedResult<ComplaintCase>> fetchPage(int page) => ref
      .read(complaintRepositoryProvider)
      .list(role: role, page: page, pageSize: PagedNotifier.pageSize);
}

final complaintsProvider = AsyncNotifierProvider.autoDispose
    .family<ComplaintsNotifier, PagedState<ComplaintCase>, String>(
      ComplaintsNotifier.new,
    );

/// Làm mới danh sách và chi tiết sau khi mở/phản hồi/quyết định/nhắn tin.
void refreshComplaints(WidgetRef ref, {String? id}) {
  ref.invalidate(complaintsProvider);
  if (id != null) ref.invalidate(complaintProvider(id));
}
