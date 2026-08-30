import '../../../../core/network/api_client.dart';
import '../../domain/models/delivery_address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<DeliveryAddressModel>> fetchAddresses();
  Future<DeliveryAddressModel> createAddress(DeliveryAddressModel address);
  Future<DeliveryAddressModel> updateAddress(DeliveryAddressModel address);
  Future<void> deleteAddress(String id);
  Future<void> setDefaultAddress(String id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiClient _apiClient;

  AddressRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<DeliveryAddressModel>> fetchAddresses() async {
    try {
      final response = await _apiClient.get('/api/v1/addresses/');
      if (response is List) {
        return response.map((e) => DeliveryAddressModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response is Map && response.containsKey('results') && response['results'] is List) {
        return (response['results'] as List)
            .map((e) => DeliveryAddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback mock addresses
    }

    return _getFallbackAddresses();
  }

  @override
  Future<DeliveryAddressModel> createAddress(DeliveryAddressModel address) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/addresses/',
        data: address.toJson(),
      );
      return DeliveryAddressModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return address;
    }
  }

  @override
  Future<DeliveryAddressModel> updateAddress(DeliveryAddressModel address) async {
    try {
      final response = await _apiClient.put(
        '/api/v1/addresses/${address.id}/',
        data: address.toJson(),
      );
      return DeliveryAddressModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return address;
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await _apiClient.delete('/api/v1/addresses/$id/');
    } catch (_) {}
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    try {
      await _apiClient.post('/api/v1/addresses/$id/set-default/');
    } catch (_) {}
  }

  List<DeliveryAddressModel> _getFallbackAddresses() {
    return const [
      DeliveryAddressModel(
        id: 'addr_1',
        label: AddressLabel.home,
        addressLine: 'House 42, Road 11, Block D',
        area: 'Banani, Dhaka',
        floorApt: 'Apt 4B (4th Floor)',
        deliveryInstructions: 'Ring bell on left gate',
        latitude: 23.7937,
        longitude: 90.4066,
        isDefault: true,
      ),
      DeliveryAddressModel(
        id: 'addr_2',
        label: AddressLabel.work,
        addressLine: 'Level 8, Concord Tower, Gulshan 2',
        area: 'Gulshan 2, Dhaka',
        floorApt: 'Office Suite 802',
        deliveryInstructions: 'Leave with reception security',
        latitude: 23.8162,
        longitude: 90.4180,
        isDefault: false,
      ),
    ];
  }
}
