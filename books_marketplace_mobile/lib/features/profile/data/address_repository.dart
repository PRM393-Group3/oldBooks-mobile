import '../../../core/network/api_client.dart';
import '../domain/address.dart';

/// Sổ địa chỉ giao hàng `/me/addresses`. Server giữ các quy tắc mặc định
/// (địa chỉ đầu tiên luôn mặc định, luôn đúng một mặc định), client chỉ hiển thị.
class AddressRepository {
  AddressRepository(this._api);

  final ApiClient _api;

  /// Địa chỉ mặc định lên đầu, sau đó mới nhất trước. Không phân trang.
  Future<List<Address>> list() => _api.get(
    '/me/addresses',
    parse: (data) => [for (final j in data as List) Address.fromJson(j)],
  );

  Future<Address> create(Address a) =>
      _api.post('/me/addresses', body: a.toJson(), parse: Address.fromJson);

  Future<Address> update(Address a) => _api.patch(
    '/me/addresses/${a.id}',
    body: a.toJson(),
    parse: Address.fromJson,
  );

  Future<void> delete(String id) => _api.deleteNoContent('/me/addresses/$id');
}
