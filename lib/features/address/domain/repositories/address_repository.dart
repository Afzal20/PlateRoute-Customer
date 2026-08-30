import '../models/delivery_address_model.dart';

abstract class AddressRepository {
  Future<List<DeliveryAddressModel>> getAddresses();
  Future<DeliveryAddressModel> addAddress(DeliveryAddressModel address);
  Future<DeliveryAddressModel> updateAddress(DeliveryAddressModel address);
  Future<void> deleteAddress(String id);
  Future<void> setDefaultAddress(String id);
}
