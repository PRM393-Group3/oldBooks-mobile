import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../../auth/application/auth_controller.dart';
import '../data/ai_repository.dart';
import '../domain/ai_models.dart';

final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => AiRepository(
    ref.watch(apiClientProvider),
    ref.watch(blobUploaderProvider),
  ),
);

/// Gói AI của người dùng (`GET /me/ai`). Tải lại khi đăng nhập/đăng xuất (theo
/// [authControllerProvider]), sau khi mua gói và khi app quay lại foreground
/// (gọi [refresh]).
class AiStatusNotifier extends AsyncNotifier<AiStatus> {
  @override
  Future<AiStatus> build() {
    final authed = ref.watch(
      authControllerProvider.select((s) => s == AuthStatus.authenticated),
    );
    if (!authed) return Future.value(const AiStatus());
    return ref.read(aiRepositoryProvider).status();
  }

  /// Tải lại mà không nháy về trạng thái loading.
  Future<void> refresh() async {
    final authed = ref.read(authControllerProvider) == AuthStatus.authenticated;
    if (!authed) return;
    state = await AsyncValue.guard(
      () => ref.read(aiRepositoryProvider).status(),
    );
  }

  /// Dùng kết quả của `POST /me/ai/subscription` ngay, không gọi lại.
  void set(AiStatus status) => state = AsyncData(status);
}

final aiStatusProvider = AsyncNotifierProvider<AiStatusNotifier, AiStatus>(
  AiStatusNotifier.new,
);

/// Đường xử lý hiện tại. Đang tải hoặc lỗi thì dùng model trên máy.
final aiRouteProvider = Provider<AiRoute>(
  (ref) => chooseAiRoute(ref.watch(aiStatusProvider).value),
);

class AiConversationsNotifier extends PagedNotifier<AiConversation> {
  @override
  Future<PagedResult<AiConversation>> fetchPage(int page) => ref
      .read(aiRepositoryProvider)
      .conversations(page: page, pageSize: PagedNotifier.pageSize);

  void remove(String id) {
    final s = state.value;
    if (s == null) return;
    state = AsyncData(
      s.copyWith(
        items: [
          for (final c in s.items)
            if (c.id != id) c,
        ],
      ),
    );
  }
}

final aiConversationsProvider =
    AsyncNotifierProvider.autoDispose<
      AiConversationsNotifier,
      PagedState<AiConversation>
    >(AiConversationsNotifier.new);
