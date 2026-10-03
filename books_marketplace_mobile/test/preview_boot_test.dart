import 'package:books_marketplace_mobile/app/app.dart';
import 'package:books_marketplace_mobile/core/preview/preview_overrides.dart';
import 'package:books_marketplace_mobile/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('chế độ xem trước khởi động đúng như main.dart và vào Khám phá', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_locale': 'vi'});
    final prefs = await SharedPreferences.getInstance();
    final tokens = PreviewTokenStore();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          // Giống main.dart: token store và prefs ở ngoài, phần còn lại từ preview.
          tokenStoreProvider.overrideWithValue(tokens),
          sharedPreferencesProvider.overrideWithValue(prefs),
          ...previewOverrides(tokens, prefs),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.text('Oldbook'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Oldbook')).dy,
      lessThan(100),
      reason: 'đầu trang Khám phá nằm ở trên cùng, không bị cuộn mất',
    );
    expect(find.text('Nhà giả kim'), findsOneWidget);
  });
}
