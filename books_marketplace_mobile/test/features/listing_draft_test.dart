import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/features/listings/application/listing_providers.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

const _input = BookInfoInput(
  title: 'A',
  author: 'B',
  categoryId: 'c1',
  condition: BookCondition.good,
  description: 'mô tả',
);

void main() {
  late FakeListingRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeListingRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [listingRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  ListingDraft notifier() =>
      container.read(listingDraftProvider(null).notifier);

  test('mở wizard mới không tạo gì trên server (tạo lười)', () async {
    final value = await container.read(listingDraftProvider(null).future);
    expect(value, isNull);
    expect(repo.calls, isEmpty);
  });

  test('bước 1 tạo nháp rồi PUT; bước sau không tạo thêm', () async {
    await container.read(listingDraftProvider(null).future);

    await notifier().saveBookInfo(_input);
    await notifier().saveBookInfo(_input);

    expect(repo.calls.where((c) => c == 'create'), hasLength(1));
    expect(repo.calls.where((c) => c == 'bookInfo'), hasLength(2));
    expect(container.read(listingDraftProvider(null)).value!.id, 'L1');
  });

  test(
    'PUT bước 1 lỗi: giữ nháp vừa tạo, thử lại không tạo nháp thứ hai',
    () async {
      await container.read(listingDraftProvider(null).future);
      repo.saveBookInfoError = const ApiError(
        status: 400,
        code: ApiErrorCode.validationFailed,
      );

      await expectLater(
        notifier().saveBookInfo(_input),
        throwsA(isA<ApiError>()),
      );
      expect(container.read(listingDraftProvider(null)).value?.id, 'L1');

      repo.saveBookInfoError = null;
      await notifier().saveBookInfo(_input);

      expect(repo.calls.where((c) => c == 'create'), hasLength(1));
    },
  );

  test('lưu ảnh, cách bán rồi nộp: state luôn là bản server trả về', () async {
    await container.read(listingDraftProvider(null).future);
    await notifier().saveBookInfo(_input);
    await notifier().saveImages([
      (blobName: 'u1/a.png', type: ImageType.frontCover),
    ]);
    await notifier().saveSaleMethod(
      const FixedPriceInput(price: 120000, quantity: 1),
    );
    final result = await notifier().submit();

    final listing = container.read(listingDraftProvider(null)).value!;
    expect(listing.status, ListingStatus.pendingInspection);
    expect(listing.fixedPrice!.price, 120000);
    expect(result.estimatedProcessingHours, 24);
    expect(repo.calls, [
      'create',
      'bookInfo',
      'images:1',
      'sale:FixedPrice',
      'submit',
    ]);
  });

  test('mở lại nháp có sẵn tải từ server', () async {
    repo.stored = fakeListing(id: 'L9', bookInfo: completeBookInfo);
    final value = await container.read(listingDraftProvider('L9').future);
    expect(value!.title, 'Nhà giả kim');
    expect(repo.calls, ['get:L9']);
  });

  test('lỗi nộp được ném ra để giao diện xử lý, state không đổi', () async {
    await container.read(listingDraftProvider(null).future);
    await notifier().saveBookInfo(_input);
    repo.submitError = const ApiError(
      status: 400,
      code: ApiErrorCode.listingIncomplete,
      fieldErrors: {'images': 'x'},
    );

    await expectLater(
      notifier().submit(),
      throwsA(
        isA<ApiError>().having((e) => e.fieldErrors.keys, 'fields', ['images']),
      ),
    );
    expect(
      container.read(listingDraftProvider(null)).value!.status,
      ListingStatus.draft,
    );
  });
}
