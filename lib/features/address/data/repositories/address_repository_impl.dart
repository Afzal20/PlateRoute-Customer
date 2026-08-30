import '../../domain/models/delivery_address_model.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DeliveryAddressModel>> getAddresses() async {
    return await remoteDataSource.fetchAddresses();
  }

  @override
  Future<DeliveryAddressModel> addAddress(DeliveryAddressModel address) async {
    return await remoteDataSource.createAddress(address);
  }

  @override
  Future<DeliveryAddressModel> updateAddress(DeliveryAddressModel address) async {
    return await remoteDataSource.updateAddress(address);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await remoteDataSource.deleteAddress(id);
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    await remoteDataSource.setDefaultAddress(id);
  }
}
