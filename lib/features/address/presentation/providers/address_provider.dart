import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/address_remote_data_source.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../domain/models/delivery_address_model.dart';
import '../../domain/repositories/address_repository.dart';

final addressRemoteDataSourceProvider = Provider<AddressRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AddressRemoteDataSourceImpl(apiClient);
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final remoteDataSource = ref.watch(addressRemoteDataSourceProvider);
  return AddressRepositoryImpl(remoteDataSource: remoteDataSource);
});

class AddressState {
  final bool isLoading;
  final List<DeliveryAddressModel> addresses;
  final DeliveryAddressModel? selectedAddress;
  final String? errorMessage;

  const AddressState({
    this.isLoading = true,
    this.addresses = const [],
    this.selectedAddress,
    this.errorMessage,
  });

  AddressState copyWith({
    bool? isLoading,
    List<DeliveryAddressModel>? addresses,
    DeliveryAddressModel? selectedAddress,
    String? errorMessage,
  }) {
    return AddressState(
      isLoading: isLoading ?? this.isLoading,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  final repo = ref.watch(addressRepositoryProvider);
  return AddressNotifier(repo);
});

class AddressNotifier extends StateNotifier<AddressState> {
  final AddressRepository _repository;

  AddressNotifier(this._repository) : super(const AddressState()) {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final list = await _repository.getAddresses();
      final defaultAddr = list.firstWhere(
        (a) => a.isDefault,
        orElse: () => list.isNotEmpty ? list.first : const DeliveryAddressModel(
          id: 'temp_default',
          addressLine: 'Road 11, Block D',
          area: 'Banani, Dhaka',
          latitude: 23.7937,
          longitude: 90.4066,
        ),
      );

      state = state.copyWith(
        isLoading: false,
        addresses: list,
        selectedAddress: defaultAddr,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectAddress(DeliveryAddressModel address) {
    state = state.copyWith(selectedAddress: address);
  }

  Future<void> addAddress(DeliveryAddressModel newAddress) async {
    try {
      final created = await _repository.addAddress(newAddress);
      final updatedList = List<DeliveryAddressModel>.from(state.addresses)..add(created);
      state = state.copyWith(
        addresses: updatedList,
        selectedAddress: created.isDefault ? created : state.selectedAddress,
      );
    } catch (_) {}
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _repository.deleteAddress(id);
      final updatedList = state.addresses.where((a) => a.id != id).toList();
      state = state.copyWith(
        addresses: updatedList,
        selectedAddress: state.selectedAddress?.id == id
            ? (updatedList.isNotEmpty ? updatedList.first : null)
            : state.selectedAddress,
      );
    } catch (_) {}
  }
}
