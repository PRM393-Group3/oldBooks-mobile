import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/features/devices/data/device_repository.dart';
import 'package:books_marketplace_mobile/features/profile/data/address_repository.dart';
import 'package:books_marketplace_mobile/features/profile/domain/address.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

const _addressJson = {
  'id': 'b3f1',
  'recipientName': 'Nguyễn Văn A',
  'phone': '+84901234567',
  'province': 'TP. Hồ Chí Minh',
  'district': 'Quận 1',
  'ward': 'Phường Bến Nghé',
  'detail': '12 Lê Lợi',
  'isDefault': true,
};

void main() {
  late List<RequestOptions> seen;
  late ApiClient api;

  void setup(ResponseBody Function(RequestOptions) handler) {
    seen = [];
    final adapter = FakeAdapter((o) {
      seen.add(o);
      return handler(o);
    });
    api = ApiClient(
      Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = adapter,
    );
  }

  group('AddressRepository', () {
    test('list đọc mảng AddressDto theo thứ tự server', () async {
      setup((o) => jsonResponse(200, okBody([_addressJson])));
      final list = await AddressRepository(api).list();
      expect(seen.single.path, '/me/addresses');
      expect(list.single.recipient, 'Nguyễn Văn A');
      expect(list.single.phone, '+84901234567');
      expect(list.single.isDefault, isTrue);
    });

    test('create gửi đủ trường, cắt khoảng trắng; update dùng PATCH', () async {
      setup(
        (o) =>
            jsonResponse(o.method == 'POST' ? 201 : 200, okBody(_addressJson)),
      );
      final repo = AddressRepository(api);
      const a = Address(
        id: 'b3f1',
        recipient: ' Nguyễn Văn A ',
        phone: '0901234567',
        province: 'TP. Hồ Chí Minh',
        district: 'Quận 1',
        ward: 'Phường Bến Nghé',
        detail: '12 Lê Lợi',
      );

      await repo.create(a);
      await repo.update(a.copyWith(isDefault: true));

      expect(seen[0].method, 'POST');
      expect(seen[0].data, {
        'recipientName': 'Nguyễn Văn A',
        'phone': '0901234567',
        'province': 'TP. Hồ Chí Minh',
        'district': 'Quận 1',
        'ward': 'Phường Bến Nghé',
        'detail': '12 Lê Lợi',
        'isDefault': false,
      });
      expect(seen[1].method, 'PATCH');
      expect(seen[1].path, '/me/addresses/b3f1');
      expect((seen[1].data as Map)['isDefault'], isTrue);
    });

    test('delete 204; ADDRESS_NOT_FOUND ném ApiError', () async {
      setup((o) => ResponseBody.fromString('', 204));
      await AddressRepository(api).delete('b3f1');
      expect(seen.single.method, 'DELETE');

      setup((o) => jsonResponse(404, errorBody(ApiErrorCode.addressNotFound)));
      await expectLater(
        AddressRepository(api).delete('zz'),
        throwsA(isA<ApiError>().having((e) => e.status, 'status', 404)),
      );
    });
  });

  group('DeviceRepository', () {
    test('register gửi platform viết hoa và trả id', () async {
      setup(
        (o) => jsonResponse(201, okBody({'id': '9c1e', 'platform': 'ANDROID'})),
      );
      final id = await DeviceRepository(api)
          .register(pushToken: 'tok', platform: PushPlatform.android);
      expect(id, '9c1e');
      expect(seen.single.data, {'pushToken': 'tok', 'platform': 'ANDROID'});
    });

    test('unregister bỏ qua DEVICE_NOT_FOUND, ném lỗi khác', () async {
      setup((o) => jsonResponse(404, errorBody(ApiErrorCode.deviceNotFound)));
      await DeviceRepository(api).unregister('9c1e');
      expect(seen.single.path, '/me/devices/9c1e');

      setup((o) => jsonResponse(500, errorBody(ApiErrorCode.internal)));
      await expectLater(
        DeviceRepository(api).unregister('9c1e'),
        throwsA(isA<ApiError>()),
      );
    });
  });
}
